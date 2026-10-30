// test/data/repositories/ble_repository_test.dart
//
// Testa BleRepository em isolamento, mockando BleService e BlePlatform.
// BleRepository é responsável por:
//   - expor devicesStream (BleDeviceModel) a partir de rawScanResults,
//     mesclando dispositivos pareados (bonded) e resultados do scan
//   - delegar startScan/stopScan/connect/disconnect ao BleService
//   - converter o estado de conexão para BleConnectionState
//   - lançar BlePermissionException quando permissões são negadas

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bullsapp/data/services/ble_service.dart';
import 'package:bullsapp/data/repositories/ble_repository.dart';

import '../../mocks/mocks.dart';

void main() {
  late MockBleService mockService;
  late MockBlePlatform mockPlatform;
  late BleRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeBleDeviceModel());
  });

  setUp(() {
    mockService = MockBleService();
    mockPlatform = MockBlePlatform();
    // Padrão: desktop (sem bonded e sem permissões em runtime).
    when(() => mockPlatform.isDesktop).thenReturn(true);
    when(() => mockPlatform.isMobile).thenReturn(false);
    repository = BleRepository(service: mockService, platform: mockPlatform);
  });

  // ── construtor ─────────────────────────────────────────────────────────────

  group('BleRepository construtor', () {
    test('cria instância com service e platform padrão', () {
      expect(BleRepository(), isA<BleRepository>());
    });
  });

  // ── BlePermissionException ─────────────────────────────────────────────────

  group('BlePermissionException', () {
    test('guarda a mensagem e formata o toString', () {
      const e = BlePermissionException('negado');

      expect(e.message, 'negado');
      expect(e.toString(), 'BlePermissionException: negado');
      expect(e, isA<Exception>());
    });
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
    test('chama service.startScan sem pedir permissões em desktop', () async {
      when(() => mockService.startScan()).thenAnswer((_) async {});

      await repository.startScan();

      verifyNever(() => mockPlatform.requestBlePermissions());
      verify(() => mockService.startScan()).called(1);
    });

    test('chama service.startScan quando permissões são concedidas (mobile)',
        () async {
      when(() => mockPlatform.isMobile).thenReturn(true);
      when(() => mockPlatform.requestBlePermissions()).thenAnswer(
        (_) async => [PermissionStatus.granted, PermissionStatus.granted],
      );
      when(() => mockService.startScan()).thenAnswer((_) async {});

      await repository.startScan();

      verify(() => mockPlatform.requestBlePermissions()).called(1);
      verify(() => mockService.startScan()).called(1);
    });

    test('lança BlePermissionException quando alguma permissão é negada',
        () async {
      when(() => mockPlatform.isMobile).thenReturn(true);
      when(() => mockPlatform.requestBlePermissions()).thenAnswer(
        (_) async => [PermissionStatus.granted, PermissionStatus.denied],
      );

      await expectLater(
        repository.startScan(),
        throwsA(isA<BlePermissionException>()),
      );
      verifyNever(() => mockService.startScan());
    });

    test('lança BlePermissionException quando negada permanentemente',
        () async {
      when(() => mockPlatform.isMobile).thenReturn(true);
      when(() => mockPlatform.requestBlePermissions()).thenAnswer(
        (_) async => [PermissionStatus.permanentlyDenied],
      );

      await expectLater(
        repository.startScan(),
        throwsA(isA<BlePermissionException>()),
      );
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

  // ── connectionStateOf ──────────────────────────────────────────────────────

  group('BleRepository.connectionStateOf', () {
    test('converte o estado do service para BleConnectionState', () async {
      const mac = 'AA:BB:CC:DD:EE:FF';
      when(() => mockService.connectionStateOf(mac)).thenAnswer(
        (_) => Stream.fromIterable([
          BluetoothConnectionState.connected,
          BluetoothConnectionState.disconnected,
        ]),
      );

      await expectLater(
        repository.connectionStateOf(makeDevice(mac: mac)),
        emitsInOrder([
          BleConnectionState.connected,
          BleConnectionState.disconnected,
        ]),
      );
    });
  });

  // ── devicesStream ──────────────────────────────────────────────────────────

  group('BleRepository.devicesStream', () {
    void stubScan(List<ScanResult> results) {
      when(() => mockService.rawScanResults)
          .thenAnswer((_) => Stream.value(results));
    }

    test('em desktop converte apenas os resultados do scan', () async {
      stubScan([makeScanResult('Bull', 'AA:01', -50)]);

      final list = await repository.devicesStream.first;

      verifyNever(() => mockPlatform.bondedDevices);
      expect(list, hasLength(1));
      expect(list.first.name, 'Bull');
      expect(list.first.macAddress, 'AA:01');
      expect(list.first.rssi, -50);
      expect(list.first.isPaired, isFalse);
    });

    test('ignora dispositivos do scan sem nome', () async {
      stubScan([
        makeScanResult('', 'AA:01', -50),
        makeScanResult('Bull', 'AA:02', -60),
      ]);

      final list = await repository.devicesStream.first;

      expect(list.map((d) => d.macAddress), ['AA:02']);
    });

    test('ordena o scan por RSSI decrescente', () async {
      stubScan([
        makeScanResult('Fraco', 'AA:01', -90),
        makeScanResult('Forte', 'AA:02', -40),
        makeScanResult('Medio', 'AA:03', -70),
      ]);

      final list = await repository.devicesStream.first;

      expect(list.map((d) => d.name), ['Forte', 'Medio', 'Fraco']);
    });

    test('em mobile inclui pareados primeiro, sem duplicar com o scan',
        () async {
      final bonded = [
        makeBluetoothDevice('Pareado', 'BB:01'),
        makeBluetoothDevice('', 'BB:02'), // sem nome: ignorado
      ];
      when(() => mockPlatform.isDesktop).thenReturn(false);
      when(() => mockPlatform.bondedDevices).thenAnswer((_) async => bonded);
      stubScan([
        makeScanResult('Forte', 'AA:01', -30),
        makeScanResult('Pareado', 'BB:01', -20), // duplicado do bonded
      ]);

      final list = await repository.devicesStream.first;

      expect(list.map((d) => d.macAddress), ['BB:01', 'AA:01']);
      expect(list.first.isPaired, isTrue);
      expect(list.first.rssi, 0);
      expect(list.last.isPaired, isFalse);
    });

    test('ordena corretamente muitos pareados e não pareados misturados',
        () async {
      final bonded = [
        for (var i = 0; i < 40; i++) makeBluetoothDevice('P$i', 'BB:$i'),
      ];
      when(() => mockPlatform.isDesktop).thenReturn(false);
      when(() => mockPlatform.bondedDevices).thenAnswer((_) async => bonded);
      stubScan([
        for (var i = 0; i < 40; i++)
          makeScanResult('S$i', 'AA:$i', -(i * 7 % 41) - 10),
      ]);

      final list = await repository.devicesStream.first;

      expect(list, hasLength(80));
      expect(list.take(40).every((d) => d.isPaired), isTrue);
      expect(list.skip(40).every((d) => !d.isPaired), isTrue);
      final rssis = list.skip(40).map((d) => d.rssi).toList();
      expect(rssis, [...rssis]..sort((a, b) => b.compareTo(a)));
    });

    test('ignora falha ao obter bondedDevices e segue com o scan', () async {
      when(() => mockPlatform.isDesktop).thenReturn(false);
      when(() => mockPlatform.bondedDevices).thenThrow(Exception('falhou'));
      stubScan([makeScanResult('Bull', 'AA:01', -50)]);

      final list = await repository.devicesStream.first;

      expect(list.map((d) => d.macAddress), ['AA:01']);
    });
  });
}
