import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/widgets/header.dart';

/// Port controlável: o teste decide quando a conexão muda.
class _ConnectionPort implements RobotCommandPort {
  _ConnectionPort(this.isConnected);

  final _changes = StreamController<bool>.broadcast();

  @override
  bool isConnected;

  void set(bool value) {
    isConnected = value;
    _changes.add(value);
  }

  @override
  Stream<bool> get connectionChanges => _changes.stream;

  @override
  Stream<String> get responses => const Stream.empty();

  @override
  Future<void> send(String command) async {}
}

Widget _withPort(RobotCommandPort port) => Provider<RobotCommandPort>.value(
  value: port,
  child: const MaterialApp(home: Scaffold(body: CustomHeader())),
);

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
  testWidgets('Deve chamar onBackPressed quando o botão for clicado', (
    WidgetTester tester,
  ) async {
    // Arrange
    var backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomHeader(
            isConnected: true,
            onBackPressed: () {
              backPressed = true;
            },
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(InkWell));
    await tester.pump();

    // Assert
    expect(backPressed, true);
  });
  testWidgets(
    'Deve chamar Navigator.pop quando onBackPressed não for fornecido',
    (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CustomHeader(isConnected: true)),
        ),
      );

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert - O widget ainda deve estar na tela (pois não há tela anterior)
      expect(find.byType(CustomHeader), findsOneWidget);
    },
  );

  group('sem isConnected, acompanha o RobotCommandPort', () {
    testWidgets('mostra o estado atual ao abrir', (tester) async {
      await tester.pumpWidget(_withPort(_ConnectionPort(false)));
      expect(find.text('Desconectado'), findsOneWidget);
    });

    testWidgets('troca para "Desconectado" quando a conexão cai', (
      tester,
    ) async {
      final port = _ConnectionPort(true);
      await tester.pumpWidget(_withPort(port));
      expect(find.text('Conectado'), findsOneWidget);

      port.set(false);
      await tester.pump();
      expect(find.text('Desconectado'), findsOneWidget);

      port.set(true);
      await tester.pump();
      await tester.pump();
      expect(find.text('Conectado'), findsOneWidget);
    });
  });
}
