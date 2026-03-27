# Dockerfile 最佳实践

## 基本原则

### 1. 使用合适的基础镜像
- 优先使用官方镜像
- 选择精简版本（alpine/slim）减少攻击面和体积
- 固定镜像标签，避免使用 `latest`

### 2. 减少镜像层数
- 合并 RUN 指令，使用 `&&` 连接命令
- 但保持可读性，不要为了合并而合并

### 3. 优化构建缓存
- 将不常变动的指令放在前面
- 将经常变动的指令放在后面
- `.dockerignore` 排除不需要的文件

### 4. 安全性
- 使用非 root 用户运行应用
- 最小权限原则
- 扫描镜像漏洞

### 5. 镜像大小优化
- 多阶段构建分离构建和运行环境
- 清理临时文件和缓存
- 只复制必要的文件到最终镜像

## 语言特定建议

### Python
- 使用 `python:3.x-slim` 或 `python:3.x-alpine`
- 使用虚拟环境避免与系统包冲突
- 先复制 requirements.txt 再安装依赖（利用缓存）

### Node.js
- 使用 `node:18-alpine` 或 `node:18-slim`
- 区分 dependencies 和 devDependencies
- 使用 `npm ci` 替代 `npm install`（CI/CD 环境）

### Java
- 使用多阶段构建，JDK 构建 JRE 运行
- 考虑使用 Distroless 镜像
- Spring Boot 可以使用分层构建

### Go
- 使用多阶段构建，编译后在 scratch/alpine 运行
- 静态编译 `CGO_ENABLED=0`
- 单二进制文件非常适合 scratch 镜像
