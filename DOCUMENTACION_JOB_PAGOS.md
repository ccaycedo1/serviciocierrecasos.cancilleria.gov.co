# Actualización Automática de Estados de Pagos

## Descripción

Este módulo implementa una tarea programada (Job) que se ejecuta automáticamente cada 5 minutos para actualizar los estados de pagos en la base de datos `Pagos` basándose en el estado de recaudo en la base de datos `Apostilla`.

## Objetivo

Identificar todos los registros de pagos pendientes y, cuando el recaudo asociado tenga estado pagado (`codEstadoRecaudo = 2`), actualizar automáticamente el estado del pago a 4.

## Frecuencia de Ejecución

- **Intervalo**: Cada 5 minutos
- **Tipo**: Automático y continuo
- **Mecanismo**: Background Service de .NET

## Componentes

### 1. Modelos de Datos (`Models/`)

#### `PagoNotificacion.cs`
Representa un registro de pago en la tabla `AppPagosPagoNotificacion`:
- `Id`: Identificador único del pago
- `ReferenciaPago`: Referencia del pago (ej: `PSE2024-123456`)
- `IdEstado`: Estado actual del pago
- `FechaModificacion`: Fecha de última modificación

#### `Recaudo.cs`
Representa un recaudo en la tabla `tbRecaudo` (Apostilla):
- `IdRecaudo`: Identificador único del recaudo
- `CodEstadoRecaudo`: Código del estado del recaudo (2 = pagado)

#### `JobExecutionLog.cs`
Registro de ejecución del job:
- `FechaInicio`: Fecha y hora de inicio
- `FechaFinalizacion`: Fecha y hora de finalización
- `RegistrosConsultados`: Total de pagos pendientes encontrados
- `RegistrosActualizados`: Cantidad de pagos actualizados
- `RegistrosSinCoincidencia`: Pagos sin recaudo asociado
- `Errores`: Lista de errores presentados

### 2. Servicios (`Services/`)

#### `IPagoService` / `PagoService.cs`
Gestiona operaciones sobre pagos en la base de datos `Pagos`:

**Métodos:**
- `ObtenerPagosPendientesAsync()`: Obtiene todos los pagos con `idEstado <> 4`
- `ActualizarEstadoPagoAsync(idPago)`: Actualiza el estado a 4

**Consultas SQL:**
```sql
-- Obtener pagos pendientes
SELECT id, referenciaPago, idEstado, fechaModificacion
FROM [Pagos].[pse].[AppPagosPagoNotificacion]
WHERE idEstado <> 4

-- Actualizar pago
UPDATE [Pagos].[pse].[AppPagosPagoNotificacion]
SET idEstado = 4,
    fechaModificacion = GETDATE()
WHERE id = @IdPago
```

#### `IRecaudoService` / `RecaudoService.cs`
Gestiona búsqueda de recaudos en la base de datos `Apostilla`:

**Métodos:**
- `ObtenerRecaudoAsync(idRecaudo)`: Busca un recaudo por su ID

**Consulta SQL:**
```sql
SELECT idRecaudo, codEstadoRecaudo
FROM [Apostilla].[dbo].[tbRecaudo]
WHERE idRecaudo = @IdRecaudo
```

#### `IActualizarEstadosPagosJob` / `ActualizarEstadosPagosJob.cs`
Orquesta la lógica principal del job:

**Métodos:**
- `EjecutarAsync()`: Ejecuta el flujo completo del job

**Flujo de Ejecución:**
1. Consulta pagos pendientes (`idEstado <> 4`)
2. Para cada pago:
   - Extrae el ID de recaudo de `referenciaPago` (elimina primeros 7 caracteres)
   - Busca el recaudo asociado en Apostilla
   - Valida que `codEstadoRecaudo = 2`
   - Actualiza el estado del pago a 4
3. Registra trazabilidad en logs

**Validaciones:**
- Verifica que el ID de recaudo sea válido
- Maneja casos donde no existe recaudo en Apostilla
- Continúa procesamiento en caso de errores individuales
- Logs detallados de cada paso

### 3. Worker (`Worker.cs`)

Implementa el `BackgroundService` que:
- Ejecuta el job cada 5 minutos
- Captura errores sin detener la ejecución
- Permite cancelación ordenada del servicio

## Flujo de Procesamiento

