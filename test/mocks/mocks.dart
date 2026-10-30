import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/data/services/ble_service.dart';
import 'package:bullsapp/data/services/ble_platform.dart';
import 'package:bullsapp/data/repositories/ble_repository.dart';
import 'package:bullsapp/data/models/device_model.dart';

// ── Service mock ────────────────────────────────────────────────────────────

class MockBleService extends Mock implements BleService {}

// ── Repository mock ─────────────────────────────────────────────────────────

class MockBleRepository extends Mock implements BleRepository {}

// ── GATT mocks (flutter_blue_plus) ──────────────────────────────────────────

class MockCharacteristic extends Mock implements BluetoothCharacteristic {}

class MockProperties extends Mock implements CharacteristicProperties {}

class MockBlePlatform extends Mock implements BlePlatform {}

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

class MockScanResult extends Mock implements ScanResult {}

/// Cria um [MockBluetoothDevice] com nome e MAC informados.
MockBluetoothDevice makeBluetoothDevice(String name, String mac) {
  final d = MockBluetoothDevice();
  when(() => d.platformName).thenReturn(name);
  when(() => d.remoteId).thenReturn(DeviceIdentifier(mac));
  return d;
}

/// Cria um [MockScanResult] para o dispositivo e RSSI informados.
MockScanResult makeScanResult(String name, String mac, int rssi) {
  final device = makeBluetoothDevice(name, mac);
  final r = MockScanResult();
  when(() => r.device).thenReturn(device);
  when(() => r.rssi).thenReturn(rssi);
  return r;
}

// ── Fake fallbacks (mocktail exige fakes para tipos não-primitivos) ──────────

class FakeBleDeviceModel extends Fake implements BleDeviceModel {}

// ── Helpers ─────────────────────────────────────────────────────────────────

/// Cria um [BleDeviceModel] de teste com valores padrão razoáveis.
BleDeviceModel makeDevice({
  String name = 'RobotBull',
  String mac = 'AA:BB:CC:DD:EE:FF',
  int rssi = -55,
  bool isPaired = false,
}) =>
    BleDeviceModel(
      name: name,
      macAddress: mac,
      rssi: rssi,
      isPaired: isPaired,
    );

/// Stream controller reutilizável para simular [BleRepository.devicesStream].
StreamController<List<BleDeviceModel>> makeDevicesController() =>
    StreamController<List<BleDeviceModel>>.broadcast();

/// Stream controller reutilizável para simular [BleRepository.isScanning].
StreamController<bool> makeScanningController() =>
    StreamController<bool>.broadcast();

/// Cria um [MockCharacteristic] com as propriedades GATT informadas.
MockCharacteristic makeCharacteristic({
  bool read = false,
  bool write = false,
  bool writeWithoutResponse = false,
  bool notify = false,
  bool indicate = false,
}) {
  final props = MockProperties();
  when(() => props.read).thenReturn(read);
  when(() => props.write).thenReturn(write);
  when(() => props.writeWithoutResponse).thenReturn(writeWithoutResponse);
  when(() => props.notify).thenReturn(notify);
  when(() => props.indicate).thenReturn(indicate);

  final c = MockCharacteristic();
  when(() => c.properties).thenReturn(props);
  return c;
}
