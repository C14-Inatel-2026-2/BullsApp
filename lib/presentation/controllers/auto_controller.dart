import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/robot_protocol.dart';
import '../../data/models/lado.dart';
import '../../data/repositories/robot_command_exception.dart';
import '../../data/repositories/robot_command_port.dart';
import 'auto_status.dart';

class AutoController extends ChangeNotifier {
  AutoController({required RobotCommandPort port}) : _port = port;

  final RobotCommandPort _port;

  AutoStatus status = AutoStatus.idle;
  String? lastCommand;
  String? lastResponse;
  String? errorMessage;

  StreamSubscription<String>? _responsesSub;

  void init() {
    _responsesSub = _port.responses.listen((line) {
      lastResponse = line;
      notifyListeners();
    });
  }

  /// [teste] envia a jogada em modo teste ("TD08").
  Future<void> sendJogada(
    String jogadaKey,
    String side,
    List<String> actions, {
    bool teste = false,
  }) async {
    final number = _jogadaNumber(jogadaKey);
    if (number == null) {
      _fail('Jogada inválida: $jogadaKey');
      return;
    }
    final lado = Lado.fromSide(side);
    if (lado == null) {
      _fail('Lado inválido: $side');
      return;
    }
    await _send(RobotProtocol.jogada(lado, number, teste: teste));
  }

  Future<void> startRC(String side) async {
    final lado = Lado.fromSide(side);
    if (lado == null) {
      _fail('Lado inválido: $side');
      return;
    }
    await _send(RobotProtocol.rc(lado));
  }

  /// Para o robô. Nunca é descartado, mesmo com outro envio em andamento.
  Future<void> stop() async {
    await _send(RobotProtocol.parar, force: true);
    if (status != AutoStatus.error) status = AutoStatus.idle;
    notifyListeners();
  }

  /// Conta os envios para que a resposta de um envio antigo (ex.: a jogada
  /// que estava indo quando o STOP passou na frente) não sobrescreva o
  /// status do mais recente.
  int _sendSeq = 0;

  Future<void> _send(String command, {bool force = false}) async {
    if (status == AutoStatus.sending && !force) return;

    final seq = ++_sendSeq;
    status = AutoStatus.sending;
    lastCommand = command;
    lastResponse = null; // a resposta exibida é sempre a deste envio
    errorMessage = null;
    notifyListeners();

    AutoStatus result;
    String? error;
    try {
      await _port.send(command);
      result = AutoStatus.running;
    } on RobotCommandException catch (e) {
      error = e.message;
      result = AutoStatus.error;
    } catch (e) {
      error = 'Falha ao enviar: $e';
      result = AutoStatus.error;
    }
    if (seq != _sendSeq) return; // um envio mais novo já assumiu o status
    status = result;
    errorMessage = error;
    notifyListeners();
  }

  static int? _jogadaNumber(String key) {
    final match = RegExp(r'\d+').firstMatch(key);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  void _fail(String message) {
    errorMessage = message;
    status = AutoStatus.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _responsesSub?.cancel();
    super.dispose();
  }
}
