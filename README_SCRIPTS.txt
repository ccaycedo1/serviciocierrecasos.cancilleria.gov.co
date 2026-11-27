📌 RESUMEN RÁPIDO - Scripts de Ejecución

╔════════════════════════════════════════════════════════════════════════════╗
║                     ARCHIVOS CREADOS Y SU USO                             ║
╚════════════════════════════════════════════════════════════════════════════╝

┌─ ejecutar.bat (RECOMENDADO)
│  Uso: Doble clic o "ejecutar.bat" en terminal
│  Función: Validación completa + Compilación + Ejecución con depuración
│  Tiempo: ~20-30 segundos en primera ejecución
│  Muestra: 9 pasos detallados con verificaciones
│  Mejor para: Primera ejecución, diagnóstico de problemas

┌─ ejecutar-rapido.bat (NORMAL)
│  Uso: "ejecutar-rapido.bat"
│  Función: Compilación y ejecución rápida
│  Tiempo: ~5-15 segundos
│  Mejor para: Después de cambios en código

┌─ ejecutar-directo.bat (MÁS RÁPIDO)
│  Uso: "ejecutar-directo.bat"
│  Función: Solo ejecución sin compilación
│  Tiempo: ~2-5 segundos
│  Mejor para: Cambios solo en configuración, pruebas rápidas

┌─ ejecutar-debug.bat (DIAGNÓSTICO)
│  Uso: "ejecutar-debug.bat"
│  Función: Compilación con verbosidad máxima + diagnósticos
│  Tiempo: ~20-30 segundos
│  Mejor para: Resolver problemas de compilación o configuración

┌─ GUIA_EJECUCION.md
   Archivo de referencia con documentación completa


╔════════════════════════════════════════════════════════════════════════════╗
║                           INICIO RÁPIDO                                   ║
╚════════════════════════════════════════════════════════════════════════════╝

1️⃣  Abre CMD o PowerShell en la carpeta del proyecto

2️⃣  Ejecuta (primera vez):
    ejecutar.bat

3️⃣  Después de cambios en código:
    ejecutar-rapido.bat

4️⃣  Para pruebas rápidas (sin código modificado):
    ejecutar-directo.bat


╔════════════════════════════════════════════════════════════════════════════╗
║                         LÍNEA DE COMANDOS                                 ║
╚════════════════════════════════════════════════════════════════════════════╝

Desde la carpeta del proyecto:

Compilar:
  dotnet build ServicioCierreCasos.csproj --configuration Debug

Ejecutar:
  dotnet bin\Debug\net10.0\ServicioCierreCasos.dll

Compilar y ejecutar (combinado):
  dotnet build && dotnet bin\Debug\net10.0\ServicioCierreCasos.dll

Limpiar:
  dotnet clean

Ver versión .NET:
  dotnet --version


╔════════════════════════════════════════════════════════════════════════════╗
║                      SOLUCIÓN DE PROBLEMAS COMUNES                        ║
╚════════════════════════════════════════════════════════════════════════════╝

❌ "dotnet: comando no encontrado"
   → Instala .NET SDK desde https://dotnet.microsoft.com/download
   → Reinicia tu terminal

❌ "No se encuentra ServicioCierreCasos.csproj"
   → Navega a la carpeta correcta:
      cd C:\ApostillaCcaycedo\ServicioCierreCasos

❌ Error de conexión a base de datos
   → Revisa appsettings.json
   → Verifica que SQL Server esté disponible
   → Revisa las credenciales

❌ Error de compilación
   → Ejecuta: ejecutar-debug.bat (para más detalles)
   → Verifica que no haya errores de sintaxis


╔════════════════════════════════════════════════════════════════════════════╗
║                            INFORMACIÓN ÚTIL                               ║
╚════════════════════════════════════════════════════════════════════════════╝

Proyecto: Servicio de Cierre de Casos
Target: .NET 10.0
Configuración: Desarrollo (Debug) / Producción (Release)

Dependencias principales:
  - Microsoft.Extensions.Hosting
  - System.Data.SqlClient
  - Dapper (ORM)
  - Polly (Reintentos)

Archivos de configuración:
  - appsettings.json (configuración base)
  - appsettings.Development.json (desarrollo)


╔════════════════════════════════════════════════════════════════════════════╗
║                            CARACTERÍSTICAS DE LOS SCRIPTS                 ║
╚════════════════════════════════════════════════════════════════════════════╝

✅ Validación del entorno antes de compilar
✅ Verificación de .NET SDK
✅ Restauración automática de dependencias
✅ Compilación limpia (sin artefactos viejos)
✅ Verificación de configuración
✅ Captura de errores detallada
✅ Código de salida apropiado para automatización
✅ Menú de opciones interactivas (en ejecutar.bat)
✅ Colores y símbolos para mejor legibilidad
✅ Logs con timestamps


┌────────────────────────────────────────────────────────────────────────────┐
│ Para más información detallada, consulta: GUIA_EJECUCION.md               │
└────────────────────────────────────────────────────────────────────────────┘
