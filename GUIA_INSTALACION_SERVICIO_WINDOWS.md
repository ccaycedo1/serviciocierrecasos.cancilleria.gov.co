# Instalador del servicio Windows

El instalador `bin\instalador\InstalarServicioCierreCasos.exe` es para Windows
x64 e incluye el runtime de .NET 10. Solicita permisos de administrador. No
incluye credenciales y no modifica una instalación existente.

1. Ejecute el instalador en el equipo destino. El servicio se instala detenido,
   con inicio manual, en `C:\Program Files\ServicioCierreCasos`.
2. Configure `ApostillaDb` y `ApostillaRecaudoDb` en el `appsettings.json` de
   esa carpeta. Proteja el acceso al archivo, que contendrá las credenciales.
3. Verifique la conectividad y los permisos de lectura y actualización requeridos
   por el servicio. Este procesa pagos cada cinco minutos y puede actualizar datos.
4. Cuando esté autorizado para iniciar el procesamiento, ejecute PowerShell como
   administrador:

   ```powershell
   Set-Service -Name ServicioCierreCasos -StartupType Automatic
   Start-Service -Name ServicioCierreCasos
   Get-Service -Name ServicioCierreCasos
   ```

Para regenerar el instalador desde el proyecto, con el SDK .NET 10 instalado:

```powershell
.\Generar-Instalador.ps1
```

El instalador no realiza actualizaciones ni elimina servicios existentes.
