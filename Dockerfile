FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

# without this environment variable, the apt-get statement below will
# hang waiting user input after a prompt of:
#
#  "Configuring tzdata
#   Please select the geographic area in which you live."

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "Installing dependencies..." && \
	apt-get -y --no-install-recommends update && \
	apt-get -y --no-install-recommends upgrade && \
	apt-get install -y --no-install-recommends \
	build-essential \
	cmake \
	git \
	libatlas-base-dev \
	libprotobuf-dev \
	libleveldb-dev \
	libsnappy-dev \
	libhdf5-serial-dev \
	protobuf-compiler \
	libboost-all-dev \
	libgflags-dev\ 
	libgoogle-glog-dev \
	liblmdb-dev \
	pciutils \
	python3-setuptools \
	python3-dev \
	python3-pip \
	opencl-headers \
	ocl-icd-opencl-dev \
	libviennacl-dev \
	libcanberra-gtk-module \
	libopencv-dev

# without scikit-build, opencv-python gives an error 
#  " ModuleNotFoundError: No module named 'skbuild' "
# https://github.com/scikit-build/cmake-python-distributions/issues/86

RUN python3 -m pip install scikit-build

RUN python3 -m pip install \
	numpy \
	protobuf \
	opencv-python

RUN echo "Downloading and building OpenPose..." && \
	git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git && \
	mkdir -p /openpose/build && \
	cd /openpose/build && \
	cmake .. && \
	make -j`nproc`

WORKDIR /openpose
