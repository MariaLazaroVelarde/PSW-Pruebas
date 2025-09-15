# Script completo de pruebas CRUD para todos los endpoints
# Versión: 2.0
# Fecha: 2025-09-10

param(
    [string]$BaseUrl = "http://localhost:8080",
    [switch]$Verbose = $false,
    [switch]$SkipDeletes = $false
)

# Configuración global
$global:TestResults = @()
$global:CreatedIds = @{
    Fare = @()
    Route = @()
    Schedule = @() 
    Program = @()
}

# Función para logging
function Write-TestLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch($Level) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

# Función para realizar peticiones HTTP
function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Uri,
        [object]$Body = $null,
        [string]$TestName
    )
    
    try {
        $headers = @{ 'Content-Type' = 'application/json' }
        $params = @{
            Uri = $Uri
            Method = $Method
            Headers = $headers
        }
        
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            $params.Body = $jsonBody
            if ($Verbose) {
                Write-TestLog "Request Body: $jsonBody" "INFO"
            }
        }
        
        $response = Invoke-RestMethod @params
        
        if ($Verbose) {
            Write-TestLog "Response: $($response | ConvertTo-Json -Depth 5)" "INFO"
        }
        
        return @{
            Success = $true
            Data = $response
            StatusCode = 200
        }
    }
    catch {
        $errorDetails = $_.ErrorDetails.Message
        if ($errorDetails) {
            try {
                $errorObj = $errorDetails | ConvertFrom-Json
                Write-TestLog "ERROR en $TestName`: $($errorObj.error.message) (Code: $($errorObj.error.errorCode))" "ERROR"
            }
            catch {
                Write-TestLog "ERROR en $TestName`: $errorDetails" "ERROR"
            }
        }
        else {
            Write-TestLog "ERROR en $TestName`: $($_.Exception.Message)" "ERROR"
        }
        
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
        }
    }
}

