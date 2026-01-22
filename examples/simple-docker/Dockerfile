FROM ubuntu:22.04

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

# ========== 创建 apulis-dev 用户 ==========
RUN set -x && \
    groupadd apulis-dev && \
    useradd -m -s /bin/bash -g apulis-dev apulis-dev && \
    # 为 apulis-dev 用户添加 sudo 权限（可选）
    echo "apulis-dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/apulis-dev && \
    chmod 440 /etc/sudoers.d/apulis-dev && \
    echo "===== 用户创建完成 ====="
