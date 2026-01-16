# GitHub Actions 磁盘空间问题解决方案

## 问题描述

当尝试拉取或构建大型 Docker 镜像（如 PyTorch CUDA 镜像）时，可能会遇到以下错误：

```
Error response from daemon: write /var/lib/docker/tmp/docker-export-xxx: no space left on device
```

## 问题原因

GitHub Actions runner 的磁盘空间有限：
- **总磁盘空间**: 约 70-80GB
- **系统占用**: 约 50-60GB
- **可用空间**: 约 14-20GB

大型镜像（如 PyTorch CUDA）通常占用 5-10GB，加上 Docker 构建缓存和临时文件，容易超过可用空间限制。

## 解决方案

### ✅ 已实施的优化措施

工作流已自动包含以下优化步骤：

#### 1. 磁盘空间检查
在每个操作前检查可用空间：
```bash
df -h                    # 检查总体磁盘使用
docker system df         # 检查 Docker 占用空间
```

#### 2. 自动清理 Docker 缓存
在保存镜像前自动清理：
```bash
docker builder prune -af      # 清理构建缓存
docker image prune -f         # 清理悬挂镜像
docker system prune -f        # 清理所有未使用资源
```

#### 3. 空间预警机制
如果可用空间小于 5GB，会自动触发深度清理：
```bash
docker system prune -f --volumes  # 包括卷的深度清理
```

## 针对大镜像的替代方案

如果镜像太大（超过 10GB），即使清理缓存也可能不够，可以考虑以下方案：

### 方案 1：使用阿里云 OSS 工作流（推荐）

直接上传到阿里云 OSS，不占用 GitHub Release 空间：

```yaml
# 使用 .github/workflows/build-dockerfile-oss.yml
oss_endpoint: oss-cn-hangzhou.aliyuncs.com
oss_bucket: your-bucket
oss_path: docker-images/
```

**优点**：
- ✅ 不受 GitHub 磁盘限制
- ✅ 上传速度快
- ✅ 可以存储超大文件
- ✅ 成本低廉

详见：[ALIYUN_OSS_SETUP.md](ALIYUN_OSS_SETUP.md)

### 方案 2：使用本地自托管 Runner

在自己的服务器上运行 GitHub Actions runner：

**优点**：
- ✅ 无磁盘空间限制
- ✅ 完全控制环境
- ✅ 可以使用私有镜像仓库

**设置方法**：
1. 在服务器上安装 Actions Runner
2. 在仓库设置中配置自托管 runner
3. 运行工作流时选择自托管 runner

### 方案 3：使用更小的基础镜像

如果可能，使用更小的镜像变体：

| 镜像类型 | 大小 | 示例 |
|---------|------|------|
| 完整版 | ~8GB | `pytorch/pytorch:2.9.1-cuda12.6-cudnn9-devel` |
| Runtime 版 | ~5GB | `pytorch/pytorch:2.9.1-cuda12.6-cudnn9-runtime` |
| CPU 版 | ~2GB | `pytorch/pytorch:2.9.1-cuda12.6-cudnn9-devel` (无 CUDA) |

### 方案 4：分批处理

将大镜像拆分为多个小镜像：
```dockerfile
# 分离基础环境和应用
FROM pytorch/pytorch:2.9.1-cuda12.6-cudnn9-runtime AS base
# 安装依赖...
```

### 方案 5：使用 Docker Squash

使用 `docker-squash` 压缩镜像层：

```bash
# 安装 docker-squash
pip install docker-squash

# 压缩镜像
docker-squash pytorch/pytorch:2.9.1-cuda12.6-cudnn9-devel
```

### 方案 6：禁用 GitHub Release，仅使用 OSS

在上传到 OSS 的同时禁用 GitHub Release：

```yaml
enable_release: false  # 不创建 GitHub Release
```

## 使用建议

### 对于小型镜像（< 2GB）

可以使用任何工作流：
- ✅ `pull-docker-image.yml`
- ✅ `build-dockerfile.yml`
- ✅ `build-dockerfile-oss.yml`

### 对于中型镜像（2-5GB）

推荐使用：
- ✅ `build-dockerfile-oss.yml`（上传到 OSS）
- ⚠️ 其他工作流可能需要多次清理

### 对于大型镜像（> 5GB）

强烈推荐：
- ✅ `build-dockerfile-oss.yml`（上传到 OSS）
- ✅ 自托管 runner
- ❌ 不推荐使用 GitHub Release

