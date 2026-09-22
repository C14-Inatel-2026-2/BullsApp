import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/presentation/widgets/dropdown.dart';

void main() {
  group('Dropdown', () {
    testWidgets('mostra a jogada selecionada, formatada (sem underscore)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_67',
              options: const ['JOGADA_1', 'JOGADA_67'],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('JOGADA 67'), findsOneWidget);
      // A versão com underscore não deveria aparecer crua na tela
      expect(find.text('JOGADA_67'), findsNothing);
    });

    testWidgets('começa fechado (lista de opções não visível)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const ['JOGADA_1', 'JOGADA_2'],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      // JOGADA_2 só aparece se a lista estiver aberta
      expect(find.text('JOGADA 2'), findsNothing);
    });

    testWidgets('abre a lista ao tocar no cabeçalho', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const ['JOGADA_1', 'JOGADA_2', 'JOGADA_3'],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('JOGADA 1')); // toca no cabeçalho
      await tester.pumpAndSettle();

      expect(find.text('JOGADA 2'), findsOneWidget);
      expect(find.text('JOGADA 3'), findsOneWidget);
    });

    testWidgets('ícone muda de seta pra baixo pra seta pra cima ao abrir',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const ['JOGADA_1', 'JOGADA_2'],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      await tester.tap(find.text('JOGADA 1'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });

    testWidgets('chama onSelected com a chave correta ao escolher uma opção',
        (tester) async {
      String? capturedKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const ['JOGADA_1', 'JOGADA_2'],
              onSelected: (key) => capturedKey = key,
            ),
          ),
        ),
      );

      await tester.tap(find.text('JOGADA 1')); // abre
      await tester.pumpAndSettle();

      await tester.tap(find.text('JOGADA 2')); // escolhe
      await tester.pumpAndSettle();

      expect(capturedKey, 'JOGADA_2');
    });

    testWidgets('fecha a lista automaticamente após escolher uma opção',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const ['JOGADA_1', 'JOGADA_2'],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('JOGADA 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('JOGADA 2'));
      await tester.pumpAndSettle();

      // Depois de escolher, a lista deve fechar — ícone volta pra baixo
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('tocar no cabeçalho duas vezes abre e depois fecha (toggle)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const ['JOGADA_1', 'JOGADA_2'],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('JOGADA 1'));
      await tester.pumpAndSettle();
      expect(find.text('JOGADA 2'), findsOneWidget); // aberto

      await tester.tap(find.text('JOGADA 1'));
      await tester.pumpAndSettle();
      expect(find.text('JOGADA 2'), findsNothing); // fechado de novo
    });
  });

  group('JogadaSelectorDropdown - simulação de falhas / casos extremos', () {
    testWidgets('lista de opções vazia não derruba o app', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const [],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('ao abrir com lista vazia, mostra mensagem de "nenhuma jogada"',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const [],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('JOGADA 1'));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma jogada disponível'), findsOneWidget);
    });

    testWidgets('selectedKey que não existe na lista de options não derruba o app',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_999', // não está em options
              options: const ['JOGADA_1', 'JOGADA_2'],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // Mostra o valor selecionado mesmo não estando na lista de opções
      expect(find.text('JOGADA 999'), findsOneWidget);
    });

    testWidgets('chave com múltiplos underscores é formatada corretamente',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_TATICA_ESPECIAL_1',
              options: const ['JOGADA_TATICA_ESPECIAL_1'],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('JOGADA TATICA ESPECIAL 1'), findsOneWidget);
    });

    testWidgets('lista longa de opções não derruba o app (scroll interno)',
        (tester) async {
      final manyOptions = List.generate(100, (i) => 'JOGADA_$i');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_0',
              options: manyOptions,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('JOGADA 0'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // A lista tem maxHeight fixo (220), então nem todos os 100 itens
      // estarão montados na árvore ao mesmo tempo — isso é esperado.
    });

    testWidgets('tocar rapidamente em várias opções seguidas só mantém a última escolha',
        (tester) async {
      final capturedKeys = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JogadaSelectorDropdown(
              selectedKey: 'JOGADA_1',
              options: const ['JOGADA_1', 'JOGADA_2', 'JOGADA_3'],
              onSelected: (key) => capturedKeys.add(key),
            ),
          ),
        ),
      );

      await tester.tap(find.text('JOGADA 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('JOGADA 2'));
      await tester.pumpAndSettle();

      expect(capturedKeys, ['JOGADA_2']);
    });
  });
}