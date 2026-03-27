# Go 后端 Dockerfile
# 使用多阶段构建，编译后在最小镜像中运行

# =================== 阶段1：构建 ===================
FROM golang:1.21-alpine AS builder

# 安装 git 和 ca-certificates（用于 HTTPS）
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# 复制依赖文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 静态编译（禁用 CGO，静态链接）
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main .

# =================== 阶段2：运行 ===================
FROM scratch

# 从 builder 复制 CA 证书（用于 HTTPS 请求）
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

WORKDIR /app

# 复制编译好的二进制文件
COPY --from=builder /app/main .

# 暴露端口
EXPOSE 8080

# 非 root 用户（scratch 中需要指定 UID）
USER 65534:65534

# 启动应用
ENTRYPOINT ["./main"]
