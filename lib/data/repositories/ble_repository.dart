import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/device_model.dart';
import '../services/ble_platform.dart';
import '../services/ble_service.dart';

class BleRepository {
  BleRepository({BleService? service, BlePlatform? platform})
      : _platform = platform ?? BlePlatform(),
        _service = service ?? BleService();

  final BleService _service;
  final BlePlatform _platform;

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

  // ── Comandos (RobotCommandPort) ───────────────────────────────────────────

  @override
  Stream<String> get responses => _service.robotLines;

  @override
  bool get isConnected => _service.isConnected;

  @override
  Stream<bool> get connectionChanges => _service.connectionChanges;

  @override
  Future<void> send(String command) async {
    try {
      await _service.sendLine(command);
    } on BleException catch (e) {
      throw RobotCommandException(e.message);
    } catch (e) {
      throw RobotCommandException('Falha ao enviar comando: $e');
    }
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
    if (!_platform.isDesktop) {
      try {
        final bonded = await _platform.bondedDevices;
        for (final d in bonded) {
          if (d.platformName.isEmpty) continue; // ignora sem nome
          final mac = d.remoteId.toString();
          seen.add(mac);
          models.add(
            BleDeviceModel(
              name: d.platformName,
              macAddress: mac,
              rssi: 0, // RSSI indisponível para pareados fora do scan
              isPaired: true,
            ),
          );
        }
      } catch (_) {
        // bondedDevices pode falhar em algumas versões — ignora
      }
    }

    // 2. Dispositivos encontrados no scan ativo
    for (final r in results) {
      final mac = r.device.remoteId.toString();
      if (seen.contains(mac)) continue; // já está como pareado
      // platformName vem do cache do sistema e costuma vir vazio para
      // dispositivos nunca pareados; o nome anunciado vem em advName.
      final name = r.advertisementData.advName.isNotEmpty
          ? r.advertisementData.advName
          : r.device.platformName;
      if (name.isEmpty) continue; // ignora sem nome
      seen.add(mac);
      models.add(
        BleDeviceModel(
          name: name,
          macAddress: mac,
          rssi: r.rssi,
          isPaired: false,
        ),
      );
    }

    // Pareados primeiro, depois por RSSI decrescente
    int rank(BleDeviceModel d) => d.isPaired ? 0 : 1;
    return models..sort((a, b) {
      final byPaired = rank(a).compareTo(rank(b));
      return byPaired != 0 ? byPaired : b.rssi.compareTo(a.rssi);
    });
  }

  BleConnectionState _toAppConnectionState(BluetoothConnectionState s) {
    return s == BluetoothConnectionState.connected
        ? BleConnectionState.connected
        : BleConnectionState.disconnected;
  }

  // ── Permissões ────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    if (!_platform.isMobile) return;
    // No navegador quem pede permissão é o próprio Chrome, no seletor do scan.
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    // Pede todas as permissões necessárias, incluindo localização
    // (necessária em algumas versões do Android para BLE scan)
    final statuses = await _platform.requestBlePermissions();

    final denied =
    statuses.any((s) => s.isDenied || s.isPermanentlyDenied);
    if (denied) {
      throw BlePermissionException(
        'Permissões de Bluetooth negadas. Habilite nas configurações do app.',
      );
    }
  }
}

// ── Tipos de domínio ──────────────────────────────────────────────────────────

enum BleConnectionState { disconnected, connecting, connected, disconnecting }

class BlePermissionException implements Exception {
  final String message;
  const BlePermissionException(this.message);

  @override
  String toString() => 'BlePermissionException: $message';
}
