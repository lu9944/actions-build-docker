# OpenCode + OpenChamber Ubuntu 镜像

基于 Ubuntu（x86_64）的 All-in-one 镜像，把 AI 编码工作台整体装进容器：

- **[OpenCode](https://opencode.ai/v2/docs)**：来自 [lu9944/offline-opencode-installer](https://github.com/lu9944/offline-opencode-installer)
  Release 的官方独立二进制（不依赖 Node.js），构建时校验 SHA256 后离线安装
- **[OpenChamber](https://github.com/openchamber/openchamber)**：基于 OpenCode 的 Web 工作台
  （npm 包 `@openchamber/web`，构建时安装最新版），默认启动，浏览器即可使用
- **Node.js 24**：OpenChamber 运行所需，也方便在容器内做开发（`openchamber update` 可直接就地升级）
- **常用网络工具 + vim**：`ping` `ip` `ifconfig` `netstat` `dig` `traceroute` `telnet` `nc`
  `tcpdump` `wget` `curl` `ssh` `rsync` + `vim`、`git`、`ripgrep`、`build-essential`、`python3`

## 镜像内容

- `/usr/local/bin/opencode`（以及兼容旧命令名的 `opencode2` shim）
- `/usr/local/bin/openchamber`（Node.js 全局安装）
- 容器入口脚本：默认监听 `0.0.0.0`（端口映射可访问）、自动生成并持久化 UI 密码、首次启动生成 SSH 密钥
- 默认工作目录 `/workspace`，默认命令 `openchamber serve --foreground`（Web 服务，端口 3000）

## 使用

### 方式一：启动 OpenChamber Web 服务（默认命令）

```bash
docker run -d --name openchamber -p 3000:3000 -v "$PWD":/workspace opencode-ubuntu:latest
docker logs openchamber   # 日志里有自动生成的 UI 密码
```

浏览器访问 `http://<主机IP>:3000`，输入密码即可进入 OpenChamber（内部已自动带起 OpenCode）。

常用环境变量：

| 变量 | 说明 |
|------|------|
| `OPENCHAMBER_UI_PASSWORD` | 自定义 UI 密码（不设置则自动生成并持久化） |
| `OPENCHAMBER_HOST` | 监听地址（镜像内默认 `0.0.0.0`） |
| `OPENCHAMBER_LAN_URL` | 局域网配对链接使用的地址（如 `http://192.168.1.20:3000`） |
| `OPENCHAMBER_ALLOW_UNAUTHENTICATED_LAN=true` | 配合 `-e OPENCHAMBER_UI_PASSWORD=` 可在可信内网关闭认证 |

需要持久化的目录（可选挂载）：

```bash
-v openchamber-config:/root/.config/openchamber   # OpenChamber 设置与 UI 密码
-v openchamber-data:/root/.local/share/opencode   # OpenCode 数据
-v openchamber-state:/root/.local/state/opencode  # OpenCode 状态
-v ~/.ssh-openchamber:/root/.ssh                  # SSH 密钥（远程功能使用）
```

### 方式二：使用 opencode TUI

```bash
docker run -it --rm -v "$PWD":/workspace opencode-ubuntu:latest opencode
```

### 方式三：进入 shell 或其他命令

```bash
docker run -it --rm -v "$PWD":/workspace opencode-ubuntu:latest bash
docker run --rm opencode-ubuntu:latest opencode --version
docker run --rm opencode-ubuntu:latest openchamber --version
```

> 入口脚本支持参数透传：`docker run -d -p 8080:3000 opencode-ubuntu:latest --port 3000` 等写法会自动补全为默认命令。

## 方式一：使用 GitHub Actions 构建（推荐）

使用仓库中的 `Build OpenCode Ubuntu Image` 工作流：

1. GitHub → **Actions** → **Build OpenCode Ubuntu Image** → **Run workflow**
2. 常用参数：
   - **opencode_version**：`latest`（默认）或具体版本如 `2.0.29`
   - **openchamber_version**：`latest`（默认）或具体版本如 `2.3.2`
   - **ubuntu_version**：`24.04`（默认）/ `22.04` / `20.04`
   - **variant**：`linux-x64`（默认）；无 AVX2 的老 CPU 选 `linux-x64-baseline`
   - **enable_dockerhub_push**：推送到 Docker Hub（需要 `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN`）
3. 构建完成后工作流会自动验证：opencode / openchamber / Node 版本、网络工具与 vim、
   并真实启动一次 OpenChamber 服务确认可访问；随后推送到 Docker Hub 并导出 TAR 到
   GitHub Release（FTP 可选）

## 方式二：本地构建

```bash
# 1. 下载离线包（以 2.0.29 为例，可替换为最新版本）
curl -fL -O https://github.com/lu9944/offline-opencode-installer/releases/download/offline-2.0.29/opencode-offline-2.0.29-linux-x64-arm64.zip

# 2. 准备构建上下文
mkdir -p ctx
unzip -q opencode-offline-2.0.29-linux-x64-arm64.zip -d ctx
mv ctx/opencode-offline-* ctx/opencode-offline
cp examples/opencode/docker-entrypoint.sh ctx/

# 3. 构建镜像
docker build \
  -f examples/opencode/Dockerfile \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg OPENCODE_VERSION=2.0.29 \
  --build-arg OPENCODE_VARIANT=linux-x64 \
  --build-arg OPENCHAMBER_VERSION=latest \
  -t opencode-ubuntu:latest \
  ctx
```

## 离线机器使用

在有网机器上把镜像导出为 tar：

```bash
docker save -o opencode-image.tar opencode-ubuntu:latest
```

拷贝到离线机器后：

```bash
docker load -i opencode-image.tar
docker run -d --name openchamber -p 3000:3000 -v "$PWD":/workspace opencode-ubuntu:latest
docker logs openchamber   # 查看 UI 密码
```

> 提示：使用模型时容器需要能访问你配置的 LLM 服务（公网或内网自建端点均可）。

## 说明

- 镜像只包含 x86_64（amd64）平台；ARM 机器请构建 `arm64` 变体（Dockerfile 已同时兼容两种架构）。
- `linux-x64` 需要 CPU 支持 AVX2；老 CPU 用 `linux-x64-baseline`。
- OpenChamber 由 npm 全局安装，镜像内保留 npm 与编译工具，`openchamber update` 可在容器内直接升级。
- 离线包解压后约 400 MB（含 x64 + arm64 两个二进制）；多阶段构建保证镜像内不残留离线包文件。
