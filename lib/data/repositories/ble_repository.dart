import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/device_model.dart';
import '../services/ble_service.dart';

class BleRepository {
  BleRepository({BleService? service}) : _service = service ?? BleService();

  final BleService _service;

  // ── Scan ──────────────────────────────────────────────────────────────────

  /// Combina dispositivos do scan ativo + dispositivos já pareados.
  Stream<List<BleDeviceModel>> get devicesStream =>
      _service.rawScanResults.asyncMap(_convertAndMergeWithBonded);

  Stream<bool> get isScanning => _service.isScanning;

  Future<void> startScan() async {
    await _requestPermissions();
    await _service.startScan();
  }

  Future<void> stopScan() => _service.stopScan();

  // ── Conexão ───────────────────────────────────────────────────────────────

  Future<void> connect(BleDeviceModel device) =>
      _service.connectToDevice(device.macAddress);

  Future<void> disconnect() => _service.disconnect();

  Stream<BleConnectionState> connectionStateOf(BleDeviceModel device) {
    return _service
        .connectionStateOf(device.macAddress)
        .map(_toAppConnectionState);
  }

  // ── Conversões privadas ───────────────────────────────────────────────────

  /// Mescla resultados do scan com dispositivos já pareados (bonded).
  /// Pareados aparecem primeiro, depois os demais por RSSI.
  Future<List<BleDeviceModel>> _convertAndMergeWithBonded(
      List<ScanResult> results,
      ) async {
    final seen = <String>{};
    final models = <BleDeviceModel>[];

    // 1. Dispositivos já pareados (bonded) — Android only
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final bonded = await FlutterBluePlus.bondedDevices;
        for (final d in bonded) {
          final mac = d.remoteId.toString();
          seen.add(mac);
          models.add(BleDeviceModel(
            name: d.platformName.isNotEmpty ? d.platformName : mac,
            macAddress: mac,
            rssi: 0, // RSSI indisponível para pareados fora do scan
            isPaired: true,
          ));
        }
      } catch (_) {
        // bondedDevices pode falhar em algumas versões — ignora
      }
    }

    // 2. Dispositivos encontrados no scan ativo
    for (final r in results) {
      final mac = r.device.remoteId.toString();
      if (seen.contains(mac)) continue; // já está como pareado
      seen.add(mac);
      final name = r.device.platformName.isNotEmpty
          ? r.device.platformName
          : r.advertisementData.advName;
      models.add(BleDeviceModel(
        name: name.isNotEmpty ? name : mac,
        macAddress: mac,
        rssi: r.rssi,
        isPaired: false,
      ));
    }

    // Pareados primeiro, depois por RSSI decrescente
    models.sort((a, b) {
      if (a.isPaired && !b.isPaired) return -1;
      if (!a.isPaired && b.isPaired) return 1;
      return b.rssi.compareTo(a.rssi);
    });

    return models;
  }

  BleConnectionState _toAppConnectionState(BluetoothConnectionState s) {
    return switch (s) {
      BluetoothConnectionState.connected => BleConnectionState.connected,
      BluetoothConnectionState.disconnected => BleConnectionState.disconnected,
    };
  }

  // ── Permissões ────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    // Pede todas as permissões necessárias, incluindo localização
    // (necessária em algumas versões do Android para BLE scan)
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // necessário em Android 10/11
    ].request();

    // No Android 12+, localização não é necessária para o BLE. Ela só é
    // exigida pelo sistema em versões anteriores ao Android 12.
    final bluetoothDenied = [
      statuses[Permission.bluetoothScan],
      statuses[Permission.bluetoothConnect],
    ].any((status) => status?.isDenied == true || status?.isPermanentlyDenied == true);
    if (bluetoothDenied) {
      throw BlePermissionException(
        'Permissões de Bluetooth negadas. Habilite o Bluetooth e as permissões do app nas configurações.',
      );
    }
  }
}

// ── Tipos de domínio ──────────────────────────────────────────────────────────

enum BleConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

class BlePermissionException implements Exception {
  final String message;
  const BlePermissionException(this.message);

  @override
  String toString() => 'BlePermissionException: $message';
}