import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/robot_protocol.dart';
import '../../data/models/lado.dart';
import '../../data/repositories/fake_robot_command_port.dart';
import '../../data/repositories/robot_command_exception.dart';
import '../../data/repositories/robot_command_port.dart';
import 'auto_status.dart';

/// Estado da tela do modo AUTO (CommandPage) gerenciado por ChangeNotifier.
///
/// Recebe a jogada escolhida na tela (ex.: "JOGADA_22" + "ladoDir"), monta o
/// comando que o robô entende ("D22") e envia pelo [RobotCommandPort],
/// guardando o status de execução.
class AutoController extends ChangeNotifier {
  // TODO(kaynan): trocar o fake pelo BleRepository quando ele implementar
  // RobotCommandPort (escrita/notify na característica do robô).
  AutoController({RobotCommandPort? port})
      : _port = port ?? FakeRobotCommandPort();

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
      errorMessage = 'Jogada inválida: $jogadaKey';
      status = AutoStatus.error;
      notifyListeners();
      return;
    }
    await _send(RobotProtocol.jogada(_ladoFromSide(side), number));
  }

  /// Entra no modo rádio-controlado pelo lado indicado ('ladoDir'/'ladoEsc').
  Future<void> startRC(String side) =>
      _send(RobotProtocol.rc(_ladoFromSide(side)));

  Future<void> stop() async {
    await _send(RobotProtocol.parar);
    if (status != AutoStatus.error) status = AutoStatus.idle;
    notifyListeners();
  }

  // ── Internos ───────────────────────────────────────────────────────────
  Future<void> _send(String command) async {
    if (status == AutoStatus.sending) return;

    status = AutoStatus.sending;
    lastCommand = command;
    errorMessage = null;
    notifyListeners();

    try {
      await _port.send(command);
      status = AutoStatus.running;
    } on RobotCommandException catch (e) {
      errorMessage = e.message;
      status = AutoStatus.error;
    } catch (e) {
      errorMessage = 'Falha ao enviar: $e';
      status = AutoStatus.error;
    }
    notifyListeners();
  }

  /// "JOGADA_22" -> 22. Mesma regra que a CommandPage usa para ordenar.
  static int? _jogadaNumber(String key) {
    final match = RegExp(r'\d+').firstMatch(key);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  static Lado _ladoFromSide(String side) =>
      side == 'ladoEsc' ? Lado.esquerdo : Lado.direito;

  // ── Cleanup ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _responsesSub?.cancel();
    super.dispose();
  }
}
