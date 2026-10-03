// Toda a lógica de escaneamento, conexão e canal de comandos BLE.
// Única camada do app que importa flutter_blue_plus.
// Nenhum outro arquivo deve importar essa lib diretamente.

import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/app_constants.dart';
import 'robot_line_decoder.dart';

class BleService {
  // ── Streams internos ─────────────────────────────────────────────────────

  Stream<List<ScanResult>> get rawScanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;

  // ── Dispositivo conectado ─────────────────────────────────────────────────

  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Canal de comandos com o robô (serial sobre BLE).
  BluetoothCharacteristic? _writeChar;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;

  final _lines = StreamController<String>.broadcast();
  late final _decoder = RobotLineDecoder(onLine: _lines.add);

  /// Linhas de texto recebidas do robô, sem o fim de linha.
  Stream<String> get robotLines => _lines.stream;

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> startScan() async {
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      throw BleException('Bluetooth está desligado.');
    }
    if (await FlutterBluePlus.isScanning.first) return;

    await FlutterBluePlus.startScan(
      timeout: AppConstants.bleScanTimeout,
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // ── Conexão ───────────────────────────────────────────────────────────────

  /// Conecta e prepara o canal de comandos. Se o robô não expuser um canal
  /// serial reconhecível, desconecta e lança [BleException].
  Future<void> connectToDevice(String macAddress) async {
    if (_connectedDevice != null) await disconnect();

    final device = BluetoothDevice.fromId(macAddress);
    try {
      await device.connect(
        license: License.nonprofit,
        timeout: AppConstants.bleConnectionTimeout,
      );
      await _openCommandChannel(device);
    } on FlutterBluePlusException catch (e) {
      await _safeDisconnect(device);
      throw BleException('Falha ao conectar: ${e.description}');
    } on BleException {
      await _safeDisconnect(device);
      rethrow;
    } catch (e) {
      await _safeDisconnect(device);
      throw BleException('Falha ao preparar o canal de comandos: $e');
    }

    _connectedDevice = device;

    // Se a conexão cair (robô desligou, saiu do alcance), o canal fica
    // inválido — limpa para o próximo send() falhar com mensagem clara.
    _connectionSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) _closeCommandChannel();
    });
  }

  Future<void> disconnect() async {
    final device = _connectedDevice;
    _closeCommandChannel();
    if (device != null) await device.disconnect();
  }

  Stream<BluetoothConnectionState> connectionStateOf(String macAddress) {
    return BluetoothDevice.fromId(macAddress).connectionState;
  }

  // ── Canal de comandos ─────────────────────────────────────────────────────

  /// Envia uma linha de texto ao robô (o fim de linha é adicionado aqui).
  Future<void> sendLine(String text) async {
    final device = _connectedDevice;
    final char = _writeChar;
    if (device == null || char == null) {
      throw const BleException('Nenhum robô conectado.');
    }

    final bytes = utf8.encode('$text${AppConstants.robotLineTerminator}');
    final withResponse = char.properties.write;
    // Quebra em pacotes do tamanho do MTU (3 bytes são do cabeçalho ATT).
    final chunkSize = (device.mtuNow - 3).clamp(20, 512);

    try {
      for (var i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize).clamp(0, bytes.length);
        await char.write(bytes.sublist(i, end), withoutResponse: !withResponse);
      }
    } on FlutterBluePlusException catch (e) {
      throw BleException('Falha ao enviar comando: ${e.description}');
    }
  }

  Future<void> _openCommandChannel(BluetoothDevice device) async {
    final services = await device.discoverServices();
    final channel = _findSerialChannel(services);
    if (channel == null) {
      throw const BleException(
        'Este dispositivo não tem um canal de comandos compatível. '
        'Confira se é o robô certo.',
      );
    }

    final (writeChar, notifyChar) = channel;
    await notifyChar.setNotifyValue(true);
    // onValueReceived (e não lastValueStream): lastValueStream também emite
    // o que o próprio app escreve, e no HM-10 escrita e notificação são a
    // mesma característica — o terminal mostraria os comandos como resposta.
    _notifySub = notifyChar.onValueReceived.listen(_decoder.add);
    device.cancelWhenDisconnected(_notifySub!);
    _writeChar = writeChar;
  }

  /// Procura primeiro os perfis conhecidos; senão, o primeiro serviço que
  /// tenha uma característica de escrita e uma de notificação.
  (BluetoothCharacteristic, BluetoothCharacteristic)? _findSerialChannel(
    List<BluetoothService> services,
  ) {
    bool canWrite(BluetoothCharacteristic c) =>
        c.properties.write || c.properties.writeWithoutResponse;
    bool canNotify(BluetoothCharacteristic c) =>
        c.properties.notify || c.properties.indicate;

    for (final (serviceId, writeId, notifyId) in AppConstants.robotSerialProfiles) {
      for (final s in services.where((s) => s.uuid == Guid(serviceId))) {
        final write = s.characteristics
            .where((c) => c.uuid == Guid(writeId) && canWrite(c))
            .firstOrNull;
        final notify = s.characteristics
            .where((c) => c.uuid == Guid(notifyId) && canNotify(c))
            .firstOrNull;
        if (write != null && notify != null) return (write, notify);
      }
    }

    // Serviços genéricos do GATT (1800/1801) nunca são o canal do robô.
    final generic = [Guid('1800'), Guid('1801')];
    for (final s in services.where((s) => !generic.contains(s.uuid))) {
      final write = s.characteristics.where(canWrite).firstOrNull;
      final notify = s.characteristics.where(canNotify).firstOrNull;
      if (write != null && notify != null) return (write, notify);
    }
    return null;
  }

  void _closeCommandChannel() {
    _decoder.reset();
    _notifySub?.cancel();
    _notifySub = null;
    _connectionSub?.cancel();
    _connectionSub = null;
    _writeChar = null;
    _connectedDevice = null;
  }

  Future<void> _safeDisconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (_) {
      // já desconectado — nada a fazer
    }
  }
}

class BleException implements Exception {
  final String message;
  const BleException(this.message);

  @override
  String toString() => 'BleException: $message';
}