ARG UBUNTU_VERSION=20.04
ARG ARCH=
ARG CUDA=11.2.1
ARG CUDNN=base

FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-${CUDNN}-ubuntu${UBUNTU_VERSION}

USER root
ENV HOME=/root
ENV XDG_CACHE_HOME=$HOME/.cache

RUN : \
    && apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository -y ppa:deadsnakes \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3-venv python3.8-venv \
    && apt-get install libquadmath0 -y

RUN python3.8 -m venv /venv

ENV PATH=/venv/bin:$PATH

RUN : \
    && pip3 install --upgrade pip \
    && pip3 install \
	torch \
	torchvision \
	catalyst \
	albumentations \
	opencv-python \
	efficientnet_pytorch \
	geffnet \
	tqdm \
	numpy \
	sklearn \
	scipy \
	matplotlib \
	pandas \
	onnx \
	tensorboard \
	pyyaml \
	scikit-learn \
	matplotlib \
	mxnet

RUN : \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* ~/.cache/* /tmp/* /var/tmp/* \
    && :

WORKDIR /workdir

CMD ["bash"]
