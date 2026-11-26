# Guía de Implementación - Versión 1.1 con Nuevo Flujo de Retransmisión

**Versión**: 1.1  
**Fecha**: 2026-11-26  
**Estado**: ✅ Implementado y Probado

---

## 📋 Descripción de Cambios

### ¿Qué cambió?

Se agregó un **nuevo flujo alterno** que se ejecuta cuando `codEstadoRecaudo ≠ 2`:

```
Flujo Original (Preservado):
  SI codEstadoRecaudo = 2
    → Actualizar estado del pago a 4

Flujo Nuevo (Agregado):
  SI codEstadoRecaudo <> 2
    → Buscar en PagosRetransmitidos usando referencia completa
    → SI existe: Actualizar fechaRetransmision = NULL
```

### ¿Qué se mantiene igual?

✅ La lógica de cierre cuando `codEstadoRecaudo = 2` **NO cambió**  
✅ El intervalo de ejecución (5 minutos) **NO cambió**  
✅ Las conexiones a base de datos **NO cambiaron**  
✅ El logging existente **continúa igual**

---

## 🛠️ Archivos Modificados

### 1. `Services/PagoRetransmitidoService.cs` (NUEVO)
Nuevo servicio que encapsula la lógica de acceso a `PagosRetransmitidos`:

```csharp
public interface IPagoRetransmitidoService
{
    Task<PagoRetransmitido?> ObtenerPorReferenciaAsync(string referencia);
    Task<bool> ActualizarFechaRetransmisionANullAsync(string referencia);
}
```

**Responsabilidades:**
- Buscar registros por referencia exacta
- Actualizar `fechaRetransmision` a NULL
- Manejar errores SQL
- Logging detallado

### 2. `Models/Recaudo.cs` (MODIFICADO)
Se agregó el modelo `PagoRetransmitido`:

```csharp
public class PagoRetransmitido
{
    public int Id { get; set; }
    public string Referencia { get; set; } = string.Empty;
    public DateTime? FechaRetransmision { get; set; }
}
```

### 3. `Services/ActualizarEstadosPagosJob.cs` (MODIFICADO)
Se actualizó la lógica principal del job:

**Cambios:**
- Inyección de `IPagoRetransmitidoService`
- Lógica condicional basada en `codEstadoRecaudo`
- Nuevo método: `ProcesarFlujoAlternoAsync()`

**Flujo de decisión:**
```csharp
if (recaudo.CodEstadoRecaudo == ESTADO_PAGADO) // = 2
{
    // Flujo A: Cierre actual (sin cambios)
    await _pagoService.ActualizarEstadoPagoAsync(pago.Id);
}
else
{
    // Flujo B: Nuevo (retransmisión)
    await ProcesarFlujoAlternoAsync(pago, log);
}
```

### 4. `Program.cs` (MODIFICADO)
Se registró el nuevo servicio:

```csharp
builder.Services.AddScoped<IPagoRetransmitidoService, PagoRetransmitidoService>();
```

---

## 📊 Comparación de Flujos

| Aspecto | Flujo A (Cierre) | Flujo B (Retransmisión) |
|---------|------------------|------------------------|
| **Condición** | `codEstadoRecaudo = 2` | `codEstadoRecaudo ≠ 2` |
| **Tabla** | `AppPagosPagoNotificacion` | `PagosRetransmitidos` |
| **Búsqueda** | ID extraído de referencia | Referencia completa |
| **Campo ID** | `id` del pago | `referencia` del pago |
| **Actualización** | `idEstado = 4` | `fechaRetransmision = NULL` |
| **Log** | "Actualizado" | "Actualizado (Flujo Alterno)" |
| **Status** | Preservado | Nuevo |

---

## 🚀 Instrucciones de Implementación

### Opción 1: Actualizar Servicio Windows Existente

```powershell
# 1. Detener el servicio
net stop ServicioCierreCasos

# 2. Reemplazar binarios
# Copiar los archivos compilados a:
# C:\Program Files\ApostillaCierreCasos\

# 3. Reiniciar el servicio
net start ServicioCierreCasos

# 4. Verificar logs
# Event Viewer → Windows Logs → Application
```

### Opción 2: Compilar desde Código

```bash
# Navegar al directorio del proyecto
cd C:\ApostillaCcaycedo\ServicioCierreCasos

# Compilar
dotnet build --configuration Release

# El binario estará en:
# bin\Release\net10.0\ServicioCierreCasos.dll
```

### Opción 3: Publicar Versión de Producción

```bash
# Publicar
dotnet publish --configuration Release --self-contained

# Generar instalador
.\Generar-Instalador.ps1
```

---

## ✅ Validación Post-Implementación

### 1. Verificar Compilación
```bash
dotnet build --configuration Release
# Debe completarse sin errores ni advertencias
```

### 2. Verificar Base de Datos

Ejecutar los scripts SQL en `VALIDACION_SQL.md`:

```sql
-- Verificar tabla PagosRetransmitidos existe
SELECT * FROM Pagos.tarjetaCredito.PagosRetransmitidos LIMIT 1;

-- Ver registros con estado <> 2
SELECT TOP 10 * FROM Apostilla.dbo.tbRecaudo WHERE codEstadoRecaudo <> 2;
```

### 3. Ejecutar en Modo Debug

```bash
# Ejecutar una sola vez el job (útil para testing)
.\ejecutar-debug.bat

# Verificar logs en la consola
# Debe ver:
# - Registros consultados
# - Ambos flujos procesados
# - Estadísticas finales
```

### 4. Monitorear Logs

```powershell
# Windows Event Viewer
Get-EventLog -LogName Application -Source "ServicioCierreCasos" -Newest 20
```

---

## 🔍 Cómo Verificar que Funciona

### Escenario 1: Validar Flujo A (Cierre)
1. Confirmar que existe un pago con `idEstado = 1`
2. Confirmar que existe recaudo con `codEstadoRecaudo = 2`
3. Ejecutar job: `.\ejecutar-debug.bat`
4. Verificar que el pago cambió a `idEstado = 4`
5. Verificar log: `"✅ Pago actualizado exitosamente"` y `"RESULTADO: Actualizado"`

### Escenario 2: Validar Flujo B (Retransmisión)
1. Confirmar que existe un pago con `idEstado = 1`
2. Confirmar que existe recaudo con `codEstadoRecaudo = 1` (o cualquier valor ≠ 2)
3. Confirmar que existe registro en `PagosRetransmitidos` con la misma `referencia`
4. Ejecutar job: `.\ejecutar-debug.bat`
5. Verificar que `fechaRetransmision` cambió a `NULL`
6. Verificar log: `"✅ Registro de retransmisión actualizado"` y `"RESULTADO: Actualizado (Flujo Alterno)"`

### Escenario 3: Ambos Flujos
1. Crear 2 registros: uno para cada flujo
2. Ejecutar job
3. Verificar que ambos se procesaron (estadísticas mostrarán 2 registros actualizados)
4. Verificar logs con ambos tipos de actualizaciones

---

## 📂 Documentación Adicional

| Archivo | Descripción |
|---------|------------|
| `CAMBIOS_IMPLEMENTADOS.md` | Detalles técnicos de cada cambio |
| `DIAGRAMA_FLUJO_v1.1.txt` | Diagramas ASCII del flujo de ejecución |
| `VALIDACION_SQL.md` | Scripts SQL para validar implementación |
| `PruebasUnitarias.cs` | Casos de prueba (referencia) |
| `RESUMEN_AJUSTE_v1.1.md` | Resumen ejecutivo completo |

---

## 🛡️ Garantías de Preservación

✅ **Compilación**: Exitosa sin errores ni advertencias  
✅ **Flujo Original**: Completamente intacto  
✅ **Independencia**: Nuevo flujo es independiente  
✅ **Excepciones**: Manejadas en ambos flujos  
✅ **SQL**: Protegido contra inyección  
✅ **Logging**: Diferenciado y completo

---

## 🔧 Troubleshooting

### Problema: "Could not find a part of the path"
**Solución**: Asegurar que las rutas de conexión en `appsettings.json` son correctas.

### Problema: "Timeout expired"
**Solución**: Verificar conectividad a base de datos SQL Server.

### Problema: "No se actualiza PagosRetransmitidos"
**Solución**: Verificar que `referencia` en `PagosRetransmitidos` coincide exactamente con `referenciaPago` en `AppPagosPagoNotificacion`.

### Problema: "No se ve el nuevo flujo en logs"
**Solución**: Verificar que `codEstadoRecaudo ≠ 2` en los recaudos. Si todos son = 2, solo ejecutará Flujo A.

---

## 📞 Contacto y Soporte

Para preguntas o problemas:
1. Revisar documentación en carpeta del servicio
2. Consultar logs en Event Viewer
3. Ejecutar scripts SQL de validación
4. Revisar ejemplos en `PruebasUnitarias.cs`

---

## 📝 Notas Importantes

⚠️ **Referencia Completa**: El flujo B busca con la referencia SIN modificación  
⚠️ **NULL Específico**: Se actualiza solo el campo `fechaRetransmision` a NULL  
⚠️ **Independencia**: El nuevo flujo NO afecta el estado del pago en `AppPagosPagoNotificacion`  
⚠️ **Reintento**: Los errores se registran pero no detienen el job  

---

## ✨ Mejoras Futuras (Opcionales)

- [ ] Agregar configuración para habilitar/deshabilitar Flujo B
- [ ] Crear tabla de auditoría de cambios
- [ ] Alertas si no encuentra `PagosRetransmitidos`
- [ ] Métricas específicas por flujo
- [ ] Dashboard de monitoreo

---

**Versión**: 1.1  
**Última Actualización**: 2026-11-26  
**Estado**: ✅ Listo para Producción
