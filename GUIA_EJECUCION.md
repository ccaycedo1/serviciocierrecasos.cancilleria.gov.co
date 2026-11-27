# Guía de Ejecución - Servicio de Cierre de Casos

## 📋 Scripts Disponibles

### 1. **ejecutar.bat** (Recomendado)
Script completo con depuración paso a paso.

**Características:**
- ✓ Validación del entorno
- ✓ Verificación de .NET SDK
- ✓ Limpieza de compilaciones anteriores
- ✓ Restauración de dependencias
- ✓ Compilación del proyecto
- ✓ Verificación de configuración
- ✓ Ejecución del programa
- ✓ Captura de errores
- ✓ Menú de opciones adicionales

**Uso:**
```bash
ejecutar.bat
```

**Resultado:**
El script mostrará cada paso en detalle, permitiendo identificar exactamente dónde falla el proceso si hay algún error.

---

### 2. **ejecutar-rapido.bat**
Script simplificado para compilación y ejecución rápida.

**Características:**
- ✓ Compilación (si es necesaria)
- ✓ Ejecución directa
- ✓ Mínimo de output

**Uso:**
```bash
ejecutar-rapido.bat
```

**Cuándo usar:**
Cuando ya has verificado que el entorno está correctamente configurado y solo quieres compilar y ejecutar rápidamente.

---

### 3. **ejecutar-directo.bat**
Script de ejecución sin compilación.

**Características:**
- ✓ Ejecuta el assembly ya compilado
- ✓ Más rápido (sin compilación)
- ✗ Requiere que el proyecto ya esté compilado

**Uso:**
```bash
ejecutar-directo.bat
```

**Cuándo usar:**
- Después de haber compilado con `ejecutar.bat` o `ejecutar-rapido.bat`
- Para pruebas rápidas sin cambios de código
- Para depuración rápida de cambios en configuración

---

### 4. **ejecutar-debug.bat**
Script para depuración avanzada con máxima verbosidad.

**Características:**
- ✓ Validación de configuración
- ✓ Verificación de ConnectionStrings
- ✓ Compilación con diagnósticos completos
- ✓ Listado de archivos compilados
- ✓ Ejecución con logs detallados

**Uso:**
```bash
ejecutar-debug.bat
```

**Cuándo usar:**
- Cuando sospechas que hay problemas de configuración
- Para diagnósticos detallados
- Cuando necesitas investigar errores de compilación

---

## 🔧 Requisitos Previos

### Instalación de .NET SDK

1. Descarga .NET SDK desde: https://dotnet.microsoft.com/download
2. Instala la versión **net10.0** (o compatible con tu proyecto)
3. Verifica la instalación:
   ```bash
   dotnet --version
   ```

### Configuración del Proyecto

1. Asegúrate de que `appsettings.json` esté configurado correctamente
2. Verifica la ConnectionString para la base de datos:
   ```json
   "ConnectionStrings": {
     "ApostillaDb": "Server=tu-servidor;Database=tu-db;User Id=usuario;Password=contraseña;"
   }
   ```

---

## 🚀 Guía de Uso Rápido

### Primera Ejecución (Configuración inicial)
```bash
ejecutar.bat
```
- Validará todo el entorno
- Compilará el proyecto
- Ejecutará el programa
- Mostrará un menú con opciones adicionales

### Ejecuciones Posteriores (sin cambios de código)
```bash
ejecutar-directo.bat
```
- Ejecuta directamente el assembly compilado
- Más rápido que compilar nuevamente

### Después de cambios en el código
```bash
ejecutar-rapido.bat
```
- Recompila si hay cambios
- Ejecuta inmediatamente

### Cuando hay problemas
```bash
ejecutar-debug.bat
```
- Proporciona información detallada
- Ayuda a diagnosticar problemas

---

## 📊 Paso a Paso de Depuración

### Paso 1: Validar Entorno
El script verifica:
- ✓ Ubicación del proyecto
- ✓ Existencia de `ServicioCierreCasos.csproj`
- ✓ Instalación de .NET SDK

**Si falla:**
- Asegúrate de que estés en la carpeta correcta
- Instala .NET SDK si no está disponible

### Paso 2: Restaurar Dependencias
```bash
dotnet restore ServicioCierreCasos.csproj
```
Descarga todos los paquetes NuGet necesarios (Dapper, Polly, etc.)

**Si falla:**
- Verifica tu conexión a internet
- Revisa si hay proxy/firewall bloqueando nuget.org

