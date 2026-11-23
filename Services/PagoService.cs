using System.Data;
using System.Data.SqlClient;
using Dapper;
using ServicioCierreCasos.Models;

namespace ServicioCierreCasos.Services;

public interface IPagoService
{
    Task<IEnumerable<PagoNotificacion>> ObtenerPagosPendientesAsync();
    Task<bool> ActualizarEstadoPagoAsync(int idPago);
}

public class PagoService : IPagoService
{
    private readonly string _connectionString;
    private readonly ILogger<PagoService> _logger;

    public PagoService(IConfiguration configuration, ILogger<PagoService> logger)
    {
        _connectionString = configuration.GetConnectionString("ApostillaDb") 
            ?? throw new InvalidOperationException("La cadena de conexión 'ApostillaDb' no está configurada.");
        _logger = logger;
    }

    public async Task<IEnumerable<PagoNotificacion>> ObtenerPagosPendientesAsync()
    {
        try
        {
            _logger.LogDebug("🔍 Iniciando consulta de pagos pendientes...");
            
            using (var connection = new SqlConnection(_connectionString))
            {
                _logger.LogDebug("  ↳ Abriendo conexión a SQL Server...");
                await connection.OpenAsync();
                _logger.LogDebug("  ✅ Conexión establecida correctamente");

                const string sql = @"
                    SELECT 
                        id,
                        referenciaPago,
                        idEstado,
                        fechaModificacion
                    FROM [Pagos].[pse].[AppPagosPagoNotificacion]
                    WHERE idEstado <> 4";

                _logger.LogDebug("  ↳ Ejecutando query SQL...");
                var pagos = await connection.QueryAsync<PagoNotificacion>(sql);
                _logger.LogInformation("✅ Consulta de pagos pendientes completada. Total encontrado: {Total}", pagos.Count());
                
                if (pagos.Count() == 0)
                {
                    _logger.LogInformation("ℹ️  No hay pagos pendientes para procesar");
                }

                return pagos;
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "❌ Error de SQL al consultar pagos pendientes");
            _logger.LogError("   Número de Error SQL: {SqlErrorNumber}", ex.Number);
            _logger.LogError("   Mensaje: {SqlMessage}", ex.Message);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ Error inesperado al consultar pagos pendientes");
            throw;
        }
    }

    public async Task<bool> ActualizarEstadoPagoAsync(int idPago)
    {
        try
        {
            _logger.LogDebug("  ↳ Actualizando estado del pago ID: {IdPago}", idPago);

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                const string sql = @"
                    UPDATE [Pagos].[pse].[AppPagosPagoNotificacion]
                    SET idEstado = 4,
                        fechaModificacion = GETDATE()
                    WHERE id = @IdPago";

                var result = await connection.ExecuteAsync(sql, new { IdPago = idPago });
                
                if (result > 0)
                {
                    _logger.LogDebug("    ✅ Pago actualizado exitosamente");
                    return true;
                }
                else
                {
                    _logger.LogWarning("    ⚠️  No se encontró el pago con ID {IdPago}", idPago);
                    return false;
                }
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "    ❌ Error de SQL al actualizar el pago ID {IdPago}", idPago);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "    ❌ Error inesperado al actualizar el pago ID {IdPago}", idPago);
            throw;
        }
    }
}
