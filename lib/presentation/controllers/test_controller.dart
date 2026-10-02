import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/robot_protocol.dart';
import '../../data/models/sensor_status.dart';
import '../../data/repositories/fake_robot_command_port.dart';
import '../../data/repositories/robot_command_exception.dart';
import '../../data/repositories/robot_command_port.dart';

/// Estado das telas de teste (terminal, sensores, motores, PID)
/// gerenciado por ChangeNotifier (Provider).
///
/// Envia comandos de teste individuais pelo [RobotCommandPort] e acumula as
/// respostas: em texto cru em [log] (terminal) e já interpretadas em
/// [sensores] (tela de sensores).
class TestController extends ChangeNotifier {
  // TODO(kaynan): trocar o fake pelo BleRepository quando ele implementar
  // RobotCommandPort (escrita/notify na característica do robô).
  TestController({RobotCommandPort? port})
      : _port = port ?? FakeRobotCommandPort();

  final RobotCommandPort _port;

  // ── Estado público ─────────────────────────────────────────────────────
  /// Linhas do terminal. `> ` = enviado pelo app, `< ` = resposta do robô,
  /// `! ` = erro local.
  final List<String> log = ['Terminal iniciado...', 'Aguardando entrada...'];

  /// Último estado conhecido de cada sensor, indexado pelo id ("D2", "E0").
  final Map<String, SensorStatus> sensores = {};

  bool isBusy = false;
  String? errorMessage;

  StreamSubscription<String>? _responsesSub;

  // ── Inicialização ──────────────────────────────────────────────────────
  void init() {
    _responsesSub = _port.responses.listen(_onResponse);
  }

  // ── Ações ──────────────────────────────────────────────────────────────
  /// Envia um comando cru digitado pelo usuário (terminal).
  Future<void> sendCommand(String command) async {
    final text = command.trim();
    if (text.isEmpty || isBusy) return;

    isBusy = true;
    errorMessage = null;
    log.add('> $text');
    notifyListeners();

    try {
      await _port.send(text);
    } on RobotCommandException catch (e) {
      errorMessage = e.message;
      log.add('! ${e.message}');
    } catch (e) {
      errorMessage = 'Falha ao enviar: $e';
      log.add('! $errorMessage');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> testSensors() => sendCommand(RobotProtocol.testarSensores);

  Future<void> testMotors({required int left, required int right}) =>
      sendCommand(RobotProtocol.testarMotores(left, right));

  Future<void> stopMotors() => sendCommand(RobotProtocol.parar);

  Future<void> savePid({
    required double kp,
    required double ki,
    required double kd,
  }) =>
      sendCommand(RobotProtocol.pid(kp, ki, kd));

  void clearLog() {
    log.clear();
    notifyListeners();
  }

  // ── Respostas ──────────────────────────────────────────────────────────
  void _onResponse(String line) {
    log.add('< $line');

    final match = RobotProtocol.respostaSensor.firstMatch(line.trim());
    if (match != null) {
      sensores[match.group(1)!.toUpperCase()] =
          SensorStatus.fromResposta(match.group(2)!);
    }
    notifyListeners();
  }

  // ── Cleanup ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _responsesSub?.cancel();
    super.dispose();
  }
}
