# 多阶段构建指南

## 什么是多阶段构建

多阶段构建允许在单个 Dockerfile 中使用多个 FROM 指令。每个 FROM 指令开始一个新的构建阶段，可以选择性地命名。最终镜像只包含最后一个阶段的文件。

## 核心优势

1. **减小镜像体积** - 只保留运行时需要的文件
2. **分离构建和运行环境** - 构建工具不进入最终镜像
3. **提高安全性** - 减少攻击面
4. **保持构建一致性** - 构建环境标准化

## 典型模式

### 模式1：构建-运行分离
```dockerfile
# 阶段1：构建
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# 阶段2：运行
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json .
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### 模式2：使用不同基础镜像
```dockerfile
# 阶段1：使用完整 JDK 编译
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests

# 阶段2：使用 JRE 运行
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 模式3：静态编译到 Scratch
```dockerfile
# 阶段1：编译
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# 阶段2：最小镜像
FROM scratch
WORKDIR /app
COPY --from=builder /app/main .
EXPOSE 8080
ENTRYPOINT ["./main"]
```

## 关键指令

### FROM ... AS <name>
命名阶段，便于后续引用

### COPY --from=<name>
从前一个阶段复制文件

### 使用外部镜像作为阶段
```dockerfile
COPY --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
```

## 最佳实践

1. **合理命名阶段** - 使用描述性名称（builder、test、production）
2. **仅在需要时复制** - 只复制运行所需的文件
3. **考虑缓存** - 合理利用构建缓存加速
4. **测试阶段** - 可以添加专门的 test 阶段
