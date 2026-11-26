using System.Data;
using System.Data.SqlClient;
using Dapper;
using ServicioCierreCasos.Models;

namespace ServicioCierreCasos.Services;

public interface IPagoRetransmitidoService
{
    Task<PagoRetransmitido?> ObtenerPorReferenciaAsync(string referencia);
    Task<bool> ActualizarFechaRetransmisionANullAsync(string referencia);
}

public class PagoRetransmitidoService : IPagoRetransmitidoService
{
    private readonly string _connectionString;
    private readonly ILogger<PagoRetransmitidoService> _logger;

    public PagoRetransmitidoService(IConfiguration configuration, ILogger<PagoRetransmitidoService> logger)
    {
        _connectionString = configuration.GetConnectionString("ApostillaDb") 
            ?? throw new InvalidOperationException("La cadena de conexión 'ApostillaDb' no está configurada.");
        _logger = logger;
    }

    public async Task<PagoRetransmitido?> ObtenerPorReferenciaAsync(string referencia)
    {
        try
        {
            _logger.LogDebug("    ↳ Buscando registro en PagosRetransmitidos con referencia '{Referencia}'", referencia);

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                const string sql = @"
                    SELECT 
                        id,
                        referencia,
                        fechaRetransmision
                    FROM [Pagos].[tarjetaCredito].[PagosRetransmitidos]
                    WHERE referencia = @Referencia";

                var pagoRetransmitido = await connection.QueryFirstOrDefaultAsync<PagoRetransmitido>(sql, 
                    new { Referencia = referencia });
                
                if (pagoRetransmitido != null)
                {
                    _logger.LogDebug("      ✅ Registro encontrado en PagosRetransmitidos. ID: {Id}", pagoRetransmitido.Id);
                }
                else
                {
                    _logger.LogDebug("      ⚠️  No se encontró registro en PagosRetransmitidos");
                }

                return pagoRetransmitido;
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "      ❌ Error de SQL al consultar PagosRetransmitidos con referencia '{Referencia}'", referencia);
            _logger.LogError("         Número de Error SQL: {SqlErrorNumber}", ex.Number);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "      ❌ Error inesperado al consultar PagosRetransmitidos con referencia '{Referencia}'", referencia);
            throw;
        }
    }

    public async Task<bool> ActualizarFechaRetransmisionANullAsync(string referencia)
    {
        try
        {
            _logger.LogDebug("    ↳ Actualizando fechaRetransmision a NULL para referencia '{Referencia}'", referencia);

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                const string sql = @"
                    UPDATE [Pagos].[tarjetaCredito].[PagosRetransmitidos]
                    SET fechaRetransmision = NULL
                    WHERE referencia = @Referencia";

                var result = await connection.ExecuteAsync(sql, new { Referencia = referencia });
                
                if (result > 0)
                {
                    _logger.LogDebug("      ✅ Registro actualizado exitosamente. Filas afectadas: {FilasAfectadas}", result);
                    return true;
                }
                else
                {
                    _logger.LogWarning("      ⚠️  No se encontró registro para actualizar con referencia '{Referencia}'", referencia);
                    return false;
                }
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "      ❌ Error de SQL al actualizar PagosRetransmitidos con referencia '{Referencia}'", referencia);
            _logger.LogError("         Número de Error SQL: {SqlErrorNumber}", ex.Number);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "      ❌ Error inesperado al actualizar PagosRetransmitidos con referencia '{Referencia}'", referencia);
            throw;
        }
    }
}
