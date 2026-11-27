@echo off
REM Script simplificado para ejecución rápida

cd /d "%~dp0"
echo Ejecutando Servicio de Cierre de Casos...
echo.

set ASPNETCORE_ENVIRONMENT=Development

REM Compilar
dotnet build ServicioCierreCasos.csproj --configuration Debug --no-restore -v minimal
if errorlevel 1 exit /b 1

REM Ejecutar
dotnet bin\Debug\net10.0\ServicioCierreCasos.dll

exit
