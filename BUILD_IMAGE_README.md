# 🐳 Cómo Construir la Imagen Docker
## vg-ms-distribution

Este README explica paso a paso cómo construir y desplegar la imagen Docker del microservicio de distribución de agua.

---

## 📋 Requisitos Previos

### Herramientas Necesarias
- ✅ **Docker Desktop** (v20.10+)
- ✅ **Java 17** (JDK)
- ✅ **Maven 3.6+** (o usar el wrapper incluido)
- ✅ **Git** (para clonar el repositorio)

### Verificar Instalación
```bash
# Verificar Docker
docker --version
docker info

# Verificar Java
java --version

# Verificar Maven
mvn --version
```

---

## 🚀 Construcción Manual Paso a Paso

### 1. Preparar el Proyecto
```bash
# Clonar o navegar al directorio del proyecto
cd c:\Users\victo\OneDrive\Desktop\TestDistribution

# Verificar que tenemos los archivos necesarios
ls Dockerfile
ls pom.xml
ls src/
```

### 2. Compilar la Aplicación Java
```bash
# Usar Maven Wrapper (recomendado)
.\mvnw.cmd clean package -DskipTests

# O usar Maven directamente
mvn clean package -DskipTests
```

**🎯 Resultado esperado:**
- Se crea `target/structure-microservice-1.0.0.jar`
- No errores de compilación

### 3. Construir la Imagen Docker
```bash
# Construir imagen con tag latest
docker build -t victorcuaresmadev/vg-ms-distribution:latest .

# Construir con tag específico (opcional)
docker build -t victorcuaresmadev/vg-ms-distribution:v1.0.0 .
```

**🎯 Resultado esperado:**
```
Successfully built [IMAGE_ID]
Successfully tagged victorcuaresmadev/vg-ms-distribution:latest
```

### 4. Verificar la Imagen
```bash
# Listar imágenes
docker images victorcuaresmadev/vg-ms-distribution

# Ver detalles de la imagen
docker inspect victorcuaresmadev/vg-ms-distribution:latest
```

---

## 🧪 Probar la Imagen Localmente

### 1. Ejecutar Contenedor de Prueba
```bash
# Ejecutar con variables de entorno básicas
docker run -d --name test-vg-ms-distribution \
  -p 8086:8086 \
  -e SPRING_PROFILES_ACTIVE=docker \
  -e MONGO_USERNAME=test \
  -e MONGO_PASSWORD=test123 \
  -e MONGO_DATABASE=test_db \
  victorcuaresmadev/vg-ms-distribution:latest
```

### 2. Verificar que Funciona
```bash
# Ver logs
docker logs test-vg-ms-distribution

# Probar health check
curl http://localhost:8086/actuator/health

# Probar Swagger UI
# Abrir: http://localhost:8086/swagger-ui.html
```

### 3. Limpiar Prueba
```bash
# Detener y eliminar contenedor de prueba
docker stop test-vg-ms-distribution
docker rm test-vg-ms-distribution
```

---

## 📤 Subir a Docker Hub

### 1. Login a Docker Hub
```bash
# Hacer login (te pedirá usuario y password)
docker login
```

### 2. Subir Imagen
```bash
# Subir imagen latest
docker push victorcuaresmadev/vg-ms-distribution:latest

# Subir imagen con versión específica (si existe)
docker push victorcuaresmadev/vg-ms-distribution:v1.0.0
```

**🎯 URL final:** https://hub.docker.com/r/victorcuaresmadev/vg-ms-distribution

---

## 🤖 Construcción Automática

### Opción 1: Script PowerShell (Windows)
```powershell
# Ejecutar script automático
.\deploy-docker-hub.ps1

# Con parámetros personalizados
.\deploy-docker-hub.ps1 -DockerUsername "victorcuaresmadev" -ImageName "vg-ms-distribution"
```

### Opción 2: Script Bash (Linux/Mac)
```bash
# Dar permisos de ejecución
chmod +x deploy-docker-hub.sh

# Ejecutar script
./deploy-docker-hub.sh
```

