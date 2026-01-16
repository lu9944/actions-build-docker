# Docker Pull Artifact

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF.svg?logo=github-actions)](https://github.com/features/actions)

GitHub Actions 工作流，用于拉取指定的 Docker 镜像并保存为 TAR 文件供下载。

## 功能特点

- 拉取任意 Docker 镜像（包括私有仓库，需配置权限）
- 自动保存为 TAR 格式文件
- 自动创建 GitHub Release，方便下载和长期存储
- 支持多架构镜像（amd64, arm64, arm/v7, ppc64le, s390x）
- 手动触发，灵活控制
- 自动显示镜像信息和文件大小

## 使用场景

- 在无法访问 Docker Hub 的环境中下载镜像
- 将镜像保存到本地进行离线部署
- 备份重要的 Docker 镜像
- 在内网环境中部署容器应用

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

### 多架构工作流 (`pull-docker-image-multiarch.yml`)

| 参数 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| image_name | 是 | nginx:latest | Docker 镜像名称 |
| platform | 否 | linux/amd64 | 目标平台架构 |

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

如果需要拉取私有仓库的镜像，需要先配置 Docker 登录凭证：

在工作流中添加以下步骤：

```yaml
- name: Login to Docker Registry
  uses: docker/login-action@v3
  with:
    registry: https://your-registry.com
    username: ${{ secrets.REGISTRY_USERNAME }}
    password: ${{ secrets.REGISTRY_PASSWORD }}
```

然后在 Repository Settings > Secrets and variables > Actions 中添加对应的密钥。

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
