import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bullsapp/presentation/widgets/custom_button.dart';

// Mock para VoidCallback
class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('CustomButton Widget Tests', () {
    late MockVoidCallback mockOnTap;

    setUp(() {
      mockOnTap = MockVoidCallback();
    });

    testWidgets('deve renderizar o label corretamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Botão Teste',
              onTap: mockOnTap.call,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Botão Teste'), findsOneWidget);
    });

    testWidgets('deve renderizar label2 quando fornecido', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Botão Principal',
              label2: 'Subtítulo',
              onTap: mockOnTap.call,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Botão Principal'), findsOneWidget);
      expect(find.text('Subtítulo'), findsOneWidget);
    });

    testWidgets('deve renderizar ícone quando fornecido', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Botão com Ícone',
              icon: Icons.add,
              onTap: mockOnTap.call,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('deve renderizar imagem asset quando fornecido', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Botão com Imagem',
              iconAsset: 'assets/images/icon.png',
              onTap: mockOnTap.call,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('deve chamar onTap quando clicado', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Botão',
              onTap: mockOnTap.call,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Assert
      verify(() => mockOnTap()).called(1);
    });

    testWidgets('deve ter espaçamento entre ícone e texto', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Botão',
              icon: Icons.add,
              onTap: mockOnTap.call,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(SizedBox), findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 10);
    });

    testWidgets('deve centralizar o conteúdo horizontalmente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Botão',
              onTap: mockOnTap.call,
            ),
          ),
        ),
      );

      // Act
      final row = tester.widget<Row>(
        find.byType(Row),
      );
      // Assert
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
    });
 
  });
}