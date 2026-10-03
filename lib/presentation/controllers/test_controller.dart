import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/robot_protocol.dart';
import '../../data/models/sensor_status.dart';
import '../../data/repositories/robot_command_exception.dart';
import '../../data/repositories/robot_command_port.dart';

/// Estado das telas de teste (terminal, sensores, motores, PID)
/// gerenciado por ChangeNotifier (Provider).
///
/// Envia comandos de teste individuais pelo [RobotCommandPort] e acumula as
/// respostas: em texto cru em [log] (terminal) e já interpretadas em
/// [sensores] (tela de sensores).
class TestController extends ChangeNotifier {
  TestController({required RobotCommandPort port}) : _port = port;

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
  /// Ignorado se vazio ou se já houver um envio em andamento.
  Future<void> sendCommand(String command) => _sendCommand(command);

  Future<void> _sendCommand(String command, {bool force = false}) async {
    final text = command.trim();
    if (text.isEmpty || (isBusy && !force)) return;

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

  /// Nunca é descartado, mesmo com outro envio em andamento.
  Future<void> stopMotors() => _sendCommand(RobotProtocol.parar, force: true);

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
