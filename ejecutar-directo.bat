@echo off
REM Script para ejecutar sin compilación (asume que ya está compilado)

cd /d "%~dp0"
echo Ejecutando Servicio de Cierre de Casos...
echo.

set ASPNETCORE_ENVIRONMENT=Development
dotnet bin\Debug\net10.0\ServicioCierreCasos.dll
