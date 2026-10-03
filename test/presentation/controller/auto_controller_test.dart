import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/controllers/auto_controller.dart';
import 'package:bullsapp/presentation/controllers/auto_status.dart';

class MockRobotCommandPort extends Mock implements RobotCommandPort {}

void main() {
  test('sendJogada monta D22 para JOGADA_22 do lado direito', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.sendJogada('JOGADA_22', 'ladoDir', []);

    verify(() => port.send('D22')).called(1);
    expect(controller.status, AutoStatus.running);
  });

  test('sendJogada monta E22 para JOGADA_22 do lado esquerdo', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.sendJogada('JOGADA_22', 'ladoEsc', []);

    verify(() => port.send('E22')).called(1);
    expect(controller.status, AutoStatus.running);
  });

  test('sendJogada rejeita lado desconhecido sem enviar comando', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.sendJogada('JOGADA_22', 'ladoEsq', []);

    expect(controller.status, AutoStatus.error);
    expect(controller.errorMessage, isNotNull);
    verifyNever(() => port.send(any()));
  });

  test('STOP é enviado mesmo com uma jogada ainda sendo enviada', () async {
    final port = MockRobotCommandPort();
    final jogadaEnviada = Completer<void>();
    when(() => port.send('D22')).thenAnswer((_) => jogadaEnviada.future);
    when(() => port.send('STOP')).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    final jogada = controller.sendJogada('JOGADA_22', 'ladoDir', []);
    expect(controller.status, AutoStatus.sending);

    await controller.stop();
    verify(() => port.send('STOP')).called(1);
    expect(controller.status, AutoStatus.idle);

    // A jogada antiga terminando depois não pode "religar" o status.
    jogadaEnviada.complete();
    await jogada;
    expect(controller.status, AutoStatus.idle);
  });
}
