// test/data/services/ble_service_test.dart
//
// Testa o BleService REAL. As chamadas estáticas do FlutterBluePlus ficam
// atrás de BlePlatform (injetado), e os mocks vivem em test/mocks/mocks.dart.

import 'dart:async';

import 'package:bullsapp/core/constants/app_constants.dart';
import 'package:bullsapp/data/services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mocks.dart';

void main() {
  late MockBlePlatform platform;
  late BleService service;

  const mac = 'AA:BB:CC:DD:EE:FF';

  setUp(() {
    platform = MockBlePlatform();
    service = BleService(platform: platform);
  });

  /// Conecta o service a um [MockBluetoothDevice] e o retorna.
  Future<MockBluetoothDevice> connect() async {
    final device = MockBluetoothDevice();
    when(() => platform.deviceFromId(mac)).thenReturn(device);
    when(() => device.connect(
          license: License.nonprofit,
          timeout: AppConstants.bleConnectionTimeout,
        )).thenAnswer((_) async {});
    await service.connectToDevice(mac);
    return device;
  }

  group('construtor', () {
    test('cria instância com plataforma padrão', () {
      expect(BleService().connectedDevice, isNull);
    });
  });

  group('BleException', () {
    test('guarda a mensagem', () {
      expect(const BleException('erro').message, 'erro');
    });

    test('toString inclui o prefixo e a mensagem', () {
      expect(const BleException('falhou').toString(), 'BleException: falhou');
    });

    test('implementa Exception', () {
      expect(const BleException('x'), isA<Exception>());
    });
  });

  group('streams', () {
    test('rawScanResults repassa o stream da plataforma', () async {
      when(() => platform.scanResults)
          .thenAnswer((_) => Stream.value(<ScanResult>[]));

      await expectLater(service.rawScanResults, emits(isEmpty));
    });

    test('isScanning repassa o stream da plataforma', () async {
      when(() => platform.isScanning)
          .thenAnswer((_) => Stream.fromIterable([false, true, false]));

      await expectLater(service.isScanning, emitsInOrder([false, true, false]));
    });

    test('adapterState repassa o stream da plataforma', () async {
      when(() => platform.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.on));

      await expectLater(service.adapterState, emits(BluetoothAdapterState.on));
    });
  });

  group('startScan', () {
    test('inicia o scan quando Bluetooth está ON e não está escaneando',
        () async {
      when(() => platform.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
      when(() => platform.isScanning).thenAnswer((_) => Stream.value(false));
      when(() => platform.startScan(timeout: AppConstants.bleScanTimeout))
          .thenAnswer((_) async {});

      await service.startScan();

      verify(() => platform.startScan(timeout: AppConstants.bleScanTimeout))
          .called(1);
    });

    test('lança BleException quando Bluetooth está OFF', () async {
      when(() => platform.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.off));

      await expectLater(service.startScan(), throwsA(isA<BleException>()));
      verifyNever(() => platform.startScan(timeout: any(named: 'timeout')));
    });

    test('não inicia o scan quando já está escaneando', () async {
      when(() => platform.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
      when(() => platform.isScanning).thenAnswer((_) => Stream.value(true));

      await service.startScan();

      verifyNever(() => platform.startScan(timeout: any(named: 'timeout')));
    });
  });

  group('stopScan', () {
    test('chama stopScan na plataforma', () async {
      when(() => platform.stopScan()).thenAnswer((_) async {});

      await service.stopScan();

      verify(() => platform.stopScan()).called(1);
    });
  });

  group('connectToDevice', () {
    test('conecta e guarda o dispositivo', () async {
      final device = await connect();

      expect(service.connectedDevice, same(device));
    });

    test('lança BleException quando a conexão falha', () async {
      final device = MockBluetoothDevice();
      when(() => platform.deviceFromId(mac)).thenReturn(device);
      when(() => device.connect(
            license: License.nonprofit,
            timeout: AppConstants.bleConnectionTimeout,
          )).thenThrow(
        FlutterBluePlusException(ErrorPlatform.fbp, 'connect', 1, 'timeout'),
      );

      await expectLater(
        service.connectToDevice(mac),
        throwsA(
          isA<BleException>().having(
            (e) => e.message,
            'message',
            contains('Falha ao conectar'),
          ),
        ),
      );
      expect(service.connectedDevice, isNull);
    });
  });

  group('disconnect', () {
    test('sem dispositivo conectado não lança e mantém null', () async {
      await service.disconnect();

      expect(service.connectedDevice, isNull);
    });

    test('desconecta o dispositivo e limpa a referência', () async {
      final device = await connect();
      when(() => device.disconnect()).thenAnswer((_) async {});

      await service.disconnect();

      verify(() => device.disconnect()).called(1);
      expect(service.connectedDevice, isNull);
    });
  });

  group('connectionStateOf', () {
    test('repassa o connectionState do dispositivo', () async {
      final device = MockBluetoothDevice();
      when(() => platform.deviceFromId(mac)).thenReturn(device);
      when(() => device.connectionState).thenAnswer(
          (_) => Stream.value(BluetoothConnectionState.connected));

      await expectLater(
        service.connectionStateOf(mac),
        emits(BluetoothConnectionState.connected),
      );
    });
  });

  group('discoverServices', () {
    test('lança BleException quando nenhum dispositivo está conectado',
        () async {
      await expectLater(
        service.discoverServices(),
        throwsA(
          isA<BleException>().having(
            (e) => e.message,
            'message',
            'Nenhum dispositivo conectado.',
          ),
        ),
      );
    });

    test('retorna os serviços do dispositivo conectado', () async {
      final device = await connect();
      when(() => device.discoverServices())
          .thenAnswer((_) async => <BluetoothService>[]);

      final result = await service.discoverServices();

      expect(result, isEmpty);
      verify(() => device.discoverServices()).called(1);
    });
  });

  group('readCharacteristic', () {
    test('lança BleException quando não suporta leitura', () async {
      final c = makeCharacteristic(read: false);

      await expectLater(
        service.readCharacteristic(c),
        throwsA(isA<BleException>()),
      );
      verifyNever(() => c.read());
    });

    test('retorna os bytes lidos quando suporta leitura', () async {
      final c = makeCharacteristic(read: true);
      when(() => c.read()).thenAnswer((_) async => [1, 2, 3]);

      expect(await service.readCharacteristic(c), [1, 2, 3]);
      verify(() => c.read()).called(1);
    });
  });

  group('writeCharacteristic', () {
    test('lança BleException quando não suporta escrita', () async {
      final c = makeCharacteristic();

      await expectLater(
        service.writeCharacteristic(c, [1]),
        throwsA(isA<BleException>()),
      );
      verifyNever(() =>
          c.write(any(), withoutResponse: any(named: 'withoutResponse')));
    });

    test('escreve com resposta quando suporta write', () async {
      final c = makeCharacteristic(write: true);
      when(() => c.write(any(), withoutResponse: any(named: 'withoutResponse')))
          .thenAnswer((_) async {});

      await service.writeCharacteristic(c, [10, 20]);

      verify(() => c.write([10, 20], withoutResponse: false)).called(1);
    });

    test('escreve sem resposta quando suporta writeWithoutResponse', () async {
      final c = makeCharacteristic(writeWithoutResponse: true);
      when(() => c.write(any(), withoutResponse: any(named: 'withoutResponse')))
          .thenAnswer((_) async {});

      await service.writeCharacteristic(c, [7]);

      verify(() => c.write([7], withoutResponse: true)).called(1);
    });
  });

  group('subscribeToCharacteristic', () {
    test('lança BleException quando não suporta notify nem indicate',
        () async {
      final c = makeCharacteristic();

      await expectLater(
        service.subscribeToCharacteristic(c),
        throwsA(isA<BleException>()),
      );
      verifyNever(() => c.setNotifyValue(any()));
    });

    test('ativa notificações e retorna lastValueStream (notify)', () async {
      final c = makeCharacteristic(notify: true);
      when(() => c.setNotifyValue(any())).thenAnswer((_) async => true);
      when(() => c.lastValueStream).thenAnswer((_) => Stream.fromIterable([
            [1],
            [2],
          ]));

      final result = await service.subscribeToCharacteristic(c);

      verify(() => c.setNotifyValue(true)).called(1);
      await expectLater(
        result,
        emitsInOrder([
          [1],
          [2],
        ]),
      );
    });

    test('aceita característica com indicate', () async {
      final c = makeCharacteristic(indicate: true);
      when(() => c.setNotifyValue(any())).thenAnswer((_) async => true);
      when(() => c.lastValueStream)
          .thenAnswer((_) => const Stream<List<int>>.empty());

      final result = await service.subscribeToCharacteristic(c);

      expect(result, isA<Stream<List<int>>>());
      verify(() => c.setNotifyValue(true)).called(1);
    });
  });
}
