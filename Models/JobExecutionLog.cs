namespace ServicioCierreCasos.Models;

public class JobExecutionLog
{
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFinalizacion { get; set; }
    public int RegistrosConsultados { get; set; }
    public int RegistrosActualizados { get; set; }
    public int RegistrosSinCoincidencia { get; set; }
    public List<string> Errores { get; set; } = new();

    public TimeSpan GetDuration()
    {
        if (FechaFinalizacion.HasValue)
            return FechaFinalizacion.Value - FechaInicio;
        return TimeSpan.Zero;
    }
}
