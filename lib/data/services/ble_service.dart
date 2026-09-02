// Única camada do app que importa flutter_blue_plus.
// Nenhum outro arquivo deve importar essa lib diretamente.

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/app_constants.dart';

class BleService {
  // ── Streams internos ─────────────────────────────────────────────────────

  Stream<List<ScanResult>> get rawScanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;

  // ── Dispositivo conectado ─────────────────────────────────────────────────

  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> startScan() async {
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      throw BleException('Bluetooth está desligado.');
    }
    if (await FlutterBluePlus.isScanning.first) return;

    await FlutterBluePlus.startScan(
      timeout: AppConstants.bleScanTimeout,
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // ── Conexão ───────────────────────────────────────────────────────────────

  Future<void> connectToDevice(String macAddress) async {
    final device = BluetoothDevice.fromId(macAddress);
    try {
      await device.connect(
        license: License.nonprofit, // <-- A linha que faltava!
        timeout: AppConstants.bleConnectionTimeout,
      );

      // Garante que o dispositivo fique salvo na memória do Service para uso nas características GATT
      _connectedDevice = device;

    } on FlutterBluePlusException catch (e) {
      throw BleException('Falha ao conectar: ${e.description}');
    }
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
  }

  Stream<BluetoothConnectionState> connectionStateOf(String macAddress) {
    return BluetoothDevice.fromId(macAddress).connectionState;
  }

  // ── GATT ──────────────────────────────────────────────────────────────────

  Future<List<BluetoothService>> discoverServices() async {
    final device = _connectedDevice;
    if (device == null) throw BleException('Nenhum dispositivo conectado.');
    return device.discoverServices();
  }

  Future<List<int>> readCharacteristic(
      BluetoothCharacteristic characteristic,
      ) async {
    if (!characteristic.properties.read) {
      throw BleException('Característica não suporta leitura.');
    }
    return characteristic.read();
  }

  Future<void> writeCharacteristic(
      BluetoothCharacteristic characteristic,
      List<int> data,
      ) async {
    final supportsWrite = characteristic.properties.write ||
        characteristic.properties.writeWithoutResponse;
    if (!supportsWrite) {
      throw BleException('Característica não suporta escrita.');
    }
    await characteristic.write(
      data,
      withoutResponse: characteristic.properties.writeWithoutResponse,
    );
  }

  Future<Stream<List<int>>> subscribeToCharacteristic(
      BluetoothCharacteristic characteristic,
      ) async {
    final supportsNotify = characteristic.properties.notify ||
        characteristic.properties.indicate;
    if (!supportsNotify) {
      throw BleException('Característica não suporta notificações.');
    }
    await characteristic.setNotifyValue(true);
    return characteristic.lastValueStream;
  }
}

class BleException implements Exception {
  final String message;
  const BleException(this.message);

  @override
  String toString() => 'BleException: $message';
}