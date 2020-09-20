# openpose-docker

Dockerfile to build [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose), based on a Docker image of NVIDIA's custom Caffe implementation.

Ensure that you have `nvidia-docker` installed before you download this image.

To run the container, use the following commmand - 

```bash
xhost +
docker run -it --net=host --gpus all <container-id>
```

OpenPose is located at `/openpose`, and the build directory is `/openpose/build`.

# Software versions
1. OpenPose (last tested on commit de3bea5f7)
1. CUDA 10.2
2. cuDNN 7.5
3. Python 3.6.9 (will be 3.7 soon)

# Acknowledgements
This repo is based off of previous OpenPose Docker work:
 * https://github.com/ExSidius/openpose-docker
 * https://github.com/ramayer/openpose-docker/tree/ubuntu18.04

Some fixes used here were also suggested by the author of this blog post:
http://peter-uhrig.de/openpose-with-nvcaffe-in-a-singularity-container-with-support-for-multiple-architectures/
