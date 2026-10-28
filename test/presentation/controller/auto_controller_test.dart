import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/presentation/controllers/auto_controller.dart';
import 'package:bullsapp/presentation/controllers/auto_status.dart';

import '../../mocks/mocks.dart';

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

  test('sendJogada rejeita jogada sem número sem enviar comando', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.sendJogada('JOGADA_X', 'ladoDir', []);

    expect(controller.status, AutoStatus.error);
    expect(controller.errorMessage, 'Jogada inválida: JOGADA_X');
    verifyNever(() => port.send(any()));
  });

  test('sendJogada em modo teste envia TD08 para JOGADA_8', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    await controller.sendJogada('JOGADA_8', 'ladoDir', [], teste: true);

    verify(() => port.send('TD08')).called(1);
    expect(controller.lastCommand, 'TD08');
  });

  test('sendJogada ignora um segundo envio enquanto o primeiro sai', () async {
    final port = MockRobotCommandPort();
    final primeiroEnvio = Completer<void>();
    when(() => port.send(any())).thenAnswer((_) => primeiroEnvio.future);
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = AutoController(port: port)..init();

    final envio = controller.sendJogada('JOGADA_22', 'ladoDir', []);
    await controller.sendJogada('JOGADA_11', 'ladoEsc', []);
    primeiroEnvio.complete();
    await envio;

    verify(() => port.send('D22')).called(1);
    verifyNever(() => port.send('E11'));
    expect(controller.lastCommand, 'D22');
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
}
