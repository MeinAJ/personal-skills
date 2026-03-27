# React/Vue/Angular 前端应用 Dockerfile
# 使用多阶段构建，最终使用 Nginx 提供静态文件

# =================== 阶段1：构建 ===================
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制依赖文件（利用缓存）
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# =================== 阶段2：运行 ===================
FROM nginx:alpine

# 复制构建产物到 Nginx 目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 可选：复制自定义 Nginx 配置
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
