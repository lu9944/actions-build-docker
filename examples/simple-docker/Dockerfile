FROM ubuntu:22.04
# conda 环境名称（可根据需要修改）
ARG CONDA_ENV_NAME=ubuntu_env
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

# 强制安装 Miniconda 24.4.0（删除基础镜像中的旧 conda 以避免 ToS 问题）
RUN set -eux \
    # 删除基础镜像中可能存在的 conda（避免使用 25.x 版本）
    && rm -rf /opt/conda \
    && echo "开始安装 Miniconda 24.4.0"; \
    # 验证curl可用
    command -v curl || (echo "ERROR: curl not found" && exit 1) \
    # 下载Miniconda安装包（使用 24.4.0 版本，避免 ToS 问题）
    && curl -fL -o Miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-py310_24.4.0-0-Linux-x86_64.sh \
    # 验证文件下载成功
    && ls -lh Miniconda3.sh \
    # 安装Miniconda
    && /bin/bash Miniconda3.sh -b -p /opt/conda \
    # 清理安装包
    && rm Miniconda3.sh \
    # 验证conda安装成功
    && /opt/conda/bin/conda --version


# 重新声明构建参数（确保在RUN命令中可用）
ARG CONDA_ENV_NAME=ubuntu_env
ARG PYTHON_VERSION=3.11

# ========== 步骤1: 验证 conda 安装 ==========
RUN set -x && \
    ls -la /opt/conda/bin/conda && \
    /opt/conda/bin/conda --version && \
    echo "CONDA_ENV_NAME=${CONDA_ENV_NAME}" && \
    echo "PYTHON_VERSION=${PYTHON_VERSION}"

# ========== 步骤2: 创建 conda 环境 ==========
RUN set -x && \
    /opt/conda/bin/conda create -y -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} && \
    echo "===== conda 环境创建成功 =====" || \
    (echo "===== 失败，尝试列出可用 Python 版本 =====" && \
     /opt/conda/bin/conda search "python=[${PYTHON_VERSION}]*" && exit 1)

# ========== 步骤3: 使用 pip 安装所有依赖包（更简单统一）==========
RUN set -x && \
    /opt/conda/envs/${CONDA_ENV_NAME}/bin/pip install \
        pillow==9.5.0 && \
    echo "===== 依赖包安装成功 ====="

# ========== 步骤5: 清理 conda 缓存 ==========
RUN set -x && \
    /opt/conda/bin/conda clean -y --all && \
    chmod -R a+w /opt/conda/envs/${CONDA_ENV_NAME}/lib/python*/site-packages/ \
    && echo "===== conda 缓存清理完成 ====="

# ========== 步骤6: 创建 apulis-dev 用户 ==========
RUN set -x && \
    groupadd apulis-dev && \
    useradd -m -s /bin/bash -g apulis-dev apulis-dev && \
    # 为 apulis-dev 用户添加 sudo 权限（可选）
    echo "apulis-dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/apulis-dev && \
    chmod 440 /etc/sudoers.d/apulis-dev && \
    echo "===== 用户创建完成 ====="

# ========== 步骤7: 修复权限并配置环境 ==========
RUN set -x && \
    chown -R apulis-dev:apulis-dev /opt/conda/envs/${CONDA_ENV_NAME} && \
    # 清理可能导致错误的 conda 配置
    rm -f /opt/conda/.condarc /root/.condarc /home/apulis-dev/.condarc && \
    # 重新初始化 conda
    /opt/conda/bin/conda init bash && \
    # 设置正确的 conda 配置
    /opt/conda/bin/conda config --set auto_activate_base false && \
    /opt/conda/bin/conda config --set env_prompt '({name})' && \
    # 在系统级 bashrc 中激活环境（所有用户）
    echo "source /opt/conda/bin/activate ${CONDA_ENV_NAME}" >> /etc/bash.bashrc && \
    # 在用户的 .bashrc 中激活环境
    echo "source /opt/conda/bin/activate ${CONDA_ENV_NAME}" >> /home/apulis-dev/.bashrc && \
    # 在用户的 .bash_profile 中也激活环境（登录 shell）
    echo "source /opt/conda/bin/activate ${CONDA_ENV_NAME}" >> /home/apulis-dev/.bash_profile && \
    # 同时也设置在用户的 .profile 中
    echo "source /opt/conda/bin/activate ${CONDA_ENV_NAME}" >> /home/apulis-dev/.profile && \
    echo "===== conda 环境配置完成 ====="

# ========== 步骤8: 创建全局环境激活脚本 ==========
RUN set -x && \
    # 创建一个配置脚本，在所有 shell 会话中激活 conda 环境
    printf '#!/bin/bash\n\
# 自动激活 conda 环境\n\
if [ -f /opt/conda/bin/activate ]; then\n\
    source /opt/conda/bin/activate %s 2>/dev/null\n\
fi\n' "${CONDA_ENV_NAME}" > /etc/profile.d/activate-conda-env.sh && \
    chmod +x /etc/profile.d/activate-conda-env.sh && \
    # 创建简化的 entrypoint 脚本
    printf '#!/bin/bash\n\
# 激活conda环境\n\
source /opt/conda/bin/activate %s\n\
# 执行传入的命令\n\
if [ $# -eq 0 ]; then\n\
    exec bash -l\n\
else\n\
    exec "$@"\n\
fi\n' "${CONDA_ENV_NAME}" > /entrypoint.sh && \
    chmod +x /entrypoint.sh && \
    echo "===== 环境配置脚本创建完成 ====="

# 将conda加入全局PATH，确保环境激活命令可用
ENV PATH="/opt/conda/bin:${PATH}"

# 设置默认激活环境的环境变量（增强兼容性）
ENV CONDA_DEFAULT_ENV="${CONDA_ENV_NAME}"

# 设置 entrypoint 自动激活 conda 环境
ENTRYPOINT ["/entrypoint.sh"]