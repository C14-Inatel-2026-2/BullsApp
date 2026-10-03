import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/robot_protocol.dart';
import '../../data/models/lado.dart';
import '../../data/repositories/robot_command_exception.dart';
import '../../data/repositories/robot_command_port.dart';
import 'auto_status.dart';

/// Estado da tela do modo AUTO (CommandPage) gerenciado por ChangeNotifier.
///
/// Recebe a jogada escolhida na tela (ex.: "JOGADA_22" + "ladoDir"), monta o
/// comando que o robô entende ("D22") e envia pelo [RobotCommandPort],
/// guardando o status de execução.
class AutoController extends ChangeNotifier {
  AutoController({required RobotCommandPort port}) : _port = port;

  final RobotCommandPort _port;

  // ── Estado público ─────────────────────────────────────────────────────
  AutoStatus status = AutoStatus.idle;
  String? lastCommand;
  String? lastResponse;
  String? errorMessage;

  StreamSubscription<String>? _responsesSub;

  // ── Inicialização ──────────────────────────────────────────────────────
  void init() {
    _responsesSub = _port.responses.listen((line) {
      lastResponse = line;
      notifyListeners();
    });
  }

  // ── Ações ──────────────────────────────────────────────────────────────
  /// Callback para `CommandPage.onSendCommand`.
  /// [jogadaKey] vem no formato "JOGADA_22"; [side] é 'ladoDir' ou 'ladoEsc'.
  /// [actions] é a sequência simulada na tela — o robô já a conhece pelo
  /// número da jogada, então só o número viaja pelo BLE.
  Future<void> sendJogada(
    String jogadaKey,
    String side,
    List<String> actions,
  ) async {
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
    await _send(RobotProtocol.jogada(lado, number));
  }

  /// Entra no modo rádio-controlado pelo lado indicado ('ladoDir'/'ladoEsc').
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

  // ── Internos ───────────────────────────────────────────────────────────
  /// Conta os envios para que a resposta de um envio antigo (ex.: a jogada
  /// que estava indo quando o STOP passou na frente) não sobrescreva o
  /// status do mais recente.
  int _sendSeq = 0;

  Future<void> _send(String command, {bool force = false}) async {
    if (status == AutoStatus.sending && !force) return;

    final seq = ++_sendSeq;
    status = AutoStatus.sending;
    lastCommand = command;
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

  /// "JOGADA_22" -> 22. Mesma regra que a CommandPage usa para ordenar.
  static int? _jogadaNumber(String key) {
    final match = RegExp(r'\d+').firstMatch(key);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  /// Marca erro de validação: nada é enviado ao robô.
  void _fail(String message) {
    errorMessage = message;
    status = AutoStatus.error;
    notifyListeners();
  }

  // ── Cleanup ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _responsesSub?.cancel();
    super.dispose();
  }
}