---

## 🔧 Configuraciones Avanzadas

### Multi-tag Build
```bash
# Crear múltiples tags
docker build -t victorcuaresmadev/vg-ms-distribution:latest \
             -t victorcuaresmadev/vg-ms-distribution:v1.0.0 \
             -t victorcuaresmadev/vg-ms-distribution:stable .

# Subir todos los tags
docker push victorcuaresmadev/vg-ms-distribution --all-tags
```

### Build con Argumentos
```bash
# Construir con argumentos personalizados
docker build --build-arg JAVA_OPTS="-Xmx1g" \
             --build-arg APP_VERSION="1.0.0" \
             -t victorcuaresmadev/vg-ms-distribution:latest .
```

### Build Para Diferentes Arquitecturas
```bash
# Build multi-arquitectura (x86_64 + ARM64)
docker buildx build --platform linux/amd64,linux/arm64 \
  -t victorcuaresmadev/vg-ms-distribution:latest \
  --push .
```

---

## 📊 Información de la Imagen

### Características
- **Base**: `eclipse-temurin:17-jre-alpine`
- **Tamaño**: ~200-300 MB
- **Puerto**: `8086`
- **Usuario**: `appuser` (no-root)
- **Health Check**: `/actuator/health`

### Estructura de Capas
```
🗂️ Multi-stage Build:
├── 📦 Stage 1: Build (eclipse-temurin:17-jdk-alpine)
│   ├── Maven dependencies
│   ├── Source code compilation
│   └── JAR packaging
└── 📦 Stage 2: Runtime (eclipse-temurin:17-jre-alpine)
    ├── JRE optimizado
    ├── Usuario no-root
    ├── Health checks
    └── JAR ejecutable
```

### Variables de Entorno Importantes
```bash
JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"
SPRING_PROFILES_ACTIVE=docker
SERVER_PORT=8086
```

---

## 🛠️ Troubleshooting

### Error: "No space left on device"
```bash
# Limpiar imágenes no utilizadas
docker system prune -a

# Limpiar todo (cuidado!)
docker system prune -a --volumes
```

### Error: "Permission denied"
```bash
# En Linux/Mac, usar sudo
sudo docker build -t victorcuaresmadev/vg-ms-distribution:latest .

# O agregar usuario al grupo docker
sudo usermod -aG docker $USER
```

### Error de compilación Maven
```bash
# Limpiar target y volver a compilar
rm -rf target/
mvn clean compile package -DskipTests
```

### Error de conexión a Docker Hub
```bash
# Verificar login
docker login

# Verificar conectividad
ping hub.docker.com
```

---

## 📚 Comandos de Referencia Rápida

```bash
# 🔨 BUILD
docker build -t victorcuaresmadev/vg-ms-distribution:latest .

# 🚀 RUN
docker run -p 8086:8086 victorcuaresmadev/vg-ms-distribution:latest

# 📤 PUSH
docker push victorcuaresmadev/vg-ms-distribution:latest

# 📥 PULL
docker pull victorcuaresmadev/vg-ms-distribution:latest

# 🔍 INSPECT
docker images victorcuaresmadev/vg-ms-distribution
docker inspect victorcuaresmadev/vg-ms-distribution:latest

# 🧹 CLEAN
docker rmi victorcuaresmadev/vg-ms-distribution:latest
docker system prune -f
```

---

## ✅ Checklist Final

Antes de considerarlo completo, verificar:

- [ ] ✅ Imagen construida sin errores
- [ ] ✅ JAR incluido en la imagen (target/structure-microservice-1.0.0.jar)
- [ ] ✅ Health check responde en `/actuator/health`
- [ ] ✅ Swagger UI accesible en `/swagger-ui.html`
- [ ] ✅ Imagen subida a Docker Hub
- [ ] ✅ Tag `latest` disponible públicamente
- [ ] ✅ Documentación actualizada

---

**🎯 ¡Imagen lista para producción!** 🚀

**Docker Hub URL:** https://hub.docker.com/r/victorcuaresmadev/vg-ms-distribution