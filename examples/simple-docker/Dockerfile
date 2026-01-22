FROM ubuntu:22.04

RUN apt update && \
    apt install build-essential iputils-ping net-tools iproute2 curl dnsutils tcpdump netcat-openbsd vim sudo unzip curl zip screen libgl1-mesa-glx htop sudo git openssh-server libsm6 libxext6 ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 gcc g++ make cmake file wget -y && \
    apt install python3-pip -y && \
    apt clean

RUN pip3 install jupyter jupyterlab

WORKDIR /usr/local/src
