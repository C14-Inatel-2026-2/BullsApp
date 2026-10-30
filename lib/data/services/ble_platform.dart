// coverage:ignore-file
// Wrapper fino (não-estático) sobre as chamadas estáticas do FlutterBluePlus.
// Existe apenas para permitir injeção/mocks em BleService; não contém lógica.

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BlePlatform {
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Future<void> startScan({Duration? timeout}) =>
      FlutterBluePlus.startScan(timeout: timeout);

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  BluetoothDevice deviceFromId(String macAddress) =>
      BluetoothDevice.fromId(macAddress);
}
