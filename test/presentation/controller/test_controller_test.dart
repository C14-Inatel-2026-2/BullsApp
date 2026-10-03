import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/data/models/sensor_status.dart';
import 'package:bullsapp/data/repositories/fake_robot_command_port.dart';
import 'package:bullsapp/data/repositories/robot_command_exception.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/controllers/test_controller.dart';

class MockRobotCommandPort extends Mock implements RobotCommandPort {}

void main() {
  // Robô fake sem latência: responde "OK <comando>" e, para SENSORES,
  // quatro linhas de sensor.
  late FakeRobotCommandPort robot;
  late TestController controller;

  setUp(() {
    robot = FakeRobotCommandPort(latency: Duration.zero);
    controller = TestController(port: robot)..init();
  });

  tearDown(() async {
    controller.dispose();
    await robot.dispose();
  });

  test('comando do terminal vai para o robô e a resposta entra no log', () async {
    await controller.sendCommand('  PING  ');
    await pumpEventQueue();

    expect(robot.enviados, ['PING']);
    expect(controller.log, containsAllInOrder(['> PING', '< OK PING']));
    expect(controller.isBusy, isFalse);
  });

  test('comando vazio não é enviado', () async {
    await controller.sendCommand('   ');

    expect(robot.enviados, isEmpty);
  });

  test('testSensors interpreta as respostas dos sensores', () async {
    await controller.testSensors();
    await pumpEventQueue();

    expect(controller.sensores['D2'], SensorStatus.vendo);
    expect(controller.sensores['E0'], SensorStatus.cego);
  });

  test('PID e motores usam o formato do protocolo', () async {
    await controller.savePid(kp: 1.5, ki: 0.2, kd: 3);
    await controller.testMotors(left: 5000, right: -5000);

    expect(robot.enviados, ['PID 1.5 0.2 3.0', 'MOTOR 5000 -5000']);
  });

  test('STOP passa mesmo com outro comando em andamento', () async {
    final slowRobot =
        FakeRobotCommandPort(latency: const Duration(milliseconds: 50));
    final c = TestController(port: slowRobot)..init();

    final first = c.sendCommand('MOTOR 100 100');
    expect(c.isBusy, isTrue);

    await c.sendCommand('OUTRO'); // ignorado: ocupado
    await c.stopMotors(); // nunca ignorado
    await first;

    expect(slowRobot.enviados, ['MOTOR 100 100', 'STOP']);
    c.dispose();
    await slowRobot.dispose();
  });

  test('erro do canal aparece no log e em errorMessage', () async {
    final port = MockRobotCommandPort();
    when(() => port.responses).thenAnswer((_) => const Stream.empty());
    when(() => port.send(any()))
        .thenThrow(const RobotCommandException('Nenhum robô conectado.'));
    final c = TestController(port: port)..init();

    await c.sendCommand('STOP');

    expect(c.errorMessage, 'Nenhum robô conectado.');
    expect(c.log.last, '! Nenhum robô conectado.');
    expect(c.isBusy, isFalse);
  });
}
