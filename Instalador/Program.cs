using System.Diagnostics;
using System.Reflection;

const string serviceName = "ServicioCierreCasos";
var destination = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), serviceName);

try
{
    var query = await RunScAsync("query", serviceName);
    if (query.ExitCode == 0)
        throw new InvalidOperationException($"El servicio {serviceName} ya existe; no se modifico.");
    if (query.ExitCode != 1060)
        throw new InvalidOperationException($"No se pudo verificar el servicio: {query.Output}");
    if (Directory.Exists(destination))
        throw new InvalidOperationException($"La carpeta {destination} ya existe; no se modifico.");

    Directory.CreateDirectory(destination);
    foreach (var name in new[] { "ServicioCierreCasos.exe", "appsettings.json" })
    {
        await using var source = Assembly.GetExecutingAssembly().GetManifestResourceStream(name)
            ?? throw new InvalidOperationException($"Falta el recurso {name}.");
        await using var target = new FileStream(Path.Combine(destination, name), FileMode.CreateNew);
        await source.CopyToAsync(target);
    }

    var executable = Path.Combine(destination, "ServicioCierreCasos.exe");
    var create = await RunScAsync("create", serviceName, "binPath=", $"\"{executable}\"",
        "start=", "demand", "DisplayName=", "Servicio de cierre de casos");
    if (create.ExitCode != 0)
        throw new InvalidOperationException($"No se pudo crear el servicio: {create.Output}");

    Console.WriteLine($"Servicio instalado y detenido. Configure {Path.Combine(destination, "appsettings.json")} antes de iniciarlo.");
    Console.WriteLine("Configure el inicio automatico despues de validar las conexiones.");
}
catch (Exception ex)
{
    Console.Error.WriteLine($"Error de instalacion: {ex.Message}");
    Environment.ExitCode = 1;
}

if (!Console.IsInputRedirected)
{
    Console.WriteLine("Presione una tecla para cerrar.");
    Console.ReadKey(true);
}

static async Task<(int ExitCode, string Output)> RunScAsync(params string[] arguments)
{
    var start = new ProcessStartInfo(Path.Combine(Environment.SystemDirectory, "sc.exe"))
    {
        UseShellExecute = false,
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        CreateNoWindow = true
    };
    foreach (var argument in arguments)
        start.ArgumentList.Add(argument);

    using var process = Process.Start(start) ?? throw new InvalidOperationException("No se pudo iniciar sc.exe.");
    var output = process.StandardOutput.ReadToEndAsync();
    var error = process.StandardError.ReadToEndAsync();
    await process.WaitForExitAsync();
    return (process.ExitCode, (await output) + (await error));
}
