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

  test('sendJogada rejeita lado vazio sem enviar comando', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.sendJogada('JOGADA_22', '', []);

    expect(controller.status, AutoStatus.error);
    expect(controller.errorMessage, isNotNull);
    verifyNever(() => port.send(any()));
  });

  test('sendJogada rejeita jogada sem número', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.sendJogada('JOGADA_X', 'ladoDir', []);

    expect(controller.status, AutoStatus.error);
    expect(controller.errorMessage, isNotNull);
    verifyNever(() => port.send(any()));
  });

  test('startRC envia DRC para o lado direito', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();
    
    await controller.startRC('ladoDir');

    verify(() => port.send('DRC')).called(1);
    expect(controller.status, AutoStatus.running);
  });

  test('startRC envia ERC para o lado esquerdo', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.startRC('ladoEsc');

    verify(() => port.send('ERC')).called(1);
    expect(controller.status, AutoStatus.running);
  });

  test('startRC não envia nada para lado invalido', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.startRC('xpto');

    expect(controller.status, AutoStatus.error);
    expect(controller.errorMessage, isNotNull);
    verifyNever(() => port.send(any()));
  });

  test('stop envia STOP e volta para idle', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.stop();

    verify(() => port.send('STOP')).called(1);
    expect(controller.status, AutoStatus.idle);
  });
}
