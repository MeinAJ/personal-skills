# Java Spring Boot Dockerfile
# 使用多阶段构建，JDK 编译 JRE 运行

# =================== 阶段1：构建 ===================
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

# 复制 Maven/Gradle 文件
COPY pom.xml mvnw ./
COPY .mvn .mvn

# 下载依赖（利用缓存）
RUN ./mvnw dependency:go-offline -B

# 复制源代码
COPY src src

# 构建应用
RUN ./mvnw clean package -DskipTests && \
    mkdir -p target/dependency && \
    (cd target/dependency; jar -xf ../*.jar)

# =================== 阶段2：运行 ===================
FROM eclipse-temurin:17-jre-alpine

# 创建非 root 用户
RUN addgroup -S spring && adduser -S spring -G spring

WORKDIR /app

# 从阶段1复制构建产物
ARG DEPENDENCY=/app/target/dependency
COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app

# 设置权限
RUN chown -R spring:spring /app

# 切换到非 root 用户
USER spring

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# 启动应用
ENTRYPOINT ["java", "-cp", "app:app/lib/*", "com.example.Application"]
