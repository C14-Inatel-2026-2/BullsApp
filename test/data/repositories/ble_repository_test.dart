// test/data/repositories/ble_repository_test.dart
//
// Testa BleRepository em isolamento, mockando BleService.
// BleRepository é responsável por:
//   - expor devicesStream (BleDeviceModel) a partir de rawScanResults
//   - delegar startScan/stopScan/connect/disconnect ao BleService
//   - lançar BlePermissionException quando permissões são negadas

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/data/services/ble_service.dart';
import 'package:bullsapp/data/repositories/ble_repository.dart';
import 'package:bullsapp/data/repositories/robot_command_exception.dart';

import '../../mocks/mocks.dart';

ScanResult _makeScanResult({
  required String mac,
  String advName = '',
  String platformName = '',
  int rssi = -60,
}) {
  final device = MockBluetoothDevice();
  when(() => device.remoteId).thenReturn(DeviceIdentifier(mac));
  when(() => device.platformName).thenReturn(platformName);

  final adv = MockAdvertisementData();
  when(() => adv.advName).thenReturn(advName);

  final result = MockScanResult();
  when(() => result.device).thenReturn(device);
  when(() => result.advertisementData).thenReturn(adv);
  when(() => result.rssi).thenReturn(rssi);
  return result;
}

void main() {
  late MockBleService mockService;
  late BleRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeBleDeviceModel());
  });

  setUp(() {
    mockService = MockBleService();
    repository = BleRepository(service: mockService);
  });

  // ── devicesStream ──────────────────────────────────────────────────────────

  group('BleRepository.devicesStream', () {
    test(
      'converte ScanResults usando advName ou platformName, ignora sem nome, '
      'remove MACs duplicados e ordena por RSSI decrescente',
      () async {
        final rFraco = _makeScanResult(
          mac: 'AA:AA:AA:AA:AA:01',
          advName: 'BullFraco',
          rssi: -80,
        );
        final rForte = _makeScanResult(
          mac: 'AA:AA:AA:AA:AA:02',
          advName: '',
          platformName: 'BullForte',
          rssi: -45,
        );
        final rDuplicado = _makeScanResult(
          mac: 'AA:AA:AA:AA:AA:01',
          advName: 'BullFracoDuplicado',
          rssi: -30,
        );
        final rSemNome = _makeScanResult(
          mac: 'AA:AA:AA:AA:AA:03',
          advName: '',
          platformName: '',
          rssi: -20,
        );

        when(() => mockService.rawScanResults).thenAnswer(
          (_) => Stream.value([rFraco, rForte, rDuplicado, rSemNome]),
        );

        final list = await repository.devicesStream.first;

        expect(
          list.map((d) => (d.name, d.macAddress, d.rssi, d.isPaired)).toList(),
          [
            ('BullForte', 'AA:AA:AA:AA:AA:02', -45, false),
            ('BullFraco', 'AA:AA:AA:AA:AA:01', -80, false),
          ],
        );
      },
    );
  });

  // ── isScanning ─────────────────────────────────────────────────────────────

  group('BleRepository.isScanning', () {
    test('repassa o stream do BleService', () async {
      when(
        () => mockService.isScanning,
      ).thenAnswer((_) => Stream.fromIterable([false, true]));

      await expectLater(repository.isScanning, emitsInOrder([false, true]));
    });
  });

  // ── startScan ──────────────────────────────────────────────────────────────

  group('BleRepository.startScan', () {
    test('chama service.startScan quando permissões são concedidas '
        '(plataforma de teste = Linux, sem requisição de permissão)', () async {
      // Em ambiente de teste (Linux), _requestPermissions é no-op.
      when(() => mockService.startScan()).thenAnswer((_) async {});

      await repository.startScan();

      verify(() => mockService.startScan()).called(1);
    });

    test('propaga BleException lançada pelo service', () async {
      when(
        () => mockService.startScan(),
      ).thenThrow(const BleException('Bluetooth desligado.'));

      // BleRepository não trata BleException — ela sobe para o controller.
      await expectLater(repository.startScan(), throwsA(isA<BleException>()));
    });
  });

  // ── stopScan ───────────────────────────────────────────────────────────────

  group('BleRepository.stopScan', () {
    test('delega para service.stopScan', () async {
      when(() => mockService.stopScan()).thenAnswer((_) async {});

      await repository.stopScan();

      verify(() => mockService.stopScan()).called(1);
    });
  });

  // ── connect / disconnect / connectionStateOf ───────────────────────────────

  group('BleRepository.connect', () {
    test('chama connectToDevice com o MAC correto', () async {
      const mac = 'AA:BB:CC:DD:EE:FF';
      when(() => mockService.connectToDevice(mac)).thenAnswer((_) async {});

      final device = makeDevice(mac: mac);
      await repository.connect(device);

      verify(() => mockService.connectToDevice(mac)).called(1);
    });

    test('propaga BleException em falha de conexão', () async {
      const mac = 'AA:BB:CC:DD:EE:FF';

      // 1. Usa thenAnswer com async para simular a falha num Future
      when(
        () => mockService.connectToDevice(mac),
      ).thenAnswer((_) async => throw const BleException('Falha ao conectar.'));

      final device = makeDevice(mac: mac);

      // 2. Envolve a chamada numa função anónima () =>
      await expectLater(
        () => repository.connect(device),
        throwsA(isA<BleException>()),
      );
    });
  });

  group('BleRepository.disconnect', () {
    test('delega para service.disconnect', () async {
      when(() => mockService.disconnect()).thenAnswer((_) async {});

      await repository.disconnect();

      verify(() => mockService.disconnect()).called(1);
    });
  });

  group('BleRepository.connectionStateOf', () {
    test('mapeia BluetoothConnectionState para BleConnectionState', () async {
      const mac = 'AA:BB:CC:DD:EE:FF';
      when(() => mockService.connectionStateOf(mac)).thenAnswer(
        (_) => Stream.fromIterable([
          BluetoothConnectionState.connected,
          BluetoothConnectionState.disconnected,
        ]),
      );

      final device = makeDevice(mac: mac);

      await expectLater(
        repository.connectionStateOf(device),
        emitsInOrder([
          BleConnectionState.connected,
          BleConnectionState.disconnected,
        ]),
      );
    });
  });

  // ── Comandos (RobotCommandPort) ────────────────────────────────────────────

  group('BleRepository.send e estado do canal', () {
    test('repassa isConnected e connectionChanges do BleService', () async {
      when(() => mockService.isConnected).thenReturn(true);
      when(
        () => mockService.connectionChanges,
      ).thenAnswer((_) => Stream.fromIterable([true, false]));

      expect(repository.isConnected, isTrue);
      await expectLater(
        repository.connectionChanges,
        emitsInOrder([true, false]),
      );
    });

    test('envia a linha pelo service', () async {
      when(() => mockService.sendLine('D22')).thenAnswer((_) async {});

      await repository.send('D22');

      verify(() => mockService.sendLine('D22')).called(1);
    });

    test('converte BleException em RobotCommandException', () async {
      when(
        () => mockService.sendLine(any()),
      ).thenThrow(const BleException('Nenhum robô conectado.'));

      await expectLater(
        () => repository.send('STOP'),
        throwsA(
          isA<RobotCommandException>().having(
            (e) => e.message,
            'message',
            'Nenhum robô conectado.',
          ),
        ),
      );
    });

    test('converte erro inesperado em RobotCommandException', () async {
      when(
        () => mockService.sendLine(any()),
      ).thenThrow(StateError('canal fechado'));

      await expectLater(
        () => repository.send('STOP'),
        throwsA(
          isA<RobotCommandException>().having(
            (e) => e.message,
            'message',
            contains('Falha ao enviar comando:'),
          ),
        ),
      );
    });

    test('responses repassa as linhas do robô', () async {
      when(
        () => mockService.robotLines,
      ).thenAnswer((_) => Stream.fromIterable(['sensorD2 vendo', 'OK']));

      await expectLater(
        repository.responses,
        emitsInOrder(['sensorD2 vendo', 'OK', emitsDone]),
      );
    });
  });

  group('BlePermissionException', () {
    test('formata mensagem no toString', () {
      // ignore: prefer_const_constructors
      final ex = BlePermissionException('Permissão negada');
      expect(ex.message, 'Permissão negada');
      expect(ex.toString(), 'BlePermissionException: Permissão negada');
    });
  });
}
