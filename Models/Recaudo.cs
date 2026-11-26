namespace ServicioCierreCasos.Models;

public class Recaudo
{
    public int IdRecaudo { get; set; }
    public int CodEstadoRecaudo { get; set; }
}

public class PagoRetransmitido
{
    public int Id { get; set; }
    public string Referencia { get; set; } = string.Empty;
    public DateTime? FechaRetransmision { get; set; }
}
