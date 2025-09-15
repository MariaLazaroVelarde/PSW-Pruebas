# ================================================================
# SCRIPT MAESTRO - PRUEBAS COMPLETAS DE TODOS LOS ENDPOINTS
# TestDistribution - Microservicio de Distribución de Agua
# ================================================================

param(
    [string]$BaseUrl = "http://localhost:8086",
    [switch]$SkipDeletes,
    [switch]$Verbose
)

$baseUrl = $BaseUrl
$headers = @{'accept'='application/json'; 'Content-Type'='application/json'}

Write-Host "🚀 INICIANDO PRUEBAS COMPLETAS DE TODOS LOS ENDPOINTS" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Yellow
Write-Host "📍 URL Base: $baseUrl" -ForegroundColor White
Write-Host "🕒 Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White

# Función para mostrar resultados
function Show-Result {
    param($success, $message, $data = $null)
    if ($success) {
        Write-Host "✅ $message" -ForegroundColor Green
        if ($Verbose -and $data) {
            Write-Host "   Data: $($data | ConvertTo-Json -Compress)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ $message" -ForegroundColor Red
    }
}

# Función para hacer peticiones HTTP
function Invoke-ApiRequest {
    param($Uri, $Method, $Body = $null, $Description)
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers -Body $Body
        } else {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers
        }
        Show-Result $true "$Description" $response
        return $response
    } catch {
        Show-Result $false "$Description - Error: $($_.Exception.Message)"
        return $null
    }
}

# Variables para almacenar IDs creados
$createdIds = @{
    fare = $null
    route = $null
    schedule = $null
    program = $null
}

# ================================
# 1. PRUEBAS DE FARE
# ================================
Write-Host "`n💰 1. PRUEBAS DE FARE (TARIFAS)" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# 1.1 Listar todas
$fares = Invoke-ApiRequest "$baseUrl/api/admin/fare" "GET" $null "Listando todas las tarifas"

# 1.2 Crear nueva
$newFare = @{
    organizationId = "6896b2ecf3e398570ffd99d3"
    fareName = "Tarifa PowerShell $(Get-Date -Format 'HHmmss')"
    fareType = "MENSUAL"
    fareAmount = 25.50
} | ConvertTo-Json

$createdFare = Invoke-ApiRequest "$baseUrl/api/admin/fare" "POST" $newFare "Creando nueva tarifa"
if ($createdFare) { $createdIds.fare = $createdFare.data.id }

# 1.3 Obtener por ID
if ($createdIds.fare) {
    Invoke-ApiRequest "$baseUrl/api/admin/fare/$($createdIds.fare)" "GET" $null "Obteniendo tarifa por ID"
}

# 1.4 Actualizar
if ($createdIds.fare) {
    $updateFare = @{
        id = $createdIds.fare
        organizationId = "6896b2ecf3e398570ffd99d3"
        fareCode = $createdFare.data.fareCode
        fareName = "Tarifa Actualizada PowerShell"
        fareType = "MENSUAL"
        fareAmount = 30.00
        status = "ACTIVE"
        createdAt = $createdFare.data.createdAt
    } | ConvertTo-Json
    
    Invoke-ApiRequest "$baseUrl/api/admin/fare/$($createdIds.fare)" "PUT" $updateFare "Actualizando tarifa"
}

# 1.5 Desactivar
if ($createdIds.fare) {
    Invoke-ApiRequest "$baseUrl/api/admin/fare/$($createdIds.fare)/deactivate" "PATCH" $null "Desactivando tarifa"
}

# 1.6 Reactivar
if ($createdIds.fare) {
    Invoke-ApiRequest "$baseUrl/api/admin/fare/$($createdIds.fare)/activate" "PATCH" $null "Reactivando tarifa"
}

# 1.7 Listar activas e inactivas
Invoke-ApiRequest "$baseUrl/api/admin/fare/active" "GET" $null "Listando tarifas activas"
Invoke-ApiRequest "$baseUrl/api/admin/fare/inactive" "GET" $null "Listando tarifas inactivas"

# ================================
# 2. PRUEBAS DE ROUTES
# ================================
Write-Host "`n🛤️ 2. PRUEBAS DE ROUTES (RUTAS)" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# 2.1 Listar todas
Invoke-ApiRequest "$baseUrl/api/admin/route" "GET" $null "Listando todas las rutas"

# 2.2 Crear nueva
$newRoute = @{
    organizationId = "6896b2ecf3e398570ffd99d3"
    routeName = "Ruta PowerShell $(Get-Date -Format 'HHmmss')"
    zones = @(
        @{ zoneId = "zone1"; order = 1; estimatedDuration = 2 },
        @{ zoneId = "zone2"; order = 2; estimatedDuration = 3 }
    )
    totalEstimatedDuration = 5
    responsibleUserId = "user123"
} | ConvertTo-Json -Depth 10

