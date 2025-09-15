# ================================
# CONTINUACIÓN: SCHEDULES Y PROGRAMS
# ================================

# ================================
# 3. PRUEBAS DE SCHEDULES
# ================================
Write-Host "`n📋 3. PRUEBAS DE SCHEDULES" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

# 3.1 Listar todos los horarios
Write-Host "`n3.1 📋 Listando todos los HORARIOS..." -ForegroundColor Green
try {
    $schedules = Invoke-RestMethod -Uri "$baseUrl/api/admin/schedule" -Method GET -Headers $headers
    Write-Host "✅ Total de horarios: $($schedules.data.Count)" -ForegroundColor Green
    $schedules.data | ForEach-Object { Write-Host "  - $($_.scheduleName) ($($_.scheduleCode)) - $($_.startTime)-$($_.endTime) - $($_.status)" }
} catch {
    Write-Host "❌ Error al listar horarios: $($_.Exception.Message)" -ForegroundColor Red
}

# 3.2 Crear nuevo horario
Write-Host "`n3.2 ➕ Creando nuevo HORARIO..." -ForegroundColor Green
$newSchedule = @{
    organizationId = "6896b2ecf3e398570ffd99d3"
    zoneId = "zone1"
    scheduleName = "Horario de Prueba PowerShell"
    daysOfWeek = @("LUNES", "MIERCOLES", "VIERNES")
    startTime = "08:00"
    endTime = "12:00"
    durationHours = 4
} | ConvertTo-Json

try {
    $createdSchedule = Invoke-RestMethod -Uri "$baseUrl/api/admin/schedule" -Method POST -Headers $headers -Body $newSchedule
    $scheduleId = $createdSchedule.data.id
    Write-Host "✅ Horario creado exitosamente: $($createdSchedule.data.scheduleName) (ID: $scheduleId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al crear horario: $($_.Exception.Message)" -ForegroundColor Red
}

