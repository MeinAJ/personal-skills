# Python (Flask/FastAPI/Django) 后端 Dockerfile
# 使用多阶段构建优化镜像大小

# =================== 阶段1：依赖 ===================
FROM python:3.11-slim AS requirements

WORKDIR /app

# 安装编译依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装依赖到虚拟环境
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# =================== 阶段2：运行 ===================
FROM python:3.11-slim

# 创建非 root 用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# 从阶段1复制虚拟环境
COPY --from=requirements /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 复制应用代码
COPY . .

# 设置权限
RUN chown -R appuser:appuser /app

# 切换到非 root 用户
USER appuser

# 暴露端口（根据框架调整）
# Flask 默认 5000，FastAPI/Uvicorn 默认 8000，Django 默认 8000
EXPOSE 8000

# 启动命令（根据框架选择）
# FastAPI: CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
# Flask: CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
# Django: CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