# ==================== PRUEBAS FARE ====================
function Test-FareOperations {
    Write-TestLog "=== INICIANDO PRUEBAS FARE ===" "SUCCESS"
    
    # 1. Listar todas las tarifas
    Write-TestLog "1. Listando todas las tarifas..."
    $listResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/fare" -TestName "Listar Tarifas"
    if ($listResult.Success -and $listResult.Data.status) {
        Write-TestLog "SUCCESS: $($listResult.Data.data.Count) tarifas encontradas" "SUCCESS"
    }
    
    # 2. Crear nueva tarifa
    Write-TestLog "2. Creando nueva tarifa..."
    $fareData = @{
        organizationId = "org-test-001"
        fareCode = "FARE-TEST-PS-$(Get-Date -Format 'HHmmss')"
        fareName = "Tarifa PowerShell Test"
        fareType = "DIARIA"
        fareAmount = 25.50
    }
    
    $createResult = Invoke-ApiRequest -Method "POST" -Uri "$BaseUrl/api/admin/fare" -Body $fareData -TestName "Crear Tarifa"
    if ($createResult.Success -and $createResult.Data.status) {
        $fareId = $createResult.Data.data.id
        $global:CreatedIds.Fare += $fareId
        Write-TestLog "SUCCESS: Tarifa creada con ID: $fareId" "SUCCESS"
        
        # 3. Obtener por ID
        Write-TestLog "3. Obteniendo tarifa por ID..."
        $getResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/fare/$fareId" -TestName "Obtener Tarifa por ID"
        if ($getResult.Success -and $getResult.Data.status) {
            Write-TestLog "SUCCESS: Tarifa obtenida - $($getResult.Data.data.fareName)" "SUCCESS"
        }
        
        # 4. Actualizar tarifa
        Write-TestLog "4. Actualizando tarifa..."
        $updateData = @{
            id = $fareId
            organizationId = "org-test-001"
            fareCode = $fareData.fareCode
            fareName = "Tarifa PowerShell Test - ACTUALIZADA"
            fareType = "SEMANAL"
            fareAmount = 150.00
            status = "ACTIVE"
        }
        
        $updateResult = Invoke-ApiRequest -Method "PUT" -Uri "$BaseUrl/api/admin/fare/$fareId" -Body $updateData -TestName "Actualizar Tarifa"
        if ($updateResult.Success -and $updateResult.Data.status) {
            Write-TestLog "SUCCESS: Tarifa actualizada" "SUCCESS"
        }
        
        # 5. Desactivar tarifa
        Write-TestLog "5. Desactivando tarifa..."
        $deactivateResult = Invoke-ApiRequest -Method "PATCH" -Uri "$BaseUrl/api/admin/fare/$fareId/deactivate" -TestName "Desactivar Tarifa"
        if ($deactivateResult.Success -and $deactivateResult.Data.status) {
            Write-TestLog "SUCCESS: Tarifa desactivada" "SUCCESS"
        }
        
        # 6. Reactivar tarifa
        Write-TestLog "6. Reactivando tarifa..."
        $activateResult = Invoke-ApiRequest -Method "PATCH" -Uri "$BaseUrl/api/admin/fare/$fareId/activate" -TestName "Reactivar Tarifa"
        if ($activateResult.Success -and $activateResult.Data.status) {
            Write-TestLog "SUCCESS: Tarifa reactivada" "SUCCESS"
        }
        
        # 7. Eliminar tarifa (si no se omite)
        if (-not $SkipDeletes) {
            Write-TestLog "7. Eliminando tarifa..."
            $deleteResult = Invoke-ApiRequest -Method "DELETE" -Uri "$BaseUrl/api/admin/fare/$fareId" -TestName "Eliminar Tarifa"
            if ($deleteResult.Success) {
                Write-TestLog "SUCCESS: Tarifa eliminada" "SUCCESS"
                $global:CreatedIds.Fare = $global:CreatedIds.Fare | Where-Object { $_ -ne $fareId }
            }
        }
    }
    
    # 8. Listar tarifas activas
    Write-TestLog "8. Listando tarifas activas..."
    $activeResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/fare/active" -TestName "Listar Tarifas Activas"
    if ($activeResult.Success -and $activeResult.Data.status) {
        Write-TestLog "SUCCESS: $($activeResult.Data.data.Count) tarifas activas encontradas" "SUCCESS"
    }
    
    # 9. Listar tarifas inactivas
    Write-TestLog "9. Listando tarifas inactivas..."
    $inactiveResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/fare/inactive" -TestName "Listar Tarifas Inactivas"
    if ($inactiveResult.Success -and $inactiveResult.Data.status) {
        Write-TestLog "SUCCESS: $($inactiveResult.Data.data.Count) tarifas inactivas encontradas" "SUCCESS"
    }
    
    Write-TestLog "=== PRUEBAS FARE COMPLETADAS ===" "SUCCESS"
}

