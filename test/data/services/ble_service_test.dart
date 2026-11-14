import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/core/constants/app_constants.dart';
import 'package:bullsapp/data/services/ble_service.dart';

import '../../mocks/mocks.dart';

class FakeStreamSubscription extends Fake
    implements StreamSubscription<List<int>> {}

CharacteristicProperties _props({
  bool write = false,
  bool writeWithoutResponse = false,
  bool notify = false,
  bool indicate = false,
}) {
  return CharacteristicProperties(
    broadcast: false,
    read: false,
    writeWithoutResponse: writeWithoutResponse,
    write: write,
    notify: notify,
    indicate: indicate,
    authenticatedSignedWrites: false,
    extendedProperties: false,
    notifyEncryptionRequired: false,
    indicateEncryptionRequired: false,
  );
}

MockBluetoothCharacteristic _makeChar(
  String uuid, {
  bool write = false,
  bool writeWithoutResponse = false,
  bool notify = false,
  bool indicate = false,
  Stream<List<int>>? onValueReceived,
}) {
  final char = MockBluetoothCharacteristic();
  when(() => char.uuid).thenReturn(Guid(uuid));
  when(() => char.properties).thenReturn(
    _props(
      write: write,
      writeWithoutResponse: writeWithoutResponse,
      notify: notify,
      indicate: indicate,
    ),
  );
  when(() => char.setNotifyValue(any())).thenAnswer((_) async => true);
  when(
    () => char.onValueReceived,
  ).thenAnswer((_) => onValueReceived ?? const Stream.empty());
  when(
    () => char.write(any(), withoutResponse: any(named: 'withoutResponse')),
  ).thenAnswer((_) async {});
  return char;
}

MockBluetoothService _makeService(
  String uuid,
  List<BluetoothCharacteristic> characteristics,
) {
  final service = MockBluetoothService();
  when(() => service.uuid).thenReturn(Guid(uuid));
  when(() => service.characteristics).thenReturn(characteristics);
  return service;
}

