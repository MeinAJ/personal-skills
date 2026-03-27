# 常用基础镜像参考

## 前端/静态网站

| 镜像 | 大小 | 适用场景 |
|------|------|----------|
| `nginx:alpine` | ~23MB | 静态网站、SPA |
| `nginx:stable` | ~187MB | 需要完整功能的 Nginx |
| `caddy:alpine` | ~40MB | 现代化 Web 服务器 |
| `httpd:alpine` | ~60MB | Apache 场景 |

## Node.js 后端

| 镜像 | 大小 | 适用场景 |
|------|------|----------|
| `node:18-alpine` | ~176MB | 生产环境首选 |
| `node:18-slim` | ~240MB | 需要 glibc 时 |
| `node:18` | ~1GB | 包含完整构建工具 |

## Python

| 镜像 | 大小 | 适用场景 |
|------|------|----------|
| `python:3.11-alpine` | ~55MB | 极简部署 |
| `python:3.11-slim` | ~128MB | 生产环境推荐 |
| `python:3.11` | ~1GB | 需要编译 C 扩展 |

## Java

| 镜像 | 大小 | 适用场景 |
|------|------|----------|
| `eclipse-temurin:17-jre-alpine` | ~60MB | 运行 Java 应用 |
| `eclipse-temurin:17-jdk-alpine` | ~350MB | 构建 Java 应用 |
| `amazoncorretto:17-alpine` | ~340MB | AWS 环境 |
| `gcr.io/distroless/java17` | ~80MB | 超安全环境 |

## Go

| 镜像 | 大小 | 适用场景 |
|------|------|----------|
| `golang:1.21-alpine` | ~350MB | 构建 Go 应用 |
| `scratch` | 0MB | 静态编译后运行 |
| `alpine:latest` | ~7MB | 需要 shell 时 |
| `gcr.io/distroless/static` | ~20MB | 安全运行环境 |

## 数据库/缓存

| 镜像 | 大小 | 用途 |
|------|------|------|
| `postgres:15-alpine` | ~250MB | PostgreSQL |
| `mysql:8.0` | ~600MB | MySQL |
| `redis:7-alpine` | ~30MB | Redis |
| `mongo:6.0` | ~700MB | MongoDB |

## 选择建议

### 生产环境优先选择
1. Alpine 版本 - 最小体积
2. Slim 版本 - Debian 基础，兼容性更好
3. Distroless - 最高安全性

### 开发/构建环境
1. 完整版本 - 包含所有工具
2. 特定语言官方镜像

### 安全考虑
- 使用非 root 用户运行
- 定期更新基础镜像
- 扫描镜像漏洞
