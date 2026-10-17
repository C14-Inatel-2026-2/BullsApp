import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/data/models/sensor_status.dart';
import 'package:bullsapp/data/repositories/robot_command_exception.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/controllers/test_controller.dart';

class MockRobotCommandPort extends Mock implements RobotCommandPort {}

void main() {
  test('sendCommand manda o comando SENSORES', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.sendCommand('SENSORES');

    verify(() => port.send('SENSORES')).called(1);
    expect(controller.log, contains('> SENSORES'));
  });

  test('sendCommand ignora comando vazio', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.sendCommand('');

    expect(controller.log, hasLength(2));
    expect(controller.errorMessage, isNull);
    verifyNever(() => port.send(any()));
  });

  test('sendCommand ignora comando só com espaços', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.sendCommand('   ');

    expect(controller.log, hasLength(2));
    expect(controller.errorMessage, isNull);
    verifyNever(() => port.send(any()));
  });

  test('sendCommand registra erro quando o envio falha', () async {
    final port = MockRobotCommandPort();
    when(
      () => port.send(any()),
    ).thenThrow(const RobotCommandException('sem robô'));
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.sendCommand('SENSORES');

    verify(() => port.send('SENSORES')).called(1);
    expect(controller.errorMessage, 'sem robô');
    expect(controller.log, contains('! sem robô'));
  });

  test('clearLog esvazia o log', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();
    await controller.sendCommand('SENSORES');

    expect(controller.log, isNotEmpty);
    controller.clearLog();

    expect(controller.log, isEmpty);
  });

  test('resposta de sensor entra no log e atualiza sensores', () async {
    final respostas = StreamController<String>();
    final port = MockRobotCommandPort();
    when(() => port.responses).thenAnswer((_) => respostas.stream);
    final controller = TestController(port: port)..init();

    respostas.add('sensorD2 vendo');
    await Future.delayed(Duration.zero);

    expect(controller.log, contains('< sensorD2 vendo'));
    expect(controller.sensores['D2'], SensorStatus.vendo);
    await respostas.close();
  });

  test(
    'resposta que não é de sensor entra no log sem alterar sensores',
    () async {
      final respostas = StreamController<String>();
      final port = MockRobotCommandPort();
      when(() => port.responses).thenAnswer((_) => respostas.stream);
      final controller = TestController(port: port)..init();

      respostas.add('OK D22');
      await Future.delayed(Duration.zero);

      expect(controller.log, contains('< OK D22'));
      expect(controller.sensores, isEmpty);
      await respostas.close();
    },
  );

  test('id do sensor em minúsculas é guardado em maiúsculas', () async {
    final respostas = StreamController<String>();
    final port = MockRobotCommandPort();
    when(() => port.responses).thenAnswer((_) => respostas.stream);
    final controller = TestController(port: port)..init();

    respostas.add('sensord2 cego');
    await Future.delayed(Duration.zero);

    expect(controller.sensores, {'D2': SensorStatus.cego});
    await respostas.close();
  });

  test('nova resposta do mesmo sensor substitui o estado anterior', () async {
    final respostas = StreamController<String>();
    final port = MockRobotCommandPort();
    when(() => port.responses).thenAnswer((_) => respostas.stream);
    final controller = TestController(port: port)..init();

    respostas.add('sensorD2 vendo');
    respostas.add('sensorD2 cego');
    await Future.delayed(Duration.zero);

    expect(controller.sensores, {'D2': SensorStatus.cego});
    await respostas.close();
  });

  test('dispose para de ouvir as respostas do robô', () async {
    final respostas = StreamController<String>();
    final port = MockRobotCommandPort();
    when(() => port.responses).thenAnswer((_) => respostas.stream);
    final controller = TestController(port: port)..init();

    controller.dispose();
    respostas.add('sensorD2 vendo');
    await Future.delayed(Duration.zero);

    expect(controller.log, isNot(contains('< sensorD2 vendo')));
    expect(controller.sensores, isEmpty);
    await respostas.close();
  });

  test('sendCommand registra erro inesperado do canal', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenThrow(Exception('canal fechado'));
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.sendCommand('SENSORES');

    expect(
      controller.errorMessage,
      'Falha ao enviar: Exception: canal fechado',
    );
    expect(
      controller.log,
      contains('! Falha ao enviar: Exception: canal fechado'),
    );
  });

  test('testSensors envia SENSORES', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.testSensors();

    verify(() => port.send('SENSORES')).called(1);
  });

  test('testMotors envia os valores dos dois motores', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.testMotors(left: 1000, right: -500);

    verify(() => port.send('MOTOR 1000 -500')).called(1);
  });

  test('stopMotors envia STOP', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.stopMotors();

    verify(() => port.send('STOP')).called(1);
  });

  // O formato do comando PID ainda não foi confirmado com o firmware (ver
  // TODO no RobotProtocol). Se mudar, este teste é o que deve ser atualizado.
  test('savePid envia os três ganhos', () async {
    final port = MockRobotCommandPort();
    when(() => port.send(any())).thenAnswer((_) async {});
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    final controller = TestController(port: port)..init();

    await controller.savePid(kp: 1.5, ki: 0.2, kd: 3.0);

    verify(() => port.send('PID 1.5 0.2 3.0')).called(1);
  });
}
