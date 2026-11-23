param(
    [Parameter(Mandatory = $true)]
    [string] $RutaPublicacion
)

$ErrorActionPreference = 'Stop'
$nombre = 'ServicioCierreCasos'
$ejecutable = Join-Path (Resolve-Path -LiteralPath $RutaPublicacion).Path 'ServicioCierreCasos.exe'

if (-not (Test-Path -LiteralPath $ejecutable -PathType Leaf)) {
    throw "No se encontro el ejecutable publicado: $ejecutable"
}
if (Get-Service -Name $nombre -ErrorAction SilentlyContinue) {
    throw "El servicio $nombre ya existe."
}

New-Service -Name $nombre -BinaryPathName "`"$ejecutable`"" `
    -DisplayName 'Servicio de cierre de casos' `
    -Description 'Servicio base para el cierre de casos.' `
    -StartupType Automatic
Write-Host 'Servicio instalado. Configure las conexiones de produccion antes de iniciarlo.'
