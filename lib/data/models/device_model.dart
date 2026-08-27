//modelo do dispositivo BLE
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
}