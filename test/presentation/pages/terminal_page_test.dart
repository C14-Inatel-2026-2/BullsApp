import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/pages/terminal_page.dart';

import '../../mocks/mocks.dart';

void main() {
  late MockRobotCommandPort port;
  late StreamController<String> responses;

  setUp(() {
    port = MockRobotCommandPort();
    responses = StreamController<String>.broadcast();
    when(() => port.isConnected).thenReturn(true);
    when(() => port.connectionChanges).thenAnswer((_) => const Stream.empty());
    when(() => port.responses).thenAnswer((_) => responses.stream);
    when(() => port.send(any())).thenAnswer((_) async {});
  });

  Future<void> pumpTerminal(WidgetTester tester) => tester.pumpWidget(
    Provider<RobotCommandPort>.value(
      value: port,
      child: const MaterialApp(home: TerminalPage()),
    ),
  );

  Future<void> tapSend(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
  }

  String typedText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('mostra as linhas iniciais do terminal', (tester) async {
    await pumpTerminal(tester);

    expect(find.text('Terminal iniciado...'), findsOneWidget);
    expect(find.text('Aguardando entrada...'), findsOneWidget);
  });

  testWidgets('botão envia o comando e limpa o campo', (tester) async {
    await pumpTerminal(tester);

    await tester.enterText(find.byType(TextField), '  D22  ');
    await tapSend(tester);

    verify(() => port.send('D22')).called(1);
    expect(find.text('> D22'), findsOneWidget);
    expect(typedText(tester), isEmpty);
  });

  testWidgets('enviar pelo teclado também manda o comando', (tester) async {
    await pumpTerminal(tester);

    await tester.enterText(find.byType(TextField), 'E11');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(() => port.send('E11')).called(1);
  });

  testWidgets('não envia comando vazio', (tester) async {
    await pumpTerminal(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tapSend(tester);

    verifyNever(() => port.send(any()));
  });

  testWidgets('mostra a resposta do robô', (tester) async {
    await pumpTerminal(tester);

    responses.add('sensorD2 vendo');
    await tester.pump();

    expect(find.text('< sensorD2 vendo'), findsOneWidget);
  });

  testWidgets('mostra o erro quando o envio falha', (tester) async {
    when(() => port.send(any())).thenThrow(Exception('sem conexão'));
    await pumpTerminal(tester);

    await tester.enterText(find.byType(TextField), 'D22');
    await tapSend(tester);

    expect(find.textContaining('! Falha ao enviar'), findsOneWidget);
  });

  testWidgets('com envio em andamento bloqueia o botão e mantém o texto', (
    tester,
  ) async {
    final pending = Completer<void>();
    when(() => port.send(any())).thenAnswer((_) => pending.future);
    await pumpTerminal(tester);

    await tester.enterText(find.byType(TextField), 'D22');
    await tapSend(tester);

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'E11');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(typedText(tester), 'E11');
    verifyNever(() => port.send('E11'));

    pending.complete();
    await tester.pump();

    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('rola até a última linha quando chega resposta nova', (
    tester,
  ) async {
    await pumpTerminal(tester);

    for (var i = 0; i < 60; i++) {
      responses.add('linha $i');
    }
    // Um pump para o evento do stream, um para reconstruir e dois para a rolagem.
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('< linha 59'), findsOneWidget);
  });
}
