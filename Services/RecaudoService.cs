using System.Data;
using System.Data.SqlClient;
using Dapper;
using ServicioCierreCasos.Models;

namespace ServicioCierreCasos.Services;

public interface IRecaudoService
{
    Task<Recaudo?> ObtenerRecaudoAsync(int idRecaudo);
}

public class RecaudoService : IRecaudoService
{
    private readonly string _connectionString;
    private readonly ILogger<RecaudoService> _logger;

    public RecaudoService(IConfiguration configuration, ILogger<RecaudoService> logger)
    {
        _connectionString = configuration.GetConnectionString("ApostillaRecaudoDb") 
            ?? throw new InvalidOperationException("La cadena de conexión 'ApostillaRecaudoDb' no está configurada.");
        _logger = logger;
    }

    public async Task<Recaudo?> ObtenerRecaudoAsync(int idRecaudo)
    {
        try
        {
            _logger.LogDebug("    ↳ Buscando recaudo ID {IdRecaudo} en Apostilla...", idRecaudo);

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                const string sql = @"
                    SELECT 
                        idRecaudo,
                        codEstadoRecaudo
                    FROM [Apostilla].[dbo].[tbRecaudo]
                    WHERE idRecaudo = @IdRecaudo";

                var recaudo = await connection.QueryFirstOrDefaultAsync<Recaudo>(sql, new { IdRecaudo = idRecaudo });
                
                if (recaudo != null)
                {
                    _logger.LogDebug("      ✅ Recaudo encontrado. Estado: {Estado}", recaudo.CodEstadoRecaudo);
                }
                else
                {
                    _logger.LogDebug("      ⚠️  Recaudo no encontrado en Apostilla");
                }

                return recaudo;
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "      ❌ Error de SQL al consultar recaudo ID {IdRecaudo}", idRecaudo);
            _logger.LogError("         Número de Error SQL: {SqlErrorNumber}", ex.Number);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "      ❌ Error inesperado al consultar recaudo ID {IdRecaudo}", idRecaudo);
            throw;
        }
    }
}