## 监控磁盘空间

工作流运行时，在日志中查看以下信息：

```
==========================================
磁盘空间检查
==========================================
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        72G   58G   14G  81% /

Docker 磁盘使用情况:
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          15        3         8.5GB     6.2GB (72%)
Containers      0         0         0B        0B
Local Volumes   0         0         0B        0B
Build Cache     45        0         2.1GB     2.1GB (100%)
==========================================
```

关键指标：
- **Avail（可用空间）**: 应该 > 5GB
- **RECLAIMABLE（可回收）**: 如果很大，说明需要清理

## 常见镜像大小参考

| 镜像 | 大小 | 能否在 GitHub Actions 上处理 |
|------|------|--------------------------|
| nginx:alpine | ~40MB | ✅ 完全没问题 |
| python:3.11 | ~1GB | ✅ 完全没问题 |
| node:20 | ~1.2GB | ✅ 完全没问题 |
| ubuntu:22.04 | ~80MB | ✅ 完全没问题 |
| pytorch/pytorch:latest | ~6GB | ⚠️ 需要清理缓存 |
| pytorch/pytorch:cuda-devel | ~10GB | ❌ 建议使用 OSS |
| nvidia/cuda:12.6-devel | ~5GB | ⚠️ 需要清理缓存 |

## 故障排查

### 问题 1: 持续出现空间不足

**原因**: 镜像太大，即使清理也无法释放足够空间

**解决**:
1. 使用阿里云 OSS 工作流
2. 使用自托管 runner
3. 压缩镜像（使用更小的基础镜像）

### 问题 2: 清理后仍然失败

**原因**: Docker 占用的空间无法及时释放

**解决**:
```bash
# 手动重启 Docker 服务（需要管理员权限）
sudo systemctl restart docker
```

注意：GitHub Actions runner 可能没有此权限。

### 问题 3: 多次运行后空间越来越小

**原因**: 之前的运行残留了文件

**解决**:
- 工作流会在每次运行前自动清理
- 确保 `Clean Docker Cache` 步骤正常执行
- 检查是否有错误日志

## 最佳实践

### 1. 选择合适的工作流

```
小型镜像（< 2GB） → pull-docker-image.yml 或 build-dockerfile.yml
大型镜像（> 5GB） → build-dockerfile-oss.yml
需要长期存储     → build-dockerfile-oss.yml
```

### 2. 定期检查日志

关注以下步骤的输出：
- ✅ Check Disk Space
- ✅ Clean Docker Cache
- ✅ Available Space 警告

### 3. 优化 Dockerfile

```dockerfile
# ❌ 不好：多层构建
FROM ubuntu:22.04
RUN apt-get update
RUN apt-get install python3
RUN apt-get clean

# ✅ 好：合并指令
FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 4. 使用多阶段构建

```dockerfile
# 构建阶段
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# 运行阶段（更小）
FROM alpine:latest
COPY --from=builder /app/myapp /usr/local/bin/myapp
CMD ["myapp"]
```

### 5. 选择合适的基础镜像

| 基础镜像 | 大小 | 适用场景 |
|---------|------|---------|
| alpine | ~5MB | 最小化镜像 |
| debian:slim | ~80MB | 需要完整系统 |
| ubuntu:22.04 | ~80MB | 兼容性好 |
| scratch | 0MB | 静态编译程序 |

## 相关资源

- [GitHub Actions Runner 磁盘限制](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#standard-github-hosted-runners-for-public-repositories)
- [Docker 系统 prune 文档](https://docs.docker.com/engine/reference/commandline/system_prune/)
- [ALIYUN_OSS_SETUP.md](ALIYUN_OSS_SETUP.md) - 阿里云 OSS 配置指南
- [自托管 Runner 设置](https://docs.github.com/en/actions/hosting-your-own-runners)

## 总结

对于 PyTorch 等大型镜像，**最佳实践是使用阿里云 OSS 工作流**：

```yaml
# 推荐配置
dockerfile_path: Dockerfile
image_name: pytorch/pytorch:2.9.1-cuda12.6-cudnn9-devel
oss_endpoint: oss-cn-hangzhou.aliyuncs.com
oss_bucket: your-docker-images
oss_path: pytorch-images/
enable_release: false  # 禁用 GitHub Release，节省空间
```

这样可以：
- ✅ 避免磁盘空间限制
- ✅ 快速上传和下载
- ✅ 降低存储成本
- ✅ 支持超大文件
