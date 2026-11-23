@echo off
REM Programa de Depuración - Actualización de Estados de Pagos
REM Este script ejecuta el programa en modo consola para ver todos los mensajes

cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║   EJECUTANDO PROGRAMA DE DEPURACIÓN                           ║
echo ║   Actualización Automática de Estados de Pagos               ║
echo ║   Versión 1.0                                                 ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Cambiar al directorio del proyecto
cd /d "%~dp0"

echo.
echo 📂 Directorio: %CD%
echo.

REM Verificar que las herramientas estén disponibles
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: .NET SDK no está instalado o no está en el PATH
    echo.
    echo Por favor, instala .NET 10.0 SDK desde: https://dotnet.microsoft.com/download
    pause
    exit /b 1
)

echo ✅ .NET SDK detectado
echo.

REM Compilar el proyecto en modo Debug
echo.
echo 🔨 Compilando el proyecto...
echo.

dotnet build -c Debug

if errorlevel 1 (
    echo.
    echo ❌ ERROR: La compilación falló
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Compilación exitosa
echo.

REM Ejecutar el programa de depuración
echo.
echo 🚀 Iniciando programa de depuración...
echo.
echo ════════════════════════════════════════════════════════════════
echo.

dotnet run --project DebugConsole\DebugConsole.csproj --no-build

REM Si la ejecución falla
if errorlevel 1 (
    echo.
    echo ════════════════════════════════════════════════════════════════
    echo ❌ ERROR: El programa falló durante la ejecución
    echo.
    echo Por favor, verifica:
    echo   1. Las cadenas de conexión en appsettings.json
    echo   2. La accesibilidad del servidor SQL
    echo   3. Los permisos de la base de datos
    echo.
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════════════════════════════
echo ✅ Ejecución completada exitosamente
echo.
pause
exit /b 0
