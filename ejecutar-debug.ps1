# Script de Depuración - Actualización de Estados de Pagos
# Este script ejecuta el programa en modo consola para ver todos los mensajes

[System.Console]::Clear()

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   EJECUTANDO PROGRAMA DE DEPURACIÓN                           ║" -ForegroundColor Cyan
Write-Host "║   Actualización Automática de Estados de Pagos               ║" -ForegroundColor Cyan
Write-Host "║   Versión 1.0                                                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Cambiar al directorio del script
Push-Location $PSScriptRoot

Write-Host "📂 Directorio: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

# Verificar que .NET esté disponible
try {
    $dotnetVersion = dotnet --version 2>$null
    Write-Host "✅ .NET SDK detectado: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: .NET SDK no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, instala .NET 10.0 SDK desde:" -ForegroundColor Yellow
    Write-Host "https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presiona Enter para cerrar..."
    exit 1
}

Write-Host ""

# Compilar el proyecto en modo Debug
Write-Host "🔨 Compilando el proyecto..." -ForegroundColor Yellow
Write-Host ""

dotnet build -c Debug

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ ERROR: La compilación falló" -ForegroundColor Red
    Write-Host ""
    Read-Host "Presiona Enter para cerrar..."
    exit 1
}

Write-Host ""
Write-Host "✅ Compilación exitosa" -ForegroundColor Green
Write-Host ""

# Ejecutar el programa de depuración
Write-Host "🚀 Iniciando programa de depuración..." -ForegroundColor Yellow
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host ""

dotnet run --project DebugConsole\DebugConsole.csproj --no-build

$exitCode = $LASTEXITCODE

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Gray

if ($exitCode -ne 0) {
    Write-Host "❌ ERROR: El programa falló durante la ejecución" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, verifica:" -ForegroundColor Yellow
    Write-Host "  1. Las cadenas de conexión en appsettings.json" -ForegroundColor Yellow
    Write-Host "  2. La accesibilidad del servidor SQL" -ForegroundColor Yellow
    Write-Host "  3. Los permisos de la base de datos" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "✅ Ejecución completada exitosamente" -ForegroundColor Green
}

Write-Host ""
Read-Host "Presiona Enter para cerrar..."

Pop-Location
exit $exitCode
