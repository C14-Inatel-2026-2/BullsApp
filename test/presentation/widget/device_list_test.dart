import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bullsapp/presentation/widgets/device_list_item.dart';
import 'package:bullsapp/data/models/device_model.dart';

// Mock do BleDeviceModel
class MockBleDeviceModel extends Mock implements BleDeviceModel {}

void main() {
  group('DeviceListItem Widget Tests', () {
    late BleDeviceModel mockDevice;
    late VoidCallback mockOnConnect;

    setUp(() {
      mockDevice = MockBleDeviceModel();
      mockOnConnect = MockVoidCallback();
      
      // Configurando os mocks
      when(() => mockDevice.name).thenReturn('Test Device');
      when(() => mockDevice.macAddress).thenReturn('AA:BB:CC:DD:EE:FF');
      when(() => mockDevice.rssi).thenReturn(-45);
      when(() => mockDevice.isPaired).thenReturn(false);
    });

    testWidgets('deve renderizar o nome do dispositivo corretamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Device'), findsOneWidget);
    });

    testWidgets('deve renderizar o endereço MAC corretamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('AA:BB:CC:DD:EE:FF'), findsOneWidget);
    });

    testWidgets('deve renderizar o valor RSSI corretamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('-45 dBm'), findsOneWidget);
    });

    testWidgets('deve exibir "CONECTAR" quando o dispositivo está pareado', (WidgetTester tester) async {
      // Arrange
      when(() => mockDevice.isPaired).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('CONECTAR'), findsOneWidget);
      expect(find.text('PAREAR'), findsNothing);
    });

    testWidgets('deve exibir "PAREAR" quando o dispositivo está conectado', (WidgetTester tester) async {
      // Arrange
      when(() => mockDevice.isPaired).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('PAREAR'), findsOneWidget);
      expect(find.text('CONECTAR'), findsNothing);
    });

    testWidgets('deve chamar onConnect quando o botão for pressionado', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      verify(() => mockOnConnect()).called(1);
    });

    testWidgets('deve lidar com nomes longos sem quebrar', (WidgetTester tester) async {
      // Arrange
      const longName = 'Nomeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeio';
      when(() => mockDevice.name).thenReturn(longName);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(longName), findsOneWidget);
      // Verifica se não houve erro de overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('deve exibir RSSI negativo corretamente', (WidgetTester tester) async {
      // Arrange
      when(() => mockDevice.rssi).thenReturn(-75);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('-75 dBm'), findsOneWidget);
    });

    testWidgets('deve exibir RSSI positivo corretamente', (WidgetTester tester) async {
      // Arrange
      when(() => mockDevice.rssi).thenReturn(45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('45 dBm'), findsOneWidget);
    });

  });
}

// Mock para VoidCallback
class MockVoidCallback extends Mock {
  void call();
}