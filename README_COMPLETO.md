# 🚰 TestDistribution - Microservicio de Gestión de Distribución de Agua

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.5-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-green.svg)](https://www.mongodb.com/atlas)
[![Maven](https://img.shields.io/badge/Maven-3.9+-blue.svg)](https://maven.apache.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Ejecución](#-ejecución)
- [API Endpoints](#-api-endpoints)
- [Pruebas](#-pruebas)
- [Documentación de la API](#-documentación-de-la-api)
- [Configuración Externa](#-configuración-externa)
- [Monitoreo](#-monitoreo)
- [Contribución](#-contribución)
- [Licencia](#-licencia)

## 📖 Descripción

TestDistribution es un microservicio diseñado para la gestión integral de servicios de distribución de agua en organizaciones comunitarias (JASS - Juntas Administradoras de Servicios de Saneamiento). El sistema proporciona una solución escalable y reactiva para:

- 🏢 **Gestión de Organizaciones**: Administración de JASS y usuarios autorizados
- 📅 **Programación de Distribución**: Planificación y scheduling de servicios
- 🚛 **Gestión de Rutas**: Optimización de rutas de distribución
- 💰 **Tarifas y Facturación**: Cálculo y gestión de tarifas de servicio
- 📊 **Monitoreo y Reportes**: Seguimiento en tiempo real del servicio

### 🎯 Objetivos del Proyecto

- Centralizar la gestión de infraestructura de distribución de agua
- Automatizar procesos de facturación y seguimiento de pagos
- Proporcionar monitoreo en tiempo real de la calidad y distribución
- Facilitar la gestión de quejas e incidencias
- Implementar un sistema de notificaciones multicanal

## 🏗️ Arquitectura

El microservicio está construido siguiendo los principios de **Domain-Driven Design (DDD)** y **Arquitectura Hexagonal**:

```
src/
├── main/
│   ├── java/pe/edu/vallegrande/ms_distribution/
│   │   ├── application/           # Servicios de aplicación y configuración
│   │   │   ├── config/           # Configuraciones Spring
│   │   │   └── services/         # Servicios de negocio
│   │   ├── domain/               # Lógica de dominio
│   │   │   └── models/           # Entidades de dominio
│   │   └── infrastructure/       # Infraestructura y adaptadores
│   │       ├── dto/              # Data Transfer Objects
│   │       ├── repository/       # Repositorios ReactiveMongoRepository
│   │       ├── rest/             # Controladores REST
│   │       └── service/          # Servicios de infraestructura
│   └── resources/
│       └── application.yml       # Configuración de la aplicación
└── test/                         # Pruebas unitarias e integración
```

### 🔄 Patrones de Diseño Implementados

- **Repository Pattern**: Para abstracción de acceso a datos
- **Service Layer Pattern**: Encapsulación de lógica de negocio
- **DTO Pattern**: Transferencia de datos entre capas
- **Exception Handling Pattern**: Manejo centralizado de errores

## 🚀 Tecnologías

### Backend Core
- **Java 17** - Lenguaje de programación
- **Spring Boot 3.4.5** - Framework principal
- **Spring WebFlux** - Programación reactiva
- **Spring Data MongoDB Reactive** - Acceso reactivo a datos
- **Project Lombok** - Reducción de boilerplate

### Base de Datos
- **MongoDB Atlas** - Base de datos NoSQL en la nube
- **Reactive Streams** - Manejo asíncrono de datos

### Documentación y Testing
- **SpringDoc OpenAPI 3** - Documentación automática de API
- **Swagger UI 2.8.8** - Interfaz interactiva de documentación
- **JUnit 5** - Framework de testing
- **Reactor Test** - Testing para programación reactiva

### Seguridad y Validación
- **JWT (JSON Web Tokens) 0.11.5** - Autenticación y autorización
- **Spring Validation** - Validación de datos de entrada

### Monitoreo
- **Spring Actuator** - Endpoints de salud y métricas
- **Micrometer Prometheus** - Métricas para monitoreo

### Build y Dependencias
- **Maven 3.9+** - Gestión de dependencias y build
- **Maven Compiler Plugin 3.13.0** - Compilación con Java 17

## ⚙️ Requisitos Previos

### Software Requerido
- **JDK 17** o superior
- **Maven 3.6+**
- **Git** (para clonar el repositorio)

### Servicios Externos
- **MongoDB Atlas** - Base de datos (configurada)
- **API Externa MS-USERS** - Servicio de usuarios (https://lab.vallegrande.edu.pe/jass/ms-users)

### Recomendado
- **IDE** con soporte para Lombok (IntelliJ IDEA, Eclipse, VS Code)
- **Postman** o similar para pruebas de API
- **Docker** (opcional, para contenedorización futura)

## 🛠️ Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone <repository-url>
cd TestDistribution
```

### 2. Verificar Requisitos
```bash
# Verificar Java 17
java -version

# Verificar Maven
mvn -version
```

### 3. Configurar Variables de Entorno (Opcional)
```bash
# Para configuración personalizada
export MONGO_USERNAME=your_username
export MONGO_PASSWORD=your_password
export MONGO_DATABASE=your_database
export MS_USERS_BASE_URL=https://lab.vallegrande.edu.pe/jass/ms-users
```

### 4. Compilar el Proyecto
```bash
# Limpiar y compilar
mvn clean compile

# Compilar con tests
mvn clean install

# Compilar sin tests (más rápido)
mvn clean install -DskipTests
```

## 🚀 Ejecución

### Ejecución con Maven
```bash
# Ejecutar la aplicación
mvn spring-boot:run

# Ejecutar en puerto específico
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8087
```

### Ejecución con JAR
```bash
# Generar JAR
mvn package

# Ejecutar JAR
java -jar target/structure-microservice-1.0.0.jar
```

### Verificar que la Aplicación esté Ejecutándose
```bash
# Verificar salud de la aplicación
curl http://localhost:8086/actuator/health

# Respuesta esperada:
# {"status":"UP"}
```

## 📚 API Endpoints

### 🏢 Organizaciones (`/api/organizations`)

#### Gestión de Administradores
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/organizations/{organizationId}/admins` | Obtener administradores autorizados |
| `GET` | `/api/organizations/{organizationId}/admins/{userId}/authorized` | Verificar si usuario es administrador autorizado |
| `GET` | `/api/organizations/{organizationId}/admins/{adminId}` | Obtener administrador específico |

#### Gestión de Usuarios y Clientes
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/organizations/{organizationId}/users` | Obtener usuarios de organización |
| `GET` | `/api/organizations/{organizationId}/clients` | Obtener clientes de organización |
| `GET` | `/api/organizations/users/{userId}` | Obtener usuario por ID |

#### Validaciones
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/organizations/{organizationId}/exists` | Verificar existencia de organización |

### 💰 Tarifas (`/api/v2/fare`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v2/fare` | Obtener todas las tarifas |
| `GET` | `/api/v2/fare/active` | Obtener tarifas activas |
| `GET` | `/api/v2/fare/inactive` | Obtener tarifas inactivas |
| `GET` | `/api/v2/fare/{id}` | Obtener tarifa por ID |
| `POST` | `/api/v2/fare` | Crear nueva tarifa |
| `PUT` | `/api/v2/fare/{id}` | Actualizar tarifa |
| `DELETE` | `/api/v2/fare/{id}` | Eliminar tarifa |
| `PATCH` | `/api/v2/fare/{id}/activate` | Activar tarifa |
| `PATCH` | `/api/v2/fare/{id}/deactivate` | Desactivar tarifa |

### 📅 Programas de Distribución (`/api/v2/programs`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v2/programs` | Obtener todos los programas |
| `GET` | `/api/v2/programs/{id}` | Obtener programa por ID |
| `POST` | `/api/v2/programs` | Crear nuevo programa |
| `PUT` | `/api/v2/programs/{id}` | Actualizar programa |
| `DELETE` | `/api/v2/programs/{id}` | Eliminar programa |
| `PATCH` | `/api/v2/programs/{id}/activate` | Activar programa |
| `PATCH` | `/api/v2/programs/{id}/deactivate` | Desactivar programa |

### 🕐 Horarios de Distribución (`/api/v2/schedules`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v2/schedules` | Obtener todos los horarios |
| `GET` | `/api/v2/schedules/active` | Obtener horarios activos |
| `GET` | `/api/v2/schedules/inactive` | Obtener horarios inactivos |
| `GET` | `/api/v2/schedules/{id}` | Obtener horario por ID |
| `POST` | `/api/v2/schedules` | Crear nuevo horario |
| `PUT` | `/api/v2/schedules/{id}` | Actualizar horario |
| `DELETE` | `/api/v2/schedules/{id}` | Eliminar horario |
| `PATCH` | `/api/v2/schedules/{id}/activate` | Activar horario |
| `PATCH` | `/api/v2/schedules/{id}/deactivate` | Desactivar horario |

### 🚛 Rutas de Distribución (`/api/v2/routes`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v2/routes` | Obtener todas las rutas |
| `GET` | `/api/v2/routes/active` | Obtener rutas activas |
| `GET` | `/api/v2/routes/inactive` | Obtener rutas inactivas |
| `GET` | `/api/v2/routes/{id}` | Obtener ruta por ID |
| `POST` | `/api/v2/routes` | Crear nueva ruta |
| `PUT` | `/api/v2/routes/{id}` | Actualizar ruta |
| `DELETE` | `/api/v2/routes/{id}` | Eliminar ruta |
| `PATCH` | `/api/v2/routes/{id}/activate` | Activar ruta |
| `PATCH` | `/api/v2/routes/{id}/deactivate` | Desactivar ruta |

### 📊 Monitoreo (`/actuator`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/actuator/health` | Estado de salud de la aplicación |
| `GET` | `/actuator/info` | Información de la aplicación |
| `GET` | `/actuator/metrics` | Métricas de la aplicación |
| `GET` | `/actuator/prometheus` | Métricas en formato Prometheus |

## 🧪 Pruebas

### Ejecutar Pruebas Unitarias
```bash
# Ejecutar todas las pruebas
mvn test

# Ejecutar con reporte detallado
mvn test -Dtest.verbose=true

# Ejecutar pruebas específicas
mvn test -Dtest=OrganizationServiceTest
```

### Pruebas de Integración
```bash
# Ejecutar pruebas de integración
mvn verify

# Ejecutar con perfil de integración
mvn test -Pintegration-test
```

### Ejemplos de Pruebas con cURL

#### Verificar Salud de la Aplicación
```bash
curl -X GET http://localhost:8086/actuator/health
```

#### Obtener Administradores de una Organización
```bash
curl -X GET "http://localhost:8086/api/organizations/6896b2ecf3e398570ffd99d3/admins" \
  -H "Accept: application/json"
```

#### Verificar Existencia de Organización
```bash
curl -X GET "http://localhost:8086/api/organizations/6896b2ecf3e398570ffd99d3/exists" \
  -H "Accept: application/json"
```

#### Crear Nueva Tarifa
```bash
curl -X POST "http://localhost:8086/api/v2/fare" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tarifa Básica",
    "price": 25.50,
    "description": "Tarifa para servicio básico",
    "status": "ACTIVE"
  }'
```

### Pruebas con Postman

#### Importar Colección
1. Crear nueva colección en Postman
2. Importar endpoints desde Swagger UI (`http://localhost:8086/swagger-ui.html`)
3. Configurar variables de entorno:
   - `base_url`: `http://localhost:8086`
   - `organization_id`: `6896b2ecf3e398570ffd99d3`

#### Colección de Pruebas Recomendadas
```json
{
  "info": {
    "name": "TestDistribution API",
    "description": "Colección de pruebas para el microservicio"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "{{base_url}}/actuator/health"
      }
    },
    {
      "name": "Get Organization Admins",
      "request": {
        "method": "GET",
        "url": "{{base_url}}/api/organizations/{{organization_id}}/admins"
      }
    }
  ]
}
```

## 📖 Documentación de la API

### Swagger UI
Una vez que la aplicación esté ejecutándose, accede a la documentación interactiva:

**URL**: [http://localhost:8086/swagger-ui.html](http://localhost:8086/swagger-ui.html)

### OpenAPI Specification
**URL**: [http://localhost:8086/v3/api-docs](http://localhost:8086/v3/api-docs)

### Características de la Documentación
- ✅ **Interfaz interactiva** para probar endpoints
- ✅ **Esquemas de datos** detallados
- ✅ **Ejemplos de request/response**
- ✅ **Códigos de estado HTTP** explicados
- ✅ **Parámetros y headers** documentados

## 🔧 Configuración Externa

### Variables de Entorno

#### Base de Datos MongoDB
```bash
MONGO_USERNAME=sistemajass           # Usuario de MongoDB Atlas
MONGO_PASSWORD=ZC7O1Ok40SwkfEje      # Contraseña de MongoDB Atlas
MONGO_DATABASE=JASS_DIGITAL          # Nombre de la base de datos
```

#### API Externa MS-USERS
```bash
MS_USERS_BASE_URL=https://lab.vallegrande.edu.pe/jass/ms-users
MS_USERS_AUTH_TYPE=bearer            # Tipo de autenticación (bearer/apikey/basic)
MS_USERS_AUTH_TOKEN=                 # Token de autenticación (opcional)
MS_USERS_API_KEY=                    # API Key (opcional)
MS_USERS_USERNAME=                   # Usuario para autenticación básica (opcional)
MS_USERS_PASSWORD=                   # Contraseña para autenticación básica (opcional)
```

#### Configuración del Servidor
```bash
SERVER_PORT=8086                     # Puerto del servidor (default: 8086)
NOMBRE_MICROSERVICIO=test-distribution # Nombre del microservicio
```

### Archivo application.yml
```yaml
# Configuración principal
spring:
  application:
    name: ${NOMBRE_MICROSERVICIO:structure-microservice}
  data:
    mongodb:
      uri: mongodb+srv://${MONGO_USERNAME:sistemajass}:${MONGO_PASSWORD:ZC7O1Ok40SwkfEje}@sistemajass.jn6cpoz.mongodb.net/${MONGO_DATABASE:JASS_DIGITAL}?retryWrites=true&w=majority

server:
  port: ${SERVER_PORT:8086}

# Configuración de API Externa
external:
  apis:
    ms-users:
      base-url: ${MS_USERS_BASE_URL:https://lab.vallegrande.edu.pe/jass/ms-users}
      auth:
        type: ${MS_USERS_AUTH_TYPE:bearer}
        token: ${MS_USERS_AUTH_TOKEN:}
```

### Perfiles de Configuración

#### Desarrollo (`application-dev.yml`)
```yaml
spring:
  data:
    mongodb:
      uri: mongodb://localhost:27017/test_distribution_dev
server:
  port: 8086
logging:
  level:
    pe.edu.vallegrande: DEBUG
```

#### Producción (`application-prod.yml`)
```yaml
spring:
  data:
    mongodb:
      uri: ${MONGODB_URI}
server:
  port: ${PORT:8080}
logging:
  level:
    root: WARN
    pe.edu.vallegrande: INFO
```

## 📊 Monitoreo

### Endpoints de Actuator
- **Health**: `/actuator/health` - Estado de salud de la aplicación
- **Info**: `/actuator/info` - Información básica de la aplicación
- **Metrics**: `/actuator/metrics` - Métricas detalladas
- **Prometheus**: `/actuator/prometheus` - Métricas en formato Prometheus

### Métricas Disponibles
- **JVM**: Uso de memoria, threads, garbage collection
- **HTTP**: Requests, responses, latencia
- **MongoDB**: Conexiones, operaciones, latencia
- **Aplicación**: Métricas personalizadas de negocio

### Configuración de Monitoreo

#### Prometheus (prometheus.yml)
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'test-distribution'
    static_configs:
      - targets: ['localhost:8086']
    metrics_path: '/actuator/prometheus'
```

#### Grafana Dashboard
1. Importar dashboard para Spring Boot
2. Configurar datasource de Prometheus
3. Crear alertas personalizadas

### Health Checks Personalizados
```java
@Component
public class MongoHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        // Implementación personalizada
    }
}
```

## 🚀 Despliegue

### Docker (Recomendado)

#### Dockerfile
```dockerfile
FROM openjdk:17-jre-slim

VOLUME /tmp

ARG JAR_FILE=target/structure-microservice-1.0.0.jar
COPY ${JAR_FILE} app.jar

EXPOSE 8086

ENTRYPOINT ["java","-jar","/app.jar"]
```

#### docker-compose.yml
```yaml
version: '3.8'
services:
  test-distribution:
    build: .
    ports:
      - "8086:8086"
    environment:
      - MONGO_USERNAME=${MONGO_USERNAME}
      - MONGO_PASSWORD=${MONGO_PASSWORD}
      - MONGO_DATABASE=${MONGO_DATABASE}
    depends_on:
      - mongodb
  
  mongodb:
    image: mongo:latest
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db

volumes:
  mongodb_data:
```

#### Comandos Docker
```bash
# Construir imagen
docker build -t test-distribution:latest .

# Ejecutar contenedor
docker run -p 8086:8086 test-distribution:latest

# Ejecutar con docker-compose
docker-compose up -d
```

### Cloud Deployment

#### Heroku
```bash
# Configurar buildpack
heroku buildpacks:set heroku/java

# Configurar variables de entorno
heroku config:set MONGO_USERNAME=your_username
heroku config:set MONGO_PASSWORD=your_password

# Desplegar
git push heroku main
```

#### AWS ECS/Fargate
1. Crear task definition
2. Configurar service en ECS
3. Configurar load balancer
4. Configurar auto-scaling

## 🔧 Troubleshooting

### Problemas Comunes

#### Error de Compilación
```bash
# Problema: Java version incompatible
Error: incompatible types

# Solución: Verificar Java 17
java -version
export JAVA_HOME=/path/to/java17
```

#### Error de Conexión MongoDB
```bash
# Problema: No se puede conectar a MongoDB
MongoSocketOpenException: Exception opening socket

# Solución: Verificar configuración
# 1. Verificar credenciales en application.yml
# 2. Verificar conectividad de red
# 3. Verificar whitelist de IPs en MongoDB Atlas
```

#### Error de Puerto en Uso
```bash
# Problema: Port already in use
Port 8086 was already in use

# Solución en Windows:
netstat -ano | findstr :8086
taskkill /PID <PID> /F

# Solución en Linux/Mac:
lsof -i :8086
kill -9 <PID>
```

#### Error de Mapeo JSON
```bash
# Problema: Unrecognized field
JsonMappingException: Unrecognized field "status"

# Solución: Ya implementada con @JsonIgnoreProperties
# Verificar que la clase DTO tenga la anotación correcta
```

### Logs y Debugging

#### Configurar Logging
```yaml
logging:
  level:
    pe.edu.vallegrande: DEBUG
    org.springframework.web: DEBUG
    org.mongodb: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/application.log
```

#### Debug con IDE
1. Configurar breakpoints en servicios
2. Ejecutar en modo debug
3. Inspeccionar variables y flujo

## 🤝 Contribución

### Guías de Contribución
1. **Fork** el repositorio
2. **Crear** una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. **Commit** tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. **Push** a la rama (`git push origin feature/nueva-funcionalidad`)
5. **Crear** un Pull Request

### Estándares de Código
- Usar **Lombok** para reducir boilerplate
- Seguir **convenciones de naming** de Java
- **Documentar** métodos públicos con JavaDoc
- **Escribir pruebas** unitarias para nueva funcionalidad
- Usar **programación reactiva** con Mono/Flux

### Code Style
```java
// Ejemplo de clase de servicio
@Service
@RequiredArgsConstructor
@Slf4j
public class DistributionService {

    private final DistributionRepository repository;

    /**
     * Obtiene todas las distribuciones activas
     * @return Flux de distribuciones activas
     */
    public Flux<Distribution> getAllActive() {
        log.info("Obteniendo distribuciones activas");
        return repository.findByStatusActive()
                .doOnNext(dist -> log.debug("Distribución encontrada: {}", dist.getId()))
                .onErrorMap(ex -> new ServiceException("Error al obtener distribuciones", ex));
    }
}
```

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo de Desarrollo

- **Desarrollador Principal**: [Nombre]
- **Arquitecto de Software**: [Nombre]
- **DevOps**: [Nombre]

## 📞 Soporte

Para reportar bugs o solicitar nuevas funcionalidades:
- **Issues**: [GitHub Issues](repository-url/issues)
- **Email**: support@vallegrande.edu.pe
- **Documentación**: [Wiki del Proyecto](repository-url/wiki)

## 📈 Roadmap

### Versión 1.1.0
- [ ] Implementación de caché con Redis
- [ ] Integración con sistema de notificaciones
- [ ] Mejoras en la autenticación JWT

### Versión 1.2.0
- [ ] API Gateway integrado
- [ ] Métricas avanzadas de negocio
- [ ] Containerización con Docker

### Versión 2.0.0
- [ ] Migración a microservicios distribuidos
- [ ] Event Sourcing implementation
- [ ] Real-time notifications con WebSockets

---

⭐ **¡Dale una estrella al proyecto si te resulta útil!**

📝 **Última actualización**: Septiembre 2025