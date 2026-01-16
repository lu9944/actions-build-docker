# 阿里云 OSS 上传工作流使用说明

## 功能概述

这个工作流会：
1. 从你的 Dockerfile 构建 Docker 镜像
2. 将镜像保存为 TAR 文件
3. 自动上传到阿里云 OSS
4. （可选）同时创建 GitHub Release

## 前置准备

### 1. 获取阿里云 OSS 访问密钥

1. 登录 [阿里云控制台](https://oss.console.aliyun.com/)
2. 创建 AccessKey：
   - 进入「访问控制」->「用户」
   - 创建新用户或使用现有用户
   - 为用户添加 `AliyunOSSFullAccess` 权限
   - 创建 AccessKey 并保存 `AccessKey ID` 和 `AccessKey Secret`

### 2. 创建 OSS Bucket

1. 在 OSS 控制台创建 Bucket
2. 记录：
   - Bucket 名称（例如：`my-docker-images`）
   - Endpoint（例如：`oss-cn-hangzhou.aliyuncs.com`）

### 3. 配置 GitHub Secrets

在你的 GitHub 仓库中添加以下 Secrets：

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `ALIYUN_OSS_ACCESS_KEY_ID` | 阿里云 AccessKey ID | `LTAI5t...` |
| `ALIYUN_OSS_ACCESS_KEY_SECRET` | 阿里云 AccessKey Secret | `xxxxx...` |
| `DOCKERHUB_TOKEN` | Docker Hub Token（可选，用于拉取基础镜像） | `dckr_pat_...` |

添加步骤：
```
仓库 Settings -> Secrets and variables -> Actions -> New repository secret
```

## 使用方法

### 手动触发工作流

1. 进入 GitHub 仓库的「Actions」标签
2. 选择 `Build Dockerfile and Upload to Aliyun OSS` 工作流
3. 点击 `Run workflow`
4. 填写参数：

| 参数 | 说明 | 示例值 | 必填 |
|------|------|--------|------|
| `dockerfile_path` | Dockerfile 文件路径 | `Dockerfile` | ✅ |
| `image_name` | 构建的镜像名称 | `myapp:v1.0` | ✅ |
| `build_context` | 构建上下文路径 | `.` | ❌ |
| `oss_endpoint` | OSS 服务地址 | `oss-cn-hangzhou.aliyuncs.com` | ✅ |
| `oss_bucket` | OSS Bucket 名称 | `my-docker-images` | ✅ |
| `oss_path` | OSS 存储路径 | `docker-images/` | ❌ |
| `enable_release` | 是否创建 GitHub Release | `true`/`false` | ❌ |
| `retention_days` | 文件保留天数（0=永久） | `0` | ❌ |

## 示例场景

### 示例 1：简单镜像构建

假设你有一个简单的 Node.js 应用：

**仓库结构：**
```
my-app/
├── Dockerfile
├── package.json
└── src/
```

**工作流参数：**
- `dockerfile_path`: `Dockerfile`
- `image_name`: `my-nodejs-app:latest`
- `build_context`: `.`
- `oss_endpoint`: `oss-cn-hangzhou.aliyuncs.com`
- `oss_bucket`: `my-docker-images`
- `oss_path`: `nodejs-apps/`

### 示例 2：多服务项目

**仓库结构：**
```
microservices/
├── services/
│   ├── api/
│   │   └── Dockerfile
│   └── worker/
│       └── Dockerfile
```

**构建 API 服务：**
- `dockerfile_path`: `services/api/Dockerfile`
- `image_name`: `my-api:v1.0`
- `build_context`: `services/api`

**构建 Worker 服务：**
- `dockerfile_path`: `services/worker/Dockerfile`
- `image_name`: `my-worker:v1.0`
- `build_context`: `services/worker`

### 示例 3：定时清理（设置生命周期）

如果你希望 OSS 上的文件自动过期，可以：

1. 在 OSS 控制台设置生命周期规则
2. 或在工作流中设置 `retention_days` 参数

**参数设置：**
- `retention_days`: `30`（30天后自动删除）

## 从 OSS 下载镜像

### 方法 1：使用 ossutil 命令行工具

```bash
# 安装 ossutil
wget https://gosspublic.alicdn.com/ossutil/1.7.16/ossutil64
chmod +x ossutil64
sudo mv ossutil64 /usr/local/bin/ossutil

# 配置 ossutil
ossutil config -e oss-cn-hangzhou.aliyuncs.com \
  -i YOUR_ACCESS_KEY_ID \
  -k YOUR_ACCESS_KEY_SECRET

# 下载镜像
ossutil cp oss://my-bucket/docker-images/myapp_latest.tar ./

# 加载镜像
docker load -i myapp_latest.tar

# 运行镜像
docker run -it myapp:latest
```

### 方法 2：直接下载（如果 Bucket 设置了公共读）

```bash
# 下载
wget https://my-bucket.oss-cn-hangzhou.aliyuncs.com/docker-images/myapp_latest.tar

# 加载并运行
docker load -i myapp_latest.tar
docker run -it myapp:latest
```

### 方法 3：使用浏览器登录 OSS 控制台下载

1. 登录阿里云 OSS 控制台
2. 进入对应的 Bucket
3. 找到文件并点击下载

## 常见问题

### Q1: 上传失败，提示权限不足

**解决方案：**
- 检查 AccessKey 是否有 OSS 操作权限
- 确保 Bucket 策略允许该用户写入

### Q2: 找不到 Dockerfile 文件

**解决方案：**
- 检查 `dockerfile_path` 参数是否正确
- 确保路径相对于仓库根目录
- 例如：`./docker/Dockerfile`

### Q3: 构建失败，提示基础镜像拉取失败

**解决方案：**
- 配置 `DOCKERHUB_TOKEN` Secret（推荐）
- 或在 Dockerfile 中使用公开的基础镜像

### Q4: 如何设置 Bucket 为公共读

**解决方案：**
1. 进入 OSS 控制台
2. 选择 Bucket -> 权限控制 -> 读写权限
3. 设置为「公共读」

⚠️ **注意**：公共读允许任何人访问文件，请确保不包含敏感信息！

### Q5: 文件很大，上传很慢怎么办

**解决方案：**
- 工作流会自动压缩 TAR 文件
- 可以使用 `docker-slim` 等工具优化镜像大小
- 选择离你最近的 OSS 区域

## 进阶配置

### 1. 设置生命周期规则

在 OSS 控制台设置自动删除旧文件：

```
基础设置 -> 生命周期 -> 创建规则
- 前缀：docker-images/
- 过期时间：30天
```

### 2. 启用 CDN 加速

1. 在 OSS 控制台启用 CDN
2. 配置 CDN 域名
3. 使用 CDN 域名下载文件

### 3. 自动化工作流

可以使用 GitHub API 自动触发：

```bash
curl -X POST \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/OWNER/REPO/actions/workflows/build-dockerfile-oss.yml/dispatches \
  -d '{"ref":"main","inputs":{"dockerfile_path":"Dockerfile","image_name":"myapp:latest","oss_endpoint":"oss-cn-hangzhou.aliyuncs.com","oss_bucket":"my-bucket"}}'
```

## 成本估算

阿里云 OSS 定价（以华东区域为例）：

| 项目 | 价格 | 说明 |
|------|------|------|
| 存储费用 | ¥0.12/GB/月 | 按实际存储量计费 |
| 外网流出流量 | ¥0.50/GB | 下载流量费用 |
| 请求次数 | ¥0.01/万次 | PUT/GET 请求 |

**示例**：存储 10 个 1GB 的镜像
- 存储费用：10GB × ¥0.12 = ¥1.2/月
- 假设每月下载 50 次：50GB × ¥0.50 = ¥25/月

## 安全建议

1. **使用 RAM 子账号**：不要使用主账号的 AccessKey
2. **设置最小权限**：只授予必要的 OSS 权限
3. **定期轮换密钥**：定期更换 AccessKey
4. **启用日志审计**：开启 OSS 访问日志
5. **敏感信息**：不要在镜像中包含密码、密钥等敏感信息

## 相关链接

- [阿里云 OSS 文档](https://help.aliyun.com/product/31815.html)
- [ossutil 工具文档](https://help.aliyun.com/document_detail/120075.html)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
