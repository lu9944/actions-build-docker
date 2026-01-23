# MiniMind Dockerfile
# 基于 PyTorch 官方镜像，已包含 PyTorch 2.6.0 + CUDA 12.6 + cuDNN 9
# 镜像包含: Python 3.11, PyTorch 2.6.0, torchvision 0.21.0, CUDA 12.6, cuDNN 9

FROM pytorch/pytorch:2.6.0-cuda12.6-cudnn9-runtime

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    TORCH_CUDA_ARCH_LIST="7.0 7.5 8.0 8.6+PTX" \
    FORCE_CUDA=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 设置工作目录
WORKDIR /app/minimind

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    wget \
    openssh-server \
    iputils-ping \
    net-tools \
    dnsutils \
    tcpdump \
    netcat-openbsd \
    sudo \
    unzip \
    vim \
    build-essential \
    libsparsehash-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 升级 pip（PyTorch 镜像已包含 Python 和 pip）
RUN pip install --upgrade pip setuptools wheel

# 安装 Python 依赖包（torch 和 torchvision 已包含在镜像中）
RUN pip install --no-cache-dir \
    datasets==3.6.0 \
    datasketch==1.6.4 \
    Flask==3.0.3 \
    Flask_Cors==4.0.0 \
    jieba==0.42.1 \
    jsonlines==4.0.0 \
    marshmallow==3.22.0 \
    matplotlib==3.10.0 \
    ngrok==1.4.0 \
    nltk==3.8 \
    numpy==1.26.4 \
    openai==1.59.6 \
    peft==0.7.1 \
    psutil==5.9.8 \
    pydantic==2.11.5 \
    rich==13.7.1 \
    scikit_learn==1.5.1 \
    sentence_transformers==2.3.1 \
    simhash==2.1.2 \
    tiktoken==0.10.0 \
    transformers==4.57.1 \
    jinja2==3.1.2 \
    trl==0.13.0 \
    ujson==5.1.0 \
    wandb==0.18.3 \
    streamlit==1.50.0 \
    einops==0.8.1 \
    swanlab==0.6.8

# 设置 Python 路径（代码将通过 volume 挂载）
ENV PYTHONPATH=/app/minimind:$PYTHONPATH

# 暴露常用端口
# 8501: Streamlit WebUI
# 5000: Flask API Server
EXPOSE 8501 5000

# 默认命令：启动 bash
CMD ["/bin/bash"]

# 使用示例：
#
# 1. 构建镜像（在项目根目录）：
#    docker build -t minimind:latest .
#
# 2. 运行容器（GPU 支持，挂载项目代码）：
#    docker run --gpus all -it --rm \
#      -v $(pwd):/app/minimind \
#      -p 8501:8501 -p 5000:5000 \
#      --name minimind \
#      minimind:latest
#
# 3. 启动 WebUI：
#    docker exec minimind streamlit run scripts/web_demo.py --server.address 0.0.0.0
#
# 4. 启动 API 服务器：
#    docker exec minimind python scripts/serve_openai_api.py
#
# 5. 运行训练：
#    docker exec minimind python trainer/train_pretrain.py
#
# 6. 交互式推理：
#    docker exec -it minimind python eval_llm.py --load_from ./MiniMind2
