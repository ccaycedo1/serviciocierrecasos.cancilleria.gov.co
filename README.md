# Servicio de cierre de casos

Proyecto base de Worker Service para .NET 11. El servicio arranca y espera; la
funcionalidad de cierre y el acceso a la base de datos se implementarán cuando
se definan sus requisitos. Todavía no realiza conexiones.

## Desarrollo

Se requiere el SDK de .NET 11. Las cadenas `ApostillaDb` y `SitacDb` están en
la configuración, sin contraseña. Para desarrollo, se han guardado las cadenas
completas en User Secrets del usuario actual; no se publican con el proyecto.
Para configurarlas en otro equipo:

```powershell
dotnet user-secrets set "ConnectionStrings:ApostillaDb" "<cadena completa>"
dotnet user-secrets set "ConnectionStrings:SitacDb" "<cadena completa>"
$env:DOTNET_ENVIRONMENT = "Development"
dotnet run
```

User Secrets solo se carga en el entorno `Development` y no es un almacén
cifrado. No incluya contraseñas en archivos de código ni en el repositorio.
Las opciones de conexión recibidas deshabilitan el cifrado TLS y confían en el
certificado; revise estos ajustes antes de utilizarlos en producción.

## Publicación e instalación

En Windows, publique en una carpeta permanente:

```powershell
dotnet publish -c Release -r win-x64 --self-contained true -o .\publish
```

Antes de iniciar el servicio, configure las cadenas completas para producción.
Por ejemplo, cree `appsettings.Production.json` en la carpeta publicada, con
la misma estructura `ConnectionStrings` y ambas cadenas completas. Restrinja
sus permisos de lectura a administradores y a la identidad del servicio.
Este archivo contiene credenciales y no debe distribuirse ni incluirse en
control de versiones. El servicio instalado con el script usa `LocalSystem`
por defecto; User Secrets de desarrollo no se transfiere al servicio.

Ejecute el script en PowerShell como administrador, conforme a la política de
ejecución de su organización:

```powershell
.\Instalar-Servicio.ps1 -RutaPublicacion .\publish
Start-Service -Name ServicioCierreCasos
```

El servicio apunta al ejecutable de la carpeta publicada; no la mueva ni la
elimine mientras esté instalado. El script registra el servicio, pero no
genera un instalador gráfico ni un paquete MSI.
