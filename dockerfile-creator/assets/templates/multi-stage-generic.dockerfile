# 通用多阶段构建 Dockerfile 模板
# 根据实际项目类型修改以下阶段

# =================== 阶段1：基础依赖 ===================
FROM base-image:tag AS deps

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖清单文件
COPY package*.json requirements.txt go.mod pom.xml* ./

# 安装项目依赖
RUN install-dependencies-command

# =================== 阶段2：构建 ===================
FROM base-image:tag AS builder

WORKDIR /app

# 从 deps 阶段复制依赖
COPY --from=deps /app/node_modules ./node_modules
# 或 COPY --from=deps /opt/venv /opt/venv

# 复制源代码
COPY . .

# 执行构建
RUN build-command

# =================== 阶段3：测试（可选）===================
FROM builder AS tester

# 运行测试
RUN test-command

# =================== 阶段4：运行（最终镜像）===================
FROM minimal-base-image:tag

# 创建非 root 用户
RUN adduser --disabled-password --gecos '' appuser

WORKDIR /app

# 只复制运行所需的文件
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# 设置权限
RUN chown -R appuser:appuser /app

# 切换到非 root 用户
USER appuser

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD health-check-command

# 启动应用
CMD ["start-command"]
