# Script de Prueba de Conectividad a Bases de Datos
# Autor: Copilot
# Fecha: 2026-11-23

# Función para ocultar contraseñas
function OcultarPassword {
    param([string]$connectionString)
    
    if ([string]::IsNullOrEmpty($connectionString)) {
        return "No configurada"
    }
    
    # Simple ocultacion sin regex
    if ($connectionString -like "*password*") {
        $cadenaOculta = $connectionString -replace "password=[^;]*", "password=***oculta***"
        return $cadenaOculta
    }
    
    return $connectionString
}

# Función para probar conexión
function ProbarConexion {
    param(
        [string]$Nombre,
        [string]$ConnectionString
    )
    
    $resultado = @{
        Nombre = $Nombre
        Exitosa = $false
        Servidor = "N/A"
        BaseDatos = "N/A"
        FechaServidor = "N/A"
        Error = ""
        DetalleError = ""
    }
    
    try {
        if ([string]::IsNullOrEmpty($ConnectionString)) {
            Write-Host "RESULTADO: No configurada" -ForegroundColor Red
            $resultado.Error = "Conexion no configurada"
            return $resultado
        }

        Write-Host "Intentando conectar..." -ForegroundColor Yellow
        
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = $ConnectionString
        $connection.Open()

        Write-Host "Conexion establecida correctamente" -ForegroundColor Green
        Write-Host ("  Servidor: " + $connection.DataSource) -ForegroundColor Green
        Write-Host ("  BaseDatos: " + $connection.Database) -ForegroundColor Green
        Write-Host ("  Estado: " + $connection.State) -ForegroundColor Green

        # Ejecutar query de prueba
        Write-Host "Ejecutando query de prueba..." -ForegroundColor Yellow
        
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT @@SERVERNAME as Servidor, DB_NAME() as BaseDatos, GETDATE() as FechaServidor"
        $command.CommandTimeout = 10

        $reader = $command.ExecuteReader()
        if ($reader.Read()) {
            $servidor = $reader["Servidor"]
            $baseDatos = $reader["BaseDatos"]
            $fechaServidor = $reader["FechaServidor"]

            Write-Host "Query ejecutada exitosamente" -ForegroundColor Green
            Write-Host ("  Servidor DB: " + $servidor) -ForegroundColor Green
            Write-Host ("  BD Actual: " + $baseDatos) -ForegroundColor Green
            Write-Host ("  Hora del Servidor: " + $fechaServidor) -ForegroundColor Green

            $resultado.Exitosa = $true
            $resultado.Servidor = $servidor
            $resultado.BaseDatos = $baseDatos
            $resultado.FechaServidor = $fechaServidor
        }
        
        $reader.Close()
        $connection.Close()
        
        Write-Host "RESULTADO: Conexion exitosa" -ForegroundColor Green
    }
    catch [System.Data.SqlClient.SqlException] {
        Write-Host "RESULTADO: Error de SQL" -ForegroundColor Red
        Write-Host ("  Codigo Error: " + $_.Exception.Number) -ForegroundColor Red
        Write-Host ("  Mensaje: " + $_.Exception.Message) -ForegroundColor Red
        
        $resultado.Error = $_.Exception.Message
        
        if ($_.Exception.Number -eq 4221) {
            Write-Host "  Info: Error de Timeout - Servidor no responde" -ForegroundColor Yellow
            $resultado.DetalleError = "Timeout - Servidor no responde"
        }
        elseif ($_.Exception.Number -eq 18456) {
            Write-Host "  Info: Error de Autenticacion - Usuario/Password incorrecto" -ForegroundColor Yellow
            $resultado.DetalleError = "Autenticacion fallida - Usuario/Password incorrecto"
        }
        elseif ($_.Exception.Number -eq 4060) {
            Write-Host "  Info: Error de BaseDatos - BD no existe o esta offline" -ForegroundColor Yellow
            $resultado.DetalleError = "BaseDatos no existe o esta offline"
        }
    }
    catch {
        Write-Host "RESULTADO: Error inesperado" -ForegroundColor Red
        Write-Host ("  Tipo: " + $_.Exception.GetType().Name) -ForegroundColor Red
        Write-Host ("  Mensaje: " + $_.Exception.Message) -ForegroundColor Red
        $resultado.Error = $_.Exception.Message
        $resultado.DetalleError = $_.Exception.GetType().Name
    }
    
    return $resultado
}

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "   BATERIA DE PRUEBAS DE CONECTIVIDAD A BASES DE DATOS            " -ForegroundColor Cyan
Write-Host "   Version: 1.0                                                   " -ForegroundColor Cyan
Write-Host ("   Fecha: " + (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')) -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

# Cargar configuracion de appsettings.json
$appSettingsPath = "appsettings.json"
$config = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
$connectionStrings = $config.ConnectionStrings

# Definir conexiones a probar
$conexiones = @{
    "ApostillaDb" = $connectionStrings.ApostillaDb
    "SitacDb" = $connectionStrings.SitacDb
    "ApostillaRecaudoDb" = $connectionStrings.ApostillaRecaudoDb
}

$totalConexiones = $conexiones.Count
$conexionesExitosas = 0
$conexionesFallidas = 0
$resultados = @()

Write-Host "CONEXIONES CONFIGURADAS:"
Write-Host ""

foreach ($nombre in $conexiones.Keys) {
    $connectionString = $conexiones[$nombre]
    
    Write-Host "-------------------------------------------------------------"
    Write-Host "Nombre: $nombre" -ForegroundColor Yellow
    Write-Host "Cadena: $(OcultarPassword $connectionString)" -ForegroundColor Gray
    Write-Host ""

    $resultado = ProbarConexion -Nombre $nombre -ConnectionString $connectionString
    $resultados += $resultado
    
    if ($resultado.Exitosa) {
        $conexionesExitosas++
    } else {
        $conexionesFallidas++
    }

    Write-Host ""
}

# Resumen Final
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "                        RESUMEN FINAL                           " -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total de Conexiones: $totalConexiones"
Write-Host ("Exitosas: " + $conexionesExitosas) -ForegroundColor Green
Write-Host ("Fallidas: " + $conexionesFallidas) -ForegroundColor Red
$tasaExito = [math]::Round(($conexionesExitosas * 100 / $totalConexiones), 2)
Write-Host ("Tasa de Exito: " + $tasaExito + "%")
Write-Host ""

if ($conexionesFallidas -eq 0) {
    Write-Host "TODAS LAS CONEXIONES SON CORRECTAS!" -ForegroundColor Green
} else {
    Write-Host ("ATENCION: " + $conexionesFallidas + " conexion(es) fallida(s)") -ForegroundColor Red
}

Write-Host ""
Write-Host "====================================================================="
Write-Host ""

# Mostrar detalles de errores si los hay
if ($conexionesFallidas -gt 0) {
    Write-Host "DETALLES DE ERRORES:" -ForegroundColor Red
    Write-Host ""
    foreach ($resultado in $resultados) {
        if (-not $resultado.Exitosa) {
            Write-Host ("FALLO: " + $resultado.Nombre) -ForegroundColor Red
            Write-Host ("Error: " + $resultado.Error) -ForegroundColor Gray
            if ($resultado.DetalleError) {
                Write-Host ("Detalle: " + $resultado.DetalleError) -ForegroundColor Gray
            }
            Write-Host ""
        }
    }
}

# Tabla de resumen
Write-Host ""
Write-Host "TABLA DE RESUMEN:" -ForegroundColor Cyan
Write-Host ""

$tablaResumen = @()
foreach ($resultado in $resultados) {
    $status = if ($resultado.Exitosa) { "OK" } else { "FALLO" }
    $tablaResumen += [PSCustomObject]@{
        'Conexion' = $resultado.Nombre
        'Estado' = $status
        'Servidor' = $resultado.Servidor
        'BaseDatos' = $resultado.BaseDatos
    }
}

$tablaResumen | Format-Table -AutoSize | Out-String | Write-Host

Write-Host ""
Write-Host "====================================================================="
Write-Host ""

# Guardar reporte
$reportePath = ("reporte-conectividad-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + ".txt")
Write-Host ("Guardando reporte en: " + $reportePath) -ForegroundColor Cyan

$reporte = @"
REPORTE DE CONECTIVIDAD - ServicioCierreCasos
Generado: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')

RESUMEN:
--------
Total de Conexiones: $totalConexiones
Conexiones Exitosas: $conexionesExitosas
Conexiones Fallidas: $conexionesFallidas
Tasa de Exito: $tasaExito%

DETALLES POR CONEXION:
---------------------
"@

foreach ($resultado in $resultados) {
    $status = if ($resultado.Exitosa) { "OK" } else { "FALLO" }
    $reporte += @"

Conexion: $($resultado.Nombre)
Estado: $status
Servidor: $($resultado.Servidor)
BaseDatos: $($resultado.BaseDatos)
HoraServidor: $($resultado.FechaServidor)
Detalles: $($resultado.DetalleError)

"@
}

$reporte | Out-File -FilePath $reportePath -Encoding UTF8

Write-Host "Reporte guardado correctamente" -ForegroundColor Green
Write-Host ""
