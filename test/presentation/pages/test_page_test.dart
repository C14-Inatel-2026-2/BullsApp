import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bullsapp/data/repositories/fake_robot_command_port.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/pages/pid_page.dart';
import 'package:bullsapp/presentation/pages/sensor_page.dart';
import 'package:bullsapp/presentation/pages/terminal_page.dart';
import 'package:bullsapp/presentation/pages/test_page.dart';

void main() {
  Future<void> pumpTestPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Provider<RobotCommandPort>.value(
        value: FakeRobotCommandPort(latency: Duration.zero),
        child: const MaterialApp(home: TestPage()),
      ),
    );
  }

  Future<void> tapAndOpen(WidgetTester tester, String label) async {
    await tester.tap(find.textContaining(label, findRichText: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('mostra o título e todas as opções de teste', (tester) async {
    await pumpTestPage(tester);

    expect(find.text('ESCOLHA UM TESTE'), findsOneWidget);
    for (final label in [
      'TESTAR MOTORES',
      'TESTAR SENSORES',
      'CALIBRAR PID',
      'TERMINAL',
    ]) {
      expect(find.textContaining(label, findRichText: true), findsOneWidget);
    }
  });

  testWidgets('TESTAR SENSORES abre a tela de sensores', (tester) async {
    await pumpTestPage(tester);

    await tapAndOpen(tester, 'TESTAR SENSORES');
    expect(find.byType(SensorPage), findsOneWidget);

    // Deixa terminar o delay do stream simulado, senão sobra um Timer pendente.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('CALIBRAR PID abre a tela de PID', (tester) async {
    await pumpTestPage(tester);

    await tapAndOpen(tester, 'CALIBRAR PID');

    expect(find.byType(PIDControllerPage), findsOneWidget);
  });

  testWidgets('TERMINAL abre o terminal', (tester) async {
    await pumpTestPage(tester);

    await tapAndOpen(tester, 'TERMINAL');

    expect(find.byType(TerminalPage), findsOneWidget);
  });

  testWidgets('TESTAR MOTORES continua na mesma tela', (tester) async {
    await pumpTestPage(tester);

    await tapAndOpen(tester, 'TESTAR MOTORES');

    expect(find.text('ESCOLHA UM TESTE'), findsOneWidget);
  });
}
