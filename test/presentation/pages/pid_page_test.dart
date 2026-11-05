import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:bullsapp/core/constants/robot_protocol.dart';
import 'package:bullsapp/data/repositories/robot_command_exception.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/pages/pid_page.dart';

import '../../mocks/mocks.dart';

void main() {
  late MockRobotCommandPort port;

  setUp(() {
    port = MockRobotCommandPort();
    when(() => port.isConnected).thenReturn(true);
    when(() => port.connectionChanges).thenAnswer((_) => const Stream.empty());
    when(() => port.send(any())).thenAnswer((_) async {});
  });

  Future<void> pumpPid(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Provider<RobotCommandPort>.value(
        value: port,
        child: const MaterialApp(home: PIDControllerPage()),
      ),
    );
  }

  /// Abre o diálogo do card KP (o primeiro) e digita [value].
  Future<void> typeKp(WidgetTester tester, String value) async {
    await tester.tap(find.text('Clique para ajustar').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), value);
  }

  Future<void> tapAndSettle(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra os valores iniciais de KP, KD e KI', (tester) async {
    await pumpPid(tester);

    expect(find.text('45.00'), findsOneWidget);
    expect(find.text('50.10'), findsOneWidget);
    expect(find.text('5.20'), findsOneWidget);
  });

  testWidgets('Aplicar atualiza o valor e aceita vírgula', (tester) async {
    await pumpPid(tester);

    await typeKp(tester, '12,5');
    expect(find.text('Ajustar KP'), findsOneWidget);
    await tapAndSettle(tester, 'Aplicar');

    expect(find.text('12.50'), findsOneWidget);
    expect(find.text('45.00'), findsNothing);
    expect(find.text('Ajustar KP'), findsNothing);
  });

  testWidgets('Aplicar ignora valor fora do intervalo', (tester) async {
    await pumpPid(tester);

    await typeKp(tester, '101');
    await tapAndSettle(tester, 'Aplicar');

    expect(find.text('45.00'), findsOneWidget);
  });

  testWidgets('Aplicar ignora texto que não é número', (tester) async {
    await pumpPid(tester);

    await typeKp(tester, 'abc');
    await tapAndSettle(tester, 'Aplicar');

    expect(find.text('45.00'), findsOneWidget);
  });

  testWidgets('Cancelar fecha o diálogo sem mudar o valor', (tester) async {
    await pumpPid(tester);

    await typeKp(tester, '12');
    await tapAndSettle(tester, 'Cancelar');

    expect(find.text('45.00'), findsOneWidget);
    expect(find.text('Ajustar KP'), findsNothing);
  });

  testWidgets('SALVAR envia o PID e confirma', (tester) async {
    await pumpPid(tester);

    await tester.tap(find.text('SALVAR'));
    await tester.pump();

    verify(() => port.send(RobotProtocol.pid(45, 5.2, 50.1))).called(1);
    expect(find.text('PID enviado ao robô.'), findsOneWidget);
  });

  testWidgets('SALVAR mostra o erro quando o envio falha', (tester) async {
    when(
      () => port.send(any()),
    ).thenThrow(const RobotCommandException('Robô desconectado'));
    await pumpPid(tester);

    await tester.tap(find.text('SALVAR'));
    await tester.pump();

    expect(find.text('Robô desconectado'), findsOneWidget);
    expect(find.text('PID enviado ao robô.'), findsNothing);
  });
}
