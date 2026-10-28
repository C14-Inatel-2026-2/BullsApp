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
}
