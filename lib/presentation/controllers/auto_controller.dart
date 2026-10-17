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

  /// Parar é prioritário: passa na frente de um envio em andamento, porque
  /// é o comando que o piloto usa quando algo deu errado.
  Future<void> stop() async {
    await _send(RobotProtocol.parar, force: true);
    if (status != AutoStatus.error) status = AutoStatus.idle;
    notifyListeners();
  }

  // ── Internos ───────────────────────────────────────────────────────────
  /// [force] ignora a trava de reentrância. Use só para comandos que não
  /// podem ser descartados (parar); sem ele, dois toques no mesmo botão
  /// enviariam o comando duas vezes.
  Future<void> _send(String command, {bool force = false}) async {
    if (!force && status == AutoStatus.sending) return;

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
