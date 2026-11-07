import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:bullsapp/core/constants/robot_protocol.dart';
import 'package:bullsapp/data/repositories/robot_command_exception.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/pages/motor_page.dart';

class MockRobotCommandPort extends Mock implements RobotCommandPort {}

void main() {
  late MockRobotCommandPort port;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    port = MockRobotCommandPort();
    when(() => port.responses).thenAnswer((_) => Stream<String>.empty());
    when(() => port.send(any())).thenAnswer((_) async {});
  });

  Future<void> abrirPagina(WidgetTester tester) async {
    // Tela alta para a coluna caber sem overflow
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Provider<RobotCommandPort>.value(
        value: port,
        child: const MaterialApp(home: MotorPage()),
      ),
    );
  }

  Slider slider(WidgetTester tester, int indice) =>
      tester.widget<Slider>(find.byType(Slider).at(indice));

  group('MotorPage - comandos mockados', () {
    testWidgets('mostra as duas barras e o botão PARAR', (tester) async {
      await abrirPagina(tester);

      expect(find.byType(Slider), findsNWidgets(2));
      expect(find.text('PARAR'), findsOneWidget);
    });

    testWidgets('ao soltar a barra esquerda, envia o comando de motores',
        (tester) async {
      await abrirPagina(tester);

      slider(tester, 0).onChanged!(50);
      await tester.pump();
      slider(tester, 0).onChangeEnd!(50);
      await tester.pump();

      verify(() => port.send(RobotProtocol.testarMotores(50, 0))).called(1);
    });

    testWidgets('PARAR zera as barras e envia o comando de parada',
        (tester) async {
      await abrirPagina(tester);
      slider(tester, 0).onChanged!(50);
      await tester.pump();

      await tester.tap(find.text('PARAR'));
      await tester.pump();

      expect(slider(tester, 0).value, 0);
      expect(slider(tester, 1).value, 0);
      verify(() => port.send(RobotProtocol.parar)).called(1);
    });
  });

  group('MotorPage - simulação de falhas', () {
    testWidgets('arrastar a barra sem soltar não envia nada', (tester) async {
      await abrirPagina(tester);

      slider(tester, 1).onChanged!(70);
      await tester.pump();

      verifyNever(() => port.send(any()));
    });

    testWidgets('falha ao enviar o comando não derruba a página',
        (tester) async {
      when(() => port.send(any()))
          .thenAnswer((_) async => throw RobotCommandException('sem conexão'));
      await abrirPagina(tester);

      await tester.tap(find.text('PARAR'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('PARAR'), findsOneWidget);
    });
  });
}