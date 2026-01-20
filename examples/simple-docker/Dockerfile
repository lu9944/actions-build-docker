FROM ubuntu:22.04

# ========== 构建参数 ==========
# conda 环境名称（可根据需要修改）
ARG CONDA_ENV_NAME=requests_env
# Python 版本（可根据需要修改）
ARG PYTHON_VERSION=3.11

# 验证可用
# ========== 安装系统依赖 ==========
RUN set -eux \
    # 检查基础镜像系统信息
    && cat /etc/os-release \
    # 检查当前 apt 源配置
    && cat /etc/apt/sources.list \
    # 配置 Ubuntu 22.04 (Jammy) 官方源
    # && echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list \
    # && echo "deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    # && echo "deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list \
    # 更新包列表
    && apt update -y \
    # 安装所有系统依赖（一次性安装，避免依赖冲突）
    && apt install -y --no-install-recommends \
        build-essential \
        iputils-ping \
        net-tools \
        iproute2 \
        curl \
        wget \
        dnsutils \
        tcpdump \
        netcat-openbsd \
        vim \
        sudo \
        unzip \
        zip \
        screen \
        libgl1-mesa-glx \
        htop \
        git \
        openssh-server \
        libsm6 \
        libxext6 \
        ninja-build \
        libglib2.0-0 \
        libxrender-dev \
        gcc \
        g++ \
        make \
        cmake \
        file \
        python3-pip \
    # 验证关键工具已安装
    && command -v curl \
    && command -v wget \
    && command -v git \
    && command -v python3 \
    # 清理缓存
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# ========== pip安装 ==========
RUN set -eux \
    # 执行pip安装
    pip3 install jupyter jupyterlab

WORKDIR /usr/local/src

# 检查并安装Miniconda（如果基础镜像已包含则跳过）
RUN set -eux \
    # 检查conda是否已安装
    && if [ -d "/opt/conda" ]; then \
        echo "发现基础镜像已包含conda，跳过安装"; \
        /opt/conda/bin/conda --version; \
    else \
        echo "开始安装Miniconda"; \
        # 验证curl可用
        command -v curl || (echo "ERROR: curl not found" && exit 1) \
        # 下载Miniconda安装包
        && curl -fL -o Miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        # 验证文件下载成功
        && ls -lh Miniconda3.sh \
        # 安装Miniconda
        && /bin/bash Miniconda3.sh -b -p /opt/conda \
        # 清理安装包
        && rm Miniconda3.sh \
        # 验证conda安装成功
        && /opt/conda/bin/conda --version; \
    fi


# 重新声明构建参数（确保在RUN命令中可用）
ARG CONDA_ENV_NAME=requests_env
ARG PYTHON_VERSION=3.11

# 创建conda环境并安装依赖（完全使用官方源，不换源）
RUN set -eu \
    && CONDA_BIN="/opt/conda/bin" \
    && export PATH=$CONDA_BIN:$PATH \
    && echo "===== 开始调试 =====" \
    && echo "检查 conda 是否存在:" \
    && ls -la /opt/conda/bin/conda \
    && echo "验证 conda 版本:" \
    && conda --version \
    && echo "使用参数: CONDA_ENV_NAME=${CONDA_ENV_NAME}, PYTHON_VERSION=${PYTHON_VERSION}" \
    && echo "===== 开始创建 conda 环境 =====" \
    && conda create -y -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} || \
    (echo "===== conda create 失败，尝试列出可用 Python 版本 =====" && \
     conda search "python=[${PYTHON_VERSION}]*" && exit 1) \
    && echo "===== conda 环境创建成功 =====" \
    && echo "===== 开始安装 requests 包 =====" \
    && /opt/conda/bin/conda install -y -n ${CONDA_ENV_NAME} requests \
    && echo "===== requests 包安装成功 =====" \
    # 清理conda缓存减小镜像体积
    && /opt/conda/bin/conda clean -y --all \
    && echo "===== conda 缓存清理完成 =====" \
    # 修复环境权限，允许所有用户写入（支持非root用户运行容器）
    && chmod -R a+w /opt/conda/envs/${CONDA_ENV_NAME}/lib/python*/site-packages/ \
    # 将环境激活命令写入bashrc，容器启动后默认激活该环境
    && echo "source /opt/conda/bin/activate ${CONDA_ENV_NAME}" >> /etc/bash.bashrc \
    && echo "===== conda 环境配置完成 ====="

# 将conda加入全局PATH，确保环境激活命令可用
ENV PATH="/opt/conda/bin:${PATH}"

# 设置默认激活环境的环境变量（增强兼容性）
ENV CONDA_DEFAULT_ENV="${CONDA_ENV_NAME}"