void main() {
  late MockBlePlatform mockPlatform;
  late MockBluetoothDevice mockDevice;
  late BleService bleService;

  const mac = 'AA:BB:CC:DD:EE:FF';

  setUpAll(() {
    registerFallbackValue(License.nonprofit);
    registerFallbackValue(Duration.zero);
    registerFallbackValue(FakeStreamSubscription());
  });

  setUp(() {
    mockPlatform = MockBlePlatform();
    mockDevice = MockBluetoothDevice();
    bleService = BleService(platform: mockPlatform);

    when(() => mockPlatform.deviceFromId(mac)).thenReturn(mockDevice);
    when(
      () => mockDevice.connect(
        license: any(named: 'license'),
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockDevice.disconnect()).thenAnswer((_) async {});
    when(() => mockDevice.cancelWhenDisconnected(any())).thenReturn(null);
    when(
      () => mockDevice.connectionState,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockDevice.mtuNow).thenReturn(23);
  });

  group('BleService - Streams e estado inicial', () {
    test('estado inicial desconectado e streams repassados da plataforma', () {
      when(
        () => mockPlatform.scanResults,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockPlatform.isScanning,
      ).thenAnswer((_) => Stream.value(false));
      when(
        () => mockPlatform.adapterState,
      ).thenAnswer((_) => Stream.value(BluetoothAdapterState.on));

      expect(bleService.isConnected, isFalse);
      expect(bleService.connectedDevice, isNull);
      expect(bleService.rawScanResults, isA<Stream<List<ScanResult>>>());
      expect(bleService.isScanning, isA<Stream<bool>>());
      expect(bleService.adapterState, isA<Stream<BluetoothAdapterState>>());
    });
  });

  group('BleService.startScan / stopScan', () {
    test('inicia scan quando Bluetooth está ligado e não escaneando', () async {
      when(
        () => mockPlatform.adapterState,
      ).thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
      when(
        () => mockPlatform.isScanning,
      ).thenAnswer((_) => Stream.value(false));
      when(
        () => mockPlatform.startScan(
          timeout: any(named: 'timeout'),
          webOptionalServices: any(named: 'webOptionalServices'),
        ),
      ).thenAnswer((_) async {});

      await bleService.startScan();

      verify(
        () => mockPlatform.startScan(
          timeout: AppConstants.bleScanTimeout,
          webOptionalServices: any(named: 'webOptionalServices'),
        ),
      ).called(1);
    });

    test('lança BleException quando Bluetooth está desligado', () async {
      when(
        () => mockPlatform.adapterState,
      ).thenAnswer((_) => Stream.value(BluetoothAdapterState.off));

      await expectLater(
        bleService.startScan(),
        throwsA(isA<BleException>()),
      );
    });

    test('não inicia novo scan se já estiver escaneando', () async {
      when(
        () => mockPlatform.adapterState,
      ).thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
      when(
        () => mockPlatform.isScanning,
      ).thenAnswer((_) => Stream.value(true));

      await bleService.startScan();

      verifyNever(
        () => mockPlatform.startScan(
          timeout: any(named: 'timeout'),
          webOptionalServices: any(named: 'webOptionalServices'),
        ),
      );
    });

    test('stopScan delega para a plataforma', () async {
      when(() => mockPlatform.stopScan()).thenAnswer((_) async {});

      await bleService.stopScan();

      verify(() => mockPlatform.stopScan()).called(1);
    });
  });

  group('BleService.connectToDevice e descoberta de perfil serial', () {
    test('conecta usando perfil conhecido (HM-10 FFE0/FFE1)', () async {
      final char = _makeChar('FFE1', writeWithoutResponse: true, notify: true);
      final service = _makeService('FFE0', [char]);
      when(
        () => mockDevice.discoverServices(),
      ).thenAnswer((_) async => [service]);

      await bleService.connectToDevice(mac);

      expect(bleService.isConnected, isTrue);
      expect(bleService.connectedDevice, same(mockDevice));
      verify(() => char.setNotifyValue(true)).called(1);
    });

    test('usa fallback em serviço não-genérico quando não há perfil conhecido',
        () async {
      final genericChar = _makeChar('2A00', write: true, notify: true);
      final genericService = _makeService('1800', [genericChar]);

      final customWrite = _makeChar('FFF1', write: true);
      final customNotify = _makeChar('FFF2', indicate: true);
      final customService = _makeService(
        'FFF0',
        [customWrite, customNotify],
      );

      when(
        () => mockDevice.discoverServices(),
      ).thenAnswer((_) async => [genericService, customService]);

      await bleService.connectToDevice(mac);

      expect(bleService.isConnected, isTrue);
      verify(() => customNotify.setNotifyValue(true)).called(1);
    });

    test('desconecta e lança BleException se não encontrar canal serial',
        () async {
      final genericChar = _makeChar('2A00', write: true, notify: true);
      final genericService = _makeService('1800', [genericChar]);
      when(
        () => mockDevice.discoverServices(),
      ).thenAnswer((_) async => [genericService]);

      await expectLater(
        bleService.connectToDevice(mac),
        throwsA(isA<BleException>()),
      );

      expect(bleService.isConnected, isFalse);
      verify(() => mockDevice.disconnect()).called(1);
    });

    test('fecha canal automaticamente quando dispositivo desconecta', () async {
      final connController =
          StreamController<BluetoothConnectionState>.broadcast();
      when(
        () => mockDevice.connectionState,
      ).thenAnswer((_) => connController.stream);

      final char = _makeChar('FFE1', write: true, notify: true);
      when(
        () => mockDevice.discoverServices(),
      ).thenAnswer((_) async => [_makeService('FFE0', [char])]);

      await bleService.connectToDevice(mac);
      expect(bleService.isConnected, isTrue);

      connController.add(BluetoothConnectionState.disconnected);
      await Future<void>.delayed(Duration.zero);

      expect(bleService.isConnected, isFalse);
      await connController.close();
    });
  });

  group('BleService.sendLine e robotLines', () {
    test('lança BleException se enviar sem conexão', () async {
      await expectLater(
        bleService.sendLine('STOP'),
        throwsA(isA<BleException>()),
      );
    });

    test('divide comando longo em pacotes respeitando o MTU', () async {
      final char = _makeChar('FFE1', write: true, notify: true);
      when(
        () => mockDevice.discoverServices(),
      ).thenAnswer((_) async => [_makeService('FFE0', [char])]);
      when(() => mockDevice.mtuNow).thenReturn(23); // chunk = 20 bytes

      await bleService.connectToDevice(mac);

      final longCmd = 'A' * 25; // 25 + 1 ('\n') = 26 bytes -> 2 pacotes (20 + 6)
      await bleService.sendLine(longCmd);

      verify(
        () => char.write(
          utf8.encode('A' * 20),
          withoutResponse: false,
        ),
      ).called(1);
      verify(
        () => char.write(
          utf8.encode('${'A' * 5}\n'),
          withoutResponse: false,
        ),
      ).called(1);
    });

    test('decodifica linhas recebidas de onValueReceived em robotLines',
        () async {
      final rxController = StreamController<List<int>>.broadcast();
      final char = _makeChar(
        'FFE1',
        write: true,
        notify: true,
        onValueReceived: rxController.stream,
      );
      when(
        () => mockDevice.discoverServices(),
      ).thenAnswer((_) async => [_makeService('FFE0', [char])]);

      await bleService.connectToDevice(mac);

      final expectation = expectLater(
        bleService.robotLines,
        emitsInOrder(['sensorD2 vendo', 'OK']),
      );

      rxController.add(utf8.encode('sensorD2 '));
      rxController.add(utf8.encode('vendo\r\nOK\n'));

      await expectation;
      await rxController.close();
    });
  });
}
