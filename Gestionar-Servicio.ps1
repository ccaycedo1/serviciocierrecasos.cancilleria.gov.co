# Script de Gestión del Servicio de Windows
# Autor: Copilot
# Descripción: Controla el servicio ServicioCierreCasos (iniciar, detener, reiniciar, estado)

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Iniciar", "Detener", "Reiniciar", "Estado", "Logs", "Config")]
    [string]$Accion = "Estado",
    
    [Parameter(Mandatory = $false)]
    [string]$NombreServicio = "ServicioCierreCasos"
)

$ErrorActionPreference = 'Continue'

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

# Obtener estado del servicio
function Show-ServiceStatus {
    Write-Header "ESTADO DEL SERVICIO: $NombreServicio"
    
    $servicio = Get-Service -Name $NombreServicio -ErrorAction SilentlyContinue
    
    if (-not $servicio) {
        Write-Error-Custom "El servicio '$NombreServicio' no está instalado"
        exit 1
    }
    
    Write-Host "Nombre del Servicio:" -ForegroundColor Yellow
    Write-Host "  $($servicio.Name)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Nombre Display:" -ForegroundColor Yellow
    Write-Host "  $($servicio.DisplayName)" -ForegroundColor Gray
    Write-Host ""
    
    $statusColor = if ($servicio.Status -eq "Running") { "Green" } else { "Red" }
    $statusText = if ($servicio.Status -eq "Running") { "EJECUTÁNDOSE" } else { "DETENIDO" }
    
    Write-Host "Estado:" -ForegroundColor Yellow
    Write-Host "  " -NoNewline
    Write-Host $statusText -ForegroundColor $statusColor
    Write-Host ""
    
    Write-Host "Tipo de Inicio:" -ForegroundColor Yellow
    Write-Host "  $($servicio.StartType)" -ForegroundColor Gray
    Write-Host ""
    
    # Información adicional
    Write-Host "Información Técnica:" -ForegroundColor Yellow
    
    $wmiService = Get-WmiObject Win32_Service -Filter "Name='$NombreServicio'" -ErrorAction SilentlyContinue
    
    if ($wmiService) {
        Write-Host "  Ruta Ejecutable: $($wmiService.PathName)" -ForegroundColor Gray
        Write-Host "  Cuenta: $($wmiService.StartName)" -ForegroundColor Gray
        Write-Host "  Descripción: $($wmiService.Description)" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# Iniciar servicio
function Start-Service-Custom {
    Write-Header "INICIANDO SERVICIO: $NombreServicio"
    
    $servicio = Get-Service -Name $NombreServicio -ErrorAction SilentlyContinue
    
    if (-not $servicio) {
        Write-Error-Custom "El servicio '$NombreServicio' no está instalado"
        exit 1
    }
    
    if ($servicio.Status -eq "Running") {
        Write-Warning-Custom "El servicio ya se encuentra ejecutándose"
        return
    }
    
    Write-Info "Iniciando servicio..."
    
    try {
        Start-Service -Name $NombreServicio -ErrorAction Stop
        Start-Sleep -Seconds 2
        
        $servicio = Get-Service -Name $NombreServicio
        if ($servicio.Status -eq "Running") {
            Write-Success "Servicio iniciado correctamente"
        } else {
            Write-Error-Custom "No se pudo iniciar el servicio"
            exit 1
        }
    } catch {
        Write-Error-Custom "Error al iniciar el servicio: $_"
        exit 1
    }
    
    Write-Host ""
}

# Detener servicio
function Stop-Service-Custom {
    Write-Header "DETENIENDO SERVICIO: $NombreServicio"
    
    $servicio = Get-Service -Name $NombreServicio -ErrorAction SilentlyContinue
    
    if (-not $servicio) {
        Write-Error-Custom "El servicio '$NombreServicio' no está instalado"
        exit 1
    }
    
    if ($servicio.Status -eq "Stopped") {
        Write-Warning-Custom "El servicio ya se encuentra detenido"
        return
    }
    
    Write-Info "Deteniendo servicio..."
    
    try {
        Stop-Service -Name $NombreServicio -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        
        $servicio = Get-Service -Name $NombreServicio
        if ($servicio.Status -eq "Stopped") {
            Write-Success "Servicio detenido correctamente"
        } else {
            Write-Error-Custom "No se pudo detener el servicio"
            exit 1
        }
    } catch {
        Write-Error-Custom "Error al detener el servicio: $_"
        exit 1
    }
    
    Write-Host ""
}

# Reiniciar servicio
function Restart-Service-Custom {
    Write-Header "REINICIANDO SERVICIO: $NombreServicio"
    
    $servicio = Get-Service -Name $NombreServicio -ErrorAction SilentlyContinue
    
    if (-not $servicio) {
        Write-Error-Custom "El servicio '$NombreServicio' no está instalado"
        exit 1
    }
    
    Write-Info "Deteniendo servicio..."
    Stop-Service -Name $NombreServicio -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    Write-Info "Iniciando servicio..."
    Start-Service -Name $NombreServicio -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    $servicio = Get-Service -Name $NombreServicio
    if ($servicio.Status -eq "Running") {
        Write-Success "Servicio reiniciado correctamente"
    } else {
        Write-Error-Custom "No se pudo reiniciar el servicio"
        exit 1
    }
    
    Write-Host ""
}

# Ver logs de eventos
function Show-ServiceLogs {
    Write-Header "LOGS DE EVENTOS DEL SERVICIO: $NombreServicio"
    
    Write-Info "Últimos 10 eventos registrados:"
    Write-Host ""
    
    $eventos = Get-EventLog -LogName Application -Source $NombreServicio -Newest 10 -ErrorAction SilentlyContinue
    
    if (-not $eventos) {
        Write-Warning-Custom "No hay eventos registrados para este servicio"
        Write-Host ""
        return
    }
    
    $eventos | ForEach-Object {
        $tipoColor = switch ($_.EntryType) {
            "Error" { "Red" }
            "Warning" { "Yellow" }
            "Information" { "Green" }
            default { "Gray" }
        }
        
        Write-Host "[$($_.TimeGenerated)] " -NoNewline
        Write-Host "$($_.EntryType)" -ForegroundColor $tipoColor -NoNewline
        Write-Host " - $($_.Message)" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# Mostrar configuración
function Show-ServiceConfig {
    Write-Header "CONFIGURACIÓN DEL SERVICIO: $NombreServicio"
    
    $servicio = Get-Service -Name $NombreServicio -ErrorAction SilentlyContinue
    
    if (-not $servicio) {
        Write-Error-Custom "El servicio '$NombreServicio' no está instalado"
        exit 1
    }
    
    Write-Info "Configuración del Registro:"
    Write-Host ""
    
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$NombreServicio"
    
    if (Test-Path $registryPath) {
        $items = Get-ItemProperty -Path $registryPath
        
        Write-Host "Tipo: " -NoNewline; Write-Host "$($items.Type)" -ForegroundColor Gray
        Write-Host "Start: " -NoNewline; Write-Host "$($items.Start)" -ForegroundColor Gray
        Write-Host "ImagePath: " -NoNewline; Write-Host "$($items.ImagePath)" -ForegroundColor Gray
        Write-Host "DisplayName: " -NoNewline; Write-Host "$($items.DisplayName)" -ForegroundColor Gray
        Write-Host "Description: " -NoNewline; Write-Host "$($items.Description)" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# Programa Principal
Write-Host ""

$Accion = $Accion -replace '^\s+|\s+$'

switch ($Accion) {
    "Iniciar" {
        if (-not (Test-AdminRights)) {
            Write-Error-Custom "Se requieren permisos de administrador"
            exit 1
        }
        Start-Service-Custom
    }
    
    "Detener" {
        if (-not (Test-AdminRights)) {
            Write-Error-Custom "Se requieren permisos de administrador"
            exit 1
        }
        Stop-Service-Custom
    }
    
    "Reiniciar" {
        if (-not (Test-AdminRights)) {
            Write-Error-Custom "Se requieren permisos de administrador"
            exit 1
        }
        Restart-Service-Custom
    }
    
    "Logs" {
        Show-ServiceLogs
    }
    
    "Config" {
        Show-ServiceConfig
    }
    
    "Estado" {
        Show-ServiceStatus
    }
    
    default {
        Write-Error-Custom "Acción no reconocida: $Accion"
        Write-Host ""
        Write-Host "Acciones disponibles:" -ForegroundColor Yellow
        Write-Host "  Iniciar   - Inicia el servicio" -ForegroundColor Gray
        Write-Host "  Detener   - Detiene el servicio" -ForegroundColor Gray
        Write-Host "  Reiniciar - Reinicia el servicio" -ForegroundColor Gray
        Write-Host "  Estado    - Muestra el estado del servicio" -ForegroundColor Gray
        Write-Host "  Logs      - Muestra los logs de eventos" -ForegroundColor Gray
        Write-Host "  Config    - Muestra la configuración del servicio" -ForegroundColor Gray
        Write-Host ""
        exit 1
    }
}
