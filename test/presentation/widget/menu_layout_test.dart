import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bullsapp/core/constants/app_assets.dart';
import 'package:bullsapp/data/repositories/fake_robot_command_port.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/widgets/header.dart';
import 'package:bullsapp/presentation/widgets/menu_layout.dart';

void main() {
  Future<void> pumpMenu(WidgetTester tester, MenuLayout menu) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // O CustomHeader lê o status da conexão pelo RobotCommandPort.
    await tester.pumpWidget(
      Provider<RobotCommandPort>.value(
        value: FakeRobotCommandPort(latency: Duration.zero),
        child: MaterialApp(home: menu),
      ),
    );
  }

  Widget botao(String label) =>
      SizedBox(key: Key(label), height: 40, child: Text(label));

  testWidgets('mostra o logo, o título e os botões', (tester) async {
    await pumpMenu(
      tester,
      MenuLayout(title: 'MENU', buttons: [botao('A'), botao('B')]),
    );

    expect(find.image(const AssetImage(AppAssets.logo)), findsOneWidget);
    expect(find.text('MENU'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('separa os botões com o mesmo espaçamento', (tester) async {
    await pumpMenu(
      tester,
      MenuLayout(title: 'MENU', buttons: [botao('A'), botao('B'), botao('C')]),
    );

    double topo(String key) => tester.getTopLeft(find.byKey(Key(key))).dy;
    double base(String key) => tester.getBottomLeft(find.byKey(Key(key))).dy;

    expect(topo('B') - base('A'), MenuLayout.buttonSpacing);
    expect(topo('C') - base('B'), MenuLayout.buttonSpacing);
  });

  testWidgets('mostra o cabeçalho por padrão', (tester) async {
    await pumpMenu(tester, const MenuLayout(title: 'MENU', buttons: []));

    expect(find.byType(CustomHeader), findsOneWidget);
  });

  testWidgets('esconde o cabeçalho com showHeader: false', (tester) async {
    await pumpMenu(
      tester,
      const MenuLayout(title: 'MENU', buttons: [], showHeader: false),
    );

    expect(find.byType(CustomHeader), findsNothing);
  });

  testWidgets('mostra o subtítulo abaixo do título', (tester) async {
    await pumpMenu(
      tester,
      const MenuLayout(title: 'MENU', subtitle: Text('status'), buttons: []),
    );

    expect(find.text('status'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('status')).dy,
      greaterThan(tester.getBottomLeft(find.text('MENU')).dy),
    );
  });
}
