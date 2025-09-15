# ==============================================
# Script de Despliegue a Docker Hub - Windows
# Water Distribution Microservice
# ==============================================

param(
    [string]$DockerUsername = "victorcuaresmadev",
    [string]$ImageName = "vg-ms-distribution", 
    [string]$Tag = "latest",
    [switch]$SkipTests = $true,
    [switch]$CleanLocal = $false
)

# Configuración
$FullImageName = "$DockerUsername/$ImageName`:$Tag"
$DateTag = Get-Date -Format "yyyyMMdd-HHmmss"
$DatedImageName = "$DockerUsername/$ImageName`:$DateTag"

# Funciones auxiliares
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    $ColorMap = @{
        "Red" = "Red"
        "Green" = "Green" 
        "Yellow" = "Yellow"
        "Blue" = "Blue"
        "Cyan" = "Cyan"
    }
    Write-Host $Message -ForegroundColor $ColorMap[$Color]
}

function Test-Command {
    param([string]$Command)
    try {
        & $Command --version | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Banner inicial
Write-ColorOutput "===============================================" "Blue"
Write-ColorOutput "🚀 Despliegue a Docker Hub" "Blue"
Write-ColorOutput "Proyecto: Water Distribution Microservice" "Blue"
Write-ColorOutput "===============================================" "Blue"

try {
    # 1. Verificar Docker
    Write-ColorOutput "🔍 Verificando Docker..." "Yellow"
    if (-not (Test-Command "docker")) {
        throw "Docker no está instalado o no está en el PATH"
    }
    
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker no está funcionando correctamente"
    }
    Write-ColorOutput "✅ Docker funcionando correctamente" "Green"

    # 2. Login a Docker Hub
    Write-ColorOutput "🔐 Login a Docker Hub..." "Yellow"
    Write-ColorOutput "Ingresa tus credenciales de Docker Hub:" "Cyan"
    docker login
    if ($LASTEXITCODE -ne 0) {
        throw "Error en login a Docker Hub"
    }
    Write-ColorOutput "✅ Login exitoso" "Green"

    # 3. Limpiar builds anteriores
    Write-ColorOutput "🧹 Limpiando builds anteriores..." "Yellow"
    docker system prune -f | Out-Null

    # 4. Compilar aplicación
    Write-ColorOutput "🔨 Compilando aplicación Java..." "Yellow"
    
    $mvnCommand = $null
    if (Test-Path ".\mvnw.cmd") {
        $mvnCommand = ".\mvnw.cmd"
    }
    elseif (Test-Command "mvn") {
        $mvnCommand = "mvn"
    }
    else {
        throw "Maven no encontrado (mvnw.cmd o mvn)"
    }

    $buildArgs = @("clean", "package")
    if ($SkipTests) {
        $buildArgs += "-DskipTests"
    }

    Write-ColorOutput "Ejecutando: $mvnCommand $($buildArgs -join ' ')" "Cyan"
    & $mvnCommand $buildArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Error compilando la aplicación"
    }
    Write-ColorOutput "✅ Aplicación compilada exitosamente" "Green"

    # 5. Construir imagen Docker
    Write-ColorOutput "🐳 Construyendo imagen Docker..." "Yellow"
    Write-ColorOutput "Imagen: $FullImageName" "Cyan"
    
    docker build -t $FullImageName .
    if ($LASTEXITCODE -ne 0) {
        throw "Error construyendo imagen Docker"
    }
    Write-ColorOutput "✅ Imagen construida: $FullImageName" "Green"

    # 6. Crear tag con fecha
    Write-ColorOutput "🏷️ Creando tag con fecha..." "Yellow"
    docker tag $FullImageName $DatedImageName
    if ($LASTEXITCODE -ne 0) {
        throw "Error creando tag con fecha"
    }
    Write-ColorOutput "✅ Tag creado: $DatedImageName" "Green"

    # 7. Subir a Docker Hub
    Write-ColorOutput "📤 Subiendo a Docker Hub..." "Yellow"
    
    Write-ColorOutput "Subiendo imagen principal..." "Cyan"
    docker push $FullImageName
    if ($LASTEXITCODE -ne 0) {
        throw "Error subiendo imagen principal"
    }
    
    Write-ColorOutput "Subiendo imagen con fecha..." "Cyan"
    docker push $DatedImageName
    if ($LASTEXITCODE -ne 0) {
        throw "Error subiendo imagen con fecha"
    }
    
    Write-ColorOutput "✅ Imágenes subidas exitosamente" "Green"

    # 8. Mostrar resumen
    Write-ColorOutput "===============================================" "Blue"
    Write-ColorOutput "🎉 ¡Despliegue completado exitosamente!" "Green"
    Write-ColorOutput "===============================================" "Blue"
    Write-ColorOutput "📋 Información de las imágenes:" "Yellow"
    Write-ColorOutput "   🏷️  Imagen principal: $FullImageName" "White"
    Write-ColorOutput "   📅 Imagen con fecha: $DatedImageName" "White"
    Write-ColorOutput "   🌐 Docker Hub: https://hub.docker.com/r/$DockerUsername/$ImageName" "White"
    Write-ColorOutput "" "White"
    Write-ColorOutput "🚀 Para usar en producción:" "Yellow"
    Write-ColorOutput "   docker pull $FullImageName" "White"
    Write-ColorOutput "   docker-compose -f docker-compose.prod.yml up -d" "White"
    Write-ColorOutput "" "White"
    Write-ColorOutput "🔗 Endpoints disponibles:" "Yellow"
    Write-ColorOutput "   📊 Health Check: https://lab.vallegrande.edu.pe:8086/actuator/health" "White"
    Write-ColorOutput "   📚 Swagger UI: https://lab.vallegrande.edu.pe:8086/swagger-ui.html" "White"
    Write-ColorOutput "   📈 Metrics: https://lab.vallegrande.edu.pe:8086/actuator/prometheus" "White"

    # 9. Limpiar imágenes locales (opcional)
    if ($CleanLocal) {
        Write-ColorOutput "🧹 Limpiando imágenes locales..." "Yellow"
        docker rmi $FullImageName -f | Out-Null
        docker rmi $DatedImageName -f | Out-Null
        Write-ColorOutput "✅ Limpieza completada" "Green"
    }
    else {
        Write-ColorOutput "💡 Para limpiar imágenes locales, usa: -CleanLocal" "Cyan"
    }

    Write-ColorOutput "===============================================" "Blue"
    Write-ColorOutput "🎊 ¡Proceso completado exitosamente!" "Green"
}
catch {
    Write-ColorOutput "❌ Error: $($_.Exception.Message)" "Red"
    Write-ColorOutput "❌ Proceso abortado" "Red"
    exit 1
}