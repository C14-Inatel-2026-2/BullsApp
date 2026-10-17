import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/sensor_status.dart';
import '../models/sensor_model.dart';

class SensorRepository {
  SensorRepository();

  // TODO: quando os UUIDs do firmware estiverem definidos, trocar
  // _simulatedSensorStream() por uma leitura real via BleService
  // (discoverServices + subscribeToCharacteristic), decodificando os bytes
  // recebidos para List<SensorModel> nesse mesmo método.

  Stream<List<SensorModel>> get sensorsStream => _simulatedSensorStream();

  // ── Implementação simulada (temporária) ──────────────────────────────────

  Stream<List<SensorModel>> _simulatedSensorStream() async* {
    final random = Random();

    while (true) {
      await Future.delayed(const Duration(seconds: 2));

      yield List.generate(6, (index) {
        final statusValues = SensorStatus.values;
        return SensorModel(
          id: '${index + 1}',
          label: 'Sensor ${index + 1}',
          status: statusValues[random.nextInt(statusValues.length)],
          position: _fixedPositions[index],
        );
      });
    }
  }

  // Posições fixas calibradas visualmente (as mesmas que você já calibrou)
  static const _fixedPositions = [
    Alignment(-0.37, -0.15),
    Alignment(-0.29, -0.40),
    Alignment(-0.06, -0.40),
    Alignment(0.06, -0.40),
    Alignment(0.29, -0.40),
    Alignment(0.37, -0.15),
  ];
}