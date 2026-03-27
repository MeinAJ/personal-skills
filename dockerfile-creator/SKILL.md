---
name: dockerfile-creator
description: 智能生成 Dockerfile 的技能，支持前端（React/Vue/Angular）、后端（Python/Node.js/Java/Go）以及多阶段构建。用于根据项目类型生成优化的 Dockerfile，提供最佳实践建议和模板。使用场景包括：(1) 为新项目创建 Dockerfile，(2) 为现有项目优化 Dockerfile，(3) 学习 Dockerfile 最佳实践，(4) 多服务项目的 Docker 配置。
---

# Dockerfile Creator

智能生成 Dockerfile 的技能，支持前后端各种技术栈，包含多阶段构建和最佳实践。

## 功能特性

- **智能项目检测** - 自动识别项目类型和框架
- **多阶段构建** - 生成优化的小体积镜像
- **最佳实践** - 内置安全性和性能建议
- **多语言支持** - Python、Node.js、Java、Go、前端框架

## 快速使用

### 1. 分析项目并生成 Dockerfile

```bash
# 分析当前目录项目类型
python ~/.agents/skills/dockerfile-creator/scripts/analyze_project.py .

# 验证生成的 Dockerfile
python ~/.agents/skills/dockerfile-creator/scripts/validate_dockerfile.py Dockerfile
```

### 2. 选择合适的模板

根据项目类型选择模板：

| 项目类型 | 模板文件 | 路径 |
|---------|---------|------|
| 前端 (React/Vue/Angular) | frontend-react.dockerfile | assets/templates/ |
| Python (Flask/FastAPI/Django) | backend-python.dockerfile | assets/templates/ |
| Node.js (Express/Nest.js) | backend-node.dockerfile | assets/templates/ |
| Java (Spring Boot) | backend-java.dockerfile | assets/templates/ |
| Go | backend-go.dockerfile | assets/templates/ |
| 通用多阶段 | multi-stage-generic.dockerfile | assets/templates/ |

### 3. 使用模板

复制对应模板到项目目录，根据项目实际情况修改：

```bash
# 示例：为 React 项目创建 Dockerfile
cp ~/.agents/skills/dockerfile-creator/assets/templates/frontend-react.dockerfile ./Dockerfile

# 根据项目调整端口、构建命令等
```

## 参考资料

- **最佳实践指南**: 参见 [references/best-practices.md](references/best-practices.md)
- **多阶段构建详解**: 参见 [references/multi-stage-build.md](references/multi-stage-build.md)
- **基础镜像选择**: 参见 [references/base-images.md](references/base-images.md)

## 模板使用说明

### 前端项目模板

适用于 React、Vue、Angular 等前端框架：
- 阶段1：Node.js 构建静态文件
- 阶段2：Nginx 提供服务
- 自动配置多阶段构建

需要修改的地方：
- 构建命令（`npm run build`）
- 输出目录（`dist` 或 `build`）
- 端口（Nginx 默认 80）

### Python 后端模板

适用于 Flask、FastAPI、Django：
- 使用虚拟环境隔离依赖
- 非 root 用户运行
- 支持多阶段构建

需要修改的地方：
- 启动命令（根据框架选择）
- 端口号
- 应用入口文件

### Node.js 后端模板

适用于 Express、Nest.js 等：
- 分离 deps 和 builder 阶段
- 只复制生产依赖到最终镜像
- 内置健康检查

需要修改的地方：
- 构建命令
- 启动文件路径
- 健康检查端点

### Java 模板

适用于 Spring Boot：
- Maven 多阶段构建
- JDK 编译，JRE 运行
- 分层解压优化

### Go 模板

- 静态编译
- 最终在 scratch 镜像运行
- 超小体积（通常 < 20MB）

## 最佳实践清单

生成 Dockerfile 后，请检查：

- [ ] 使用具体版本标签，避免 `latest`
- [ ] 使用非 root 用户运行应用
- [ ] 添加 `.dockerignore` 文件
- [ ] 充分利用构建缓存（先复制依赖文件）
- [ ] 多阶段构建分离构建和运行环境
- [ ] 清理临时文件和缓存
- [ ] 添加 HEALTHCHECK 指令
- [ ] 使用 EXPOSE 声明端口
- [ ] 固定基础镜像版本

## 示例：完整工作流

### 为 React + Python 全栈项目生成 Dockerfile

1. **前端 Dockerfile**:
```dockerfile
# 复制模板并修改
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build  # React 默认构建命令

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html  # React 输出到 build 目录
EXPOSE 80
```

2. **后端 Dockerfile**:
```dockerfile
# 复制 Python 模板，修改启动命令
# FastAPI 示例：
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

3. **docker-compose.yml** (可选):
```yaml
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "80:80"
  backend:
    build: ./backend
    ports:
      - "8000:8000"
```

## 故障排除

### 镜像体积过大
- 检查是否使用了多阶段构建
- 选择 alpine/slim 基础镜像
- 清理构建缓存和临时文件

### 构建缓存未命中
- 确保依赖文件（package.json, requirements.txt）先于源代码复制
- 检查 `.dockerignore` 是否包含不必要的文件

### 权限问题
- 确保正确设置了 USER 指令
- 检查文件复制时的权限（使用 `--chown`）