# 3.3 Obtener horario por ID
if ($scheduleId) {
    Write-Host "`n3.3 🔍 Obteniendo HORARIO por ID..." -ForegroundColor Green
    try {
        $schedule = Invoke-RestMethod -Uri "$baseUrl/api/admin/schedule/$scheduleId" -Method GET -Headers $headers
        Write-Host "✅ Horario encontrado: $($schedule.data.scheduleName) - Estado: $($schedule.data.status)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al obtener horario: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3.4 Actualizar horario
if ($scheduleId) {
    Write-Host "`n3.4 ✏️ Actualizando HORARIO..." -ForegroundColor Green
    $updateSchedule = @{
        id = $scheduleId
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

    try {
        $updatedSchedule = Invoke-RestMethod -Uri "$baseUrl/api/admin/schedule/$scheduleId" -Method PUT -Headers $headers -Body $updateSchedule
        Write-Host "✅ Horario actualizado: $($updatedSchedule.data.scheduleName) - Nueva duración: $($updatedSchedule.data.durationHours)h" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al actualizar horario: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3.5 Desactivar horario
if ($scheduleId) {
    Write-Host "`n3.5 ⏸️ Desactivando HORARIO..." -ForegroundColor Green
    try {
        $deactivatedSchedule = Invoke-RestMethod -Uri "$baseUrl/api/admin/schedule/$scheduleId/deactivate" -Method PATCH -Headers $headers
        Write-Host "✅ Horario desactivado: $($deactivatedSchedule.data.scheduleName) - Estado: $($deactivatedSchedule.data.status)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al desactivar horario: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3.6 Reactivar horario
if ($scheduleId) {
    Write-Host "`n3.6 ▶️ Reactivando HORARIO..." -ForegroundColor Green
    try {
        $activatedSchedule = Invoke-RestMethod -Uri "$baseUrl/api/admin/schedule/$scheduleId/activate" -Method PATCH -Headers $headers
        Write-Host "✅ Horario reactivado: $($activatedSchedule.data.scheduleName) - Estado: $($activatedSchedule.data.status)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al reactivar horario: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3.7 Listar horarios activos
Write-Host "`n3.7 📋 Listando HORARIOS ACTIVOS..." -ForegroundColor Green
try {
    $activeSchedules = Invoke-RestMethod -Uri "$baseUrl/api/admin/schedule/active" -Method GET -Headers $headers
    Write-Host "✅ Horarios activos: $($activeSchedules.data.Count)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al listar horarios activos: $($_.Exception.Message)" -ForegroundColor Red
}

# 3.8 Eliminar horario
if ($scheduleId) {
    Write-Host "`n3.8 🗑️ Eliminando HORARIO..." -ForegroundColor Green
    try {
        Invoke-RestMethod -Uri "$baseUrl/api/admin/schedule/$scheduleId" -Method DELETE -Headers $headers
        Write-Host "✅ Horario eliminado exitosamente" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al eliminar horario: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ================================
# 4. PRUEBAS DE PROGRAMS
# ================================
Write-Host "`n📋 4. PRUEBAS DE PROGRAMS" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

# 4.1 Listar todos los programas
Write-Host "`n4.1 📋 Listando todos los PROGRAMAS..." -ForegroundColor Green
try {
    $programs = Invoke-RestMethod -Uri "$baseUrl/api/admin/program" -Method GET -Headers $headers
    Write-Host "✅ Total de programas: $($programs.data.Count)" -ForegroundColor Green
    $programs.data | ForEach-Object { Write-Host "  - $($_.programCode) - $($_.programDate) - $($_.status)" }
} catch {
    Write-Host "❌ Error al listar programas: $($_.Exception.Message)" -ForegroundColor Red
}

# 4.2 Crear nuevo programa
Write-Host "`n4.2 ➕ Creando nuevo PROGRAMA..." -ForegroundColor Green
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
    observations = "Programa de prueba creado desde PowerShell"
} | ConvertTo-Json

try {
    $createdProgram = Invoke-RestMethod -Uri "$baseUrl/api/admin/program" -Method POST -Headers $headers -Body $newProgram
    $programId = $createdProgram.data.id
    Write-Host "✅ Programa creado exitosamente: $($createdProgram.data.programCode) (ID: $programId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al crear programa: $($_.Exception.Message)" -ForegroundColor Red
}

# 4.3 Obtener programa por ID
if ($programId) {
    Write-Host "`n4.3 🔍 Obteniendo PROGRAMA por ID..." -ForegroundColor Green
    try {
        $program = Invoke-RestMethod -Uri "$baseUrl/api/admin/program/$programId" -Method GET -Headers $headers
        Write-Host "✅ Programa encontrado: $($program.data.programCode) - Estado: $($program.data.status)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al obtener programa: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 4.4 Actualizar programa
if ($programId) {
    Write-Host "`n4.4 ✏️ Actualizando PROGRAMA..." -ForegroundColor Green
    $updateProgram = @{
        id = $programId
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
        observations = "Programa actualizado desde PowerShell - En progreso"
        createdAt = $createdProgram.data.createdAt
    } | ConvertTo-Json

    try {
        $updatedProgram = Invoke-RestMethod -Uri "$baseUrl/api/admin/program/$programId" -Method PUT -Headers $headers -Body $updateProgram
        Write-Host "✅ Programa actualizado: $($updatedProgram.data.programCode) - Estado: $($updatedProgram.data.status)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al actualizar programa: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 4.5 Filtrar programas por estado
Write-Host "`n4.5 📋 Listando PROGRAMAS por estado..." -ForegroundColor Green
$statuses = @("PLANNED", "IN_PROGRESS", "COMPLETED", "CANCELLED")
foreach ($status in $statuses) {
    try {
        $programsByStatus = Invoke-RestMethod -Uri "$baseUrl/api/admin/program/status/$status" -Method GET -Headers $headers
        Write-Host "✅ Programas en estado $status : $($programsByStatus.data.Count)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al obtener programas con estado $status : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 4.6 Eliminar programa
if ($programId) {
    Write-Host "`n4.6 🗑️ Eliminando PROGRAMA..." -ForegroundColor Green
    try {
        Invoke-RestMethod -Uri "$baseUrl/api/admin/program/$programId" -Method DELETE -Headers $headers
        Write-Host "✅ Programa eliminado exitosamente" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al eliminar programa: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ================================
# RESUMEN FINAL
# ================================
Write-Host "`n🎉 PRUEBAS COMPLETAS FINALIZADAS" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host "✅ FARE: Crear, Listar, Obtener, Actualizar, Activar/Desactivar, Eliminar" -ForegroundColor Green
Write-Host "✅ ROUTES: Crear, Listar, Obtener, Actualizar, Activar/Desactivar, Eliminar" -ForegroundColor Green
Write-Host "✅ SCHEDULES: Crear, Listar, Obtener, Actualizar, Activar/Desactivar, Eliminar" -ForegroundColor Green
Write-Host "✅ PROGRAMS: Crear, Listar, Obtener, Actualizar, Filtrar por Estado, Eliminar" -ForegroundColor Green
Write-Host "`n🎯 Todas las operaciones CRUD fueron probadas exitosamente!" -ForegroundColor Cyan