### Paso 3: Compilar Proyecto
```bash
dotnet build ServicioCierreCasos.csproj --configuration Debug
```
Compila el código a un assembly .DLL

**Si falla:**
- Verifica errores de sintaxis en el código
- Revisa que todos los archivos estén presentes

### Paso 4: Ejecutar Programa
```bash
dotnet bin\Debug\net10.0\ServicioCierreCasos.dll
```
Ejecuta el programa compilado

**Si falla:**
- Verifica la configuración de conexión de base de datos
- Revisa los logs de error (mostrados en consola)

---

## 🐛 Solución de Problemas Comunes

### Error: "dotnet: comando no encontrado"
**Solución:**
- Instala .NET SDK desde https://dotnet.microsoft.com/download
- Reinicia la terminal después de instalar

### Error: "No se encuentra ServicioCierreCasos.csproj"
**Solución:**
- Asegúrate de estar en la carpeta raíz del proyecto
- Verifica que el archivo existe: `dir ServicioCierreCasos.csproj`

### Error: "No se puede conectar a la base de datos"
**Solución:**
- Verifica la ConnectionString en `appsettings.json`
- Asegúrate de que el servidor SQL Server esté disponible
- Verifica las credenciales de base de datos

### Error: "No se puede restaurar las dependencias"
**Solución:**
- Verifica tu conexión a internet
- Intenta con: `dotnet restore --no-cache`
- Revisa si hay proxy configurado

### El programa se ejecuta pero no hace nada
**Solución:**
- Revisa los logs en consola (mostrados al ejecutar)
- Verifica que la base de datos tenga datos
- Revisa que el Job se esté ejecutando correctamente

---

## 📝 Órdenes Útiles (Línea de comandos)

```bash
# Ver versión de .NET
dotnet --version

# Limpiar compilaciones anteriores
dotnet clean ServicioCierreCasos.csproj

# Restaurar solo dependencias
dotnet restore

# Compilar solo
dotnet build --configuration Debug

# Compilar sin restaurar
dotnet build --no-restore

# Compilar en Release (más optimizado)
dotnet build --configuration Release

# Ejecutar con argumentos
dotnet bin\Debug\net10.0\ServicioCierreCasos.dll --argument value

# Ver información del proyecto
dotnet info
```

---

## 🎯 Interpretación de Logs

### Cuando ves esto:
```
✓ Proyecto encontrado: ServicioCierreCasos.csproj
✓ .NET SDK encontrado: 10.0.0
✓ Dependencias restauradas correctamente
✓ Compilación completada exitosamente
✓ Ensamblado encontrado: ServicioCierreCasos.dll
```
**Significa:** Todo está bien, el programa debería ejecutarse

### Cuando ves esto:
```
⚠ NOTA: No se encuentra appsettings.Development.json
```
**Significa:** No hay problema, usará la configuración por defecto

### Cuando ves esto:
```
✗ ERROR: No se encuentra ServicioCierreCasos.csproj
```
**Significa:** Estás en la carpeta incorrecta, navega a la raíz del proyecto

---

## 🔄 Opciones del Menú (ejecutar.bat)

Después de la ejecución, el script te mostrará:
```
1) Volver a ejecutar       - Cierra y reinicia el script
2) Ejecutar en Release     - Compila y ejecuta versión optimizada
3) Ver logs del build      - Abre carpeta bin\Debug\net10.0\
4) Limpiar y compilar      - Limpia artefactos y recompila
5) Salir                   - Cierra el script
```

---

## ✨ Consejos Adicionales

1. **Mantén una terminal abierta:**
   - Windows: `Win + X` → Terminal
   - Después navega: `cd C:\ApostillaCcaycedo\ServicioCierreCasos`

2. **Para desarrollo iterativo:**
   - Usa `ejecutar.bat` la primera vez
   - Usa `ejecutar-directo.bat` para ejecuciones posteriores
   - Recuerda usar `ejecutar-rapido.bat` si cambias código

3. **Para CI/CD (automatización):**
   - Personaliza los scripts según tus necesidades
   - Captura el exit code: `echo %ERRORLEVEL%`

4. **Redireccionar logs a archivo:**
   ```bash
   dotnet bin\Debug\net10.0\ServicioCierreCasos.dll > log.txt 2>&1
   ```

---

## 📞 Soporte

Si encuentras problemas:
1. Ejecuta: `ejecutar-debug.bat`
2. Copia los mensajes de error
3. Verifica tu configuración de base de datos
4. Revisa que todas las dependencias estén instaladas

---

**Creado el:** 2024
**Versión:** 1.0
**Para:** Servicio de Cierre de Casos
