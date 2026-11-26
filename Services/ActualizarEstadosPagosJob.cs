using ServicioCierreCasos.Models;

namespace ServicioCierreCasos.Services;

public interface IActualizarEstadosPagosJob
{
    Task<JobExecutionLog> EjecutarAsync();
}

public class ActualizarEstadosPagosJob : IActualizarEstadosPagosJob
{
    private readonly IPagoService _pagoService;
    private readonly IRecaudoService _recaudoService;
    private readonly IPagoRetransmitidoService _pagoRetransmitidoService;
    private readonly ILogger<ActualizarEstadosPagosJob> _logger;
    private const int CARACTERES_A_ELIMINAR = 7;
    private const int ESTADO_PAGADO = 2;
    private const int ESTADO_ACTUALIZADO = 4;

    public ActualizarEstadosPagosJob(
        IPagoService pagoService,
        IRecaudoService recaudoService,
        IPagoRetransmitidoService pagoRetransmitidoService,
        ILogger<ActualizarEstadosPagosJob> logger)
    {
        _pagoService = pagoService;
        _recaudoService = recaudoService;
        _pagoRetransmitidoService = pagoRetransmitidoService;
        _logger = logger;
    }

    public async Task<JobExecutionLog> EjecutarAsync()
    {
        var log = new JobExecutionLog
        {
            FechaInicio = DateTime.Now
        };

        _logger.LogInformation("");
        _logger.LogInformation("╔════════════════════════════════════════════════════════════════╗");
        _logger.LogInformation("║ INICIO DE EJECUCIÓN DEL JOB: ACTUALIZAR ESTADOS DE PAGOS        ║");
        _logger.LogInformation("╚════════════════════════════════════════════════════════════════╝");
        _logger.LogInformation("📅 Fecha y hora de inicio: {FechaInicio:dd/MM/yyyy HH:mm:ss.fff}", log.FechaInicio);
        _logger.LogInformation("");

        try
        {
            // PASO 1: Obtener pagos pendientes
            _logger.LogInformation("▼ PASO 1: Consultando pagos pendientes...");
            _logger.LogInformation("  Condición: idEstado <> 4");
            
            var pagosPendientes = await _pagoService.ObtenerPagosPendientesAsync();
            log.RegistrosConsultados = pagosPendientes.Count();

            _logger.LogInformation("📊 Cantidad de registros consultados: {Cantidad}", log.RegistrosConsultados);
            _logger.LogInformation("");

            if (log.RegistrosConsultados == 0)
            {
                _logger.LogInformation("ℹ️  No hay pagos pendientes para procesar.");
                return FinalizeLog(log);
            }

            _logger.LogInformation("▼ PASO 2-5: Procesando pagos...");
            _logger.LogInformation("");

            // PASO 2-5: Procesar cada pago
            int pagoActual = 0;
            foreach (var pago in pagosPendientes)
            {
                pagoActual++;
                _logger.LogInformation("[{Actual}/{Total}] Procesando pago ID: {IdPago}", pagoActual, log.RegistrosConsultados, pago.Id);

                try
                {
                    // PASO 2: Obtener identificador de búsqueda
                    _logger.LogDebug("  ├─ PASO 2: Extrayendo ID de recaudo");
                    _logger.LogDebug("    ├─ Referencia Original: {Referencia}", pago.ReferenciaPago);
                    
                    string idRecaudoStr = ExtraerIdRecaudo(pago.ReferenciaPago);
                    
                    _logger.LogDebug("    └─ ID Extraído: {IdExtraido}", idRecaudoStr);

                    if (string.IsNullOrEmpty(idRecaudoStr))
                    {
                        string error = $"No se pudo extraer ID de recaudo de referencia '{pago.ReferenciaPago}' (ID pago: {pago.Id})";
                        _logger.LogWarning("  ├─ ⚠️  {Error}", error);
                        log.Errores.Add(error);
                        log.RegistrosSinCoincidencia++;
                        _logger.LogInformation("  └─ RESULTADO: Sin Coincidencia");
                        _logger.LogInformation("");
                        continue;
                    }

                    if (!int.TryParse(idRecaudoStr, out int idRecaudo))
                    {
                        string error = $"ID de recaudo inválido: '{idRecaudoStr}' (ID pago: {pago.Id})";
                        _logger.LogWarning("  ├─ ⚠️  {Error}", error);
                        log.Errores.Add(error);
                        log.RegistrosSinCoincidencia++;
                        _logger.LogInformation("  └─ RESULTADO: Sin Coincidencia");
                        _logger.LogInformation("");
                        continue;
                    }

                    // PASO 3: Buscar recaudo en Apostilla
                    _logger.LogDebug("  ├─ PASO 3: Buscando recaudo en Apostilla");
                    var recaudo = await _recaudoService.ObtenerRecaudoAsync(idRecaudo);

                    if (recaudo == null)
                    {
                        string error = $"No se encontró recaudo con ID {idRecaudo} en Apostilla (referencia: {pago.ReferenciaPago}, ID pago: {pago.Id})";
                        _logger.LogWarning("  ├─ ⚠️  {Error}", error);
                        log.Errores.Add(error);
                        log.RegistrosSinCoincidencia++;
                        _logger.LogInformation("  └─ RESULTADO: Sin Coincidencia");
                        _logger.LogInformation("");
                        continue;
                    }

                    // PASO 4: Validar estado del recaudo
                    _logger.LogDebug("  ├─ PASO 4: Validando estado del recaudo");
                    _logger.LogDebug("    └─ Estado Recaudo: {Estado}", recaudo.CodEstadoRecaudo);

                    if (recaudo.CodEstadoRecaudo == ESTADO_PAGADO)
                    {
                        // FLUJO ACTUAL: codEstadoRecaudo = 2 → Cierre de registro
                        _logger.LogDebug("  ├─ ℹ️  Estado es PAGADO (2)");
                        
                        // PASO 5: Actualizar estado del pago
                        _logger.LogDebug("  ├─ PASO 5: Actualizando estado del pago");
                        bool actualizado = await _pagoService.ActualizarEstadoPagoAsync(pago.Id);

                        if (actualizado)
                        {
                            log.RegistrosActualizados++;
                            _logger.LogInformation("  ├─ ✅ Pago actualizado exitosamente");
                            _logger.LogInformation("  │  ├─ ID Pago: {IdPago}", pago.Id);
                            _logger.LogInformation("  │  ├─ Referencia: {Referencia}", pago.ReferenciaPago);
                            _logger.LogInformation("  │  ├─ ID Recaudo: {IdRecaudo}", idRecaudo);
                            _logger.LogInformation("  │  └─ Nuevo Estado: {NuevoEstado}", ESTADO_ACTUALIZADO);
                            _logger.LogInformation("  └─ RESULTADO: Actualizado");
                        }
                        else
                        {
                            string error = $"No se pudo actualizar el pago con ID {pago.Id} (ID recaudo: {idRecaudo})";
                            _logger.LogWarning("  ├─ ⚠️  {Error}", error);
                            log.Errores.Add(error);
                            _logger.LogInformation("  └─ RESULTADO: No Actualizado");
                        }
                    }
                    else
                    {
                        // NUEVO FLUJO: codEstadoRecaudo ≠ 2 → Actualizar PagosRetransmitidos
                        _logger.LogDebug("  ├─ ℹ️  Estado NO es PAGADO. Ejecutando flujo alterno");
                        await ProcesarFlujoAlternoAsync(pago, log);
                    }
                }
                catch (Exception ex)
                {
                    string error = $"Error procesando pago con ID {pago.Id}: {ex.Message}";
                    _logger.LogError("  ├─ ❌ {Error}", error);
                    _logger.LogError("  └─ RESULTADO: Error");
                    _logger.LogError(ex, "     Stack Trace: {StackTrace}", ex.StackTrace);
                    log.Errores.Add(error);
                }

                _logger.LogInformation("");
            }

            return FinalizeLog(log);
        }
        catch (Exception ex)
        {
            _logger.LogError("❌ Error crítico durante la ejecución del job");
            _logger.LogError(ex, "Excepción: {Excepcion}", ex.Message);
            log.Errores.Add($"Error crítico: {ex.Message}");
            return FinalizeLog(log);
        }
    }

