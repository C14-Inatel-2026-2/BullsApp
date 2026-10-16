import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/presentation/widgets/toggle_button.dart';

void main() {
  group('ToggleButton', () {
    testWidgets('renderiza o label recebido', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SideToggleButton(
              label: 'ESQUERDA',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('ESQUERDA'), findsOneWidget);
    });

    testWidgets('quando selected=true, mostra o ícone de check', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SideToggleButton(
              label: 'DIREITA',
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('quando selected=false, NÃO mostra o ícone de check', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SideToggleButton(
              label: 'DIREITA',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('quando selected=true, o fundo NÃO é transparente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SideToggleButton(
              label: 'DIREITA',
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNot(Colors.transparent));
    });

    testWidgets('quando selected=false, o fundo é transparente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SideToggleButton(
              label: 'ESQUERDA',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);
    });

    testWidgets('chama onTap ao tocar no botão', (tester) async {
      var tapped = false; // "spy" — injeção de função pra capturar a chamada

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SideToggleButton(
              label: 'DIREITA',
              selected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SideToggleButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('cor do texto muda: preto quando selecionado, cor de destaque quando não',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SideToggleButton(label: 'SELECIONADO', selected: true, onTap: () {}),
                SideToggleButton(label: 'NAO_SELECIONADO', selected: false, onTap: () {}),
              ],
            ),
          ),
        ),
      );

      final selectedText = tester.widget<Text>(find.text('SELECIONADO'));
      final unselectedText = tester.widget<Text>(find.text('NAO_SELECIONADO'));

      expect(selectedText.style?.color, Colors.black);
      expect(unselectedText.style?.color, isNot(Colors.black));
    });
  });

  group('SideToggleButton - simulação de falhas / casos extremos', () {
    testWidgets('label vazio não derruba o app', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SideToggleButton(
              label: '',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SideToggleButton), findsOneWidget);
    });

    testWidgets('múltiplos toques rápidos chamam onTap o número certo de vezes',
        (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SideToggleButton(
              label: 'DIREITA',
              selected: false,
              onTap: () => callCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SideToggleButton));
      await tester.tap(find.byType(SideToggleButton));
      await tester.tap(find.byType(SideToggleButton));
      await tester.pumpAndSettle();

      expect(callCount, 3);
    });

    testWidgets('toque fora da área do botão não aciona onTap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SideToggleButton(label: 'DIREITA', selected: false, onTap: () => tapped = true),
                const SizedBox(height: 200, child: Text('área neutra')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('área neutra'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });
  });
}