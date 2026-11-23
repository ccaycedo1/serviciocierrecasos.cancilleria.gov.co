using ServicioCierreCasos.Services;

namespace ServicioCierreCasos;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly IServiceProvider _serviceProvider;
    private readonly TimeSpan _intervaloEjecucion = TimeSpan.FromMinutes(5);

    public Worker(ILogger<Worker> logger, IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Servicio de Actualización de Estados de Pagos iniciado");
        _logger.LogInformation("El job se ejecutará automáticamente cada {Minutos} minuto(s)", _intervaloEjecucion.TotalMinutes);

        try
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var job = scope.ServiceProvider.GetRequiredService<IActualizarEstadosPagosJob>();
                        await job.EjecutarAsync();
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error en la ejecución del job. Se reintentará en la próxima iteración");
                }

                // Esperar el intervalo de ejecución
                await Task.Delay(_intervaloEjecucion, stoppingToken);
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Servicio de Actualización de Estados de Pagos detenido");
        }
    }
}
