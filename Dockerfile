ARG UBUNTU_VERSION=20.04
ARG ARCH=
ARG CUDA=11.2.2
ARG CUDNN=cudnn8-runtime

FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-${CUDNN}-ubuntu${UBUNTU_VERSION}

USER root
ENV HOME=/root
ENV XDG_CACHE_HOME=$HOME/.cache
ARG PYTHON_VERSION=3.8.0
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.8.0}
ARG PASSWORD=123456
ENV PASSWORD=${PASSWORD:-123456}

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common \
    && add-apt-repository -y ppa:deadsnakes \
    && apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        python-openssl \
        ca-certificates \
        curl \
        git \
        libjpeg-dev \
        libpng-dev \
        openmpi-bin \
        wget \
        libquadmath0 \
        vim

# ssh
RUN : \
    && mkdir /var/run/sshd \
    && mkdir /root/.ssh \
    && echo "root:${PASSWORD}" | chpasswd \
    && sed -ri "s/^#?PermitRootLogin\s+.*/PermitRootLogin yes/" /etc/ssh/sshd_config \
    && sed -ri "s/UsePAM yes/#UsePAM yes/g" /etc/ssh/sshd_config

# pyenv
ENV PYENV_ROOT=$HOME/.pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN : \
    && curl https://pyenv.run | bash \
    && echo 'export PATH="$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH"' >> $HOME/.profile \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION

# poetry
ENV POETRY_ROOT=$HOME/.poetry
ENV PATH=$POETRY_ROOT/bin:$PATH
RUN : \
    && curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

## venv
#ENV PATH=/venv/bin:$PATH
#RUN : \
#    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#        python3-venv \
#        python${PYTHON_VERSION}-venv \
#    && python${PYTHON_VERSION} -m venv /venv

RUN : \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* ~/.cache/* /tmp/* /var/tmp/* \
    && :

COPY enterypoint.sh /root/

EXPOSE 22

WORKDIR /workdir

ENTRYPOINT ["/root/enterypoint.sh"]
CMD ["bash"]
