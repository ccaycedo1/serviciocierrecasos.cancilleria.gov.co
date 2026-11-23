# Guía de Instalación y Uso - Servicio de Actualización de Estados de Pagos

## Requisitos Previos

- .NET 10.0 SDK instalado
- SQL Server accesible (Bases de datos: Pagos y Apostilla)
- Permisos de administrador para instalar el Windows Service
- PowerShell 5.1 o superior

## Pasos de Instalación

### 1. Compilar el Proyecto

```powershell
cd C:\ApostillaCcaycedo\ServicioCierreCasos
dotnet build -c Release
```

### 2. Publicar la Aplicación

```powershell
dotnet publish -c Release -o "C:\ProgramData\ServicioCierreCasos"
```

### 3. Configurar las Cadenas de Conexión

Edita el archivo `appsettings.json` en el directorio publicado:

```json
{
  "ConnectionStrings": {
    "ApostillaDb": "Server=TU_SERVIDOR;Database=Pagos;User Id=TU_USUARIO;Password=TU_PASSWORD;Integrated Security=False;TrustServerCertificate=True;Encrypt=False;",
    "ApostillaRecaudoDb": "Server=TU_SERVIDOR;Database=Apostilla;User Id=TU_USUARIO;Password=TU_PASSWORD;Integrated Security=False;TrustServerCertificate=True;Encrypt=False;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "ServicioCierreCasos": "Information"
    }
  }
}
```

### 4. Instalar como Windows Service

#### Usando PowerShell (Recomendado)

```powershell
# Ejecutar como Administrador

$servicePath = "C:\ProgramData\ServicioCierreCasos\ServicioCierreCasos.exe"
$serviceName = "ServicioCierreCasos"
$displayName = "Servicio de Actualización de Estados de Pagos"

# Crear el servicio
New-Service -Name $serviceName `
    -BinaryPathName $servicePath `
    -DisplayName $displayName `
    -StartupType Automatic `
    -Description "Actualiza automáticamente los estados de pagos cada 5 minutos"

# Iniciar el servicio
Start-Service -Name $serviceName
```

#### Usando sc.exe

```powershell
# Ejecutar como Administrador
sc.exe create ServicioCierreCasos binPath= "C:\ProgramData\ServicioCierreCasos\ServicioCierreCasos.exe" start= auto DisplayName= "Servicio de Actualización de Estados de Pagos"

# Iniciar el servicio
sc.exe start ServicioCierreCasos
```

### 5. Verificar la Instalación

```powershell
# Ver estado del servicio
Get-Service -Name ServicioCierreCasos

# Ver logs en Event Viewer
Get-EventLog -LogName Application -Source ".NET Runtime" | 
    Where-Object { $_.Message -like "*ServicioCierreCasos*" } |
    Format-Table TimeGenerated, Message -AutoSize
```

## Uso

### Iniciar el Servicio

```powershell
Start-Service -Name ServicioCierreCasos
```

### Detener el Servicio

```powershell
Stop-Service -Name ServicioCierreCasos
```

### Reiniciar el Servicio

```powershell
Restart-Service -Name ServicioCierreCasos
```

### Ver Estado del Servicio

```powershell
Get-Service -Name ServicioCierreCasos
```

## Monitoreo

### Ver Logs en Event Viewer

1. Abre **Event Viewer** (eventvwr.msc)
2. Navega a: **Windows Logs** → **Application**
3. Busca eventos de "ServicioCierreCasos" o ".NET Runtime"

### Ver Logs en Tiempo Real (Consola)

Para ejecutar el servicio en modo consola (útil para debugging):

```powershell
cd "C:\ProgramData\ServicioCierreCasos"
.\ServicioCierreCasos.exe
```

Presiona Ctrl+C para detener.

### Configurar Rotación de Logs

Para registrar los logs en archivos, agrega a `appsettings.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    },
    "EventLog": {
      "LogName": "Application",
      "SourceName": "ServicioCierreCasos"
    }
  }
}
```

## Desinstalación

### Usando PowerShell

```powershell
# Ejecutar como Administrador

$serviceName = "ServicioCierreCasos"

# Detener el servicio
Stop-Service -Name $serviceName -Force

# Eliminar el servicio
Remove-Service -Name $serviceName -Force
```

### Usando sc.exe

```powershell
# Ejecutar como Administrador
sc.exe stop ServicioCierreCasos
sc.exe delete ServicioCierreCasos
```

## Troubleshooting

### El servicio no inicia

**Posibles causas:**
- Las cadenas de conexión son incorrectas
- SQL Server no es accesible
- Faltan permisos en la base de datos
- Puerto o proceso ya en uso

**Solución:**
```powershell
# Ver logs del Event Viewer
Get-EventLog -LogName Application -Newest 20

# Ejecutar en consola para ver errores detallados
cd "C:\ProgramData\ServicioCierreCasos"
.\ServicioCierreCasos.exe
```

### Error de conexión a SQL Server

Verifica:
- El servidor SQL está disponible
- El usuario tiene permiso de lectura en `AppPagosPagoNotificacion`
- El usuario tiene permiso de lectura en `Apostilla.tbRecaudo`
- La cadena de conexión es correcta (especialmente si usas `TrustServerCertificate=True`)

### El servicio consume demasiados recursos

- Aumenta el intervalo de ejecución en `Worker.cs` (línea: `TimeSpan.FromMinutes(5)`)
- Verifica que no haya errores repetitivos en los logs

## Parámetros de Configuración

### Intervalo de Ejecución

Ubicación: `Worker.cs`, línea ~11

```csharp
private readonly TimeSpan _intervaloEjecucion = TimeSpan.FromMinutes(5);
```

Cambiar el valor para ajustar la frecuencia (ej: `FromMinutes(10)` para cada 10 minutos).

### Nivel de Log

Ubicación: `appsettings.json`

```json
"LogLevel": {
  "Default": "Information",          // Information, Warning, Error, Debug
  "ServicioCierreCasos": "Information"
}
```

## Ejemplo de Salida de Logs

```
2026-11-23 06:15:00: Servicio de Actualización de Estados de Pagos iniciado
2026-11-23 06:15:00: El job se ejecutará automáticamente cada 5 minuto(s)
2026-11-23 06:15:00: === INICIO DE EJECUCIÓN DEL JOB: Actualizar Estados de Pagos ===
2026-11-23 06:15:00: Fecha y hora de inicio: 23/11/2026 06:15:00
2026-11-23 06:15:00: Consulta de pagos pendientes completada. Total: 125
2026-11-23 06:15:00: Cantidad de registros consultados: 125
2026-11-23 06:15:10: Pago actualizado exitosamente. ID Pago: 1, Referencia: PSE2024-123456, ID Recaudo: 123456
2026-11-23 06:15:15: === RESUMEN DE EJECUCIÓN ===
2026-11-23 06:15:15: Registros consultados: 125
2026-11-23 06:15:15: Registros actualizados: 42
2026-11-23 06:15:15: Registros sin coincidencia en Apostilla: 3
2026-11-23 06:15:15: Errores presentados: 0
2026-11-23 06:15:15: Fecha y hora de finalización: 23/11/2026 06:15:15
2026-11-23 06:15:15: Duración total: 00:00:15.4532100
2026-11-23 06:15:15: === FIN DE EJECUCIÓN ===
```

## Soporte

Para soporte técnico o reportar problemas, contacta al equipo de desarrollo.

---

**Versión:** 1.0  
**Última actualización:** 23 de Noviembre de 2026  
**Autor:** Equipo de Desarrollo
