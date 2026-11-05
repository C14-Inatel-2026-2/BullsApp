import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullsapp/data/models/device_model.dart';
import 'package:bullsapp/data/repositories/ble_repository.dart';
import 'package:bullsapp/data/repositories/fake_robot_command_port.dart';
import 'package:bullsapp/data/repositories/robot_command_port.dart';
import 'package:bullsapp/presentation/pages/home_page.dart';
import 'package:bullsapp/presentation/pages/mod_page.dart';
import 'package:bullsapp/presentation/pages/scan_page.dart';
import 'package:bullsapp/presentation/pages/test_page.dart';

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
    when(
      () => repo.connectionStateOf(any()),
    ).thenAnswer((_) => connection.stream);
  });

  // Sem await: num stream já fechado dentro do fake async do testWidgets,
  // o Future de close() nunca completa e o tearDown trava.
  tearDown(() => unawaited(connection.close()));

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

    testWidgets('mostra DESCONECTADO quando começa desconectado', (
      tester,
    ) async {
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
    testWidgets('erro no stream de conexão não derruba a página', (
      tester,
    ) async {
      await pumpHome(tester);

      connection.addError(Exception('Bluetooth desligado'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('CONECTADO'), findsOneWidget);
    });

    testWidgets('stream que fecha sem emitir nada não muda o status', (
      tester,
    ) async {
      await pumpHome(tester);

      unawaited(connection.close());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('CONECTADO'), findsOneWidget);
    });

    testWidgets('para de ouvir a conexão quando a página é destruída', (
      tester,
    ) async {
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

  group('HomePage - navegação', () {
    Future<void> pumpWithProviders(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<BleRepository>.value(value: repo),
            Provider<RobotCommandPort>.value(
              value: FakeRobotCommandPort(latency: Duration.zero),
            ),
          ],
          child: const MaterialApp(
            home: HomePage(
              deviceName: 'Bull',
              isConnected: true,
              device: fakeDevice,
            ),
          ),
        ),
      );
    }

    Future<void> tapLabel(WidgetTester tester, String label) async {
      await tester.tap(find.textContaining(label, findRichText: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('COMBATE abre a ModPage', (tester) async {
      await pumpWithProviders(tester);

      await tapLabel(tester, 'COMBATE');

      expect(find.byType(ModPage), findsOneWidget);
    });

    testWidgets('TESTAR abre a TestPage', (tester) async {
      await pumpWithProviders(tester);

      await tapLabel(tester, 'TESTAR');

      expect(find.byType(TestPage), findsOneWidget);
    });

    testWidgets('queda da conexão fecha as telas abertas', (tester) async {
      await pumpWithProviders(tester);
      await tapLabel(tester, 'TESTAR');

      connection.add(BleConnectionState.disconnected);
      await tester.pumpAndSettle();

      expect(find.byType(TestPage), findsNothing);
      expect(find.text('DESCONECTADO'), findsOneWidget);
    });

    testWidgets('DESCONECTAR desconecta e volta para o scan', (tester) async {
      SharedPreferences.setMockInitialValues({});
      when(() => repo.disconnect()).thenAnswer((_) async {});
      when(() => repo.stopScan()).thenAnswer((_) async {});
      when(() => repo.isScanning).thenAnswer((_) => const Stream.empty());
      when(() => repo.devicesStream).thenAnswer((_) => const Stream.empty());
      await pumpWithProviders(tester);

      await tester.tap(find.textContaining('DESCONECTAR', findRichText: true));
      // O Future de cancel() da assinatura pertence à zona raiz: só completa
      // cedendo ao event loop real, fora do tempo falso do testWidgets.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(() => repo.disconnect()).called(1);
      expect(find.byType(ScanPage), findsOneWidget);
    });
  });
}
