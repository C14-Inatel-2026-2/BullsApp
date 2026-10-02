// test/data/models/device_model_test.dart
//
// Testa a lógica pura do BleDeviceModel:
//   - signalStrength categoriza RSSI corretamente
//   - toString formata corretamente
//   - isPaired padrão é false

import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/data/models/device_model.dart';

void main() {
  group('BleDeviceModel.signalStrength', () {
    test('sinal forte: RSSI >= -60', () {
      expect(
        const BleDeviceModel(name: 'R', macAddress: '', rssi: -60).signalStrength,
        SignalStrength.strong,
      );
      expect(
        const BleDeviceModel(name: 'R', macAddress: '', rssi: -30).signalStrength,
        SignalStrength.strong,
      );
    });

    test('sinal médio: -80 <= RSSI < -60', () {
      expect(
        const BleDeviceModel(name: 'R', macAddress: '', rssi: -80).signalStrength,
        SignalStrength.medium,
      );
      expect(
        const BleDeviceModel(name: 'R', macAddress: '', rssi: -70).signalStrength,
        SignalStrength.medium,
      );
    });

    test('sinal fraco: RSSI < -80', () {
      expect(
        const BleDeviceModel(name: 'R', macAddress: '', rssi: -81).signalStrength,
        SignalStrength.weak,
      );
      expect(
        const BleDeviceModel(name: 'R', macAddress: '', rssi: -100).signalStrength,
        SignalStrength.weak,
      );
    });
  });

  group('BleDeviceModel.isPaired', () {
    test('padrão é false', () {
      const device = BleDeviceModel(name: 'Bot', macAddress: 'AA:BB', rssi: -50);
      expect(device.isPaired, isFalse);
    });

    test('pode ser true quando explicitamente definido', () {
      const device = BleDeviceModel(
        name: 'Bot',
        macAddress: 'AA:BB',
        rssi: -50,
        isPaired: true,
      );
      expect(device.isPaired, isTrue);
    });
  });

  group('BleDeviceModel.toString', () {
    test('contém nome, MAC e RSSI', () {
      const device = BleDeviceModel(
        name: 'RobotBull',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        rssi: -55,
      );
      final str = device.toString();
      expect(str, contains('RobotBull'));
      expect(str, contains('AA:BB:CC:DD:EE:FF'));
      expect(str, contains('-55'));
    });
  });
}