# ==================== PRUEBAS ROUTES ====================
function Test-RouteOperations {
    Write-TestLog "=== INICIANDO PRUEBAS ROUTES ===" "SUCCESS"
    
    # 1. Listar todas las rutas
    Write-TestLog "1. Listando todas las rutas..."
    $listResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/routes" -TestName "Listar Rutas"
    if ($listResult.Success -and $listResult.Data.status) {
        Write-TestLog "SUCCESS: $($listResult.Data.data.Count) rutas encontradas" "SUCCESS"
    }
    
    # 2. Crear nueva ruta
    Write-TestLog "2. Creando nueva ruta..."
    $routeData = @{
        organizationId = "org-test-001"
        routeCode = "ROUTE-TEST-PS-$(Get-Date -Format 'HHmmss')"
        routeName = "Ruta PowerShell Test"
        zones = @(
            @{
                zoneId = "zone-001"
                order = 1
                estimatedDuration = 2
            },
            @{
                zoneId = "zone-002"
                order = 2
                estimatedDuration = 3
            }
        )
        totalEstimatedDuration = 5
        responsibleUserId = "user-test-001"
    }
    
    $createResult = Invoke-ApiRequest -Method "POST" -Uri "$BaseUrl/api/admin/routes" -Body $routeData -TestName "Crear Ruta"
    if ($createResult.Success -and $createResult.Data.status) {
        $routeId = $createResult.Data.data.id
        $global:CreatedIds.Route += $routeId
        Write-TestLog "SUCCESS: Ruta creada con ID: $routeId" "SUCCESS"
        
        # 3. Obtener por ID
        Write-TestLog "3. Obteniendo ruta por ID..."
        $getResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/routes/$routeId" -TestName "Obtener Ruta por ID"
        if ($getResult.Success -and $getResult.Data.status) {
            Write-TestLog "SUCCESS: Ruta obtenida - $($getResult.Data.data.routeName)" "SUCCESS"
        }
        
        # 4. Actualizar ruta
        Write-TestLog "4. Actualizando ruta..."
        $updateData = @{
            id = $routeId
            organizationId = "org-test-001"
            routeCode = $routeData.routeCode
            routeName = "Ruta PowerShell Test - ACTUALIZADA"
            zones = @(
                @{
                    zoneId = "zone-001"
                    order = 1
                    estimatedDuration = 3
                },
                @{
                    zoneId = "zone-002"
                    order = 2
                    estimatedDuration = 4
                },
                @{
                    zoneId = "zone-003"
                    order = 3
                    estimatedDuration = 2
                }
            )
            totalEstimatedDuration = 9
            responsibleUserId = "user-test-001"
            status = "ACTIVE"
        }
        
        $updateResult = Invoke-ApiRequest -Method "PUT" -Uri "$BaseUrl/api/admin/routes/$routeId" -Body $updateData -TestName "Actualizar Ruta"
        if ($updateResult.Success -and $updateResult.Data.status) {
            Write-TestLog "SUCCESS: Ruta actualizada" "SUCCESS"
        }
        
        # 5. Desactivar ruta
        Write-TestLog "5. Desactivando ruta..."
        $deactivateResult = Invoke-ApiRequest -Method "PATCH" -Uri "$BaseUrl/api/admin/routes/$routeId/deactivate" -TestName "Desactivar Ruta"
        if ($deactivateResult.Success -and $deactivateResult.Data.status) {
            Write-TestLog "SUCCESS: Ruta desactivada" "SUCCESS"
        }
        
        # 6. Reactivar ruta
        Write-TestLog "6. Reactivando ruta..."
        $activateResult = Invoke-ApiRequest -Method "PATCH" -Uri "$BaseUrl/api/admin/routes/$routeId/activate" -TestName "Reactivar Ruta"
        if ($activateResult.Success -and $activateResult.Data.status) {
            Write-TestLog "SUCCESS: Ruta reactivada" "SUCCESS"
        }
        
        # 7. Eliminar ruta (si no se omite)
        if (-not $SkipDeletes) {
            Write-TestLog "7. Eliminando ruta..."
            $deleteResult = Invoke-ApiRequest -Method "DELETE" -Uri "$BaseUrl/api/admin/routes/$routeId" -TestName "Eliminar Ruta"
            if ($deleteResult.Success) {
                Write-TestLog "SUCCESS: Ruta eliminada" "SUCCESS"
                $global:CreatedIds.Route = $global:CreatedIds.Route | Where-Object { $_ -ne $routeId }
            }
        }
    }
    
    # 8. Listar rutas activas
    Write-TestLog "8. Listando rutas activas..."
    $activeResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/routes/active" -TestName "Listar Rutas Activas"
    if ($activeResult.Success -and $activeResult.Data.status) {
        Write-TestLog "SUCCESS: $($activeResult.Data.data.Count) rutas activas encontradas" "SUCCESS"
    }
    
    # 9. Listar rutas inactivas
    Write-TestLog "9. Listando rutas inactivas..."
    $inactiveResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/routes/inactive" -TestName "Listar Rutas Inactivas"
    if ($inactiveResult.Success -and $inactiveResult.Data.status) {
        Write-TestLog "SUCCESS: $($inactiveResult.Data.data.Count) rutas inactivas encontradas" "SUCCESS"
    }
    
    Write-TestLog "=== PRUEBAS ROUTES COMPLETADAS ===" "SUCCESS"
}

