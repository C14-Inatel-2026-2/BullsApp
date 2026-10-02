import 'dart:async';

import '../../core/constants/robot_protocol.dart';
import 'robot_command_port.dart';

/// Implementação em memória do [RobotCommandPort], sem Bluetooth.
///
/// Serve para rodar o terminal e as telas de teste no emulador enquanto o
/// `BleRepository` não implementa o canal de comandos. Nos testes unitários
/// dos controllers, prefira um mock (mocktail) — aí cada teste decide o que
/// o robô responde.
class FakeRobotCommandPort implements RobotCommandPort {
  /// Quanto tempo o fake "demora" para responder. Zero nos testes.
  final Duration latency;

  final _responses = StreamController<String>.broadcast();
  final List<String> enviados = [];

  FakeRobotCommandPort({this.latency = const Duration(milliseconds: 300)});

  @override
  Stream<String> get responses => _responses.stream;

  @override
  Future<void> send(String command) async {
    enviados.add(command);
    await Future<void>.delayed(latency);

    // Respostas inventadas só para as telas terem o que mostrar.
    if (command == RobotProtocol.testarSensores) {
      _responses.add('sensorD0 vendo');
      _responses.add('sensorD2 vendo');
      _responses.add('sensorE0 cego');
      _responses.add('sensorE2 vendo');
    } else {
      _responses.add('OK $command');
    }
  }

  Future<void> dispose() => _responses.close();
}
