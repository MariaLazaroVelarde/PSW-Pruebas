# ==============================================
# Dockerfile para Water Distribution Microservice
# Spring Boot 3.4.5 + Java 17 + MongoDB Reactive
# ==============================================

# Etapa 1: Build (Compilación)
FROM eclipse-temurin:17-jdk-alpine AS build

# Instalar Maven
RUN apk add --no-cache maven

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración Maven
COPY pom.xml .
COPY mvnw .
COPY mvnw.cmd .
# Comentamos la copia de .mvn porque no existe en tu proyecto
# COPY .mvn .mvn

# Descargar dependencias (se cachea esta capa)
RUN mvn dependency:go-offline -B

# Copiar código fuente
COPY src ./src

# Compilar y empaquetar la aplicación
RUN mvn clean package -DskipTests -B

# ==============================================
# Etapa 2: Runtime (Ejecución)
FROM eclipse-temurin:17-jre-alpine AS runtime

# Metadatos de la imagen
LABEL maintainer="vallegrande.edu.pe"
LABEL version="1.0.0"
LABEL description="Water Distribution Microservice - Reactive Spring Boot"

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser

# Crear directorio de la aplicación
WORKDIR /app

# Instalar herramientas útiles para debugging
RUN apk add --no-cache curl

# Copiar el JAR compilado desde la etapa de build
# Cambia "structure-microservice-1.0.0.jar" por el nombre real que genera tu build
COPY --from=build /app/target/structure-microservice-1.0.0.jar app.jar

# Cambiar ownership al usuario appuser
RUN chown -R appuser:appgroup /app

# Cambiar al usuario no-root
USER appuser

# Puerto que expone la aplicación
EXPOSE 8086

# Variables de entorno por defecto
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
ENV SPRING_PROFILES_ACTIVE=docker

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8086/actuator/health || exit 1

# Comando para ejecutar la aplicación
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
