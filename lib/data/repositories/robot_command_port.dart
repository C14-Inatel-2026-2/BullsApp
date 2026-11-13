/// Em produção quem implementa é o `BleRepository` (escreve na
/// característica BLE do robô e lê as notificações). Com
/// `--dart-define=FAKE_ROBOT=true` o `main.dart` injeta o
/// `FakeRobotCommandPort`, e os testes usam mocks.
abstract interface class RobotCommandPort {
  Future<void> send(String command);

  Stream<String> get responses;

  /// Se há um robô conectado agora.
  bool get isConnected;

  /// Emite o novo valor de [isConnected] sempre que ele muda
  /// (conectou, desconectou ou a conexão caiu).
  Stream<bool> get connectionChanges;
}
