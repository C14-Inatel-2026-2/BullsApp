// test/data/repositories/ble_repository_test.dart
//
// Testa BleRepository em isolamento, mockando BleService.
// BleRepository é responsável por:
//   - expor devicesStream (BleDeviceModel) a partir de rawScanResults
//   - delegar startScan/stopScan/connect/disconnect ao BleService
//   - lançar BlePermissionException quando permissões são negadas

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullsapp/data/services/ble_service.dart';
import 'package:bullsapp/data/repositories/ble_repository.dart';
import 'package:bullsapp/data/models/device_model.dart';

import '../../mocks/mocks.dart';

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

  // ── isScanning ─────────────────────────────────────────────────────────────

  group('BleRepository.isScanning', () {
    test('repassa o stream do BleService', () async {
      when(() => mockService.isScanning)
          .thenAnswer((_) => Stream.fromIterable([false, true]));

      await expectLater(
        repository.isScanning,
        emitsInOrder([false, true]),
      );
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
      when(() => mockService.startScan())
          .thenThrow(const BleException('Bluetooth desligado.'));

      // BleRepository não trata BleException — ela sobe para o controller.
      await expectLater(
        repository.startScan(),
        throwsA(isA<BleException>()),
      );
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

  // ── connect ────────────────────────────────────────────────────────────────

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
      when(() => mockService.connectToDevice(mac))
          .thenAnswer((_) async => throw const BleException('Falha ao conectar.'));

      final device = makeDevice(mac: mac);

      // 2. Envolve a chamada numa função anónima () =>
      await expectLater(
            () => repository.connect(device),
        throwsA(isA<BleException>()),
      );
    });
  });

  // ── disconnect ─────────────────────────────────────────────────────────────

  group('BleRepository.disconnect', () {
    test('delega para service.disconnect', () async {
      when(() => mockService.disconnect()).thenAnswer((_) async {});

      await repository.disconnect();

      verify(() => mockService.disconnect()).called(1);
    });
  });
}
