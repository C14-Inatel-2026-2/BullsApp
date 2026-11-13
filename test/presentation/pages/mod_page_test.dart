import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bullsapp/data/repositories/fake_robot_command_port.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/pages/auto_page.dart';
import 'package:bullsapp/presentation/pages/mod_page.dart';

void main() {
  Future<void> pumpMod(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Provider<RobotCommandPort>.value(
        value: FakeRobotCommandPort(latency: Duration.zero),
        child: const MaterialApp(home: ModPage()),
      ),
    );
  }

  testWidgets('mostra o título e os modos disponíveis', (tester) async {
    await pumpMod(tester);

    expect(find.text('SELECIONE UM MODO'), findsOneWidget);
    expect(find.textContaining('AUTO', findRichText: true), findsOneWidget);
    expect(find.textContaining('RC', findRichText: true), findsOneWidget);
  });

  testWidgets('AUTO abre a tela de comandos', (tester) async {
    await pumpMod(tester);

    await tester.tap(find.textContaining('AUTO', findRichText: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CommandPage), findsOneWidget);
  });

  testWidgets('RC continua na mesma tela', (tester) async {
    await pumpMod(tester);

    await tester.tap(find.textContaining('RC', findRichText: true));
    await tester.pump();

    expect(find.byType(ModPage), findsOneWidget);
    expect(find.byType(CommandPage), findsNothing);
  });
}
