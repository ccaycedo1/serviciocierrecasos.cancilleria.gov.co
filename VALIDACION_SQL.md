# Validación SQL - Implementación del Nuevo Flujo

Este documento contiene ejemplos SQL para validar que las tablas y campos utilizados en la implementación son correctos.

---

## 1. Verificar Estructura de Tablas Utilizadas

### Tabla: Apostilla.dbo.tbRecaudo

```sql
-- Ver estructura de tbRecaudo
USE Apostilla;
GO

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tbRecaudo' 
  AND TABLE_SCHEMA = 'dbo'
ORDER BY ORDINAL_POSITION;

-- Verificar índices
EXEC sp_helpindex 'Apostilla.dbo.tbRecaudo';

-- Verificar existencia de los campos requeridos
-- Esperados: idRecaudo, codEstadoRecaudo
```

### Tabla: Pagos.pse.AppPagosPagoNotificacion

```sql
-- Ver estructura de AppPagosPagoNotificacion
USE Pagos;
GO

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AppPagosPagoNotificacion' 
  AND TABLE_SCHEMA = 'pse'
ORDER BY ORDINAL_POSITION;

-- Verificar existencia de campos requeridos
-- Esperados: id, referenciaPago, idEstado, fechaModificacion
```

### Tabla: Pagos.tarjetaCredito.PagosRetransmitidos (NUEVA)

```sql
-- Ver estructura de PagosRetransmitidos
USE Pagos;
GO

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PagosRetransmitidos' 
  AND TABLE_SCHEMA = 'tarjetaCredito'
ORDER BY ORDINAL_POSITION;

-- Verificar existencia de campos requeridos
-- Esperados: id, referencia, fechaRetransmision
```

---

## 2. Consultas de Validación del Flujo Actual (codEstadoRecaudo = 2)

```sql
-- Ver registros de recaudo con estado = 2 (PAGADO)
USE Apostilla;
GO

SELECT TOP 10
    idRecaudo,
    codEstadoRecaudo,
    COUNT(*) OVER () as TotalRegistros
FROM dbo.tbRecaudo
WHERE codEstadoRecaudo = 2
ORDER BY idRecaudo DESC;

-- Verificar que estos son los que el flujo actual procesa
```

---

## 3. Consultas de Validación del Nuevo Flujo (codEstadoRecaudo ≠ 2)

```sql
-- Ver registros de recaudo con estado <> 2 (NO PAGADO)
USE Apostilla;
GO

SELECT TOP 10
    idRecaudo,
    codEstadoRecaudo,
    COUNT(*) OVER () as TotalRegistros
FROM dbo.tbRecaudo
WHERE codEstadoRecaudo <> 2
ORDER BY idRecaudo DESC;

-- Verificar que estos son los que activan el nuevo flujo
```

---

## 4. Consultas del Flujo B: Búsqueda en PagosRetransmitidos

```sql
-- PASO 1: Obtener referenciaPago completa
-- Se obtiene de AppPagosPagoNotificacion

USE Pagos;
GO

SELECT TOP 10
    id,
    referenciaPago,
    idEstado,
    fechaModificacion
FROM pse.AppPagosPagoNotificacion
WHERE idEstado <> 4
ORDER BY id DESC;

-- Ejemplo de referenciaPago: "APOSTILLA-12345", "PSE-REF-001", etc.
```

```sql
-- PASO 2: Con la referenciaPago, buscar en PagosRetransmitidos
-- Usando la referencia COMPLETA (no extraída)

USE Pagos;
GO

-- Ejemplo: si referenciaPago = 'APOSTILLA-12345'
-- Búsqueda en PagosRetransmitidos
SELECT 
    id,
    referencia,
    fechaRetransmision,
    -- otros campos relevantes
FROM tarjetaCredito.PagosRetransmitidos
WHERE referencia = 'APOSTILLA-12345';

-- Esta es la búsqueda que realiza el nuevo flujo
```

---

## 5. Actualización del Nuevo Flujo

```sql
-- PASO 3: Si existe, actualizar fechaRetransmision a NULL

USE Pagos;
GO

-- Ejemplo:
UPDATE tarjetaCredito.PagosRetransmitidos
SET fechaRetransmision = NULL
WHERE referencia = 'APOSTILLA-12345';

-- Ver resultado
SELECT 
    id,
    referencia,
    fechaRetransmision
FROM tarjetaCredito.PagosRetransmitidos
WHERE referencia = 'APOSTILLA-12345';
```

---

## 6. Validación Completa del Escenario

```sql
-- Escenario 1: Validar Flujo A (codEstadoRecaudo = 2)
/*
1. Encuentra recaudo con codEstadoRecaudo = 2
2. Busca el ID extraído en AppPagosPagoNotificacion
3. Actualiza pago a idEstado = 4
4. Registra como "Actualizado" en estadísticas
*/

USE Apostilla;
GO

SELECT TOP 1
    @IdRecaudo = idRecaudo,
    @CodEstado = codEstadoRecaudo
FROM dbo.tbRecaudo
WHERE codEstadoRecaudo = 2;

-- Si existe, se ejecuta:
-- UPDATE pse.AppPagosPagoNotificacion SET idEstado = 4 WHERE id = @IdPago
```