```
Inicio del Servicio
     ↓
┌────────────────────────────────────┐
│ Cada 5 minutos:                    │
│                                    │
│ 1. Obtener pagos con idEstado <> 4│
│ 2. Para cada pago:                 │
│    a. Extraer ID de recaudo        │
│    b. Buscar en Apostilla          │
│    c. Validar estado (= 2)         │
│    d. Actualizar a estado 4        │
│ 3. Registrar logs de ejecución     │
└────────────────────────────────────┘
     ↓
  Esperar 5 minutos
     ↓
   (Repetir)
```

## Configuración

### appsettings.json

Las cadenas de conexión se configuran en el archivo `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "ApostillaDb": "Server=172.20.1.22;Database=Pagos;User Id=pse;...",
    "ApostillaRecaudoDb": "Server=172.20.1.22;Database=Apostilla;User Id=sa;..."
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "ServicioCierreCasos": "Information"
    }
  }
}
```

### Dependencias (ServicioCierreCasos.csproj)

```xml
<PackageReference Include="System.Data.SqlClient" Version="4.8.6" />
<PackageReference Include="Dapper" Version="2.1.15" />
<PackageReference Include="Microsoft.Extensions.Hosting.WindowsServices" Version="11.0.0" />
```

- **System.Data.SqlClient**: Acceso a SQL Server
- **Dapper**: ORM ligero para consultas SQL
- **Microsoft.Extensions.Hosting.WindowsServices**: Soporte para Windows Service

## Logs Generados

Cada ejecución del job genera logs con la siguiente información:

```
=== INICIO DE EJECUCIÓN DEL JOB: Actualizar Estados de Pagos ===
Fecha y hora de inicio: 23/11/2026 06:15:00
Cantidad de registros consultados: 125
Cantidad de registros actualizados: 42
Registros sin coincidencia en Apostilla: 3
Errores presentados: 1
Detalles de errores:
  - Error al actualizar pago con ID 456 (ID recaudo: 789456)
Fecha y hora de finalización: 23/11/2026 06:15:15
Duración total: 00:00:15.4532100
=== FIN DE EJECUCIÓN ===
```

## Manejo de Errores

La rutina está diseñada para ser resiliente:

1. **Errores de conexión**: Se registran y se reintenta en la siguiente ejecución
2. **Errores por registro**: Se continúa procesando los demás registros
3. **Errores críticos**: Se registran y la siguiente ejecución prosigue normalmente
4. **Idempotencia**: Las ejecuciones repetidas no generan inconsistencias (solo se actualiza si estado actual <> 4)

## Consideraciones Técnicas

### Seguridad
- Usa `SqlClient` con parámetros preparados para prevenir SQL injection
- Cadenas de conexión en `appsettings.json` (no hardcodeadas)
- Certificados SSL/TLS habilitables en la cadena de conexión

### Rendimiento
- Uso de `Dapper` para queries optimizadas
- Procesamiento asincrónico en todo el flujo
- Intervalo de 5 minutos evita sobrecarga

### Confiabilidad
- Registro completo de trazabilidad
- Continuación ante errores individuales
- Cancelación ordenada al detener el servicio

## Instalación como Windows Service

El servicio puede instalarse como Windows Service usando el script `Instalar-Servicio.ps1`:

```powershell
# Ejecutar como Administrador
.\Instalar-Servicio.ps1
```

El servicio se registrará con el nombre: `ServicioCierreCasos`

## Monitoreo

### Verificar estado del servicio
```powershell
Get-Service -Name ServicioCierreCasos
```

### Ver logs
Los logs se escriben en:
- **Consola** (durante desarrollo)
- **Event Viewer** de Windows (como Windows Service)
- **Archivos de log** (si está configurado un LogProvider de archivo)

### Métricas de interés
- Cantidad de pagos procesados por ciclo
- Tasa de actualización exitosa
- Errores por tipo de fallo
- Duración de cada ejecución

## Próximas Mejoras Opcionales

1. **Circuit Breaker**: Implementar con Polly para gestionar fallos de conexión
2. **Alertas**: Notificación cuando hay múltiples errores consecutivos
3. **Métricas**: Integración con Application Insights o similar
4. **Base de datos separada**: Si Apostilla está en un servidor diferente
5. **Configuración dinámica**: Permitir cambiar el intervalo sin reiniciar el servicio
