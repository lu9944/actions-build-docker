# Docker 镜像流式传输到 FTP

## 特点

此 workflow 通过**流式传输**将 Docker 镜像直接上传到 FTP 服务器，最小化磁盘占用：

- ✅ **直接管道传输**: `docker save` → `gzip` → `curl` → FTP，不保存中间文件
- ✅ **内存缓存模式**: 使用 `/dev/shm` 作为临时缓存，适用于某些 FTP 服务器
- ✅ **自动压缩**: 支持多级压缩，减少网络传输量
- ✅ **空间优化**: 完成后自动清理 Docker 镜像和缓存

## 对比

| 方式 | 磁盘占用 | 兼容性 | 速度 |
|------|---------|--------|-----|
| **原始方式** | 镜像大小 + TAR 文件（约 2x） | 100% | 慢 |
| **直接管道** | 仅镜像，边拉取边传输 | 需 FTP 支持流式上传 | 快 |
| **内存缓存** | 镜像 + 压缩缓存（在内存中） | 95% | 较快 |

## 配置 Secrets

在 GitHub 仓库设置中添加以下 Secrets：

```
FTP_SERVER         # FTP 服务器地址（例如：ftp.example.com）
FTP_USERNAME       # FTP 用户名
FTP_PASSWORD       # FTP 密码
DOCKERHUB_TOKEN    # (可选) Docker Hub Token，用于拉取私有镜像
```

## 使用方法

### 基本用法

1. 进入 Actions 标签
2. 选择 "Pull Docker Image and Stream to FTP" workflow
3. 点击 "Run workflow"
4. 填写参数：
   - **image_name**: Docker 镜像名称（例如：`nginx:latest`）
   - **ftp_port**: FTP 端口（默认 21）
   - **ftp_path**: 目标路径（例如：`/docker-images/`）
   - **compress_level**: 压缩级别 0-9（默认 6）
   - **enable_vsftpd**: 是否使用 vsftpd 兼容模式

### 传输模式选择

#### 模式 1: 直接管道（推荐）

**优点**: 最小磁盘占用，无需临时文件
**缺点**: 部分 FTP 服务器不支持流式上传

```yaml
enable_vsftpd: false  # 默认模式
```

**工作原理**:
```bash
docker save nginx | gzip | curl -T - ftp://server/nginx.tar.gz
```

#### 模式 2: 内存缓存（vsftpd 兼容）

**优点**: 兼容更多 FTP 服务器，更稳定
**缺点**: 需要足够内存（至少比镜像大 20%）

```yaml
enable_vsftpd: true
```

**工作原理**:
```bash
docker save nginx | gzip > /dev/shm/nginx.tar.gz
curl -T /dev/shm/nginx.tar.gz ftp://server/nginx.tar.gz
rm /dev/shm/nginx.tar.gz
```

## 压缩级别建议

| 级别 | 压缩率 | 速度 | 推荐场景 |
|------|--------|------|---------|
| 0 | 不压缩 | 最快 | 低带宽，镜像已压缩 |
| 1-3 | 低 | 快 | 快速传输，空间有限 |
| 6 | 中 | 中等 | **默认，平衡选择** |
| 9 | 高 | 慢 | 低带宽，节省流量 |

## 示例

### 示例 1: 上传 nginx 镜像

```
image_name: nginx:latest
ftp_port: 21
ftp_path: /docker-images/
compress_level: 6
enable_vsftpd: false
```

输出文件: `nginx_latest-20240117-153045.tar.gz`

### 示例 2: 上传私有镜像

1. 配置 `DOCKERHUB_TOKEN` Secret
2. 运行 workflow:
```
image_name: mycompany/private-app:v2.0
compress_level: 9
```

### 示例 3: 批量上传（多个 workflow）

可以同时运行多个 workflow 实例上传不同镜像：

```
实例 1: nginx:latest
实例 2: redis:alpine
实例 3: postgres:15
```

## 故障排除

### 错误 1: "curl: (25) FTP doesn't support stream upload"

**原因**: FTP 服务器不支持流式上传
**解决**: 启用 `enable_vsftpd: true`

### 错误 2: "No space left on device"

**原因**: 磁盘空间不足
**解决**:
- 检查可用空间至少 2GB
- 启用 `enable_vsftpd: true` 使用内存缓存
- 降低压缩级别减少临时缓存

### 错误 3: 上传速度慢

**解决**:
- 降低压缩级别（0-3）
- 检查网络连接
- 考虑使用 CDN 或分片上传

### 错误 4: 内存缓存模式失败

**原因**: `/dev/shm` 空间不足
**解决**:
- 检查镜像大小，确保 `/dev/shm` 有足够空间
- 使用直接管道模式
- 分批上传小镜像

## 安全建议

1. ✅ **使用 Secrets**: 永远不要在 workflow 中硬编码密码
2. ✅ **FTPS**: 如需加密，修改 URL 为 `ftps://`
3. ✅ **限制访问**: FTP 账号仅授予必要权限
4. ✅ **定期更换**: 定期更新 FTP 密码

## 性能优化

### GitHub Runner 限制

- **磁盘空间**: 约 14-20GB 可用
- **网络速度**: 约 100-500 Mbps
- **内存**: 7GB RAM，`/dev/shm` 约 3-5GB

### 推荐镜像大小

| 模式 | 最大镜像大小 |
|------|-------------|
| 直接管道 | 10GB（受限于拉取时间） |
| 内存缓存 | 3GB（受限于 /dev/shm） |

## 从 FTP 下载并使用镜像

```bash
# 1. 从 FTP 下载
wget ftp://server/docker-images/nginx_latest-20240117.tar.gz \
  --ftp-user=username \
  --ftp-password=password

# 2. 解压并加载
gunzip -c nginx_latest-20240117.tar.gz | docker load

# 3. 运行
docker run -it nginx:latest
```

## 进阶技巧

### 1. 定时自动上传

```yaml
on:
  schedule:
    - cron: '0 2 * * 0'  # 每周日凌晨 2 点
  workflow_dispatch:
```

### 2. 多 FTP 服务器

复制 workflow 文件，修改 `FTP_SERVER` 为不同值

### 3. 上传后验证

添加步骤验证文件大小：

```yaml
- name: Verify Upload
  run: |
    SIZE=$(curl -s "ftp://${{ secrets.FTP_SERVER }}/${OUTPUT_FILE}" \
      --user "${{ secrets.FTP_USERNAME }}:${{ secrets.FTP_PASSWORD }}" \
      --quote "SIZE ${OUTPUT_FILE}")
    echo "FTP 文件大小: ${SIZE} bytes"
```

## 相关文件

- `pull-docker-image.yml` - 保存到 GitHub Artifacts
- `pull-docker-image-multiarch.yml` - 多架构镜像支持
- `pull-docker-image-streaming-ftp.yml` - 本文件（流式 FTP 上传）
