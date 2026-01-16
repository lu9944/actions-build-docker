FROM nginx:alpine

# 复制自定义 HTML 文件到 Nginx 默认目录
COPY index.html /usr/share/nginx/html/

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx（alpine 镜像默认会自动启动）
CMD ["nginx", "-g", "daemon off;"]
