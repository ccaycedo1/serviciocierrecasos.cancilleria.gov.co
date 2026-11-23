$ErrorActionPreference = 'Stop'
$publicacion = Join-Path $PSScriptRoot 'obj\instalador\publicacion'
$salida = Join-Path $PSScriptRoot 'bin\instalador'

& dotnet publish (Join-Path $PSScriptRoot 'ServicioCierreCasos.csproj') `
    -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true -p:InstallerBuild=true -o $publicacion
if ($LASTEXITCODE -ne 0) { throw 'Fallo la publicacion del servicio.' }

& dotnet publish (Join-Path $PSScriptRoot 'Instalador\Instalador.csproj') `
    -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true -o $salida
if ($LASTEXITCODE -ne 0) { throw 'Fallo la generacion del instalador.' }
Write-Host "Instalador generado: $salida\InstalarServicioCierreCasos.exe"