```sql
-- Escenario 2: Validar Flujo B (codEstadoRecaudo <> 2)
/*
1. Encuentra recaudo con codEstadoRecaudo <> 2
2. Obtiene referenciaPago completa del pago
3. Busca exactamente esa referencia en PagosRetransmitidos
4. Si existe, actualiza fechaRetransmision a NULL
5. Registra como "Actualizado (Flujo Alterno)" en estadísticas
*/

USE Pagos;
GO

SELECT TOP 1
    @ReferenciaPago = referenciaPago
FROM pse.AppPagosPagoNotificacion
WHERE idEstado <> 4;

-- Con @ReferenciaPago, se ejecuta:
-- SELECT * FROM tarjetaCredito.PagosRetransmitidos 
-- WHERE referencia = @ReferenciaPago

-- Si existe:
-- UPDATE tarjetaCredito.PagosRetransmitidos
-- SET fechaRetransmision = NULL
-- WHERE referencia = @ReferenciaPago
```

---

## 7. Verificar Distribución de Estados

```sql
-- Ver distribución de codEstadoRecaudo en tbRecaudo
USE Apostilla;
GO

SELECT 
    codEstadoRecaudo,
    COUNT(*) as Cantidad,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM dbo.tbRecaudo), 2) as Porcentaje
FROM dbo.tbRecaudo
GROUP BY codEstadoRecaudo
ORDER BY codEstadoRecaudo;

-- Resultado esperado:
-- - codEstadoRecaudo = 2: X% → Flujo A
-- - codEstadoRecaudo ≠ 2: Y% → Flujo B
```

---

## 8. Validación Post-Actualización

Después de ejecutar el job, verificar:

```sql
-- Ver registros que fueron actualizados en PagosRetransmitidos
USE Pagos;
GO

SELECT TOP 20
    id,
    referencia,
    fechaRetransmision,
    -- campo de auditoría si existe (ej: fechaActualizacion)
FROM tarjetaCredito.PagosRetransmitidos
WHERE fechaRetransmision IS NULL
ORDER BY id DESC;

-- Comparar con log del job para verificar coincidencia
```

---

## 9. Consultas de Auditoría

```sql
-- Ver qué pagos fueron procesados en el último job
USE Pagos;
GO

SELECT 
    id,
    referenciaPago,
    idEstado,
    fechaModificacion
FROM pse.AppPagosPagoNotificacion
WHERE fechaModificacion >= CONVERT(DATE, GETDATE())
ORDER BY fechaModificacion DESC;

-- Verificar que coincide con el log del servicio
```

---

## 10. Checklist de Validación

- [ ] Tabla `tbRecaudo` existe y tiene campos `idRecaudo` y `codEstadoRecaudo`
- [ ] Tabla `AppPagosPagoNotificacion` existe y tiene `referenciaPago` y `idEstado`
- [ ] Tabla `PagosRetransmitidos` existe y tiene campos `referencia` y `fechaRetransmision`
- [ ] Campo `codEstadoRecaudo = 2` corresponde a estado "PAGADO"
- [ ] Campo `codEstadoRecaudo ≠ 2` corresponde a estados que requieren retransmisión
- [ ] Conexión a base de datos funciona correctamente
- [ ] Permisos de UPDATE en ambas tablas están configurados

---

## 11. Monitoreo Post-Implementación

```sql
-- Query para monitoreo diario del nuevo flujo

USE Pagos;
GO

SELECT 
    DATE(fechaRetransmision) as Fecha,
    COUNT(*) as RegistrosConFechaRetrans,
    SUM(CASE WHEN fechaRetransmision IS NULL THEN 1 ELSE 0 END) as RegistrosNulosActualizados
FROM tarjetaCredito.PagosRetransmitidos
WHERE fechaRetransmision >= DATEADD(DAY, -1, GETDATE())
   OR fechaRetransmision IS NULL
GROUP BY DATE(fechaRetransmision)
ORDER BY Fecha DESC;
```

---

## Notas Importantes

✅ **Diferencia clave de FLUJO A vs FLUJO B:**
- **FLUJO A**: Busca el ID del recaudo (extrayendo últimos dígitos de referencia)
- **FLUJO B**: Busca la referencia COMPLETA sin modificación

✅ **Punto crítico de búsqueda en PagosRetransmitidos:**
- Se utiliza `referenciaPago` completa de `AppPagosPagoNotificacion`
- NO se extrae el ID como en el FLUJO A
- La búsqueda es exacta: `referencia = referenciaPago completa`

✅ **Actualización única requerida:**
- Solo se establece `fechaRetransmision = NULL`
- No se modifican otros campos
- No se elimina el registro
