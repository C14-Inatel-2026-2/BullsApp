import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bullsapp/data/repositories/fake_robot_command_port.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/controllers/auto_status.dart';
import 'package:bullsapp/presentation/pages/auto_page.dart';
import 'package:bullsapp/presentation/widgets/display_state/display_state.dart';

class SentCommand {
  final String key;
  final String side;
  final List<String> actions;
  final bool teste;

  SentCommand(this.key, this.side, this.actions, this.teste);
}

void main() {
  late List<SentCommand> sent;
  late ValueNotifier<AutoStatus> status;

  setUp(() {
    // O cache guarda Futures da zona do teste anterior, que nunca completariam.
    rootBundle.clear();
    sent = [];
    status = ValueNotifier(AutoStatus.idle);
  });

  tearDown(() => status.dispose());

  /// Abre a página e espera os JSONs de assets carregarem.
  Future<void> pumpCommand(
    WidgetTester tester, {
    String? robotResponse,
    String? errorMessage,
  }) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Provider<RobotCommandPort>.value(
        value: FakeRobotCommandPort(latency: Duration.zero),
        child: MaterialApp(
          home: ValueListenableBuilder<AutoStatus>(
            valueListenable: status,
            builder: (_, current, _) => CommandPage(
              status: current,
              robotResponse: robotResponse,
              errorMessage: errorMessage,
              onSendCommand: (key, side, actions, {teste = false}) =>
                  sent.add(SentCommand(key, side, actions, teste)),
            ),
          ),
        ),
      ),
    );

    // O carregamento dos assets é assíncrono de verdade e não anda só com pump.
    for (
      var i = 0;
      i < 50 && find.byType(DisplayState).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pump();
  }

  testWidgets('carrega e seleciona a primeira jogada', (tester) async {
    await pumpCommand(tester);

    expect(find.text('SELECIONAR JOGADA'), findsOneWidget);
    expect(find.text('JOGADA 1'), findsOneWidget);
    expect(find.byType(DisplayState), findsOneWidget);
    expect(find.text('ENVIAR COMANDO'), findsOneWidget);
  });

  testWidgets('enviar usa a jogada, o lado direito e sem teste por padrão', (
    tester,
  ) async {
    await pumpCommand(tester);

    await tapText(tester, 'ENVIAR COMANDO');

    final command = sent.single;
    expect(command.key, 'JOGADA_1');
    expect(command.side, 'ladoDir');
    expect(command.actions, isNotEmpty);
    expect(command.teste, isFalse);
  });

  testWidgets('enviar respeita o lado e o modo teste escolhidos', (
    tester,
  ) async {
    await pumpCommand(tester);

    await tapText(tester, 'ESQUERDA');
    await tapText(tester, 'TESTE');
    await tapText(tester, 'ENVIAR COMANDO');

    expect(sent.single.side, 'ladoEsc');
    expect(sent.single.teste, isTrue);
  });

  testWidgets('trocar a jogada no dropdown muda o que é enviado', (
    tester,
  ) async {
    await pumpCommand(tester);

    await tapText(tester, 'JOGADA 1');
    await tapText(tester, 'JOGADA 2');
    await tapText(tester, 'ENVIAR COMANDO');

    expect(sent.single.key, 'JOGADA_2');
  });

  testWidgets('botão confirma o envio e mostra a resposta do robô', (
    tester,
  ) async {
    await pumpCommand(tester, robotResponse: 'OK D01');

    await tapText(tester, 'ENVIAR COMANDO');
    status.value = AutoStatus.running;
    await tester.pump();

    expect(find.text('COMANDO ENVIADO'), findsOneWidget);
    expect(find.text('OK D01'), findsOneWidget);
  });

  testWidgets('trocar a seleção depois do envio volta o botão', (tester) async {
    await pumpCommand(tester, robotResponse: 'OK D01');

    await tapText(tester, 'ENVIAR COMANDO');
    status.value = AutoStatus.running;
    await tester.pump();
    await tapText(tester, 'ESQUERDA');

    expect(find.text('ENVIAR COMANDO'), findsOneWidget);
    expect(find.text('OK D01'), findsNothing);
  });

  testWidgets('mostra o erro do envio', (tester) async {
    await pumpCommand(tester, errorMessage: 'Robô desconectado');

    await tapText(tester, 'ENVIAR COMANDO');
    status.value = AutoStatus.error;
    await tester.pump();

    expect(find.text('Robô desconectado'), findsOneWidget);
    expect(find.text('ENVIAR COMANDO'), findsOneWidget);
  });

  testWidgets('status running sem envio local não confirma o botão', (
    tester,
  ) async {
    status.value = AutoStatus.running;
    await pumpCommand(tester, robotResponse: 'OK D01');

    expect(find.text('ENVIAR COMANDO'), findsOneWidget);
    expect(find.text('OK D01'), findsNothing);
  });
}
