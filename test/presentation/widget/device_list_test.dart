import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/data/models/device_model.dart';
import 'package:bullsapp/presentation/widgets/device_list_item.dart';

class MockBleDeviceModel extends Mock implements BleDeviceModel {}

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('DeviceListItem Widget Tests', () {
    late BleDeviceModel mockDevice;
    late MockVoidCallback mockOnConnect;

    setUp(() {
      mockDevice = MockBleDeviceModel();
      mockOnConnect = MockVoidCallback();

      when(() => mockDevice.name).thenReturn('Test Device');
      when(() => mockDevice.macAddress).thenReturn('AA:BB:CC:DD:EE:FF');
      when(() => mockDevice.rssi).thenReturn(-45);
      when(() => mockDevice.isPaired).thenReturn(false);
    });

    testWidgets('deve renderizar o nome do dispositivo corretamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      expect(find.text('Test Device'), findsOneWidget);
    });

    testWidgets('deve renderizar o endereço MAC corretamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      expect(find.text('AA:BB:CC:DD:EE:FF'), findsOneWidget);
    });

    testWidgets('deve renderizar o valor RSSI corretamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      expect(find.text('-45 dBm'), findsOneWidget);
    });

    testWidgets('deve exibir "CONECTAR" quando o dispositivo está pareado', (tester) async {
      when(() => mockDevice.isPaired).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      expect(find.text('CONECTAR'), findsOneWidget);
      expect(find.text('PAREAR'), findsNothing);
    });

    testWidgets('deve exibir "PAREAR" quando o dispositivo está conectado', (tester) async {
      when(() => mockDevice.isPaired).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      expect(find.text('PAREAR'), findsOneWidget);
      expect(find.text('CONECTAR'), findsNothing);
    });

    testWidgets('deve chamar onConnect quando o botão for pressionado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(() => mockOnConnect()).called(1);
    });

    testWidgets('deve lidar com nomes longos sem quebrar', (tester) async {
      const longName = 'Nomeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeio';
      when(() => mockDevice.name).thenReturn(longName);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      expect(find.text(longName), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('deve exibir RSSI negativo corretamente', (tester) async {
      when(() => mockDevice.rssi).thenReturn(-75);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      expect(find.text('-75 dBm'), findsOneWidget);
    });

    testWidgets('deve exibir RSSI positivo corretamente', (tester) async {
      when(() => mockDevice.rssi).thenReturn(45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceListItem(
              device: mockDevice,
              onConnect: mockOnConnect.call,
            ),
          ),
        ),
      );

      expect(find.text('45 dBm'), findsOneWidget);
    });
  });
}
