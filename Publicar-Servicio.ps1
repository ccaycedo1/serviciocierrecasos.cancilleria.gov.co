# Script de Publicación para Servicio de Windows
# Autor: Copilot
# Descripción: Publica ServicioCierreCasos en formato ejecutable para Windows Service

param(
    [Parameter(Mandatory = $false)]
    [string]$DirectorioSalida = "",
    
    [Parameter(Mandatory = $false)]
    [string]$Configuracion = "Release",
    
    [Parameter(Mandatory = $false)]
    [string]$FrameworkObjeto = "net10.0",
    
    [switch]$AbrirCarpeta,
    [switch]$Silencioso
)

$ErrorActionPreference = 'Stop'

# Funciones de utilidad
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

# Programa Principal
Write-Header "PUBLICADOR DE SERVICIO WINDOWS - ServicioCierreCasos"

# Obtener directorio del script
$directorioScript = Split-Path -Parent $MyInvocation.MyCommand.Path
$rutaProyecto = $directorioScript
$archivoProyecto = Join-Path $rutaProyecto "ServicioCierreCasos.csproj"

# Verificar archivo de proyecto
Write-Info "Verificando archivo de proyecto..."
if (-not (Test-Path $archivoProyecto)) {
    Write-Error-Custom "No se encontró el archivo de proyecto: $archivoProyecto"
    exit 1
}
Write-Success "Archivo de proyecto encontrado"

# Determinar directorio de salida
if (-not $DirectorioSalida) {
    $DirectorioSalida = Join-Path $rutaProyecto "bin\$Configuracion\$FrameworkObjeto\publish"
}

Write-Host ""
Write-Info "Configuración de Publicación:"
Write-Host "  Proyecto: $rutaProyecto" -ForegroundColor Gray
Write-Host "  Configuración: $Configuracion" -ForegroundColor Gray
Write-Host "  Framework: $FrameworkObjeto" -ForegroundColor Gray
Write-Host "  Directorio de Salida: $DirectorioSalida" -ForegroundColor Gray
Write-Host ""

# Compilar proyecto
Write-Header "COMPILANDO PROYECTO"
Write-Info "Compilando en modo $Configuracion..."

$compilado = $false
try {
    Push-Location $rutaProyecto
    
    & dotnet build -c $Configuracion
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Compilación exitosa"
        $compilado = $true
    } else {
        Write-Error-Custom "Error en la compilación"
        exit 1
    }
} catch {
    Write-Error-Custom "Error durante la compilación: $_"
    exit 1
} finally {
    Pop-Location
}

Write-Host ""

# Publicar proyecto
Write-Header "PUBLICANDO PROYECTO"
Write-Info "Publicando en $DirectorioSalida..."

try {
    Push-Location $rutaProyecto
    
    & dotnet publish -c $Configuracion -o $DirectorioSalida -f $FrameworkObjeto
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Publicación exitosa"
    } else {
        Write-Error-Custom "Error en la publicación"
        exit 1
    }
} catch {
    Write-Error-Custom "Error durante la publicación: $_"
    exit 1
} finally {
    Pop-Location
}

Write-Host ""

# Verificar archivos publicados
Write-Header "VERIFICANDO ARCHIVOS PUBLICADOS"

if (-not (Test-Path $DirectorioSalida)) {
    Write-Error-Custom "No se encontró el directorio de salida"
    exit 1
}

$ejecutable = Join-Path $DirectorioSalida "ServicioCierreCasos.exe"
if (Test-Path $ejecutable) {
    Write-Success "Ejecutable generado: $ejecutable"
} else {
    Write-Error-Custom "No se encontró el ejecutable"
    exit 1
}

Write-Host ""
Write-Info "Archivos en el directorio de publicación:"
Write-Host ""

$archivos = Get-ChildItem $DirectorioSalida -File | Select-Object Name, @{Name="Tamaño (KB)";Expression={[math]::Round($_.Length/1KB, 2)}}
$archivos | Format-Table -AutoSize | Out-String | Write-Host

Write-Host ""

# Información de tamaño total
$tamanioTotal = (Get-ChildItem $DirectorioSalida -Recurse -File | Measure-Object -Property Length -Sum).Sum
$tamanioTotalMB = [math]::Round($tamanioTotal / 1MB, 2)

Write-Info "Tamaño total: $tamanioTotalMB MB"

Write-Host ""
Write-Header "PUBLICACIÓN COMPLETADA"

Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Copiar carpeta a: C:\Servicios\ServicioCierreCasos (opcional)" -ForegroundColor Gray
Write-Host "2. Ejecutar: Instalar-Servicio-v2.ps1 -RutaPublicacion `"$DirectorioSalida`"" -ForegroundColor Gray
Write-Host "3. Gestionar servicio: Gestionar-Servicio.ps1 -Accion Iniciar" -ForegroundColor Gray
Write-Host ""

# Abrir carpeta si se solicita
if ($AbrirCarpeta) {
    Write-Info "Abriendo directorio de publicación..."
    Invoke-Item $DirectorioSalida
}

Write-Success "¡Publicación lista para instalar como servicio!"
Write-Host ""
