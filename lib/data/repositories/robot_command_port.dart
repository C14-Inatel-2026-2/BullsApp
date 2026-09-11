import 'robot_command_exception.dart';

/// Canal de comandos com o robô, do jeito que os controllers precisam.
///
/// É uma interface pequena de propósito (Interface Segregation): o
/// `TestController` e o `AutoController` só precisam mandar uma string e
/// ler as respostas — não precisam saber de scan, permissões ou conexão.
///
/// Quem implementa em produção é o `BleRepository` (escrevendo na
/// característica BLE e assinando as notificações). Enquanto isso não
/// existe, o `main.dart` injeta `FakeRobotCommandPort`.
abstract interface class RobotCommandPort {
  /// Envia um comando cru (ex.: "D22", "E11"). Quem monta a string é o
  /// controller, via `RobotProtocol`; o canal só transporta.
  /// Lança [RobotCommandException] se não houver robô conectado.
  Future<void> send(String command);

  /// Linhas de resposta do robô (ex.: "sensorD2 vendo"), uma por evento.
  Stream<String> get responses;
}
