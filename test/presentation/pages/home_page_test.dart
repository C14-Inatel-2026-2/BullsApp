import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bullsapp/data/models/device_model.dart';
import 'package:bullsapp/data/repositories/ble_repository.dart';
import 'package:bullsapp/presentation/pages/home_page.dart';

class MockBleRepository extends Mock implements BleRepository {}

const fakeDevice = BleDeviceModel(
  name: 'Bull',
  macAddress: 'AA:BB:CC:DD:EE:FF',
  rssi: -50,
);

void main() {
  late MockBleRepository repo;
  late StreamController<BleConnectionState> connection;

  setUpAll(() {
    registerFallbackValue(fakeDevice);
  });

  setUp(() {
    repo = MockBleRepository();
    connection = StreamController<BleConnectionState>();
    when(() => repo.connectionStateOf(any())).thenAnswer((_) => connection.stream);
  });

  tearDown(() => connection.close());

  Future<void> pumpHome(
    WidgetTester tester, {
    String deviceName = 'Bull',
    bool isConnected = true,
    BleDeviceModel? device = fakeDevice,
  }) async {
    // Tela alta para a coluna de botões caber sem overflow
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          deviceName: deviceName,
          isConnected: isConnected,
          device: device,
          repository: repo,
        ),
      ),
    );
  }

  group('HomePage - dados mockados', () {
    testWidgets('mostra o nome do dispositivo em maiúsculas', (tester) async {
      await pumpHome(tester, deviceName: 'bull robo');

      expect(find.text('BULL ROBO'), findsOneWidget);
    });

    testWidgets('mostra CONECTADO quando começa conectado', (tester) async {
      await pumpHome(tester, isConnected: true);

      expect(find.text('CONECTADO'), findsOneWidget);
    });

    testWidgets('mostra DESCONECTADO quando começa desconectado', (tester) async {
      await pumpHome(tester, isConnected: false);

      expect(find.text('DESCONECTADO'), findsOneWidget);
    });

    testWidgets('troca para DESCONECTADO quando a conexão cai', (tester) async {
      await pumpHome(tester);

      connection.add(BleConnectionState.disconnected);
      await tester.pump();

      expect(find.text('DESCONECTADO'), findsOneWidget);
      expect(find.text('CONECTADO'), findsNothing);
    });

    testWidgets('continua CONECTADO se a conexão segue ativa', (tester) async {
      await pumpHome(tester);

      connection.add(BleConnectionState.connected);
      await tester.pump();

      expect(find.text('CONECTADO'), findsOneWidget);
    });
  });

  group('HomePage - simulação de falhas', () {
    testWidgets('erro no stream de conexão não derruba a página', (tester) async {
      await pumpHome(tester);

      connection.addError(Exception('Bluetooth desligado'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('CONECTADO'), findsOneWidget);
    });

    testWidgets('stream que fecha sem emitir nada não muda o status', (tester) async {
      await pumpHome(tester);

      await connection.close();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('CONECTADO'), findsOneWidget);
    });

    testWidgets('para de ouvir a conexão quando a página é destruída', (tester) async {
      await pumpHome(tester);
      expect(connection.hasListener, isTrue);

      await tester.pumpWidget(const SizedBox());

      expect(connection.hasListener, isFalse);
    });

    testWidgets('nome vazio não derruba a página', (tester) async {
      await pumpHome(tester, deviceName: '');

      expect(tester.takeException(), isNull);
      expect(find.text('CONECTADO'), findsOneWidget);
    });
  });
}
