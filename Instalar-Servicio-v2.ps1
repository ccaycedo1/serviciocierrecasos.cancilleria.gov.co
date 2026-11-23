# Script de Instalación del Servicio de Windows - ServicioCierreCasos
# Autor: Copilot
# Versión: 2.0
# Descripción: Instala ServicioCierreCasos como servicio de Windows con opciones avanzadas

param(
    [Parameter(Mandatory = $false)]
    [string]$RutaPublicacion = "",
    
    [Parameter(Mandatory = $false)]
    [string]$NombreServicio = "ServicioCierreCasos",
    
    [Parameter(Mandatory = $false)]
    [string]$NombreDisplay = "Servicio de Cierre de Casos",
    
    [Parameter(Mandatory = $false)]
    [string]$Descripcion = "Servicio automatizado para el cierre de casos y actualización de estados de pagos",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("Automatic", "Manual", "Disabled")]
    [string]$TipoInicio = "Automatic",
    
    [Parameter(Mandatory = $false)]
    [string]$UsuarioServicio = "LocalSystem",
    
    [Parameter(Mandatory = $false)]
    [string]$ContraseñaServicio = "",
    
    [switch]$Desinstalar,
    [switch]$Reparar,
    [switch]$Silencioso
)

# Configuración
$ErrorActionPreference = 'Stop'
$RutaScript = Split-Path -Parent $MyInvocation.MyCommand.Path

# Funciones de Utilidad
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

