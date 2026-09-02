import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/device_model.dart';
import '../../data/repositories/ble_repository.dart';

/// Estado da ScanPage gerenciado por ChangeNotifier (Provider).
/// A presentation/ conversa com o BleRepository — nunca com o BleService.
class BleController extends ChangeNotifier {
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
      return true;
    } catch (e) {
      errorMessage = 'Falha ao conectar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() => _repo.disconnect();

  // ── Cleanup ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _devicesSub?.cancel();
    _scanningSub?.cancel();
    _repo.stopScan();
    super.dispose();
  }
}