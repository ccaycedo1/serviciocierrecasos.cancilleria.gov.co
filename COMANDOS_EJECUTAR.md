# 🎯 COMANDOS PARA EJECUTAR EL PROGRAMA EN CONSOLA

## ⚡ INICIO RÁPIDO (Copiar y Pegar)

### Opción 1: PowerShell (RECOMENDADO)

```powershell
cd C:\ApostillaCcaycedo\ServicioCierreCasos
.\ejecutar-debug.ps1
```

**↓↓↓ MÁS FÁCIL: Solo abre PowerShell y pega esto ↓↓↓**
```powershell
cd C:\ApostillaCcaycedo\ServicioCierreCasos; .\ejecutar-debug.ps1
```

---

### Opción 2: CMD (Símbolo del Sistema)

```cmd
cd C:\ApostillaCcaycedo\ServicioCierreCasos
ejecutar-debug.bat
```

**↓↓↓ MÁS FÁCIL: Abre CMD y pega esto ↓↓↓**
```cmd
cd C:\ApostillaCcaycedo\ServicioCierreCasos && ejecutar-debug.bat
```

---

## 📝 PASOS DETALLADOS

### Paso 1: Abrir Terminal

**Windows PowerShell:**
- Presiona `Win + X` → Selecciona "Windows PowerShell"
- O busca "PowerShell" en el menú de inicio

**CMD (Símbolo del Sistema):**
- Presiona `Win + R` → Escribe `cmd` → Presiona Enter
- O busca "Command Prompt" en el menú de inicio

---

### Paso 2: Permitir Ejecución de Scripts (Solo primera vez en PowerShell)

Si ves un error como:
```
El archivo ejecutar-debug.ps1 no se puede cargar porque la ejecución de scripts está deshabilitada en este sistema.
```

Ejecuta esto en PowerShell como Administrador:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Cuando pregunte, escribe: `Y` y presiona Enter

---

### Paso 3: Navegar al Directorio del Proyecto

Copia y pega en tu terminal:

**PowerShell:**
```powershell
cd C:\ApostillaCcaycedo\ServicioCierreCasos
```

**CMD:**
```cmd
cd C:\ApostillaCcaycedo\ServicioCierreCasos
```

---

### Paso 4: Ejecutar el Programa

**Opción A: Usando Script (AUTOMÁTICO)**

PowerShell:
```powershell
.\ejecutar-debug.ps1
```

CMD:
```cmd
ejecutar-debug.bat
```

**Opción B: Compilar y Ejecutar Manualmente**

PowerShell o CMD:
```bash
dotnet build -c Debug
dotnet run --project DebugConsole\DebugConsole.csproj --no-build
```

---

## 📺 QUÉ VERÁS EN LA PANTALLA

Cuando ejecutes el programa, verás esto por pasos:

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
```

Luego verás:

```
🔗 CONFIGURACIÓN DE CONEXIONES:
  • Base de Datos Pagos (ApostillaDb): 172.20.1.22
  • Base de Datos Apostilla (ApostillaRecaudoDb): 172.20.1.22
```

Después verás la ejecución:

```
▼ PASO 1: Consultando pagos pendientes...
  Condición: idEstado <> 4
🔍 Iniciando consulta de pagos pendientes...
  ↳ Abriendo conexión a SQL Server...
  ✅ Conexión establecida correctamente
  ↳ Ejecutando query SQL...
✅ Consulta de pagos pendientes completada. Total encontrado: 125
📊 Cantidad de registros consultados: 125
```

Y procesará cada pago:

```
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
```

Finalmente verás el resumen:

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

---

## 🔴 SI ALGO FALLA

### Error: ".NET SDK no está instalado"

```
El término 'dotnet' no se reconoce como el nombre de un cmdlet, 
función, archivo de script o programa ejecutable.
```

**Solución:**
1. Descarga .NET 10.0 SDK: https://dotnet.microsoft.com/download
2. Instálalo
3. Reinicia tu terminal
4. Verifica con: `dotnet --version`

---

### Error: "No se puede conectar a SQL Server"

```
❌ Error de SQL al consultar pagos pendientes
   Número de Error SQL: 18456
   Mensaje: Login failed for user 'pse'
```

**Solución:**
1. Abre `appsettings.json` en la carpeta del proyecto
2. Verifica que el servidor sea correcto
3. Verifica que el usuario y contraseña sean correctos
4. Asegúrate de que SQL Server esté ejecutándose

---

### Error: "No hay pagos pendientes para procesar"

```
ℹ️  No hay pagos pendientes para procesar.
```

**Esto es NORMAL si:**
- No hay registros con `idEstado <> 4`
- Todos los pagos ya fueron actualizados
- O es la primera ejecución

---

## ✅ ¿CÓMO SABER QUE FUNCIONA?

Busca estos indicadores de éxito:

1. ✅ Verás `✅ Conexión establecida correctamente`
2. ✅ Verás `✅ Consulta de pagos pendientes completada`
3. ✅ Verás `Registros Actualizados: X` (donde X > 0)
4. ✅ Verás `Errores Presentados: 0`
5. ✅ Verás `✅ No se encontraron errores durante la ejecución`
6. ✅ Verás `RESULTADO FINAL: EXITOSO`

---

## 📊 INTERPRETACIÓN DE LOS MENSAJES

| Símbolo | Significado | Qué hacer |
|---------|-------------|-----------|
| ✅ | Éxito | Continuar, todo funciona bien |
| ❌ | Error crítico | Revisar configuración y logs |
| ⚠️ | Advertencia | Revisar, pero no detiene la ejecución |
| ℹ️ | Información | Solo para tu conocimiento |
| 🔍 | Búsqueda/Consulta | El programa está consultando la BD |
| 📊 | Estadísticas | Números finales de la ejecución |
| ⏱️ | Tiempo | Fecha, hora y duración |

---

## 🎯 CHECKLIST ANTES DE EJECUTAR

- [ ] .NET 10.0 SDK está instalado (`dotnet --version` funciona)
- [ ] Estás en el directorio correcto (`C:\ApostillaCcaycedo\ServicioCierreCasos`)
- [ ] SQL Server está accesible
- [ ] `appsettings.json` tiene las conexiones correctas
- [ ] El usuario SQL tiene permisos en las tablas

---

## 🚀 LISTO PARA EMPEZAR

**En PowerShell:**
```powershell
cd C:\ApostillaCcaycedo\ServicioCierreCasos; .\ejecutar-debug.ps1
```

**En CMD:**
```cmd
cd C:\ApostillaCcaycedo\ServicioCierreCasos && ejecutar-debug.bat
```

---

**¡Que disfrutes la depuración! 🎉**
