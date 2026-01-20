FROM nvidia/cuda:12.4.0-devel-ubuntu22.04
# conda 环境名称（可根据需要修改）
ARG CONDA_ENV_NAME=ddddocr_trainer_2026
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
ARG CONDA_ENV_NAME=ddddocr_trainer_2026
ARG PYTHON_VERSION=3.11

# ========== 步骤0: 接受 Anaconda ToS（conda 25.x 要求） ==========
# conda 25.x 使用环境变量接受 ToS，无需运行 conda tos accept 命令
ENV CONDA_YES_ACCEPT_TERMS_OF_SERVICE=true

# ========== 步骤1: 验证 conda 安装 ==========
RUN set -x && \
    ls -la /opt/conda/bin/conda && \
    /opt/conda/bin/conda --version && \
    echo "CONDA_ENV_NAME=${CONDA_ENV_NAME}" && \
    echo "PYTHON_VERSION=${PYTHON_VERSION}"

# ========== 步骤1.5: 创建非root用户 ==========
RUN set -x && \
    useradd -m -s /bin/bash apulis-dev && \
    echo "apulis-dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ========== 步骤2: 创建 conda 环境 ==========
RUN set -x && \
    /opt/conda/bin/conda create -y -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} && \
    echo "===== conda 环境创建成功 =====" || \
    (echo "===== 失败，尝试列出可用 Python 版本 =====" && \
     /opt/conda/bin/conda search "python=[${PYTHON_VERSION}]*" && exit 1)

# ========== 步骤3: 预安装依赖包(根据自己的需求) ==========
RUN set -x && \
    /opt/conda/bin/conda install -y -n ${CONDA_ENV_NAME} \
        fire \
        loguru \
        pyyaml \
        tqdm \
        "numpy<2" \
        seaborn \
        onnx \
        onnxruntime \
        onnxscript \
        pillow==9.5.0 && \
    echo "===== 多个包安装成功 ====="

# ========== 步骤3.5: 安装 PyTorch (CUDA 12.4) ==========
RUN set -x && \
    /opt/conda/envs/${CONDA_ENV_NAME}/bin/pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124 && \
    echo "===== PyTorch 安装完成 ====="

# ========== 步骤4: 清理 conda 缓存 ==========
RUN set -x && \
    /opt/conda/bin/conda clean -y --all && \
    echo "===== conda 缓存清理完成 ====="

# ========== 步骤5: 修复权限并配置环境 ==========
RUN set -x && \
    chown -R apulis-dev:apulis-dev /opt/conda/envs/${CONDA_ENV_NAME} && \
    echo "source /opt/conda/bin/activate ${CONDA_ENV_NAME}" >> /etc/bash.bashrc && \
    echo "source /opt/conda/bin/activate ${CONDA_ENV_NAME}" >> /home/apulis-dev/.bashrc && \
    echo "===== conda 环境配置完成 ====="

# 将conda加入全局PATH，确保环境激活命令可用
ENV PATH="/opt/conda/bin:${PATH}"

# 设置默认激活环境的环境变量（增强兼容性）
ENV CONDA_DEFAULT_ENV="${CONDA_ENV_NAME}"

# 切换到非root用户
USER apulis-dev
WORKDIR /home/apulis-dev