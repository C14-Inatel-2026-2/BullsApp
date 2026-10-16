import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/data/services/ble_service.dart';
import 'package:bullsapp/data/repositories/ble_repository.dart';
import 'package:bullsapp/data/models/device_model.dart';

// ── Service mock ────────────────────────────────────────────────────────────

class MockBleService extends Mock implements BleService {}

// ── Repository mock ─────────────────────────────────────────────────────────

class MockBleRepository extends Mock implements BleRepository {}

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