    private async Task ProcesarFlujoAlternoAsync(PagoNotificacion pago, JobExecutionLog log)
    {
        try
        {
            _logger.LogDebug("    ├─ FLUJO ALTERNO: Iniciando procesamiento");
            _logger.LogDebug("    ├─ Referencia Pago: {Referencia}", pago.ReferenciaPago);
            
            // Buscar en PagosRetransmitidos usando referencia completa
            var pagoRetransmitido = await _pagoRetransmitidoService.ObtenerPorReferenciaAsync(pago.ReferenciaPago);

            if (pagoRetransmitido != null)
            {
                _logger.LogDebug("    ├─ ✅ Registro encontrado en PagosRetransmitidos");
                
                // Actualizar fechaRetransmision a NULL
                bool actualizado = await _pagoRetransmitidoService.ActualizarFechaRetransmisionANullAsync(pago.ReferenciaPago);

                if (actualizado)
                {
                    log.RegistrosActualizados++;
                    _logger.LogInformation("    ├─ ✅ Registro de retransmisión actualizado exitosamente");
                    _logger.LogInformation("    │  ├─ ID Registro: {IdRegistro}", pagoRetransmitido.Id);
                    _logger.LogInformation("    │  ├─ Referencia: {Referencia}", pago.ReferenciaPago);
                    _logger.LogInformation("    │  └─ FechaRetransmision: NULL");
                    _logger.LogInformation("    └─ RESULTADO: Actualizado (Flujo Alterno)");
                }
                else
                {
                    string error = $"No se pudo actualizar el registro de retransmisión con referencia '{pago.ReferenciaPago}' (ID pago: {pago.Id})";
                    _logger.LogWarning("    ├─ ⚠️  {Error}", error);
                    log.Errores.Add(error);
                    _logger.LogInformation("    └─ RESULTADO: No Actualizado (Flujo Alterno)");
                }
            }
            else
            {
                _logger.LogDebug("    ├─ ℹ️  No existe registro en PagosRetransmitidos");
                _logger.LogInformation("    └─ RESULTADO: Sin Coincidencia (Flujo Alterno)");
            }
        }
        catch (Exception ex)
        {
            string error = $"Error en flujo alterno para pago con ID {pago.Id}: {ex.Message}";
            _logger.LogError("    ├─ ❌ {Error}", error);
            _logger.LogError("    └─ RESULTADO: Error (Flujo Alterno)");
            _logger.LogError(ex, "       Stack Trace: {StackTrace}", ex.StackTrace);
            log.Errores.Add(error);
        }
    }