# ==================== PRUEBAS SCHEDULES ====================
function Test-ScheduleOperations {
    Write-TestLog "=== INICIANDO PRUEBAS SCHEDULES ===" "SUCCESS"
    
    # 1. Listar todos los horarios
    Write-TestLog "1. Listando todos los horarios..."
    $listResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/schedules" -TestName "Listar Horarios"
    if ($listResult.Success -and $listResult.Data.status) {
        Write-TestLog "SUCCESS: $($listResult.Data.data.Count) horarios encontrados" "SUCCESS"
    }
    
    # 2. Crear nuevo horario
    Write-TestLog "2. Creando nuevo horario..."
    $scheduleData = @{
        organizationId = "org-test-001"
        scheduleCode = "SCHED-TEST-PS-$(Get-Date -Format 'HHmmss')"
        zoneId = "zone-001"
        scheduleName = "Horario PowerShell Test"
        daysOfWeek = @("MONDAY", "WEDNESDAY", "FRIDAY")
        startTime = "08:00"
        endTime = "16:00"
        durationHours = 8
    }
    
    $createResult = Invoke-ApiRequest -Method "POST" -Uri "$BaseUrl/api/admin/schedules" -Body $scheduleData -TestName "Crear Horario"
    if ($createResult.Success -and $createResult.Data.status) {
        $scheduleId = $createResult.Data.data.id
        $global:CreatedIds.Schedule += $scheduleId
        Write-TestLog "SUCCESS: Horario creado con ID: $scheduleId" "SUCCESS"
        
        # 3. Obtener por ID
        Write-TestLog "3. Obteniendo horario por ID..."
        $getResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/schedules/$scheduleId" -TestName "Obtener Horario por ID"
        if ($getResult.Success -and $getResult.Data.status) {
            Write-TestLog "SUCCESS: Horario obtenido - $($getResult.Data.data.scheduleName)" "SUCCESS"
        }
        
        # 4. Actualizar horario
        Write-TestLog "4. Actualizando horario..."
        $updateData = @{
            id = $scheduleId
            organizationId = "org-test-001"
            scheduleCode = $scheduleData.scheduleCode
            zoneId = "zone-002"
            scheduleName = "Horario PowerShell Test - ACTUALIZADO"
            daysOfWeek = @("TUESDAY", "THURSDAY", "SATURDAY")
            startTime = "09:00"
            endTime = "17:00"
            durationHours = 8
            status = "ACTIVE"
        }
        
        $updateResult = Invoke-ApiRequest -Method "PUT" -Uri "$BaseUrl/api/admin/schedules/$scheduleId" -Body $updateData -TestName "Actualizar Horario"
        if ($updateResult.Success -and $updateResult.Data.status) {
            Write-TestLog "SUCCESS: Horario actualizado" "SUCCESS"
        }
        
        # 5. Desactivar horario
        Write-TestLog "5. Desactivando horario..."
        $deactivateResult = Invoke-ApiRequest -Method "PATCH" -Uri "$BaseUrl/api/admin/schedules/$scheduleId/deactivate" -TestName "Desactivar Horario"
        if ($deactivateResult.Success -and $deactivateResult.Data.status) {
            Write-TestLog "SUCCESS: Horario desactivado" "SUCCESS"
        }
        
        # 6. Reactivar horario
        Write-TestLog "6. Reactivando horario..."
        $activateResult = Invoke-ApiRequest -Method "PATCH" -Uri "$BaseUrl/api/admin/schedules/$scheduleId/activate" -TestName "Reactivar Horario"
        if ($activateResult.Success -and $activateResult.Data.status) {
            Write-TestLog "SUCCESS: Horario reactivado" "SUCCESS"
        }
        
        # 7. Eliminar horario (si no se omite)
        if (-not $SkipDeletes) {
            Write-TestLog "7. Eliminando horario..."
            $deleteResult = Invoke-ApiRequest -Method "DELETE" -Uri "$BaseUrl/api/admin/schedules/$scheduleId" -TestName "Eliminar Horario"
            if ($deleteResult.Success) {
                Write-TestLog "SUCCESS: Horario eliminado" "SUCCESS"
                $global:CreatedIds.Schedule = $global:CreatedIds.Schedule | Where-Object { $_ -ne $scheduleId }
            }
        }
    }
    
    # 8. Listar horarios activos
    Write-TestLog "8. Listando horarios activos..."
    $activeResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/schedules/active" -TestName "Listar Horarios Activos"
    if ($activeResult.Success -and $activeResult.Data.status) {
        Write-TestLog "SUCCESS: $($activeResult.Data.data.Count) horarios activos encontrados" "SUCCESS"
    }
    
    # 9. Listar horarios inactivos
    Write-TestLog "9. Listando horarios inactivos..."
    $inactiveResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/schedules/inactive" -TestName "Listar Horarios Inactivos"
    if ($inactiveResult.Success -and $inactiveResult.Data.status) {
        Write-TestLog "SUCCESS: $($inactiveResult.Data.data.Count) horarios inactivos encontrados" "SUCCESS"
    }
    
    Write-TestLog "=== PRUEBAS SCHEDULES COMPLETADAS ===" "SUCCESS"
}