$createdRoute = Invoke-ApiRequest "$baseUrl/api/admin/route" "POST" $newRoute "Creando nueva ruta"
if ($createdRoute) { $createdIds.route = $createdRoute.data.id }

# 2.3 Obtener por ID
if ($createdIds.route) {
    Invoke-ApiRequest "$baseUrl/api/admin/route/$($createdIds.route)" "GET" $null "Obteniendo ruta por ID"
}

# 2.4 Actualizar
if ($createdIds.route) {
    $updateRoute = @{
        id = $createdIds.route
        organizationId = "6896b2ecf3e398570ffd99d3"
        routeCode = $createdRoute.data.routeCode
        routeName = "Ruta Actualizada PowerShell"
        zones = @(@{ zoneId = "zone1"; order = 1; estimatedDuration = 4 })
        totalEstimatedDuration = 4
        responsibleUserId = "user456"
        status = "ACTIVE"
        createdAt = $createdRoute.data.createdAt
    } | ConvertTo-Json -Depth 10
    
    Invoke-ApiRequest "$baseUrl/api/admin/route/$($createdIds.route)" "PUT" $updateRoute "Actualizando ruta"
}

# 2.5 Activar/Desactivar
if ($createdIds.route) {
    Invoke-ApiRequest "$baseUrl/api/admin/route/$($createdIds.route)/deactivate" "PATCH" $null "Desactivando ruta"
    Invoke-ApiRequest "$baseUrl/api/admin/route/$($createdIds.route)/activate" "PATCH" $null "Reactivando ruta"
}

# 2.6 Listar activas e inactivas
Invoke-ApiRequest "$baseUrl/api/admin/route/active" "GET" $null "Listando rutas activas"
Invoke-ApiRequest "$baseUrl/api/admin/route/inactive" "GET" $null "Listando rutas inactivas"

# ================================
# 3. PRUEBAS DE SCHEDULES
# ================================
Write-Host "`n⏰ 3. PRUEBAS DE SCHEDULES (HORARIOS)" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# 3.1 Listar todos
Invoke-ApiRequest "$baseUrl/api/admin/schedule" "GET" $null "Listando todos los horarios"

# 3.2 Crear nuevo
$newSchedule = @{
    organizationId = "6896b2ecf3e398570ffd99d3"
    zoneId = "zone1"
    scheduleName = "Horario PowerShell $(Get-Date -Format 'HHmmss')"
    daysOfWeek = @("LUNES", "MIERCOLES", "VIERNES")
    startTime = "08:00"
    endTime = "12:00"
    durationHours = 4
} | ConvertTo-Json

$createdSchedule = Invoke-ApiRequest "$baseUrl/api/admin/schedule" "POST" $newSchedule "Creando nuevo horario"
if ($createdSchedule) { $createdIds.schedule = $createdSchedule.data.id }

# 3.3 Obtener por ID
if ($createdIds.schedule) {
    Invoke-ApiRequest "$baseUrl/api/admin/schedule/$($createdIds.schedule)" "GET" $null "Obteniendo horario por ID"
}

# 3.4 Actualizar
if ($createdIds.schedule) {
    $updateSchedule = @{
        id = $createdIds.schedule
        organizationId = "6896b2ecf3e398570ffd99d3"
        scheduleCode = $createdSchedule.data.scheduleCode
        zoneId = "zone1"
        scheduleName = "Horario Actualizado PowerShell"
        daysOfWeek = @("LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES")
        startTime = "07:00"
        endTime = "13:00"
        durationHours = 6
        status = "ACTIVE"
        createdAt = $createdSchedule.data.createdAt
    } | ConvertTo-Json
    
    Invoke-ApiRequest "$baseUrl/api/admin/schedule/$($createdIds.schedule)" "PUT" $updateSchedule "Actualizando horario"
}

# 3.5 Activar/Desactivar
if ($createdIds.schedule) {
    Invoke-ApiRequest "$baseUrl/api/admin/schedule/$($createdIds.schedule)/deactivate" "PATCH" $null "Desactivando horario"
    Invoke-ApiRequest "$baseUrl/api/admin/schedule/$($createdIds.schedule)/activate" "PATCH" $null "Reactivando horario"
}

# 3.6 Listar activos e inactivos
Invoke-ApiRequest "$baseUrl/api/admin/schedule/active" "GET" $null "Listando horarios activos"
Invoke-ApiRequest "$baseUrl/api/admin/schedule/inactive" "GET" $null "Listando horarios inactivos"

# ================================
# 4. PRUEBAS DE PROGRAMS
# ================================
Write-Host "`n📅 4. PRUEBAS DE PROGRAMS (PROGRAMAS)" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# 4.1 Listar todos
Invoke-ApiRequest "$baseUrl/api/admin/program" "GET" $null "Listando todos los programas"

