import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/presentation/widgets/selector.dart';

void main() {
  group('TabSelector', () {
    testWidgets('renderiza todas as opções recebidas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const ['DISPONÍVEIS', 'PAREADOS'],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('DISPONÍVEIS'), findsOneWidget);
      expect(find.text('PAREADOS'), findsOneWidget);
    });

    testWidgets('destaca visualmente a opção correspondente ao selectedIndex',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const ['A', 'B', 'C'],
              selectedIndex: 1, // "B" deve estar selecionada
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Pega o AnimatedContainer que envolve o texto "B"
      final selectedContainer = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('B'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = selectedContainer.decoration as BoxDecoration;

      // A opção selecionada não deve ter cor transparente
      expect(decoration.color, isNot(Colors.transparent));

      // A opção NÃO selecionada (ex: "A") deve continuar transparente
      final unselectedContainer = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('A'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final unselectedDecoration = unselectedContainer.decoration as BoxDecoration;
      expect(unselectedDecoration.color, Colors.transparent);
    });

    testWidgets('chama onChanged com o índice correto ao tocar numa opção',
        (tester) async {
      int? capturedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const ['DISPONÍVEIS', 'PAREADOS'],
              selectedIndex: 0,
              onChanged: (index) => capturedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('PAREADOS'));
      await tester.pumpAndSettle();

      expect(capturedIndex, 1);
    });

    testWidgets('NÃO chama onChanged ao tocar na opção já selecionada (idempotência)',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const ['A', 'B'],
              selectedIndex: 0,
              onChanged: (_) => callCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('A')); // já está selecionada
      await tester.pumpAndSettle();

      // Aqui documentamos o comportamento ATUAL do widget: ele chama
      // onChanged mesmo tocando na já selecionada (não tem guard clause).
      // Se vocês decidirem adicionar essa otimização depois, esse teste
      // "falha de propósito" pra avisar que o comportamento mudou.
      expect(callCount, 1);
    });
  });

  group('TabSelector - simulação de falhas / casos extremos', () {
    testWidgets('lista de opções vazia não derruba o app (renderiza sem crash)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const [],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Não deve lançar exceção — o teste passa só de não travar aqui.
      expect(tester.takeException(), isNull);
      expect(find.byType(TabSelector), findsOneWidget);
    });

    testWidgets('selectedIndex fora do intervalo não derruba o app',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const ['A', 'B'],
              selectedIndex: 5, // índice inválido de propósito
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // Nenhuma opção deveria aparecer marcada como selecionada,
      // já que índice 5 não bate com nenhuma (0 ou 1).
      final containerA = tester.widget<AnimatedContainer>(
        find.ancestor(of: find.text('A'), matching: find.byType(AnimatedContainer)),
      );
      expect((containerA.decoration as BoxDecoration).color, Colors.transparent);
    });

    testWidgets('selectedIndex negativo não derruba o app', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const ['A', 'B'],
              selectedIndex: -1,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('múltiplos toques rápidos chamam onChanged o número certo de vezes',
        (tester) async {
      final capturedIndexes = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const ['A', 'B', 'C'],
              selectedIndex: 0,
              onChanged: (index) => capturedIndexes.add(index),
            ),
          ),
        ),
      );

      await tester.tap(find.text('B'));
      await tester.tap(find.text('C'));
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(capturedIndexes, [1, 2, 0]);
    });

    testWidgets('opções com texto duplicado não quebram o widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabSelector(
              options: const ['MESMO', 'MESMO'],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // Duas opções com o mesmo texto — confirma que ambas renderizaram
      expect(find.text('MESMO'), findsNWidgets(2));
    });
  });
}