// coverage:ignore-file
// Wrapper fino (não-estático) sobre as chamadas estáticas do FlutterBluePlus,
// do dart:io (Platform) e do permission_handler.
// Existe apenas para permitir injeção/mocks em BleService e BleRepository;
// não contém lógica.

import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<List<BluetoothDevice>> get bondedDevices =>
      FlutterBluePlus.bondedDevices;

  /// true em Linux, Windows e macOS (sem suporte a dispositivos pareados).
  bool get isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  /// true em Android e iOS (plataformas que exigem permissões em runtime).
  bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Solicita as permissões de BLE e retorna o status de cada uma.
  Future<Iterable<PermissionStatus>> requestBlePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // necessário em Android 10/11
    ].request();
    return statuses.values;
  }
}
