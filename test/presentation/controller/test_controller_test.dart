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
}
