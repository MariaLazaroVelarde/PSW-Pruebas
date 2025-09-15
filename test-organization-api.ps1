# Script de PowerShell para probar endpoints de organización
Write-Host "=== PRUEBAS DE ENDPOINTS DE ORGANIZACIÓN ===" -ForegroundColor Green

# URL base de la API
$baseUrl = "http://localhost:8086"

# ID de organización de prueba
$organizationId = "66fbd29e23d9041b5c1cdd37"

Write-Host "`n1. Probando endpoint de test..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/organizations/test" -Method GET -Headers @{'accept'='application/json'}
    Write-Host "✓ Endpoint de test: $response" -ForegroundColor Green
} catch {
    Write-Host "✗ Error en endpoint de test: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Probando verificación de existencia de organización..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/organizations/$organizationId/exists" -Method GET -Headers @{'accept'='application/json'}
    Write-Host "✓ Organización existe: $response" -ForegroundColor Green
} catch {
    Write-Host "✗ Error al verificar organización: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Probando obtener administradores..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/organizations/$organizationId/admins" -Method GET -Headers @{'accept'='application/json'}
    if ($response -and $response.Count -gt 0) {
        Write-Host "✓ Administradores encontrados: $($response.Count)" -ForegroundColor Green
        $response | ForEach-Object { Write-Host "  - $($_.firstName) $($_.lastName) ($($_.email))" }
    } else {
        Write-Host "⚠ No se encontraron administradores" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error al obtener administradores: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4. Probando obtener usuarios..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/organizations/$organizationId/users" -Method GET -Headers @{'accept'='application/json'}
    if ($response -and $response.Count -gt 0) {
        Write-Host "✓ Usuarios encontrados: $($response.Count)" -ForegroundColor Green
        $response | ForEach-Object { Write-Host "  - Usuario: $($_.id)" }
    } else {
        Write-Host "⚠ No se encontraron usuarios" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error al obtener usuarios: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n5. Probando obtener clientes..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/organizations/$organizationId/clients" -Method GET -Headers @{'accept'='application/json'}
    if ($response -and $response.Count -gt 0) {
        Write-Host "✓ Clientes encontrados: $($response.Count)" -ForegroundColor Green
        $response | ForEach-Object { Write-Host "  - Cliente: $($_.id)" }
    } else {
        Write-Host "⚠ No se encontraron clientes" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error al obtener clientes: $($_.Exception.Message)" -ForegroundColor Red
}

# Probar con diferentes IDs de organización
$testOrganizations = @("66fbd29e23d9041b5c1cdd37", "test-org", "123456")

Write-Host "`n=== PROBANDO MÚLTIPLES ORGANIZACIONES ===" -ForegroundColor Cyan
foreach ($testOrgId in $testOrganizations) {
    Write-Host "`nProbando organización: $testOrgId" -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/organizations/$testOrgId/exists" -Method GET -Headers @{'accept'='application/json'}
        Write-Host "  Existe: $response" -ForegroundColor Green
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== FIN DE PRUEBAS ===" -ForegroundColor Green