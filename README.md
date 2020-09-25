# openpose-docker

**NOTE: this Dockerfile occassionally segfaults on some videos. See below for details.**

Dockerfile to build [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose), based on a Docker image of NVIDIA's custom Caffe implementation.

Ensure that you have `nvidia-docker` installed before you download this image.

To run the container, use the following commmand - 

```bash
xhost +
docker run -it --net=host --gpus all <container-id>
```

OpenPose is located at `/openpose`, and the build directory is `/openpose/build`.

# Segfault on some OpenPose inputs
If anyone has insights into fixing this error, please let me know!

```bash
$ sudo docker run --rm --net=host --gpus all --shm-size=1g --ulimit stack=67108864 -v <path>:/openpose/data -t openpose-nvcaffe ./build/examples/openpose/openpose.bin -video data/in.mp4 -write_video data/out.mp4 -write_json data/out -hand -hand_detector 3 -face -display 0

==================
== NVIDIA Caffe ==
==================

NVIDIA Release 20.03 (build 11026381)
NVIDIA Caffe Version 0.17.3

Container image Copyright (c) 2019, NVIDIA CORPORATION.  All rights reserved.
Copyright (c) 2014, 2015, The Regents of the University of California (Regents)
All rights reserved.

Various files include modifications (c) NVIDIA CORPORATION.  All rights reserved.
NVIDIA modifications are covered by the license terms that apply to the underlying project or file.

NOTE: MOFED driver for multi-node communication was not detected.
      Multi-node communication performance may be reduced.

Starting OpenPose demo...
Configuring OpenPose...
Starting thread(s)...
Auto-detecting all available GPUs... Detected 1 GPU(s), using 1 of them starting at GPU 0.
ffmpeg version 3.4.8-0ubuntu0.2 Copyright (c) 2000-2020 the FFmpeg developers

[ -- clip -- ]

Temporarily saving video frames as JPG images in: data/docker-out/7KpXZcaKTlM_r8904530ijyiopf9034jiop4g90j0yh795640h38j
F0922 17:39:15.779029    91 cudnn_conv_layer.cu:56] Check failed: error == cudaSuccess (700 vs. 0)  an illegal memory access was encountered
*** Check failure stack trace: ***
    @     0x7fe011ce50cd  google::LogMessage::Fail()
    @     0x7fe011ce6f33  google::LogMessage::SendToLog()
    @     0x7fe011ce4c28  google::LogMessage::Flush()
    @     0x7fe011ce7999  google::LogMessageFatal::~LogMessageFatal()
    @     0x7fe01092927c  caffe::CuDNNConvolutionLayer<>::Forward_gpu()
    @     0x7fe010438df2  caffe::Layer<>::Forward()
    @     0x7fe0107f6b63  caffe::Net::ForwardFromTo()
    @     0x7fe013569c4c  op::NetCaffe::forwardPass()
    @     0x7fe01358fffa  op::PoseExtractorCaffe::forwardPass()
    @     0x7fe013588f85  op::PoseExtractor::forwardPass()
    @     0x7fe013585dfe  op::WPoseExtractor<>::work()
    @     0x7fe0135c7d89  op::Worker<>::checkAndWork()
    @     0x7fe0135c7f13  op::SubThread<>::workTWorkers()
    @     0x7fe0135d1b78  op::SubThreadQueueInOut<>::work()
    @     0x7fe0135ca1f1  op::Thread<>::threadFunction()
    @     0x7fe012e5966f  (unknown)
    @     0x7fe01257b6db  start_thread
    @     0x7fe0128b488f  clone
```

At first glance this seems like an NVCaffe bug, since looking up this error brings up older NVCaffe error reports.
This only happens for _some_ videos (I haven't found a pattern).
If you know a solution (or have a guess), do let me know!

In the meantime, I am going to use the `ubuntu18.04` branch.

# Software versions
1. OpenPose (last tested on commit `de3bea5f7`)
1. CUDA 10.2
2. cuDNN 7.5
3. Python 3.6.9 (will be 3.7 soon)

# Acknowledgements
This repo is based off of previous OpenPose Docker work:
 * https://github.com/ExSidius/openpose-docker
 * https://github.com/ramayer/openpose-docker/tree/ubuntu18.04

Some fixes used here were also suggested by the author of this blog post:
http://peter-uhrig.de/openpose-with-nvcaffe-in-a-singularity-container-with-support-for-multiple-architectures/
