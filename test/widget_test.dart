// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/presentation/widgets/header.dart';
import 'package:bullsapp/main.dart';

void main() {
   testWidgets('Deve renderizar o botão voltar com texto "VOLTAR"', 
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomHeader(
                isConnected: true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.text('VOLTAR'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      },
    );
    testWidgets('Deve exibir "Conectado" quando isConnected for true', 
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomHeader(
                isConnected: true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Conectado'), findsOneWidget);
        expect(find.text('Desconectado'), findsNothing);
      },
    );
    testWidgets('Deve exibir "Desconectado" quando isConnected for false', 
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomHeader(
                isConnected: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Conectado'), findsNothing);
        expect(find.text('Desconectado'), findsOneWidget);
      },
    );
  }
