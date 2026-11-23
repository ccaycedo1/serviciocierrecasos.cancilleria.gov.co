namespace ServicioCierreCasos.Models;

public class PagoNotificacion
{
    public int Id { get; set; }
    public string ReferenciaPago { get; set; } = string.Empty;
    public int IdEstado { get; set; }
    public DateTime FechaModificacion { get; set; }
}
