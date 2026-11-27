@echo off
REM Script para depuración avanzada con más detalles

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ════════════════════════════════════════════════════════════════════════════
echo                        DEPURACIÓN AVANZADA
echo ════════════════════════════════════════════════════════════════════════════
echo.

echo [PASO 1] Validando configuración...
if not exist appsettings.json (
    echo   ERROR: No existe appsettings.json
    exit /b 1
)
echo   ✓ Configuración validada
echo.

echo [PASO 2] Verificando conexiones...
echo   - Verificar que appsettings.json tenga la ConnectionString correcta
echo   - ConnectionString para ApostillaDb debe estar configurada
echo.
type appsettings.json | findstr /i "connection" && echo   ✓ ConnectionString encontrada || echo   ⚠ ConnectionString no visible (puede estar en archivo de desarrollo)
echo.

echo [PASO 3] Compilando con verbosidad...
echo   Ejecutando: dotnet build ServicioCierreCasos.csproj --configuration Debug -v diagnostic
echo.
dotnet build ServicioCierreCasos.csproj --configuration Debug --no-restore -v diagnostic

if errorlevel 1 (
    echo.
    echo   ✗ La compilación falló. Verifica los errores anteriores.
    exit /b 1
)
echo.

echo [PASO 4] Listando archivos compilados...
dir /s /b bin\Debug\net10.0\*.dll | findstr /i "ServicioCierre"
echo.

echo [PASO 5] Ejecutando con depuración...
echo   Variables de entorno:
echo   - ASPNETCORE_ENVIRONMENT=Development
echo   - Logging: Debug
echo.
echo   Presiona Ctrl+C en cualquier momento para detener la ejecución
echo.

set ASPNETCORE_ENVIRONMENT=Development
dotnet bin\Debug\net10.0\ServicioCierreCasos.dll

set EXIT_CODE=%ERRORLEVEL%
echo.
echo ════════════════════════════════════════════════════════════════════════════
if %EXIT_CODE% equ 0 (
    echo   ✓ Ejecución exitosa - Código de salida: 0
) else (
    echo   ✗ Error en ejecución - Código de salida: %EXIT_CODE%
)
echo ════════════════════════════════════════════════════════════════════════════
echo.

endlocal
exit /b %EXIT_CODE%
