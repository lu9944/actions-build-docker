# OpenCode + OpenChamber Ubuntu 镜像
#
# 用途：
#   - 离线安装 OpenCode（来自 lu9944/offline-opencode-installer 的 Release 离线包）
#   - 安装并部署 OpenChamber Web 工作台（npm 包 @openchamber/web，构建时安装最新版）
#   - 附带常用网络工具与 vim
#
# 构建上下文需要包含以下内容（.github/workflows/build-opencode-image.yml 会自动准备）：
#   opencode-offline/      离线包解压目录
#   docker-entrypoint.sh   仓库中的容器入口脚本
#
# 手动构建示例：
#   unzip opencode-offline-<版本>-linux-*.zip -d ctx
#   mv ctx/opencode-offline-* ctx/opencode-offline/
#   cp examples/opencode/docker-entrypoint.sh ctx/
#   docker build -f examples/opencode/Dockerfile \
#     --build-arg OPENCODE_VERSION=<版本> --build-arg OPENCODE_VARIANT=linux-x64 ctx

ARG UBUNTU_VERSION=24.04

# ---------------------------------------------------------------------------
# 阶段 1：从离线包安装 opencode（校验 SHA256 + 安装到 /usr/local/bin + 运行验证）
# ---------------------------------------------------------------------------
FROM ubuntu:${UBUNTU_VERSION} AS opencode-installer

ARG OPENCODE_VARIANT=auto

COPY opencode-offline /tmp/opencode-offline

# install.sh 会校验包内 SHA256SUMS、按平台安装二进制并执行 `opencode --version` 验证
RUN set -eux; \
    if [ "${OPENCODE_VARIANT}" = "auto" ]; then \
        bash /tmp/opencode-offline/install.sh --system; \
    else \
        bash /tmp/opencode-offline/install.sh --system --variant "${OPENCODE_VARIANT}"; \
    fi; \
    ls -lh /usr/local/bin/opencode /usr/local/bin/opencode2

# ---------------------------------------------------------------------------
# 阶段 2：运行镜像
#   - opencode 独立二进制（来自离线包，不依赖 Node.js）
#   - Node.js 24 + OpenChamber（Web 工作台，默认命令）
#   - 常用网络工具 + vim
# ---------------------------------------------------------------------------
FROM ubuntu:${UBUNTU_VERSION}

# 后续 RUN 使用 bash（Node.js 安装步骤用到 pipefail，dash 不支持）
SHELL ["/bin/bash", "-c"]

ARG OPENCODE_VERSION=unknown
ARG OPENCHAMBER_VERSION=latest
ARG NODE_MAJOR=24

LABEL org.opencontainers.image.title="opencode-openchamber" \
      org.opencontainers.image.description="Ubuntu + OpenCode standalone binary + OpenChamber web workspace (offline installed)" \
      org.opencontainers.image.version="${OPENCODE_VERSION}" \
      org.opencontainers.image.source="https://github.com/lu9944/offline-opencode-installer"

# LANG/LC_ALL 保证 TUI 正常显示中文和框线字符；TERM 为 TUI 提供合理的终端类型默认值
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color

# 基础工具 + 常用网络工具 + vim
# build-essential/python3 用于 npm 原生模块编译（node-pty 等），同时方便容器内开发
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        openssh-client \
        rsync \
        vim \
        less \
        procps \
        iputils-ping \
        iproute2 \
        net-tools \
        dnsutils \
        traceroute \
        telnet \
        netcat-openbsd \
        tcpdump \
        unzip \
        zip \
        xz-utils \
        build-essential \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 24（OpenChamber 要求 Node.js >= 24.14，取 nodejs.org 官方最新 24.x 并校验 SHA256）
RUN set -euxo pipefail; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) node_arch="x64" ;; \
      arm64) node_arch="arm64" ;; \
      *) echo "不支持的架构: $arch"; exit 1 ;; \
    esac; \
    dist="https://nodejs.org/dist/latest-v${NODE_MAJOR}.x"; \
    curl -fsSL "$dist/SHASUMS256.txt" -o /tmp/node-sums.txt; \
    node_file="$(grep -o "node-v[0-9.]*-linux-${node_arch}\.tar\.xz" /tmp/node-sums.txt | head -n1)"; \
    [ -n "$node_file" ] || { echo "未在 SHASUMS256.txt 中找到 Node.js 安装包"; exit 1; }; \
    echo "安装 Node.js: $node_file"; \
    curl -fsSL "$dist/$node_file" -o "/tmp/$node_file"; \
    (cd /tmp && grep " ${node_file}$" node-sums.txt | sha256sum -c -); \
    tar -xJf "/tmp/$node_file" -C /usr/local --strip-components=1 \
        --exclude=CHANGELOG.md --exclude=LICENSE --exclude=README.md; \
    rm -f "/tmp/$node_file" /tmp/node-sums.txt; \
    node --version; \
    npm --version

# 安装 OpenChamber（默认最新版，可用 --build-arg OPENCHAMBER_VERSION 固定版本）
RUN set -eux; \
    npm install -g --no-fund --no-audit "@openchamber/web@${OPENCHAMBER_VERSION}"; \
    openchamber --version; \
    npm cache clean --force; \
    rm -rf /root/.npm

# 拷贝离线包安装好的 opencode 二进制（多阶段构建，镜像内不残留离线包）
COPY --from=opencode-installer /usr/local/bin/opencode /usr/local/bin/opencode
COPY --from=opencode-installer /usr/local/bin/opencode2 /usr/local/bin/opencode2

# 构建时再次验证两个命令都可以运行
RUN opencode --version && opencode2 --version

# 允许在容器内直接操作挂载进来的仓库（宿主机用户与容器用户 uid 不一致时 git 会报 dubious ownership）
RUN git config --system --add safe.directory '*'

# 容器入口脚本：默认监听 0.0.0.0、自动生成/持久化 UI 密码、首次启动生成 SSH 密钥
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /workspace

# OpenChamber Web 服务端口
EXPOSE 3000

# 不带参数启动 = 运行 OpenChamber Web 服务（openchamber serve --foreground）
# 也可以覆盖命令：docker run -it <镜像> opencode（TUI）或 bash
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["openchamber", "serve", "--foreground"]
