import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bullsapp/data/repositories/ble_repository.dart';
import 'package:bullsapp/data/services/saved_devices_service.dart';
import 'package:bullsapp/presentation/controllers/ble_controller.dart';

import '../../mocks/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBleDeviceModel());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'sortDevicesForUI põe os já conectados primeiro e depois o sinal mais forte',
    () {
      final controller = BleController(repository: MockBleRepository());
      final conhecido = makeDevice(mac: 'AA:AA:AA:AA:AA:AA', rssi: -90);
      final forte = makeDevice(mac: 'BB:BB:BB:BB:BB:BB', rssi: -40);
      final fraco = makeDevice(mac: 'CC:CC:CC:CC:CC:CC', rssi: -70);
      controller.knownMacs = ['AA:AA:AA:AA:AA:AA'];

      final ordenados = controller.sortDevicesForUI([fraco, conhecido, forte]);

      expect(ordenados, [conhecido, forte, fraco]);
    },
  );

  test('sortDevicesForUI não altera a lista recebida', () {
    final controller = BleController(repository: MockBleRepository());
    final fraco = makeDevice(mac: 'CC:CC:CC:CC:CC:CC', rssi: -70);
    final forte = makeDevice(mac: 'BB:BB:BB:BB:BB:BB', rssi: -40);
    final lista = [fraco, forte];

    controller.sortDevicesForUI(lista);

    expect(lista, [fraco, forte]);
  });

  test('init carrega os MACs já salvos no aparelho', () async {
    SharedPreferences.setMockInitialValues({
      'saved_ble_macs': ['AA:BB:CC:DD:EE:FF'],
    });
    final repo = MockBleRepository();
    when(() => repo.isScanning).thenAnswer((_) => const Stream.empty());
    when(() => repo.devicesStream).thenAnswer((_) => const Stream.empty());
    final controller = BleController(repository: repo)..init();

    await pumpEventQueue();

    expect(controller.knownMacs, ['AA:BB:CC:DD:EE:FF']);
  });

  test('isScanning acompanha o estado do scan no repositório', () async {
    final scanning = makeScanningController();
    final repo = MockBleRepository();
    when(() => repo.isScanning).thenAnswer((_) => scanning.stream);
    when(() => repo.devicesStream).thenAnswer((_) => const Stream.empty());
    final controller = BleController(repository: repo)..init();

    scanning.add(true);
    await pumpEventQueue();
    expect(controller.isScanning, isTrue);

    scanning.add(false);
    await pumpEventQueue();
    expect(controller.isScanning, isFalse);
    await scanning.close();
  });

  test(
    'nova lista de dispositivos substitui a anterior e limpa o erro',
    () async {
      final devices = makeDevicesController();
      final repo = MockBleRepository();
      when(() => repo.isScanning).thenAnswer((_) => const Stream.empty());
      when(() => repo.devicesStream).thenAnswer((_) => devices.stream);
      final controller = BleController(repository: repo)..init();
      controller.errorMessage = 'erro antigo';
      final robo = makeDevice();

      devices.add([robo]);
      await pumpEventQueue();

      expect(controller.devices, [robo]);
      expect(controller.errorMessage, isNull);
      await devices.close();
    },
  );

  test('startScan limpa a lista e o erro e inicia o scan', () async {
    final repo = MockBleRepository();
    when(() => repo.startScan()).thenAnswer((_) async {});
    final controller = BleController(repository: repo)
      ..devices = [makeDevice()]
      ..errorMessage = 'erro antigo';

    await controller.startScan();

    verify(() => repo.startScan()).called(1);
    expect(controller.devices, isEmpty);
    expect(controller.errorMessage, isNull);
  });
}
