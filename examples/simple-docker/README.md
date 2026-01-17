# 简单 Web 应用示例

这是一个示例项目，展示如何使用 GitHub Actions 从 Dockerfile 构建镜像并导出为 TAR 包。

## 📁 文件说明

- `Dockerfile` - Docker 镜像构建文件
- `index.html` - 静态网页内容
- `README.md` - 本说明文件

## 🚀 使用 GitHub Actions 构建

### 步骤 1：将此示例添加到你的仓库

1. 复制 `simple-docker` 文件夹到你的仓库根目录
2. 确保 `Dockerfile` 和 `index.html` 都在仓库中

### 步骤 2：运行工作流

1. 进入 GitHub 仓库的 **Actions** 标签页
2. 选择 **Build Dockerfile and Save as TAR** 工作流
3. 点击 **Run workflow**
4. 填写以下参数：
   - **Dockerfile 路径**: `examples/simple-docker/Dockerfile`
   - **镜像名称**: `pytorch:2.9.0-cuda12.6-cudnn9-devel`
   - **构建上下文**: `./`
   - **是否上传到 GitHub Release**: ✅ 勾选
5. 点击 **Run workflow** 开始构建

### 步骤 3：下载构建好的镜像

1. 等待工作流完成（通常需要 1-3 分钟）
2. 进入仓库的 **Releases** 区域
3. 找到最新生成的 Release
4. 下载 `docker-image-example-webapp_v1.0.tar` 文件

## 📦 本地使用

### 加载镜像

```bash
docker load -i docker-image-example-webapp_v1.0.tar
```

### 运行容器

```bash
docker run -d -p 8080:80 --name my-webapp example-webapp:v1.0
```

### 访问网站

在浏览器中打开：http://localhost:8080

### 停止容器

```bash
docker stop my-webapp
docker rm my-webapp
```

## 🔧 自定义

### 修改网页内容

编辑 `index.html` 文件，添加你自己的内容和样式。

### 修改 Dockerfile

你可以基于这个 Dockerfile 进行修改：

```dockerfile
FROM nginx:alpine

# 复制你的文件
COPY index.html /usr/share/nginx/html/

# 添加更多文件
COPY static/ /usr/share/nginx/html/static/

# 暴露端口
EXPOSE 80

# 启动命令
CMD ["nginx", "-g", "daemon off;"]
```

### 添加构建参数

如果你想支持构建参数，可以在 Dockerfile 中使用 ARG：

```dockerfile
ARG VERSION=1.0
ENV APP_VERSION=$VERSION
```

## 📝 Dockerfile 说明

```dockerfile
# 使用轻量级的 Nginx Alpine 镜像作为基础
FROM nginx:alpine

# 复制自定义 HTML 文件到 Nginx 默认目录
COPY index.html /usr/share/nginx/html/

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx（alpine 镜像默认会自动启动）
CMD ["nginx", "-g", "daemon off;"]
```

## 💡 提示

- 这个示例使用 `nginx:alpine` 基础镜像，体积小（约 40MB）
- 适合快速测试和学习 Docker
- 可以作为模板开发你自己的应用
- 支持完全离线环境部署

## 🎯 其他示例

你可以基于这个示例创建：
- Python Web 应用
- Node.js 应用
- 静态网站生成器
- API 服务器
- 微服务

只需要修改 Dockerfile 和添加相应的代码文件即可。