# Verificar permisos de administrador
function Test-AdminRights {
    $admin = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($admin)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Obtener ruta de publicación
function Get-PublicationPath {
    if ($RutaPublicacion) {
        return (Resolve-Path -LiteralPath $RutaPublicacion).Path
    }
    
    Write-Host ""
    Write-Host "Ingrese la ruta de publicación del proyecto:" -ForegroundColor Yellow
    Write-Host "(Ejemplo: C:\PublishedApps\ServicioCierreCasos)" -ForegroundColor Gray
    $ruta = Read-Host "Ruta"
    
    if (-not $ruta) {
        # Intentar ubicación por defecto
        $rutaDefecto = Join-Path $RutaScript "bin\Release\net10.0\publish"
        if (Test-Path $rutaDefecto) {
            Write-Info "Usando ruta por defecto: $rutaDefecto"
            return $rutaDefecto
        }
        
        Write-Error-Custom "Se requiere especificar la ruta de publicación"
        exit 1
    }
    
    return (Resolve-Path -LiteralPath $ruta).Path
}

# Validar ejecutable
function Test-ExecutablePath {
    param([string]$Ruta)
    
    $ejecutable = Join-Path $Ruta "ServicioCierreCasos.exe"
    
    if (-not (Test-Path -LiteralPath $ejecutable -PathType Leaf)) {
        Write-Error-Custom "No se encontró el ejecutable: $ejecutable"
        return $null
    }
    
    return $ejecutable
}

# Instalar servicio
function Install-WindowsService {
    param(
        [string]$NombreServ,
        [string]$RutaEjecutable,
        [string]$NombreDisp,
        [string]$Desc,
        [string]$Inicio,
        [string]$Usuario,
        [string]$Contrasena
    )
    
    Write-Header "INSTALANDO SERVICIO DE WINDOWS"
    
    # Verificar si el servicio ya existe
    if (Get-Service -Name $NombreServ -ErrorAction SilentlyContinue) {
        Write-Warning-Custom "El servicio '$NombreServ' ya existe"
        
        $respuesta = Read-Host "¿Deseas reemplazarlo? (S/N)"
        if ($respuesta -eq "S" -or $respuesta -eq "s") {
            Write-Info "Deteniendo servicio existente..."
            Stop-Service -Name $NombreServ -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            
            Write-Info "Eliminando servicio existente..."
            Remove-Service -Name $NombreServ -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        } else {
            Write-Error-Custom "Instalación cancelada"
            exit 1
        }
    }
    
    # Crear servicio
    Write-Info "Creando servicio..."
    
    $params = @{
        Name = $NombreServ
        BinaryPathName = "`"$RutaEjecutable`""
        DisplayName = $NombreDisp
        Description = $Desc
        StartupType = $Inicio
    }
    
    # Si se especifica usuario diferente a LocalSystem
    if ($Usuario -ne "LocalSystem") {
        if (-not $Contrasena) {
            Write-Warning-Custom "Se requiere contraseña para usuario: $Usuario"
            $Contrasena = Read-Host "Ingrese la contraseña" -AsSecureString
        } else {
            $Contrasena = ConvertTo-SecureString $Contrasena -AsPlainText -Force
        }
        
        $params.Add("Credential", (New-Object System.Management.Automation.PSCredential($Usuario, $Contrasena)))
    }
    
    try {
        New-Service @params -ErrorAction Stop | Out-Null
        Write-Success "Servicio '$NombreServ' instalado correctamente"
    } catch {
        Write-Error-Custom "Error al instalar el servicio: $_"
        exit 1
    }
    
    # Mostrar detalles del servicio
    Write-Host ""
    Write-Info "Detalles del servicio instalado:"
    Get-Service -Name $NombreServ | Select-Object Name, DisplayName, StartType, Status | Format-List | Out-String | Write-Host
}

# Desinstalar servicio
function Uninstall-WindowsService {
    param([string]$NombreServ)
    
    Write-Header "DESINSTALANDO SERVICIO DE WINDOWS"
    
    if (-not (Get-Service -Name $NombreServ -ErrorAction SilentlyContinue)) {
        Write-Warning-Custom "El servicio '$NombreServ' no existe"
        exit 1
    }
    
    Write-Warning-Custom "Se va a desinstalar el servicio '$NombreServ'"
    $respuesta = Read-Host "¿Estás seguro? (S/N)"
    
    if ($respuesta -ne "S" -and $respuesta -ne "s") {
        Write-Info "Desinstalación cancelada"
        exit 0
    }
    
    # Detener servicio
    Write-Info "Deteniendo servicio..."
    $servicio = Get-Service -Name $NombreServ
    
    if ($servicio.Status -eq "Running") {
        Stop-Service -Name $NombreServ -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
    
    # Eliminar servicio
    Write-Info "Eliminando servicio..."
    try {
        Remove-Service -Name $NombreServ -Force -ErrorAction Stop
        Start-Sleep -Seconds 1
        Write-Success "Servicio '$NombreServ' desinstalado correctamente"
    } catch {
        Write-Error-Custom "Error al desinstalar el servicio: $_"
        exit 1
    }
}

# Reparar servicio
function Repair-WindowsService {
    param(
        [string]$NombreServ,
        [string]$RutaEjecutable,
        [string]$NombreDisp,
        [string]$Desc
    )
    
    Write-Header "REPARANDO SERVICIO DE WINDOWS"
    
    if (-not (Get-Service -Name $NombreServ -ErrorAction SilentlyContinue)) {
        Write-Warning-Custom "El servicio '$NombreServ' no existe"
        Write-Info "Procediendo a instalarlo..."
        Install-WindowsService -NombreServ $NombreServ -RutaEjecutable $RutaEjecutable `
            -NombreDisp $NombreDisp -Desc $Desc -Inicio "Automatic" -Usuario "LocalSystem" -Contrasena ""
        return
    }
    
    Write-Info "Deteniendo servicio..."
    Stop-Service -Name $NombreServ -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    Write-Info "Actualizando ruta del ejecutable..."
    
    # Usar sc.exe para actualizar la ruta (New-Service no permite modificar existentes)
    & sc.exe config $NombreServ binPath= "`"$RutaEjecutable`""
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Ruta del ejecutable actualizada"
    } else {
        Write-Error-Custom "Error al actualizar la ruta del ejecutable"
    }
    
    Write-Info "Iniciando servicio..."
    Start-Service -Name $NombreServ -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    Write-Success "Servicio reparado correctamente"
}

# Mostrar estado del servicio
function Show-ServiceStatus {
    param([string]$NombreServ)
    
    Write-Header "ESTADO DEL SERVICIO"
    
    $servicio = Get-Service -Name $NombreServ -ErrorAction SilentlyContinue
    
    if (-not $servicio) {
        Write-Warning-Custom "El servicio '$NombreServ' no está instalado"
        return
    }
    
    Write-Host ""
    Write-Host "Nombre del Servicio: $($servicio.Name)" -ForegroundColor Cyan
    Write-Host "Nombre Display: $($servicio.DisplayName)" -ForegroundColor Cyan
    Write-Host "Estado: $(if ($servicio.Status -eq 'Running') { 'Ejecutándose' } else { 'Detenido' })" -ForegroundColor $(if ($servicio.Status -eq 'Running') { 'Green' } else { 'Yellow' })
    Write-Host "Tipo de Inicio: $($servicio.StartType)" -ForegroundColor Cyan
    Write-Host ""
}

# Programa Principal
function Main {
    # Verificar permisos de administrador
    if (-not (Test-AdminRights)) {
        Write-Error-Custom "Este script requiere permisos de administrador"
        Write-Info "Por favor, ejecuta PowerShell como administrador"
        exit 1
    }
    
    # Mostrar encabezado
    if (-not $Silencioso) {
        Write-Header "INSTALADOR DE SERVICIO - ServicioCierreCasos v2.0"
    }
    
    # Opciones de operación
    if ($Desinstalar) {
        Uninstall-WindowsService -NombreServ $NombreServicio
    } elseif ($Reparar) {
        $rutaPublicacion = Get-PublicationPath
        $ejecutable = Test-ExecutablePath -Ruta $rutaPublicacion
        if (-not $ejecutable) { exit 1 }
        
        Repair-WindowsService -NombreServ $NombreServicio -RutaEjecutable $ejecutable `
            -NombreDisp $NombreDisplay -Desc $Descripcion
    } else {
        # Instalar (por defecto)
        $rutaPublicacion = Get-PublicationPath
        $ejecutable = Test-ExecutablePath -Ruta $rutaPublicacion
        if (-not $ejecutable) { exit 1 }
        
        Install-WindowsService -NombreServ $NombreServicio -RutaEjecutable $ejecutable `
            -NombreDisp $NombreDisplay -Desc $Descripcion -Inicio $TipoInicio `
            -Usuario $UsuarioServicio -Contrasena $ContraseñaServicio
        
        # Mostrar estado
        Show-ServiceStatus -NombreServ $NombreServicio
        
        Write-Header "INSTALACIÓN COMPLETADA"
        Write-Host ""
        Write-Host "Próximos pasos:" -ForegroundColor Yellow
        Write-Host "1. Verificar la configuración en appsettings.json" -ForegroundColor Gray
        Write-Host "2. Iniciar el servicio: Start-Service -Name $NombreServicio" -ForegroundColor Gray
        Write-Host "3. Verificar logs del evento: Get-EventLog -LogName Application -Source $NombreServicio" -ForegroundColor Gray
        Write-Host ""
    }
}

# Ejecutar programa principal
Main
