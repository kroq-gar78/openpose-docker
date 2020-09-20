# Ubuntu 18.04
FROM nvcr.io/nvidia/caffe:20.03-py3

# without this environment variable, the apt-get statement below will
# hang waiting user input after a prompt of:
#
#  "Configuring tzdata
#   Please select the geographic area in which you live."

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "Installing dependencies..." && \
    apt-get -y --no-install-recommends update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ffmpeg \
    git \
    libatlas-base-dev \
    libavcodec-dev libavformat-dev libavdevice-dev \
    libleveldb-dev \
    libsnappy-dev \
    libhdf5-serial-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    liblmdb-dev \
    libv4l-dev \
    pciutils \
    libcanberra-gtk-module

RUN python3 -m pip install \
    numpy

# Recompile OpenCV with ffmpeg, so that we get video support (which we want in OpenPose).
# Use the commands/flags from the NVCaffe image.
RUN OPENCV_VERSION=3.4.0 && \
    cd / && \
    wget -q -O - https://github.com/Itseez/opencv/archive/${OPENCV_VERSION}.tar.gz | tar -xzf - && \
    cd /opencv-${OPENCV_VERSION} && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr \
        -DWITH_CUDA=OFF -DWITH_1394=OFF \
        -DBUILD_opencv_cudalegacy=OFF -DBUILD_opencv_stitching=OFF -DWITH_IPP=OFF \
        -DWITH_FFMPEG=ON -DWITH_LIBV4L=ON && \
    make -j"$(nproc)" install

COPY openpose_cmake_boost.patch /workspace/

# Some flags from: http://peter-uhrig.de/openpose-with-nvcaffe-in-a-singularity-container-with-support-for-multiple-architectures/
# TODO: enable model download
RUN echo "Downloading and building OpenPose..." && \
    git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git /openpose


# Generate a link to the stub for libnvidia-ml.so.1.
# If we don't do this, we need the NVIDIA docker runtime during build, which would mean setting nvidia to the default runtime for ALL docker containers
# Source: https://github.com/NVIDIA/nvidia-docker/wiki/Advanced-topics#default-runtime
# TODO: should this only create a libnvidia-ml.so.1 link inside stubs?
# TODO: change the link name based on Docker tags
RUN ln -s  /usr/local/cuda/lib64/stubs/libnvidia-ml.so /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.450.66 && \
    ldconfig

RUN cd /openpose && \
    patch -p1 -i /workspace/openpose_cmake_boost.patch && \
    mkdir -p /openpose/build && \
    cd /openpose/build && \
    cmake .. -DDL_FRAMEWORK=NV_CAFFE -DCaffe_INCLUDE_DIRS=/usr/local/lib/include/caffe \
        -DCaffe_LIBS=/usr/local/lib/libcaffe-nv.so -DBUILD_CAFFE=OFF -DCUDA_ARCH=All && \
    make -j`nproc`

# Delete the symlink, or it will fail to boot up (since it gets overwritten)
RUN rm -f /usr/lib/x86_64-linux-gnu/libnvidia-ml.so*
RUN rm -r /opencv-3.4.0

WORKDIR /openpose
