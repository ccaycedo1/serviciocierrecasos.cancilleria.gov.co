using ServicioCierreCasos;
using ServicioCierreCasos.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Hosting.WindowsServices;

if (WindowsServiceHelpers.IsWindowsService())
{
    var serviceBuilder = Host.CreateApplicationBuilder(new HostApplicationBuilderSettings
    {
        Args = args,
        ContentRootPath = AppContext.BaseDirectory
    });
    serviceBuilder.Services.AddWindowsService(options => options.ServiceName = "ServicioCierreCasos");
    serviceBuilder.Services.AddScoped<IPagoService, PagoService>();
    serviceBuilder.Services.AddScoped<IRecaudoService, RecaudoService>();
    serviceBuilder.Services.AddScoped<IPagoRetransmitidoService, PagoRetransmitidoService>();
    serviceBuilder.Services.AddScoped<IActualizarEstadosPagosJob, ActualizarEstadosPagosJob>();
    serviceBuilder.Services.AddHostedService<Worker>();
    await serviceBuilder.Build().RunAsync();
    return;
}

var builder = Host.CreateApplicationBuilder(args);

// Configurar logging con verbosidad
builder.Services.AddLogging(loggingBuilder =>
{
    loggingBuilder
        .ClearProviders()
        .AddConsole()
        .SetMinimumLevel(LogLevel.Debug);
});

// Registrar servicios
builder.Services.AddScoped<IPagoService, PagoService>();
builder.Services.AddScoped<IRecaudoService, RecaudoService>();
builder.Services.AddScoped<IPagoRetransmitidoService, PagoRetransmitidoService>();
builder.Services.AddScoped<IActualizarEstadosPagosJob, ActualizarEstadosPagosJob>();

var host = builder.Build();

// Ejecutar una sola vez el job
Console.WriteLine("");
Console.WriteLine("╔══════════════════════════════════════════════════════════════════╗");
Console.WriteLine("║   PROGRAMA DE DEPURACIÓN - ACTUALIZACIÓN DE ESTADOS DE PAGOS      ║");
Console.WriteLine("║   Versión: 1.0                                                   ║");
Console.WriteLine($"║   Fecha de Ejecución: {DateTime.Now:dd/MM/yyyy HH:mm:ss}                              ║");
Console.WriteLine("╚══════════════════════════════════════════════════════════════════╝");
Console.WriteLine("");

Console.WriteLine("📋 INFORMACIÓN DEL ENTORNO:");
Console.WriteLine($"  • Sistema Operativo: {System.Runtime.InteropServices.RuntimeInformation.OSDescription}");
Console.WriteLine($"  • Versión .NET: {System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription}");
Console.WriteLine($"  • Directorio Actual: {Directory.GetCurrentDirectory()}");
Console.WriteLine("");

Console.WriteLine("🔗 CONFIGURACIÓN DE CONEXIONES:");
var configuration = host.Services.GetRequiredService<IConfiguration>();
var connectionStrings = configuration.GetSection("ConnectionStrings");
var apostillaDb = connectionStrings["ApostillaDb"] ?? "No configurada";

Console.WriteLine($"  • Base de Datos Pagos: {ExtractServerFromConnectionString(apostillaDb)}");
Console.WriteLine("");

Console.WriteLine("⚙️  PARÁMETROS DE EJECUCIÓN:");
Console.WriteLine("  • Intervalo de Ejecución: 5 minutos");
Console.WriteLine("  • Modo: Ejecución Única (Depuración)");
Console.WriteLine("  • Reintento en Errores: Habilitado");
Console.WriteLine("");

Console.WriteLine("════════════════════════════════════════════════════════════════════");
Console.WriteLine("🚀 INICIANDO EJECUCIÓN DEL JOB...");
Console.WriteLine("════════════════════════════════════════════════════════════════════");
Console.WriteLine("");

try
{
    var job = host.Services.GetRequiredService<IActualizarEstadosPagosJob>();
    Console.WriteLine($"⏱️  Iniciando job en: {DateTime.Now:dd/MM/yyyy HH:mm:ss.fff}");
    
    var log = await job.EjecutarAsync();
    
    Console.WriteLine($"✅ Job finalizado en: {DateTime.Now:dd/MM/yyyy HH:mm:ss.fff}");
}
catch (Exception ex)
{
    Console.WriteLine("");
    Console.WriteLine("════════════════════════════════════════════════════════════════════");
    Console.WriteLine("❌ ERROR CRÍTICO DURANTE LA EJECUCIÓN");
    Console.WriteLine("════════════════════════════════════════════════════════════════════");
    Console.WriteLine("");
    Console.WriteLine($"📍 Tipo de Excepción: {ex.GetType().Name}");
    Console.WriteLine($"📍 Mensaje de Error: {ex.Message}");
    Console.WriteLine("");
    Console.WriteLine("🔍 Stack Trace:");
    Console.WriteLine(ex.StackTrace);
}

Console.WriteLine("");
Console.WriteLine("👋 Programa de depuración finalizado.");
Console.WriteLine("Presiona cualquier tecla para cerrar...");
Console.ReadKey();

static string ExtractServerFromConnectionString(string connectionString)
{
    try
    {
        if (string.IsNullOrEmpty(connectionString))
            return "No configurada";

        var parts = connectionString.Split(';');
        var serverPart = parts.FirstOrDefault(p => p.StartsWith("Server=", StringComparison.OrdinalIgnoreCase));
        if (serverPart != null)
            return serverPart.Replace("Server=", "").Trim();

        return "No especificado";
    }
    catch
    {
        return "Error al parsear";
    }
}
