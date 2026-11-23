using System.Data;
using System.Data.SqlClient;

namespace ServicioCierreCasos;

public class TestConectividad
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<TestConectividad> _logger;

    public TestConectividad(IConfiguration configuration, ILogger<TestConectividad> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task EjecutarPruebasAsync()
    {
        Console.WriteLine("");
        Console.WriteLine("╔══════════════════════════════════════════════════════════════════╗");
        Console.WriteLine("║   BATERÍA DE PRUEBAS DE CONECTIVIDAD A BASES DE DATOS            ║");
        Console.WriteLine("║   Versión: 1.0                                                   ║");
        Console.WriteLine($"║   Fecha: {DateTime.Now:dd/MM/yyyy HH:mm:ss}                                        ║");
        Console.WriteLine("╚══════════════════════════════════════════════════════════════════╝");
        Console.WriteLine("");

        var connectionStrings = _configuration.GetSection("ConnectionStrings");
        
        var conexiones = new Dictionary<string, string>
        {
            { "ApostillaDb", connectionStrings["ApostillaDb"] ?? "No configurada" },
            { "SitacDb", connectionStrings["SitacDb"] ?? "No configurada" },
            { "ApostillaRecaudoDb", connectionStrings["ApostillaRecaudoDb"] ?? "No configurada" }
        };

        int totalConexiones = conexiones.Count;
        int conexionesExitosas = 0;
        int conexionesFallidas = 0;

        Console.WriteLine("🔍 CONEXIONES CONFIGURADAS:");
        Console.WriteLine("");

        foreach (var conexion in conexiones)
        {
            Console.WriteLine($"{'─',70}");
            Console.WriteLine($"📌 Nombre: {conexion.Key}");
            Console.WriteLine($"📌 Cadena: {OcultarPassword(conexion.Value)}");
            Console.WriteLine("");

            bool exitosa = await PruebaConexionAsync(conexion.Key, conexion.Value);
            
            if (exitosa)
                conexionesExitosas++;
            else
                conexionesFallidas++;

            Console.WriteLine("");
        }

        // Resumen
        Console.WriteLine("╔════════════════════════════════════════════════════════════════╗");
        Console.WriteLine("║                        RESUMEN FINAL                           ║");
        Console.WriteLine("╚════════════════════════════════════════════════════════════════╝");
        Console.WriteLine("");
        Console.WriteLine($"  📊 Total de Conexiones: {totalConexiones}");
        Console.WriteLine($"  ✅ Exitosas: {conexionesExitosas}");
        Console.WriteLine($"  ❌ Fallidas: {conexionesFallidas}");
        Console.WriteLine($"  📈 Tasa de Éxito: {(conexionesExitosas * 100 / totalConexiones)}%");
        Console.WriteLine("");

        if (conexionesFallidas == 0)
        {
            Console.WriteLine("  ✨ ¡TODAS LAS CONEXIONES SON CORRECTAS! ✨");
        }
        else
        {
            Console.WriteLine($"  ⚠️  ATENCIÓN: {conexionesFallidas} conexión(es) fallida(s)");
        }

        Console.WriteLine("");
        Console.WriteLine("════════════════════════════════════════════════════════════════");
    }

    private async Task<bool> PruebaConexionAsync(string nombre, string connectionString)
    {
        try
        {
            if (connectionString == "No configurada")
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"  ❌ RESULTADO: No configurada");
                Console.ResetColor();
                return false;
            }

            using (var connection = new SqlConnection(connectionString))
            {
                Console.WriteLine($"  🔄 Intentando conectar...");
                await connection.OpenAsync();

                // Información de la conexión
                Console.WriteLine($"  ✅ Conexión establecida correctamente");
                Console.WriteLine($"     ├─ Servidor: {connection.DataSource}");
                Console.WriteLine($"     ├─ Base de Datos: {connection.Database}");
                Console.WriteLine($"     └─ Estado: {connection.State}");

                // Prueba de query simple
                Console.WriteLine($"  🔄 Ejecutando query de prueba...");
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "SELECT @@SERVERNAME as Servidor, DB_NAME() as BaseDatos, GETDATE() as FechaServidor";
                    command.CommandTimeout = 10;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            string servidor = reader["Servidor"]?.ToString() ?? "N/A";
                            string baseDatos = reader["BaseDatos"]?.ToString() ?? "N/A";
                            string fechaServidor = reader["FechaServidor"]?.ToString() ?? "N/A";

                            Console.WriteLine($"  ✅ Query ejecutada exitosamente");
                            Console.WriteLine($"     ├─ Servidor DB: {servidor}");
                            Console.WriteLine($"     ├─ BD Actual: {baseDatos}");
                            Console.WriteLine($"     └─ Hora del Servidor: {fechaServidor}");
                        }
                    }
                }

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"  ✅ RESULTADO: Conexión exitosa");
                Console.ResetColor();
                return true;
            }
        }
        catch (SqlException ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"  ❌ RESULTADO: Error de SQL");
            Console.ResetColor();
            Console.WriteLine($"     ├─ Código Error: {ex.Number}");
            Console.WriteLine($"     ├─ Mensaje: {ex.Message}");
            
            if (ex.Number == 4221)
                Console.WriteLine($"     └─ ℹ️  Error de Timeout - Servidor no responde");
            else if (ex.Number == 18456)
                Console.WriteLine($"     └─ ℹ️  Error de Autenticación - Usuario/Password incorrecto");
            else if (ex.Number == 4060)
                Console.WriteLine($"     └─ ℹ️  Error de Base de Datos - BD no existe o está offline");
            
            return false;
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"  ❌ RESULTADO: Error inesperado");
            Console.ResetColor();
            Console.WriteLine($"     ├─ Tipo: {ex.GetType().Name}");
            Console.WriteLine($"     └─ Mensaje: {ex.Message}");
            return false;
        }
    }

    private string OcultarPassword(string connectionString)
    {
        if (connectionString == "No configurada")
            return connectionString;

        try
        {
            var builder = new SqlConnectionStringBuilder(connectionString);
            if (!string.IsNullOrEmpty(builder.Password))
                builder.Password = "***oculta***";
            return builder.ConnectionString;
        }
        catch
        {
            return connectionString.Replace("Password=", "Password=***");
        }
    }
}
