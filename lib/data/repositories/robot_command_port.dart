import 'robot_command_exception.dart';

/// Canal de comandos com o robô, do jeito que os controllers precisam.
///
/// É uma interface pequena de propósito (Interface Segregation): o
/// `TestController` e o `AutoController` só precisam mandar uma string e
/// ler as respostas — não precisam saber de scan, permissões ou conexão.
///
/// Em produção quem implementa é o `BleRepository` (escreve na
/// característica BLE do robô e lê as notificações). Com
/// `--dart-define=FAKE_ROBOT=true` o `main.dart` injeta o
/// `FakeRobotCommandPort`, e os testes usam mocks.
abstract interface class RobotCommandPort {
  /// Envia um comando cru (ex.: "D22", "E11"). Quem monta a string é o
  /// controller, via `RobotProtocol`; o canal só transporta.
  /// Lança [RobotCommandException] se não houver robô conectado.
  Future<void> send(String command);

  /// Linhas de resposta do robô (ex.: "sensorD2 vendo"), uma por evento.
  Stream<String> get responses;
}
