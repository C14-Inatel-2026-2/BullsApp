import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/robot_protocol.dart';
import '../../data/models/sensor_status.dart';
import '../../data/repositories/robot_command_exception.dart';
import '../../data/repositories/robot_command_port.dart';

class TestController extends ChangeNotifier {
  TestController({required RobotCommandPort port}) : _port = port;

  final RobotCommandPort _port;

  final List<String> log = ['Terminal iniciado...', 'Aguardando entrada...'];

  final Map<String, SensorStatus> sensores = {};

  bool isBusy = false;
  String? errorMessage;

  int _pendingSends = 0;

  StreamSubscription<String>? _responsesSub;

  void init() {
    _responsesSub = _port.responses.listen(_onResponse);
  }

  /// Ignorado se vazio ou se já houver um envio em andamento.
  Future<void> sendCommand(String command) => _sendCommand(command);

  Future<void> _sendCommand(String command, {bool force = false}) async {
    final text = command.trim();
    if (text.isEmpty || (isBusy && !force)) return;

    _pendingSends++;
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
      _pendingSends--;
      isBusy = _pendingSends > 0;
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
  }) => sendCommand(RobotProtocol.pid(kp, ki, kd));

  void clearLog() {
    log.clear();
    notifyListeners();
  }

  void _onResponse(String line) {
    log.add('< $line');

    final match = RobotProtocol.respostaSensor.firstMatch(line.trim());
    if (match != null) {
      sensores[match.group(1)!.toUpperCase()] = SensorStatus.fromResposta(
        match.group(2)!,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _responsesSub?.cancel();
    super.dispose();
  }
}
