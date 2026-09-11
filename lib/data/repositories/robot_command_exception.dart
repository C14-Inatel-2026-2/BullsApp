/// Erro do canal de comandos com o robô (sem conexão, escrita falhou, etc.).
///
/// A implementação deve lançar isto — e não a exception crua da lib BLE —
/// para os controllers mostrarem uma mensagem amigável sem conhecer o
/// flutter_blue_plus.
class RobotCommandException implements Exception {
  final String message;
  const RobotCommandException(this.message);

  @override
  String toString() => 'RobotCommandException: $message';
}
