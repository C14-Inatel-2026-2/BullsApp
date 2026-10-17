import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/presentation/widgets/header.dart';

void main() {
  testWidgets('Deve renderizar o botão voltar com texto "VOLTAR"', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CustomHeader(isConnected: true))),
    );

    // Assert
    expect(find.byType(InkWell), findsOneWidget);
    expect(find.text('VOLTAR'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
  testWidgets('Deve exibir "Conectado" quando isConnected for true', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CustomHeader(isConnected: true))),
    );

    // Assert
    expect(find.text('Conectado'), findsOneWidget);
    expect(find.text('Desconectado'), findsNothing);
  });
  testWidgets('Deve exibir "Desconectado" quando isConnected for false', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CustomHeader(isConnected: false))),
    );

    // Assert
    expect(find.text('Conectado'), findsNothing);
    expect(find.text('Desconectado'), findsOneWidget);
  });
}
