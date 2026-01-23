FROM ubuntu:22.04

RUN sed -i -e 's|http.*.ubuntu.com|http://mirrors.tuna.tsinghua.edu.cn|' /etc/apt/sources.list && \
    apt update && \
    apt install build-essential iputils-ping net-tools iproute2 curl dnsutils tcpdump netcat-openbsd vim sudo unzip zip screen libgl1-mesa-glx htop sudo git openssh-server libsm6 libxext6 ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 gcc g++ make cmake file wget -y && \
    apt install python3-pip -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install jupyter jupyterlab -i https://mirrors.aliyun.com/pypi/simple

RUN bash -c "$(curl -fsSL https://gitee.com/RubyMetric/nvm-cn/raw/main/install.sh)" && \
    . ~/.nvm/nvm.sh && \
    nvm install 22 && \
    nvm use 22 && \
    npm install -g @anthropic-ai/claude-code

# 配置 nvm 环境变量（使其在容器启动时可用）
ENV NVM_DIR="/root/.nvm"
ENV PATH="/root/.nvm/versions/node/v22/bin:${PATH}"

WORKDIR /usr/local/src