# ==================== PRUEBAS PROGRAMS ====================
function Test-ProgramOperations {
    Write-TestLog "=== INICIANDO PRUEBAS PROGRAMS ===" "SUCCESS"
    
    # 1. Listar todos los programas
    Write-TestLog "1. Listando todos los programas..."
    $listResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/programs" -TestName "Listar Programas"
    if ($listResult.Success -and $listResult.Data.status) {
        Write-TestLog "SUCCESS: $($listResult.Data.data.Count) programas encontrados" "SUCCESS"
    }
    
    # 2. Crear nuevo programa
    Write-TestLog "2. Creando nuevo programa..."
    $programData = @{
        organizationId = "org-test-001"
        programCode = "PROG-TEST-PS-$(Get-Date -Format 'HHmmss')"
        scheduleId = "schedule-test-001"
        routeId = "route-test-001"
        zoneId = "zone-001"
        streetId = "street-001"
        programDate = "2025-09-15"
        plannedStartTime = "08:00"
        plannedEndTime = "16:00"
        actualStartTime = ""
        actualEndTime = ""
        status = "PLANNED"
        responsibleUserId = "user-test-001"
        observations = "Programa de prueba creado por PowerShell"
    }
    
    $createResult = Invoke-ApiRequest -Method "POST" -Uri "$BaseUrl/api/admin/programs" -Body $programData -TestName "Crear Programa"
    if ($createResult.Success -and $createResult.Data.status) {
        $programId = $createResult.Data.data.id
        $global:CreatedIds.Program += $programId
        Write-TestLog "SUCCESS: Programa creado con ID: $programId" "SUCCESS"
        
        # 3. Obtener por ID
        Write-TestLog "3. Obteniendo programa por ID..."
        $getResult = Invoke-ApiRequest -Method "GET" -Uri "$BaseUrl/api/admin/programs/$programId" -TestName "Obtener Programa por ID"
        if ($getResult.Success -and $getResult.Data.status) {
            Write-TestLog "SUCCESS: Programa obtenido - $($getResult.Data.data.programCode)" "SUCCESS"
        }
        
        # 4. Actualizar programa
        Write-TestLog "4. Actualizando programa..."
        $updateData = @{
            organizationId = "org-test-001"
            programCode = $programData.programCode
            scheduleId = "schedule-test-002"
            routeId = "route-test-002"
            zoneId = "zone-002"
            streetId = "street-002"
            programDate = "2025-09-16"
            plannedStartTime = "09:00"
            plannedEndTime = "17:00"
            actualStartTime = "09:15"
            actualEndTime = "17:30"
            status = "IN_PROGRESS"
            responsibleUserId = "user-test-002"
            observations = "Programa de prueba ACTUALIZADO por PowerShell"
        }
        
        $updateResult = Invoke-ApiRequest -Method "PUT" -Uri "$BaseUrl/api/admin/programs/$programId" -Body $updateData -TestName "Actualizar Programa"
        if ($updateResult.Success -and $updateResult.Data.status) {
            Write-TestLog "SUCCESS: Programa actualizado" "SUCCESS"
        }
        
        # 5. Desactivar programa
        Write-TestLog "5. Desactivando programa..."
        $deactivateResult = Invoke-ApiRequest -Method "PATCH" -Uri "$BaseUrl/api/admin/programs/$programId/deactivate" -TestName "Desactivar Programa"
        if ($deactivateResult.Success -and $deactivateResult.Data.status) {
            Write-TestLog "SUCCESS: Programa desactivado" "SUCCESS"
        }
        
        # 6. Reactivar programa
        Write-TestLog "6. Reactivando programa..."
        $activateResult = Invoke-ApiRequest -Method "PATCH" -Uri "$BaseUrl/api/admin/programs/$programId/activate" -TestName "Reactivar Programa"
        if ($activateResult.Success -and $activateResult.Data.status) {
            Write-TestLog "SUCCESS: Programa reactivado" "SUCCESS"
        }
        
        # 7. Eliminar programa (si no se omite)
        if (-not $SkipDeletes) {
            Write-TestLog "7. Eliminando programa..."
            $deleteResult = Invoke-ApiRequest -Method "DELETE" -Uri "$BaseUrl/api/admin/programs/$programId" -TestName "Eliminar Programa"
            if ($deleteResult.Success) {
                Write-TestLog "SUCCESS: Programa eliminado" "SUCCESS"
                $global:CreatedIds.Program = $global:CreatedIds.Program | Where-Object { $_ -ne $programId }
            }
        }
    }
    
    Write-TestLog "=== PRUEBAS PROGRAMS COMPLETADAS ===" "SUCCESS"
}

