import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/models/device_model.dart';
import '../../data/repositories/ble_repository.dart';
import '../../data/services/saved_devices_service.dart';

/// Estado da ScanPage gerenciado por ChangeNotifier (Provider).
/// A presentation/ conversa com o BleRepository — nunca com o BleService.
class BleController extends ChangeNotifier {

  // Lista em memória dos MACs conhecidos
  List<String> knownMacs = [];

  Future<void> loadKnownDevices() async {
    knownMacs = await SavedDevicesService.getSavedMacs();
    notifyListeners();
  }

  BleController({BleRepository? repository})
      : _repo = repository ?? BleRepository();

  final BleRepository _repo;

  // ── Estado público ─────────────────────────────────────────────────────
  List<BleDeviceModel> devices = [];
  bool isScanning = false;
  String? errorMessage;

  StreamSubscription<List<BleDeviceModel>>? _devicesSub;
  StreamSubscription<bool>? _scanningSub;

  // ── Inicialização ──────────────────────────────────────────────────────
  void init() {
    loadKnownDevices();

    _scanningSub = _repo.isScanning.listen((scanning) {
      isScanning = scanning;
      notifyListeners();
    });

    _devicesSub = _repo.devicesStream.listen((list) {
      devices = list;
      errorMessage = null;
      notifyListeners();
    });
  }

  // ── Ações ──────────────────────────────────────────────────────────────
  Future<void> startScan() async {
    devices = [];
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.startScan();
    } on BlePermissionException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopScan() => _repo.stopScan();

  Future<bool> connect(BleDeviceModel device) async {
    try {
      await _repo.connect(device);

      // Salva o MAC localmente após a conexão ser bem-sucedida
      await SavedDevicesService.saveDeviceMac(device.macAddress);
      if (!knownMacs.contains(device.macAddress)) {
        knownMacs.add(device.macAddress);
        notifyListeners();
      }

      return true;
    } catch (e) {
      errorMessage = 'Falha ao conectar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() => _repo.disconnect();

  // Função tipada corretamente para BleDeviceModel
  List<BleDeviceModel> sortDevicesForUI(List<BleDeviceModel> scanResults) {
    List<BleDeviceModel> sortedList = List.from(scanResults);

    sortedList.sort((a, b) {
      bool isASaved = knownMacs.contains(a.macAddress);
      bool isBSaved = knownMacs.contains(b.macAddress);

      if (isASaved && !isBSaved) return -1;
      if (!isASaved && isBSaved) return 1;

      return b.rssi.compareTo(a.rssi);
    });

    return sortedList;
  }

  // ── Cleanup ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _devicesSub?.cancel();
    _scanningSub?.cancel();
    _repo.stopScan();
    super.dispose();
  }
}