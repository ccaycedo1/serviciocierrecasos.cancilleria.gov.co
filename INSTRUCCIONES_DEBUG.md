# Instrucciones para Ejecutar el Programa en Modo Depuración

## Descripción

Este documento proporciona instrucciones paso a paso para ejecutar el programa de actualización de estados de pagos en modo depuración desde la consola, donde podrás ver todos los mensajes y el flujo de ejecución en tiempo real.

## Requisitos

- .NET 10.0 SDK instalado ([Descargar](https://dotnet.microsoft.com/download))
- SQL Server accesible (opcional, solo si quieres probar con datos reales)
- PowerShell 5.1 o superior (para ejecutar el script .ps1)
- Terminal de Windows (CMD o PowerShell)

## Método 1: Usando el Script PowerShell (Recomendado)

### Paso 1: Abrir PowerShell

1. Presiona `Win + X` y selecciona **Windows PowerShell** o **PowerShell**
2. Altern ativamente, abre **PowerShell** desde el menú de inicio

### Paso 2: Permitir Ejecución de Scripts (Solo primera vez)

Si es la primera vez ejecutando un script en PowerShell, es posible que veas un error. Ejecuta:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Cuando se te pida confirmación, escribe `Y` y presiona Enter.

### Paso 3: Navegar al Directorio del Proyecto

```powershell
cd C:\ApostillaCcaycedo\ServicioCierreCasos
```

### Paso 4: Ejecutar el Script de Depuración

```powershell
.\ejecutar-debug.ps1
```

**El programa mostrará todos los mensajes de depuración en la consola.**

---

## Método 2: Usando CMD (Símbolo del Sistema)

### Paso 1: Abrir CMD

1. Presiona `Win + R`
2. Escribe `cmd` y presiona Enter

### Paso 2: Navegar al Directorio del Proyecto

```cmd
cd C:\ApostillaCcaycedo\ServicioCierreCasos
```

### Paso 3: Ejecutar el Script Batch

```cmd
ejecutar-debug.bat
```

---

## Método 3: Ejecución Manual Paso a Paso

### Paso 1: Abrir Terminal (PowerShell o CMD)

### Paso 2: Navegar al Directorio

```bash
cd C:\ApostillaCcaycedo\ServicioCierreCasos
```

### Paso 3: Compilar el Proyecto

```bash
dotnet build -c Debug
```

Deberías ver algo como:
```
  Determining projects to restore...
  Restored C:\ApostillaCcaycedo\ServicioCierreCasos\ServicioCierreCasos.csproj
  ServicioCierreCasos -> C:\ApostillaCcaycedo\ServicioCierreCasos\bin\Debug\net10.0\ServicioCierreCasos.dll

Build succeeded.
```

### Paso 4: Ejecutar el Programa de Depuración

```bash
dotnet run --project DebugConsole\DebugConsole.csproj --no-build
```

---

## Salida Esperada

Cuando ejecutes el programa, deberías ver una salida similar a esta:

```
╔══════════════════════════════════════════════════════════════════╗
║   PROGRAMA DE DEPURACIÓN - ACTUALIZACIÓN DE ESTADOS DE PAGOS      ║
║   Versión: 1.0                                                   ║
║   Fecha de Ejecución: 23/11/2026 06:15:00                        ║
╚══════════════════════════════════════════════════════════════════╝

📋 INFORMACIÓN DEL ENTORNO:
  • Sistema Operativo: Microsoft Windows 10.0.19045
  • Versión .NET: .NET 10.0.0
  • Directorio Actual: C:\ApostillaCcaycedo\ServicioCierreCasos

🔗 CONFIGURACIÓN DE CONEXIONES:
  • Base de Datos Pagos (ApostillaDb): 172.20.1.22
  • Base de Datos Apostilla (ApostillaRecaudoDb): 172.20.1.22

⚙️  PARÁMETROS DE EJECUCIÓN:
  • Intervalo de Ejecución: 5 minutos
  • Modo: Ejecución Única (Depuración)
  • Reintento en Errores: Habilitado

════════════════════════════════════════════════════════════════════
🚀 INICIANDO EJECUCIÓN DEL JOB...
════════════════════════════════════════════════════════════════════

⏱️  Iniciando job en: 23/11/2026 06:15:00.123

╔════════════════════════════════════════════════════════════════╗
║ INICIO DE EJECUCIÓN DEL JOB: ACTUALIZAR ESTADOS DE PAGOS        ║
╚════════════════════════════════════════════════════════════════╝
📅 Fecha y hora de inicio: 23/11/2026 06:15:00.123

▼ PASO 1: Consultando pagos pendientes...
  Condición: idEstado <> 4
🔍 Iniciando consulta de pagos pendientes...
  ↳ Abriendo conexión a SQL Server...
  ✅ Conexión establecida correctamente
  ↳ Ejecutando query SQL...
✅ Consulta de pagos pendientes completada. Total encontrado: 125
📊 Cantidad de registros consultados: 125

▼ PASO 2-5: Procesando pagos...

[1/125] Procesando pago ID: 1
  ├─ PASO 2: Extrayendo ID de recaudo
    ├─ Referencia Original: PSE2024-123456
    └─ ID Extraído: 123456
  ├─ PASO 3: Buscando recaudo en Apostilla
    ↳ Buscando recaudo ID 123456 en Apostilla...
      ✅ Recaudo encontrado. Estado: 2
  ├─ PASO 4: Validando estado del recaudo
    └─ Estado Recaudo: 2 (Esperado: 2)
  ├─ PASO 5: Actualizando estado del pago
    ↳ Actualizando estado del pago ID: 1
      ✅ Pago actualizado exitosamente
  ├─ ✅ Pago actualizado exitosamente
  │  ├─ ID Pago: 1
  │  ├─ Referencia: PSE2024-123456
  │  ├─ ID Recaudo: 123456
  │  └─ Nuevo Estado: 4
  └─ RESULTADO: Actualizado

[2/125] Procesando pago ID: 2
...
```

## Interpretación de los Mensajes

### Símbolos Usados

- `✅` - Operación exitosa
- `❌` - Error crítico
- `⚠️` - Advertencia
- `ℹ️` - Información
- `📊` - Estadísticas
- `🔍` - Búsqueda/Consulta
- `🚀` - Iniciando
- `⏱️` - Tiempo

### Resumen Final

Al final de la ejecución, verás un resumen como este:

```
╔════════════════════════════════════════════════════════════════╗
║ RESUMEN DE EJECUCIÓN                                           ║
╚════════════════════════════════════════════════════════════════╝

📊 Estadísticas Finales:
  ├─ Registros Consultados: 125
  ├─ Registros Actualizados: 42
  ├─ Registros Sin Coincidencia: 3
  └─ Errores Presentados: 0

⏱️  Tiempos:
  ├─ Fecha Inicio: 23/11/2026 06:15:00.123
  ├─ Fecha Finalización: 23/11/2026 06:15:15.456
  └─ Duración Total: 00:00:15.3330000

✅ No se encontraron errores durante la ejecución.

╔════════════════════════════════════════════════════════════════╗
║ FIN DE EJECUCIÓN                                               ║
╚════════════════════════════════════════════════════════════════╝
```

## Solución de Problemas

### Error: "The term 'dotnet' is not recognized"

**Causa**: .NET SDK no está instalado o no está en el PATH

**Solución**:
1. Descarga e instala [.NET 10.0 SDK](https://dotnet.microsoft.com/download)
2. Reinicia tu terminal después de la instalación
3. Verifica con: `dotnet --version`

### Error: "Cannot find path to database"

**Causa**: Las cadenas de conexión en `appsettings.json` son incorrectas o el servidor SQL no es accesible

**Solución**:
1. Abre `appsettings.json` en un editor de texto
2. Verifica que el servidor SQL sea accesible (ping al servidor)
3. Verifica que las credenciales sean correctas
4. Asegúrate de que el usuario tenga permisos en las bases de datos

### Error: "Login failed for user"

**Causa**: Credenciales incorrectas en la cadena de conexión

**Solución**:
1. Verifica el usuario y contraseña en `appsettings.json`
2. Asegúrate de que el usuario existe en SQL Server
3. Verifica que el usuario tiene permiso de lectura/escritura en las tablas

### El programa no muestra ningún mensaje

**Causa**: Posible problema con la configuración de logging

**Solución**:
1. Verifica que `appsettings.json` esté en el directorio actual
2. Intenta aumentar el nivel de log cambiando `"Default": "Information"` a `"Default": "Debug"` en appsettings.json

## Próximos Pasos

Una vez que hayas verificado que el programa funciona correctamente en modo depuración:

1. Revisa los logs y mensajes para asegurar que el flujo sea correcto
2. Verifica que se están actualizando los registros correctamente en la BD
3. Instala el servicio como Windows Service usando `Instalar-Servicio.ps1`
4. Configura la rotación de logs para producción
5. Monitorea el servicio en Event Viewer

## Contacto

Para soporte técnico, contacta al equipo de desarrollo.

---

**Versión**: 1.0  
**Última actualización**: 23 de Noviembre de 2026