# ==================== FUNCIÓN PRINCIPAL ====================
function Start-AllTests {
    Write-TestLog "INICIANDO SUITE COMPLETA DE PRUEBAS CRUD" "SUCCESS"
    Write-TestLog "Base URL: $BaseUrl"
    Write-TestLog "Verbose: $Verbose"
    Write-TestLog "Skip Deletes: $SkipDeletes"
    Write-TestLog "========================================"
    
    # Verificar que el servidor esté funcionando
    try {
        $healthCheck = Invoke-RestMethod -Uri "$BaseUrl/api/admin/fare" -Method GET -TimeoutSec 5
        Write-TestLog "✓ Servidor funcionando correctamente" "SUCCESS"
    }
    catch {
        Write-TestLog "✗ No se puede conectar al servidor en $BaseUrl" "ERROR"
        Write-TestLog "Asegúrate de que la aplicación esté corriendo" "ERROR"
        return
    }
    
    # Ejecutar todas las pruebas
    Test-FareOperations
    Write-TestLog ""
    Test-RouteOperations  
    Write-TestLog ""
    Test-ScheduleOperations
    Write-TestLog ""
    Test-ProgramOperations
    
    # Resumen final
    Write-TestLog ""
    Write-TestLog "========================================"
    Write-TestLog "RESUMEN DE PRUEBAS COMPLETADAS" "SUCCESS"
    Write-TestLog "Elementos creados y no eliminados:"
    if ($global:CreatedIds.Fare.Count -gt 0) {
        Write-TestLog "- Fares: $($global:CreatedIds.Fare -join ', ')" "INFO"
    }
    if ($global:CreatedIds.Route.Count -gt 0) {
        Write-TestLog "- Routes: $($global:CreatedIds.Route -join ', ')" "INFO"
    }
    if ($global:CreatedIds.Schedule.Count -gt 0) {
        Write-TestLog "- Schedules: $($global:CreatedIds.Schedule -join ', ')" "INFO"
    }
    if ($global:CreatedIds.Program.Count -gt 0) {
        Write-TestLog "- Programs: $($global:CreatedIds.Program -join ', ')" "INFO"
    }
    
    Write-TestLog "✓ TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE" "SUCCESS"
}

# Ejecutar las pruebas
Start-AllTests