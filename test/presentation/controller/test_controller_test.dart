import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
}
