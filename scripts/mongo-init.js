// ==============================================
// Script de inicialización de MongoDB
// Water Distribution Database Setup
// ==============================================

// Crear usuario para la aplicación
db.createUser({
  user: "waterdist_app",
  pwd: "waterdist_app_pass",
  roles: [
    {
      role: "readWrite",
      db: "water_distribution_db"
    }
  ]
});

// Crear colecciones principales con índices
db.createCollection("fare");
db.createCollection("routes");
db.createCollection("schedules");
db.createCollection("programs");

// Índices para fare
db.fare.createIndex({ "organizationId": 1 });
db.fare.createIndex({ "fareCode": 1 }, { unique: true });
db.fare.createIndex({ "status": 1 });
db.fare.createIndex({ "createdAt": -1 });

// Índices para routes
db.routes.createIndex({ "organizationId": 1 });
db.routes.createIndex({ "routeCode": 1 }, { unique: true });
db.routes.createIndex({ "status": 1 });
db.routes.createIndex({ "responsibleUserId": 1 });

// Índices para schedules
db.schedules.createIndex({ "organizationId": 1 });
db.schedules.createIndex({ "scheduleCode": 1 }, { unique: true });
db.schedules.createIndex({ "zoneId": 1 });
db.schedules.createIndex({ "status": 1 });

// Índices para programs
db.programs.createIndex({ "organizationId": 1 });
db.programs.createIndex({ "programCode": 1 }, { unique: true });
db.programs.createIndex({ "scheduleId": 1 });
db.programs.createIndex({ "routeId": 1 });
db.programs.createIndex({ "status": 1 });
db.programs.createIndex({ "programDate": -1 });

// Datos de ejemplo para testing
db.fare.insertMany([
  {
    "organizationId": "6896b2ecf3e398570ffd99d3",
    "fareCode": "TAR001",
    "fareName": "Tarifa Básica Diaria",
    "fareType": "DIARIA",
    "fareAmount": 10.00,
    "status": "ACTIVE",
    "createdAt": new Date()
  },
  {
    "organizationId": "6896b2ecf3e398570ffd99d3",
    "fareCode": "TAR002",
    "fareName": "Tarifa Semanal",
    "fareType": "SEMANAL",
    "fareAmount": 60.00,
    "status": "ACTIVE",
    "createdAt": new Date()
  },
  {
    "organizationId": "6896b2ecf3e398570ffd99d3",
    "fareCode": "TAR003",
    "fareName": "Tarifa Mensual",
    "fareType": "MENSUAL",
    "fareAmount": 200.00,
    "status": "ACTIVE",
    "createdAt": new Date()
  }
]);

print("✅ Base de datos inicializada correctamente");
print("📊 Colecciones creadas: fare, routes, schedules, programs");
print("🔍 Índices configurados para optimización");
print("📝 Datos de ejemplo insertados en fare");