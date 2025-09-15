#!/bin/bash
# ==============================================
# Script de Despliegue a Docker Hub
# Water Distribution Microservice
# ==============================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
DOCKER_USERNAME="victorcuaresmadev"
IMAGE_NAME="vg-ms-distribution"
TAG="latest"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME:$TAG"

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}🚀 Despliegue a Docker Hub${NC}"
echo -e "${BLUE}Proyecto: Water Distribution Microservice${NC}"
echo -e "${BLUE}===============================================${NC}"

# Función para manejar errores
handle_error() {
    echo -e "${RED}❌ Error en la línea $1${NC}"
    exit 1
}

trap 'handle_error $LINENO' ERR

# 1. Verificar que Docker esté funcionando
echo -e "${YELLOW}🔍 Verificando Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker no está funcionando${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker funcionando correctamente${NC}"

# 2. Login a Docker Hub
echo -e "${YELLOW}🔐 Login a Docker Hub...${NC}"
echo "Ingresa tus credenciales de Docker Hub:"
docker login

# 3. Limpiar builds anteriores
echo -e "${YELLOW}🧹 Limpiando builds anteriores...${NC}"
docker system prune -f || true

# 4. Compilar la aplicación con Maven
echo -e "${YELLOW}🔨 Compilando aplicación Java...${NC}"
if command -v mvnw.cmd &> /dev/null; then
    ./mvnw.cmd clean package -DskipTests
elif command -v mvn &> /dev/null; then
    mvn clean package -DskipTests
else
    echo -e "${RED}❌ Maven no encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Aplicación compilada${NC}"

# 5. Construir imagen Docker
echo -e "${YELLOW}🐳 Construyendo imagen Docker...${NC}"
docker build -t $FULL_IMAGE_NAME .
echo -e "${GREEN}✅ Imagen construida: $FULL_IMAGE_NAME${NC}"

# 6. Crear tag adicional con fecha
DATE_TAG=$(date +%Y%m%d-%H%M%S)
DATED_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME:$DATE_TAG"
docker tag $FULL_IMAGE_NAME $DATED_IMAGE_NAME
echo -e "${GREEN}✅ Tag creado: $DATED_IMAGE_NAME${NC}"

# 7. Subir a Docker Hub
echo -e "${YELLOW}📤 Subiendo a Docker Hub...${NC}"
docker push $FULL_IMAGE_NAME
docker push $DATED_IMAGE_NAME
echo -e "${GREEN}✅ Imagen subida exitosamente${NC}"

# 8. Mostrar información de la imagen
echo -e "${BLUE}===============================================${NC}"
echo -e "${GREEN}🎉 ¡Despliegue completado exitosamente!${NC}"
echo -e "${BLUE}===============================================${NC}"
echo -e "${YELLOW}📋 Información de la imagen:${NC}"
echo -e "   🏷️  Imagen principal: ${FULL_IMAGE_NAME}"
echo -e "   📅 Imagen con fecha: ${DATED_IMAGE_NAME}"
echo -e "   🌐 Docker Hub: https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"
echo ""
echo -e "${YELLOW}🚀 Para usar en producción:${NC}"
echo -e "   docker pull ${FULL_IMAGE_NAME}"
echo -e "   docker-compose -f docker-compose.prod.yml up -d"
echo ""
echo -e "${YELLOW}🔗 Endpoints disponibles:${NC}"
echo -e "   📊 Health Check: https://lab.vallegrande.edu.pe:8086/actuator/health"
echo -e "   📚 Swagger UI: https://lab.vallegrande.edu.pe:8086/swagger-ui.html"
echo -e "   📈 Metrics: https://lab.vallegrande.edu.pe:8086/actuator/prometheus"
echo -e "${BLUE}===============================================${NC}"

# 9. Limpiar imágenes locales (opcional)
read -p "¿Deseas limpiar las imágenes locales? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🧹 Limpiando imágenes locales...${NC}"
    docker rmi $FULL_IMAGE_NAME || true
    docker rmi $DATED_IMAGE_NAME || true
    echo -e "${GREEN}✅ Limpieza completada${NC}"
fi

echo -e "${GREEN}🎊 ¡Proceso completado!${NC}"