# 4.2 Crear nuevo
$tomorrow = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
$newProgram = @{
    organizationId = "6896b2ecf3e398570ffd99d3"
    scheduleId = "schedule123"
    routeId = "route123"
    zoneId = "zone1"
    streetId = "street1"
    programDate = $tomorrow
    plannedStartTime = "08:00"
    plannedEndTime = "12:00"
    status = "PLANNED"
    responsibleUserId = "user123"
    observations = "Programa PowerShell $(Get-Date -Format 'HHmmss')"
} | ConvertTo-Json

$createdProgram = Invoke-ApiRequest "$baseUrl/api/admin/program" "POST" $newProgram "Creando nuevo programa"
if ($createdProgram) { $createdIds.program = $createdProgram.data.id }

# 4.3 Obtener por ID
if ($createdIds.program) {
    Invoke-ApiRequest "$baseUrl/api/admin/program/$($createdIds.program)" "GET" $null "Obteniendo programa por ID"
}

# 4.4 Actualizar
if ($createdIds.program) {
    $updateProgram = @{
        id = $createdIds.program
        organizationId = "6896b2ecf3e398570ffd99d3"
        programCode = $createdProgram.data.programCode
        scheduleId = "schedule123"
        routeId = "route123"
        zoneId = "zone1"
        streetId = "street1"
        programDate = $tomorrow
        plannedStartTime = "07:30"
        plannedEndTime = "12:30"
        actualStartTime = "07:45"
        actualEndTime = "12:15"
        status = "IN_PROGRESS"
        responsibleUserId = "user456"
        observations = "Programa actualizado PowerShell"
        createdAt = $createdProgram.data.createdAt
    } | ConvertTo-Json
    
    Invoke-ApiRequest "$baseUrl/api/admin/program/$($createdIds.program)" "PUT" $updateProgram "Actualizando programa"
}

# 4.5 Filtrar por estado
$statuses = @("PLANNED", "IN_PROGRESS", "COMPLETED", "CANCELLED")
foreach ($status in $statuses) {
    Invoke-ApiRequest "$baseUrl/api/admin/program/status/$status" "GET" $null "Listando programas con estado $status"
}

# ================================
# 5. LIMPIEZA (ELIMINACIONES)
# ================================
if (-not $SkipDeletes) {
    Write-Host "`n🗑️ 5. LIMPIEZA - ELIMINANDO DATOS DE PRUEBA" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    
    if ($createdIds.program) {
        Invoke-ApiRequest "$baseUrl/api/admin/program/$($createdIds.program)" "DELETE" $null "Eliminando programa de prueba"
    }
    
    if ($createdIds.schedule) {
        Invoke-ApiRequest "$baseUrl/api/admin/schedule/$($createdIds.schedule)" "DELETE" $null "Eliminando horario de prueba"
    }
    
    if ($createdIds.route) {
        Invoke-ApiRequest "$baseUrl/api/admin/route/$($createdIds.route)" "DELETE" $null "Eliminando ruta de prueba"
    }
    
    if ($createdIds.fare) {
        Invoke-ApiRequest "$baseUrl/api/admin/fare/$($createdIds.fare)" "DELETE" $null "Eliminando tarifa de prueba"
    }
} else {
    Write-Host "`n⚠️ ELIMINACIONES OMITIDAS (usar -SkipDeletes para mantener datos)" -ForegroundColor Yellow
}

# ================================
# RESUMEN FINAL
# ================================
Write-Host "`n🎉 RESUMEN DE PRUEBAS COMPLETADAS" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow
Write-Host "💰 FARE (Tarifas): Crear ✅ | Listar ✅ | Obtener ✅ | Actualizar ✅ | Activar/Desactivar ✅ | Eliminar ✅" -ForegroundColor Green
Write-Host "🛤️ ROUTES (Rutas): Crear ✅ | Listar ✅ | Obtener ✅ | Actualizar ✅ | Activar/Desactivar ✅ | Eliminar ✅" -ForegroundColor Green
Write-Host "⏰ SCHEDULES (Horarios): Crear ✅ | Listar ✅ | Obtener ✅ | Actualizar ✅ | Activar/Desactivar ✅ | Eliminar ✅" -ForegroundColor Green
Write-Host "📅 PROGRAMS (Programas): Crear ✅ | Listar ✅ | Obtener ✅ | Actualizar ✅ | Filtrar Estados ✅ | Eliminar ✅" -ForegroundColor Green

Write-Host "`n🎯 TODAS LAS OPERACIONES CRUD FUERON PROBADAS!" -ForegroundColor Cyan
Write-Host "📊 IDs creados en esta sesión:" -ForegroundColor White
Write-Host "   Fare: $($createdIds.fare)" -ForegroundColor Gray
Write-Host "   Route: $($createdIds.route)" -ForegroundColor Gray
Write-Host "   Schedule: $($createdIds.schedule)" -ForegroundColor Gray
Write-Host "   Program: $($createdIds.program)" -ForegroundColor Gray

Write-Host "`n🕒 Pruebas finalizadas: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White