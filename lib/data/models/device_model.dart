/// Representa um dispositivo BLE no contexto do app.
/// Nenhuma outra camada (além de ble_repository.dart) deve conhecer
/// o ScanResult da lib externa
class BleDeviceModel {
  final String name;
  final String macAddress;
  final int rssi;
  final bool isPaired;

  const BleDeviceModel({
    required this.name,
    required this.macAddress,
    required this.rssi,
    this.isPaired = false,
  });

  /// Qualidade do sinal com base no RSSI.
  SignalStrength get signalStrength {
    if (rssi >= -60) return SignalStrength.strong;
    if (rssi >= -80) return SignalStrength.medium;
    return SignalStrength.weak;
  }

  @override
  String toString() =>
      'BleDeviceModel(name: $name, mac: $macAddress, rssi: $rssi dBm)';
}

enum SignalStrength { strong, medium, weak }