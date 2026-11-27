@echo off
REM ═══════════════════════════════════════════════════════════════════════════
REM SCRIPT DE EJECUCIÓN CON DEPURACIÓN
REM Programa: Servicio de Cierre de Casos
REM Versión: 1.0
REM ═══════════════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

REM Configurar variables de color (simulado con caracteres)
cls
echo.
echo ╔══════════════════════════════════════════════════════════════════════════╗
echo ║                     EJECUTAR SERVICIO CIERRE DE CASOS                    ║
echo ║                   Script de Depuración - Versión 1.0                     ║
echo ╚══════════════════════════════════════════════════════════════════════════╝
echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 1: VALIDAR ENTORNO
REM ═══════════════════════════════════════════════════════════════════════════
echo [%time%] PASO 1: VALIDANDO ENTORNO
echo ───────────────────────────────────────────────────────────────────────────
echo.

REM Detectar ubicación del script
set "SCRIPT_DIR=%~dp0"
echo   ✓ Directorio del script: %SCRIPT_DIR%

REM Verificar que estamos en el directorio correcto
if not exist "%SCRIPT_DIR%ServicioCierreCasos.csproj" (
    echo.
    echo   ✗ ERROR: No se encuentra ServicioCierreCasos.csproj
    echo   Este script debe ejecutarse desde la carpeta raíz del proyecto
    echo.
    exit /b 1
)
echo   ✓ Proyecto encontrado: ServicioCierreCasos.csproj
echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 2: VERIFICAR .NET SDK
REM ═══════════════════════════════════════════════════════════════════════════
echo [%time%] PASO 2: VERIFICANDO .NET SDK
echo ───────────────────────────────────────────────────────────────────────────
echo.

dotnet --version >nul 2>&1
if errorlevel 1 (
    echo   ✗ ERROR: .NET SDK no está instalado o no está en la ruta del sistema
    echo   Por favor instala .NET SDK desde: https://dotnet.microsoft.com/download
    echo.
    exit /b 1
)

for /f "tokens=*" %%i in ('dotnet --version') do (
    set "DOTNET_VERSION=%%i"
)
echo   ✓ .NET SDK encontrado: %DOTNET_VERSION%
echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 3: LIMPIAR COMPILACIONES ANTERIORES (Opcional)
REM ═══════════════════════════════════════════════════════════════════════════
echo [%time%] PASO 3: PREPARANDO COMPILACIÓN
echo ───────────────────────────────────────────────────────────────────────────
echo.

echo   Limpiando artefactos anteriores...
dotnet clean "%SCRIPT_DIR%ServicioCierreCasos.csproj" --configuration Debug >nul 2>&1
echo   ✓ Limpieza completada
echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 4: RESTAURAR DEPENDENCIAS
REM ═══════════════════════════════════════════════════════════════════════════
echo [%time%] PASO 4: RESTAURANDO DEPENDENCIAS
echo ───────────────────────────────────────────────────────────────────────────
echo.

echo   Restaurando paquetes NuGet...
dotnet restore "%SCRIPT_DIR%ServicioCierreCasos.csproj"
if errorlevel 1 (
    echo.
    echo   ✗ ERROR: No se pudieron restaurar las dependencias
    echo.
    exit /b 1
)
echo   ✓ Dependencias restauradas correctamente
echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 5: COMPILAR PROYECTO
REM ═══════════════════════════════════════════════════════════════════════════
echo [%time%] PASO 5: COMPILANDO PROYECTO
echo ───────────────────────────────────────────────────────────────────────────
echo.

echo   Compilando en modo Debug...
dotnet build "%SCRIPT_DIR%ServicioCierreCasos.csproj" --configuration Debug --no-restore -v minimal
if errorlevel 1 (
    echo.
    echo   ✗ ERROR: La compilación falló
    echo   Revisa los mensajes de error anteriores
    echo.
    exit /b 1
)
echo   ✓ Compilación completada exitosamente
echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 6: VERIFICAR CONFIGURACIÓN
REM ═══════════════════════════════════════════════════════════════════════════
echo [%time%] PASO 6: VERIFICANDO CONFIGURACIÓN
echo ───────────────────────────────────────────────────────────────────────────
echo.

if exist "%SCRIPT_DIR%appsettings.json" (
    echo   ✓ Configuración por defecto encontrada: appsettings.json
) else (
    echo   ✗ ADVERTENCIA: No se encuentra appsettings.json
)

if exist "%SCRIPT_DIR%appsettings.Development.json" (
    echo   ✓ Configuración de desarrollo encontrada: appsettings.Development.json
) else (
    echo   ⚠  NOTA: No se encuentra appsettings.Development.json
)

echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 7: MOSTRAR INFORMACIÓN DEL ENTORNO
REM ═══════════════════════════════════════════════════════════════════════════
echo [%time%] PASO 7: INFORMACIÓN DEL ENTORNO
echo ───────────────────────────────────────────────────────────────────────────
echo.

echo   Sistema Operativo: %OS%
echo   Directorio de Trabajo: %CD%
echo   Directorio del Proyecto: %SCRIPT_DIR%
echo   Versión .NET: %DOTNET_VERSION%
echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 8: EJECUTAR PROGRAMA
REM ═══════════════════════════════════════════════════════════════════════════
echo [%time%] PASO 8: EJECUTANDO PROGRAMA
echo ───────────────────────────────────────────────────────────────────────────
echo.

set "ASSEMBLY_PATH=%SCRIPT_DIR%bin\Debug\net10.0\ServicioCierreCasos.dll"

if not exist "%ASSEMBLY_PATH%" (
    echo   ✗ ERROR: No se encuentra el ensamblado compilado
    echo   Ruta esperada: %ASSEMBLY_PATH%
    echo.
    exit /b 1
)

echo   ✓ Ensamblado encontrado: ServicioCierreCasos.dll
echo.
echo ════════════════════════════════════════════════════════════════════════════
echo   INICIANDO PROGRAMA
echo ════════════════════════════════════════════════════════════════════════════
echo.

REM Ejecutar con variables de entorno para depuración
set ASPNETCORE_ENVIRONMENT=Development
dotnet "%ASSEMBLY_PATH%"

REM Capturar código de salida
set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ════════════════════════════════════════════════════════════════════════════
echo [%time%] PROGRAMA FINALIZADO
echo ════════════════════════════════════════════════════════════════════════════
echo.

if %EXIT_CODE% equ 0 (
    echo   ✓ El programa se ejecutó exitosamente
    echo   Código de salida: 0
) else (
    echo   ✗ El programa terminó con un error
    echo   Código de salida: %EXIT_CODE%
)
echo.

REM ═══════════════════════════════════════════════════════════════════════════
REM PASO 9: OPCIÓN DE DEPURACIÓN ADICIONAL
REM ═══════════════════════════════════════════════════════════════════════════
endlocal
exit /b %EXIT_CODE%
