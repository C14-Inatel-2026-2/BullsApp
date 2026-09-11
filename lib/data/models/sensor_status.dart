/// Estado de um sensor do robô, como reportado pelo firmware.
enum SensorStatus {
  vendo,
  cego,

  /// O robô ainda não respondeu sobre esse sensor (ou parou de responder).
  semSinal;

  /// Converte o texto que vem do robô ("vendo", "cego") no enum.
  /// Qualquer outra coisa vira [semSinal].
  static SensorStatus fromResposta(String texto) {
    switch (texto.trim().toLowerCase()) {
      case 'vendo':
        return SensorStatus.vendo;
      case 'cego':
        return SensorStatus.cego;
      default:
        return SensorStatus.semSinal;
    }
  }
}
