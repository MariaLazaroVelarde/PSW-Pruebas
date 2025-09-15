# 🐳 Docker Deployment - Water Distribution Microservice

## 📋 Resumen

Este proyecto está listo para desplegarse en **Docker Hub** con la configuración optimizada para **lab.vallegrande.edu.pe**.

## 🚀 Despliegue Rápido

### Usando imagen desde Docker Hub
```bash
# Descargar y ejecutar desde Docker Hub
docker pull victorcuaresmadev/vg-ms-distribution:latest
docker-compose -f docker-compose.prod.yml up -d
```

### Build local y subida a Docker Hub
```bash
# Windows (PowerShell)
.\deploy-docker-hub.ps1

# Linux/Mac
chmod +x deploy-docker-hub.sh
./deploy-docker-hub.sh
```

## 🔧 Configuración

### Variables de Entorno Requeridas

Copia `.env.example` a `.env` y configura:

```bash
# MongoDB (usar MongoDB Atlas para producción)
MONGO_USERNAME=your_username
MONGO_PASSWORD=your_password
MONGO_DATABASE=water_distribution_prod

# Otras configuraciones ya están optimizadas
```

### Configuración para lab.vallegrande.edu.pe

El proyecto está preconfigurado para:
- **API Externa**: `https://lab.vallegrande.edu.pe/jass/ms-users`
- **Puerto**: `8086`
- **Health Check**: `/actuator/health`
- **Swagger UI**: `/swagger-ui.html`
- **Métricas**: `/actuator/prometheus`

## 📁 Archivos Docker

| Archivo | Propósito |
|---------|-----------|
| `Dockerfile` | Imagen optimizada multi-stage (build + runtime) |
| `docker-compose.yml` | Desarrollo local con MongoDB |
| `docker-compose.prod.yml` | Producción sin dependencias locales |
| `.dockerignore` | Optimización del contexto de build |
| `deploy-docker-hub.ps1` | Script automático para Windows |
| `deploy-docker-hub.sh` | Script automático para Linux/Mac |

## 🌐 Endpoints en Producción

Una vez desplegado en `lab.vallegrande.edu.pe`:

- **Aplicación**: `https://lab.vallegrande.edu.pe:8086`
- **Health Check**: `https://lab.vallegrande.edu.pe:8086/actuator/health`
- **API Docs**: `https://lab.vallegrande.edu.pe:8086/swagger-ui.html`
- **Métricas**: `https://lab.vallegrande.edu.pe:8086/actuator/prometheus`

## 📊 Características de la Imagen

### Optimizaciones de Seguridad
- ✅ Usuario no-root (`appuser`)
- ✅ Imagen base Alpine (pequeña y segura)
- ✅ Multi-stage build (sin herramientas de desarrollo)

### Optimizaciones de Performance
- ✅ Java 17 con G1GC
- ✅ Configuración JVM para contenedores
- ✅ Health checks robustos
- ✅ Límites de recursos configurados

### Monitoreo
- ✅ Spring Boot Actuator
- ✅ Métricas Prometheus
- ✅ Logs estructurados

## 🔄 Comandos Útiles

```bash
# Ver logs en tiempo real
docker logs -f water-distribution-app-prod

# Verificar salud
curl https://lab.vallegrande.edu.pe:8086/actuator/health

# Acceder al contenedor (debugging)
docker exec -it water-distribution-app-prod sh

# Actualizar imagen
docker pull victorcuaresmadev/vg-ms-distribution:latest
docker-compose -f docker-compose.prod.yml up -d --force-recreate
```

## 🛠️ Troubleshooting

### La aplicación no inicia
1. Verificar variables de entorno
2. Comprobar conectividad a MongoDB
3. Revisar logs: `docker logs water-distribution-app-prod`

### Error de conexión a MongoDB
1. Verificar credenciales en `.env`
2. Comprobar conectividad de red
3. Usar MongoDB Atlas para producción

### Health check falla
1. Verificar que el puerto 8086 esté disponible
2. Esperar el tiempo de startup (60s)
3. Verificar logs de la aplicación

## 📚 Tecnologías

- **Base**: Spring Boot 3.4.5 + Java 17
- **Base de datos**: MongoDB (Reactive)
- **Arquitectura**: WebFlux (Reactive)
- **Containerización**: Docker + Docker Compose
- **Monitoreo**: Spring Actuator + Prometheus

---

**🎯 ¡Todo listo para producción en lab.vallegrande.edu.pe!** 🚀