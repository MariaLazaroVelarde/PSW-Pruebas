# Integración con API Externa MS-USERS

## Configuración

### Variables de Entorno para Autenticación
```bash
# Base URL
MS_USERS_BASE_URL=https://lab.vallegrande.edu.pe/jass/ms-users

# Autenticación - Opción 1: Bearer Token
MS_USERS_AUTH_TYPE=bearer
MS_USERS_AUTH_TOKEN=your_jwt_token_here

# Autenticación - Opción 2: API Key
MS_USERS_AUTH_TYPE=apikey
MS_USERS_API_KEY=your_api_key_here

# Autenticación - Opción 3: Basic Auth
MS_USERS_AUTH_TYPE=basic
MS_USERS_USERNAME=your_username
MS_USERS_PASSWORD=your_password
```

### Configuración en application.yml
```yaml
external:
  apis:
    ms-users:
      base-url: ${MS_USERS_BASE_URL:https://lab.vallegrande.edu.pe/jass/ms-users}
      endpoints:
        admins: /internal/organizations/{organizationId}/admins
        users: /internal/organizations/{organizationId}/users
        clients: /internal/organizations/{organizationId}/clients
        user-by-id: /internal/users/{userId}
      auth:
        type: ${MS_USERS_AUTH_TYPE:bearer}
        token: ${MS_USERS_AUTH_TOKEN:}
        api-key: ${MS_USERS_API_KEY:}
        username: ${MS_USERS_USERNAME:}
        password: ${MS_USERS_PASSWORD:}
      timeout:
        connection: 10000
        read: 15000
```

## Endpoints Disponibles

### 1. Obtener Administradores de Organización
```
GET /api/organizations/{organizationId}/admins
```

### 2. Obtener Usuarios de Organización
```
GET /api/organizations/{organizationId}/users
```

### 3. Obtener Clientes de Organización
```
GET /api/organizations/{organizationId}/clients
```

### 4. Obtener Usuario por ID
```
GET /api/organizations/users/{userId}
```

### 5. Verificar Admin Autorizado
```
GET /api/organizations/{organizationId}/admins/{userId}/authorized
```

### 6. Verificar Existencia de Organización
```
GET /api/organizations/{organizationId}/exists
```

## Errores Comunes y Soluciones

### Error 401 UNAUTHORIZED
**Problema**: La API externa requiere autenticación
**Solución**: Configurar variables de entorno de autenticación:

1. **Bearer Token** (Recomendado):
   ```bash
   set MS_USERS_AUTH_TYPE=bearer
   set MS_USERS_AUTH_TOKEN=your_jwt_token_here
   ```

2. **API Key**:
   ```bash
   set MS_USERS_AUTH_TYPE=apikey
   set MS_USERS_API_KEY=your_api_key_here
   ```

3. **Basic Authentication**:
   ```bash
   set MS_USERS_AUTH_TYPE=basic
   set MS_USERS_USERNAME=your_username
   set MS_USERS_PASSWORD=your_password
   ```

### Error 403 FORBIDDEN
**Problema**: Sin permisos para acceder al recurso
**Solución**: Verificar que el usuario/token tenga permisos de administrador

### Error de Conexión
**Problema**: No se puede conectar a la API externa
**Solución**: Verificar conectividad y URL base

## Cómo Configurar

1. **Obtener credenciales** del administrador de la API externa
2. **Configurar variables de entorno** según el tipo de autenticación
3. **Reiniciar la aplicación** para aplicar los cambios
4. **Probar endpoints** en Swagger UI

## Uso del Servicio

```java
@Autowired
private OrganizationService organizationService;

// Obtener horarios por calles
Flux<Object> schedules = organizationService.getStreetsSchedule();

// Obtener gestión de distribución
Flux<Object> distribution = organizationService.getDistributionManage();

// Obtener seguimiento de consumos
Flux<Object> consumption = organizationService.getConsumptionTrack();
```