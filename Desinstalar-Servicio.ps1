# Script de Desinstalación del Servicio de Windows
# Autor: Copilot
# Descripción: Desinstala ServicioCierreCasos del sistema

param(
    [Parameter(Mandatory = $false)]
    [string]$NombreServicio = "ServicioCierreCasos",
    
    [switch]$Fuerza
)

$ErrorActionPreference = 'Stop'

# Funciones de utilidad
function Test-AdminRights {
    $admin = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($admin)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Header {
    param([string]$Texto)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ $($Texto.PadRight(66)) ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Texto)
    Write-Host "✅ $Texto" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Texto)
    Write-Host "❌ $Texto" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Texto)
    Write-Host "⚠️  $Texto" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Texto)
    Write-Host "ℹ️  $Texto" -ForegroundColor Cyan
}

# Verificar permisos
if (-not (Test-AdminRights)) {
    Write-Error-Custom "Este script requiere permisos de administrador"
    exit 1
}

Write-Header "DESINSTALADOR DE SERVICIO - ServicioCierreCasos"

# Verificar si el servicio existe
if (-not (Get-Service -Name $NombreServicio -ErrorAction SilentlyContinue)) {
    Write-Warning-Custom "El servicio '$NombreServicio' no está instalado"
    exit 0
}

# Confirmar desinstalación
if (-not $Fuerza) {
    Write-Warning-Custom "Se va a desinstalar el servicio '$NombreServicio'"
    Write-Host ""
    Write-Host "¿Estás seguro de que deseas continuar? (S/N)" -ForegroundColor Yellow
    $respuesta = Read-Host
    
    if ($respuesta -ne "S" -and $respuesta -ne "s") {
        Write-Info "Desinstalación cancelada"
        exit 0
    }
}

Write-Host ""

# Obtener información del servicio
$servicio = Get-Service -Name $NombreServicio
Write-Info "Información del servicio:"
Write-Host "  Nombre: $($servicio.Name)" -ForegroundColor Gray
Write-Host "  Display: $($servicio.DisplayName)" -ForegroundColor Gray
Write-Host "  Estado: $($servicio.Status)" -ForegroundColor Gray

Write-Host ""

# Detener servicio si está corriendo
if ($servicio.Status -eq "Running") {
    Write-Info "Deteniendo servicio..."
    try {
        Stop-Service -Name $NombreServicio -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        Write-Success "Servicio detenido"
    } catch {
        Write-Error-Custom "Error al detener el servicio: $_"
        exit 1
    }
}

# Eliminar servicio
Write-Info "Eliminando servicio del sistema..."
try {
    Remove-Service -Name $NombreServicio -Force -ErrorAction Stop
    Start-Sleep -Seconds 1
    Write-Success "Servicio eliminado correctamente"
} catch {
    Write-Error-Custom "Error al eliminar el servicio: $_"
    exit 1
}

Write-Host ""
Write-Header "DESINSTALACIÓN COMPLETADA"
Write-Host "El servicio '$NombreServicio' ha sido removido del sistema." -ForegroundColor Green
Write-Host ""
