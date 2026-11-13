enum SensorStatus {
  vendo,
  cego,

  semSinal;

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
