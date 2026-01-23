# BEVFormer Dockerfile
# 适用于宿主机 CUDA 11.8
# 构建建议使用: docker build --no-cache -t bevformer:latest .
# (使用 --no-cache 防止复用之前编译错误的缓存层)

FROM pytorch/pytorch:1.9.1-cuda11.1-cudnn8-devel

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"

# [关键修复 1] 强制开启 CUDA 编译模式
# 必须加上这一行！否则在 docker build 无 GPU 环境下，mmdet3d 会编译成 CPU 版，导致运行时报错。
ENV FORCE_CUDA="1"

# [关键修复 2] 修正路径配置
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV LIBRARY_PATH=${CUDA_HOME}/lib64:${LIBRARY_PATH}

# [关键修复 3] 修复 UndefinedVar 警告，去掉末尾的 :${CPATH}
ENV CPATH=${CUDA_HOME}/include

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git wget curl ca-certificates \
    libglib2.0-0 libsm6 libxext6 libxrender-dev libgomp1 \
    ffmpeg libgl1-mesa-glx ninja-build vim unzip zip screen htop sudo openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 基础 Python 配置
RUN python -m pip install --upgrade pip setuptools wheel

SHELL ["/bin/bash", "-c"]

WORKDIR /workspace

# 安装 MMCV
RUN pip install mmcv-full==1.4.0 \
    -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.9.0/index.html

# 安装 MMDet & MMSeg
RUN pip install mmdet==2.14.0 mmsegmentation==0.14.1

# 安装基础依赖
RUN pip install einops fvcore seaborn iopath==0.1.9 timm==0.6.13 \
    typing-extensions==4.5.0 pylint ipython==8.12.0 \
    numpy==1.19.5 matplotlib==3.5.2 numba==0.48.0 \
    pandas==1.4.4 scikit-image==0.19.3 setuptools==59.5.0 jupyter jupyterlab

# 编译安装 MMDet3D v0.17.1 (此处强烈依赖 FORCE_CUDA=1)
RUN git clone https://github.com/open-mmlab/mmdetection3d.git /tmp/mmdetection3d && \
    cd /tmp/mmdetection3d && \
    git checkout v0.17.1 && \
    cp -r /tmp/mmdetection3d /workspace/mmdetection3d && \
    cd /workspace/mmdetection3d && \
    pip install setuptools==59.5.0 && \
    pip install -v -e . && \
    rm -rf /tmp/mmdetection3d

# 安装 Detectron2
RUN pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu111/torch1.9/index.html

# 下载 BEVFormer 代码与权重
RUN git clone https://github.com/fundamentalvision/BEVFormer.git /workspace/BEVFormer && \
    mkdir -p /workspace/BEVFormer/ckpts /workspace/BEVFormer/data && \
    cd /workspace/BEVFormer/ckpts && \
    wget --quiet --tries=3 --no-check-certificate https://github.com/zhiqi-li/storage/releases/download/v1.0/r101_dcn_fcos3d_pretrain.pth

CMD ["/bin/bash"]