    private string ExtraerIdRecaudo(string referenciaPago)
    {
        if (string.IsNullOrEmpty(referenciaPago) || referenciaPago.Length <= CARACTERES_A_ELIMINAR)
            return string.Empty;

        return referenciaPago.Substring(CARACTERES_A_ELIMINAR);
    }

    private JobExecutionLog FinalizeLog(JobExecutionLog log)
    {
        log.FechaFinalizacion = DateTime.Now;

        _logger.LogInformation("");
        _logger.LogInformation("╔════════════════════════════════════════════════════════════════╗");
        _logger.LogInformation("║ RESUMEN DE EJECUCIÓN                                           ║");
        _logger.LogInformation("╚════════════════════════════════════════════════════════════════╝");
        _logger.LogInformation("");

        _logger.LogInformation("📊 Estadísticas Finales:");
        _logger.LogInformation("  ├─ Registros Consultados: {Consultados}", log.RegistrosConsultados);
        _logger.LogInformation("  ├─ Registros Actualizados: {Actualizados}", log.RegistrosActualizados);
        _logger.LogInformation("  ├─ Registros Sin Coincidencia: {SinCoincidencia}", log.RegistrosSinCoincidencia);
        _logger.LogInformation("  └─ Errores Presentados: {Errores}", log.Errores.Count);

        _logger.LogInformation("");
        _logger.LogInformation("⏱️  Tiempos:");
        _logger.LogInformation("  ├─ Fecha Inicio: {Inicio:dd/MM/yyyy HH:mm:ss.fff}", log.FechaInicio);
        _logger.LogInformation("  ├─ Fecha Finalización: {Finalizacion:dd/MM/yyyy HH:mm:ss.fff}", log.FechaFinalizacion);
        _logger.LogInformation("  └─ Duración Total: {Duracion}", log.GetDuration());

        if (log.Errores.Count > 0)
        {
            _logger.LogInformation("");
            _logger.LogWarning("⚠️  Detalles de Errores ({ErroresCount}):", log.Errores.Count);
            for (int i = 0; i < log.Errores.Count; i++)
            {
                _logger.LogWarning("  {Numero}. {Error}", i + 1, log.Errores[i]);
            }
        }
        else
        {
            _logger.LogInformation("");
            _logger.LogInformation("✅ No se encontraron errores durante la ejecución.");
        }

        _logger.LogInformation("");
        _logger.LogInformation("╔════════════════════════════════════════════════════════════════╗");
        _logger.LogInformation("║ FIN DE EJECUCIÓN                                               ║");
        _logger.LogInformation("╚════════════════════════════════════════════════════════════════╝");
        _logger.LogInformation("");

        return log;
    }
}
