# Docker Pull Artifact

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF.svg?logo=github-actions)](https://github.com/features/actions)

GitHub Actions 工作流，用于拉取指定的 Docker 镜像或从 Dockerfile 构建镜像，并保存为 TAR 文件供下载。

## 功能特点

- 拉取任意 Docker 镜像（包括私有仓库，需配置权限）
- **从 Dockerfile 构建自定义镜像**
- 自动保存为 TAR 格式文件
- 自动创建 GitHub Release，方便下载和长期存储
- **支持同时上传到 FTP 服务器**
- 支持多架构镜像（amd64, arm64, arm/v7, ppc64le, s390x）
- 手动触发，灵活控制
- 自动显示镜像信息和文件大小

## 使用场景

- 在无法访问 Docker Hub 的环境中下载镜像
- 从 Dockerfile 构建自定义镜像并导出
- 将镜像保存到本地进行离线部署
- 备份重要的 Docker 镜像
- 在内网环境中部署容器应用

## 配置 Docker Hub Token（推荐）

如果你是 **Docker Pro** 或付费用户，配置 Personal Access Token 可以获得更高的拉取限制和更好的性能。

### 为什么要配置？

- ✅ **更高的速率限制**：从每 6 小时 100 次提升到更高限制
- ✅ **访问私有镜像**：可以拉取你账户下的私有镜像
- ✅ **避免匿名限制**：不再受匿名用户限制影响
- ✅ **更好的稳定性**：减少因限流导致的失败

### 快速配置步骤

**1. 创建 Docker Hub Access Token**
- 登录 https://hub.docker.com/
- 进入 **Account Settings** → **Security** → **Access Tokens**
- 点击 **New Access Token**
- 输入描述（如 `GitHub Actions`），选择权限
- 复制生成的 token（格式：`dckr_pat_...`）

**2. 添加到 GitHub Secrets**
- 进入你的仓库 **Settings** → **Secrets and variables** → **Actions**
- 点击 **New repository secret**
- **Name**: `DOCKERHUB_TOKEN`
- **Secret**: 粘贴你的 Docker Hub Token
- 点击 **Add secret**

> **用户名（可选）**：你也可以添加 `DOCKERHUB_USERNAME` Secret（你的 Docker Hub 用户名），但不是必需的。

**3. 验证配置**
运行工作流后，在日志中查找：
- ✅ `已使用 Docker Hub Token 认证（Pro 模式）` - 配置成功
- ⚠️ `未配置 Docker Hub Token，使用匿名模式` - 未配置

### 向后兼容

未配置 `DOCKERHUB_TOKEN` 的工作流仍然可以正常运行，只是使用匿名模式（有限制）。

📖 **详细配置指南**: 查看 [DOCKER_HUB_SETUP.md](DOCKER_HUB_SETUP.md) 获取完整的配置说明和故障排除。

## 快速开始

### 方式一：使用基础工作流（推荐新手）

1. 将 `.github/workflows/pull-docker-image.yml` 文件添加到你的仓库
2. 在 GitHub 上进入 **Actions** 标签页
3. 选择 **Pull Docker Image and Save as TAR** 工作流
4. 点击 **Run workflow**
5. 输入参数：
   - **镜像名称**: 例如 `nginx:latest` 或 `gcr.io/distroless/static:latest`
6. 等待执行完成
7. 在仓库的 **Releases** 区域下载 TAR 文件

### 方式二：使用多架构工作流

如果你需要下载特定架构的镜像（如 ARM64），使用 `.github/workflows/pull-docker-image-multiarch.yml`：

1. 按照上述步骤操作
2. 额外选择 **目标平台架构**（如 `linux/arm64`）

### 方式三：从 Dockerfile 构建镜像

如果你想从自己的 Dockerfile 构建镜像并打包，使用 `.github/workflows/build-dockerfile.yml`：

1. 在你的仓库中创建或添加 Dockerfile
2. 在 GitHub 上进入 **Actions** 标签页
3. 选择 **Build Dockerfile and Save as TAR** 工作流
4. 点击 **Run workflow**
5. 输入参数：
   - **Dockerfile 路径**: 例如 `Dockerfile` 或 `./docker/Dockerfile`
   - **镜像名称**: 例如 `myapp:v1.0`
   - **构建上下文**: 默认为 `.`（Dockerfile 所在目录）
6. 等待构建完成
7. 在仓库的 **Releases** 区域下载 TAR 文件

## 使用示例

### 示例 1: 下载官方 Nginx 镜像

```
镜像名称: nginx:latest
```

生成的文件名: `docker-image-nginx_latest.tar`

### 示例 2: 下载 Google Distroless 镜像

```
镜像名称: gcr.io/distroless/static:nonroot
```

生成的文件名: `docker-image-gcr.io_distroless_static_nonroot.tar`

### 示例 3: 下载 ARM64 架构的镜像

```
镜像名称: arm64v8/ubuntu:latest
目标平台: linux/arm64
```

生成的文件名: `docker-image-arm64v8_ubuntu_latest-linux_arm64.tar`

### 示例 4: 从 Dockerfile 构建自定义镜像

假设你的仓库中有以下 Dockerfile：

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
```

运行工作流时输入：

```
Dockerfile 路径: Dockerfile
镜像名称: my-nginx:custom
构建上下文: .
```

生成的文件名: `docker-image-my-nginx_custom.tar`

## 本地加载镜像

下载 TAR 文件后，使用以下命令加载到本地 Docker：

```bash
docker load -i docker-image-nginx_latest.tar
```

验证镜像：

```bash
docker images
```

运行容器：

```bash
docker run -it nginx:latest
```

## 工作流文件说明

### 基础工作流 (`pull-docker-image.yml`)

| 参数 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| image_name | 是 | nginx:latest | Docker 镜像名称 |
| enable_release | 否 | true | 是否上传到 GitHub Release |
| enable_ftp | 否 | false | 是否启用 FTP 上传 |
| ftp_port | 否 | 21 | FTP 端口 |
| ftp_path | 否 | / | FTP 目标路径 |

### 多架构工作流 (`pull-docker-image-multiarch.yml`)

| 参数 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| image_name | 是 | nginx:latest | Docker 镜像名称 |
| platform | 否 | linux/amd64 | 目标平台架构 |
| enable_release | 否 | true | 是否上传到 GitHub Release |
| enable_ftp | 否 | false | 是否启用 FTP 上传 |
| ftp_port | 否 | 21 | FTP 端口 |
| ftp_path | 否 | / | FTP 目标路径 |

### Dockerfile 构建工作流 (`build-dockerfile.yml`)

| 参数 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| dockerfile_path | 是 | Dockerfile | Dockerfile 路径（相对于仓库根目录） |
| image_name | 是 | myapp:latest | 构建后的镜像名称和标签 |
| build_context | 否 | . | 构建上下文路径 |
| enable_release | 否 | true | 是否上传到 GitHub Release |
| enable_ftp | 否 | false | 是否启用 FTP 上传 |
| ftp_port | 否 | 21 | FTP 端口 |
| ftp_path | 否 | / | FTP 目标路径 |

> **注意**：`enable_release` 和 `enable_ftp` 可以同时启用，文件将同时上传到两个位置。

### 配置步骤

1. **在 GitHub 仓库中添加 Secrets**

   进入仓库的 **Settings** > **Secrets and variables** > **Actions**，添加以下密钥：

   - `FTP_SERVER` - FTP 服务器地址（例如：`ftp.example.com`）
   - `FTP_USERNAME` - FTP 登录用户名
   - `FTP_PASSWORD` - FTP 登录密码

2. **运行工作流时启用 FTP**

   在手动触发工作流时：
   - 勾选 **enable_ftp** 选项
   - 填写 **ftp_port**（默认 `21`，一般使用默认值即可）
   - 填写 **ftp_path**（例如：`/docker-images/`，注意路径需要以 `/` 结尾）

### FTP 配置示例

**Secrets 配置**：
```
FTP_SERVER: ftp.example.com
FTP_USERNAME: your_username
FTP_PASSWORD: your_password
```

**运行工作流时**：
```
enable_ftp: ✅ (勾选)
ftp_port: 21
ftp_path: /docker-images/
```

### 注意事项

- FTP 上传使用 `curl` 命令，支持自动创建不存在的目录（`--ftp-create-dirs`）
- 凭证信息通过 GitHub Secrets 存储，不会在日志中暴露
- 文件会同时上传到 GitHub Release 和 FTP 服务器
- 上传完成后可以在 Actions 日志中查看详细的传输信息

## 支持的平台架构

- `linux/amd64` - 标准 x86_64 架构（最常见）
- `linux/arm64` - ARM 64位架构（苹果 M 系列、树莓派 4+）
- `linux/arm/v7` - ARM 32位架构（树莓派 3 及以下）
- `linux/ppc64le` - PowerPC 64位小端序
- `linux/s390x` - IBM System z

## 限制说明

1. **文件大小限制**:
   - GitHub Release 单文件最大 2GB
   - 总存储空间取决于账户类型

2. **Release 存储**:
   - Release 文件永久保存，除非手动删除
   - 每个 Release 会创建一个 git tag

3. **下载**:
   - Release 下载次数没有限制
   - 支持断点续传（相比 Artifact 更稳定）

## 使用私有镜像

### Docker Hub 私有镜像

如果你已配置 `DOCKERHUB_TOKEN`（见上方"配置 Docker Hub Token"），工作流会自动使用你的凭证登录 Docker Hub，可以直接拉取私有镜像。

### 其他私有镜像仓库

如果需要拉取其他私有仓库（如 GCR、ECR、自建 Harbor 等），需要添加登录步骤。

在工作流的"Pull Docker Image"步骤之前添加：

```yaml
- name: Login to Docker Registry
  uses: docker/login-action@v3
  with:
    registry: https://your-registry.com
    username: ${{ secrets.REGISTRY_USERNAME }}
    password: ${{ secrets.REGISTRY_PASSWORD }}
```

然后在 **Settings** → **Secrets and variables** → **Actions** 中添加对应的密钥：

- `REGISTRY_USERNAME` - 私有仓库用户名
- `REGISTRY_PASSWORD` - 私有仓库密码或访问令牌

## 故障排查

### 问题 1: Release 未创建

**原因**: 镜像拉取失败或保存失败

**解决方法**: 检查 Actions 运行日志，确认镜像名称是否正确

### 问题 2: 已存在同名 Release

**原因**: 时间戳相同（极罕见）

**解决方法**: 等待 1 秒后重新运行，或手动删除旧的 Release

### 问题 2: 下载的文件损坏

**原因**: 下载过程中网络中断

**解决方法**: 重新下载 Artifact，或使用不同的下载工具

### 问题 3: 镜像不存在

**原因**: 镜像名称错误或标签不存在

**解决方法**:
1. 在 [Docker Hub](https://hub.docker.com/) 搜索正确的镜像名称
2. 确认标签是否存在（如 `latest`, `alpine` 等）

### 问题 4: FTP 上传失败

**原因**:
- FTP 服务器地址或端口配置错误
- FTP 用户名或密码错误
- FTP 路径没有写权限

**解决方法**:
1. 检查 GitHub Secrets 中的 `FTP_SERVER`、`FTP_USERNAME` 和 `FTP_PASSWORD` 是否正确
2. 确认 FTP 服务器地址和端口配置正确
3. 确认 FTP 用户对目标路径有写入权限
4. 查看 Actions 日志中的详细错误信息（包含 `-v` 参数的详细输出）

### 问题 5: FTP 路径不存在

**原因**: 目标 FTP 目录不存在且无法自动创建

**解决方法**:
- 工作流使用 `--ftp-create-dirs` 参数自动创建目录
- 如果自动创建失败，请手动在 FTP 服务器上创建目标目录
- 或者使用 FTP 用户有权限的现有目录

## 高级用法

### 批量下载多个镜像

可以复制多个工作流文件，每个文件配置不同的默认镜像名称，实现批量下载。

### 定时自动下载

将 `workflow_dispatch` 改为 `schedule`，实现定时自动下载：

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # 每周日 00:00 执行
```

## 示例项目

仓库中包含了一个完整的示例项目，位于 `examples/simple-webapp/` 目录。

### 示例内容

- **Dockerfile** - 基于 Nginx Alpine 的简单 Web 应用
- **index.html** - 漂亮的静态网页
- **README.md** - 详细的使用说明

### 快速测试

1. **查看示例文件**
   ```bash
   ls examples/simple-webapp/
   # 输出: Dockerfile  index.html  README.md
   ```

2. **运行 GitHub Actions 构建**
   - 进入仓库的 **Actions** 标签页
   - 选择 **Build Dockerfile and Save as TAR** 工作流
   - 填写参数：
     - Dockerfile 路径: `examples/simple-webapp/Dockerfile`
     - 镜像名称: `example-webapp:v1.0`
     - 构建上下文: `examples/simple-webapp`
   - 点击运行

3. **下载并测试**
   ```bash
   # 下载 Release 中的 tar 文件
   # 加载镜像
   docker load -i docker-image-example-webapp_v1.0.tar

   # 运行容器
   docker run -d -p 8080:80 example-webapp:v1.0

   # 访问 http://localhost:8080
   ```

### 示例特点

- ✅ 简单易懂，适合学习
- ✅ 完整的文档说明
- ✅ 可直接用于生产环境
- ✅ 支持离线部署
- ✅ 体积小（约 40MB）

📖 **更多详情**: 查看 [examples/simple-webapp/README.md](examples/simple-webapp/README.md)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 相关资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker 官方文档](https://docs.docker.com/)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action)

## 作者

Created with GitHub Actions

---

⭐ 如果这个项目对你有帮助，请给个 Star！
