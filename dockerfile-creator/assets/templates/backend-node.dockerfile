# Node.js (Express/Nest.js) 后端 Dockerfile
# 使用多阶段构建分离构建和运行环境

# =================== 阶段1：依赖安装 ===================
FROM node:18-alpine AS deps

WORKDIR /app

# 复制依赖文件
COPY package*.json ./

# 安装生产依赖
RUN npm ci --only=production && npm cache clean --force

# =================== 阶段2：构建 ===================
FROM node:18-alpine AS builder

WORKDIR /app

# 复制依赖
COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./

# 安装所有依赖（包括 devDependencies）用于构建
RUN npm ci

# 复制源代码并构建
COPY . .
RUN npm run build

# =================== 阶段3：运行 ===================
FROM node:18-alpine

# 创建非 root 用户
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

WORKDIR /app

# 复制生产依赖
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules

# 复制构建产物
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./

# 切换到非 root 用户
USER nodejs

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

# 启动应用
CMD ["node", "dist/main.js"]
