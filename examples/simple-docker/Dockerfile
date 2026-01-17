FROM pytorch/pytorch:2.9.0-cuda12.6-cudnn9-devel

# ========== 安装系统依赖 ==========
RUN set -eux \
    # 检查基础镜像系统信息
    && cat /etc/os-release \
    # 检查当前 apt 源配置
    && cat /etc/apt/sources.list \
    # 配置 Ubuntu 22.04 (Jammy) 官方源
    && echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list \
    && echo "deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list \
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

# 创建conda环境并安装依赖（完全使用官方源，不换源）
RUN CONDA_BIN="/opt/conda/bin" \
    && export PATH=$CONDA_BIN:$PATH \
    # 创建名为ddddocr_env的conda环境（指定python版本，兼容依赖）
    && conda create -y -n ddddocr_env python=3.10 \
    # 激活环境并安装指定依赖包（使用官方源）
    && source activate ddddocr_env \
    && conda install -y \
        fire \
        loguru \
        pyyaml \
        tqdm \
        "numpy<2" \
        pillow==9.5.0 \
        onnx \
        onnxruntime \
        onnxscript \
    # 清理conda缓存减小镜像体积
    && conda clean -y --all \
    && CONDA_BIN="" \
    # 将环境激活命令写入bashrc，容器启动后默认激活该环境
    && echo "source /opt/conda/bin/activate ddddocr_env" >> /etc/bash.bashrc

# 将conda加入全局PATH，确保环境激活命令可用
ENV PATH="/opt/conda/bin:${PATH}"

# 设置默认激活环境的环境变量（增强兼容性）
ENV CONDA_DEFAULT_ENV="ddddocr_env"