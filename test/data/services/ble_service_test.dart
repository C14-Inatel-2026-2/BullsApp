// test/data/services/ble_service_test.dart
//
// Testa BleService usando o padrão de wrapper mockável descrito no guia
// MOCKING(1).md. Como FlutterBluePlus usa chamadas estáticas, criamos
// FlutterBluePlusMockable (wrapper não-estático) e fazemos mock dele.

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Wrapper mockável (conforme o guia) ──────────────────────────────────────

/// Encapsula todas as chamadas estáticas de [FlutterBluePlus].
/// Em produção, [BleService] usaria esta classe em vez de chamar
/// FlutterBluePlus diretamente; nos testes usamos o mock abaixo.
class FlutterBluePlusMockable {
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;

  Future<void> startScan({
    List<Guid> withServices = const [],
    Duration? timeout,
    Duration? removeIfGone,
    bool oneByOne = false,
    bool androidUsesFineLocation = false,
  }) =>
      FlutterBluePlus.startScan(
        withServices: withServices,
        timeout: timeout,
        removeIfGone: removeIfGone,
        oneByOne: oneByOne,
        androidUsesFineLocation: androidUsesFineLocation,
      );

  Future<void> stopScan() => FlutterBluePlus.stopScan();
}

// ── Mock do wrapper ──────────────────────────────────────────────────────────

class MockFlutterBluePlus extends Mock implements FlutterBluePlusMockable {}

// ── BleService adaptado para injeção (versão testável) ──────────────────────

/// Versão de [BleService] que aceita [FlutterBluePlusMockable] por injeção,
/// permitindo testes unitários sem hardware BLE real.
class TestableBleService {
  TestableBleService(this._fbp);

  final FlutterBluePlusMockable _fbp;

  Stream<List<ScanResult>> get rawScanResults => _fbp.scanResults;
  Stream<bool> get isScanning => _fbp.isScanning;

  Future<void> startScan() async {
    final state = await _fbp.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      throw BleTestException('Bluetooth está desligado.');
    }
    if (await _fbp.isScanning.first) return;
    await _fbp.startScan();
  }

  Future<void> stopScan() => _fbp.stopScan();
}

class BleTestException implements Exception {
  final String message;
  const BleTestException(this.message);
  @override
  String toString() => 'BleTestException: $message';
}

// ── Testes ───────────────────────────────────────────────────────────────────

void main() {
  late MockFlutterBluePlus mockFbp;
  late TestableBleService service;

  setUp(() {
    mockFbp = MockFlutterBluePlus();
    service = TestableBleService(mockFbp);
  });

  group('BleService.startScan', () {
    test('chama startScan quando Bluetooth está ON e não está escaneando', () async {
      // Arrange
      when(() => mockFbp.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
      when(() => mockFbp.isScanning)
          .thenAnswer((_) => Stream.value(false));
      when(() => mockFbp.startScan()).thenAnswer((_) async {});

      // Act
      await service.startScan();

      // Assert
      verify(() => mockFbp.startScan()).called(1);
    });

    test('lança BleTestException quando Bluetooth está OFF', () async {
      // Arrange
      when(() => mockFbp.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.off));
      when(() => mockFbp.isScanning)
          .thenAnswer((_) => Stream.value(false));

      // Act & Assert
      await expectLater(
        service.startScan(),
        throwsA(isA<BleTestException>()),
      );
      verifyNever(() => mockFbp.startScan());
    });

    test('não chama startScan quando já está escaneando', () async {
      // Arrange
      when(() => mockFbp.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
      when(() => mockFbp.isScanning)
          .thenAnswer((_) => Stream.value(true)); // já escaneando

      // Act
      await service.startScan();

      // Assert
      verifyNever(() => mockFbp.startScan());
    });
  });

  group('BleService.stopScan', () {
    test('chama stopScan no wrapper', () async {
      // Arrange
      when(() => mockFbp.stopScan()).thenAnswer((_) async {});

      // Act
      await service.stopScan();

      // Assert
      verify(() => mockFbp.stopScan()).called(1);
    });
  });

  group('BleService streams', () {
    test('rawScanResults repassa o stream do wrapper', () async {
      // Arrange: Cria o controlador como broadcast (padrão de eventos nativos)
      final controller = StreamController<List<ScanResult>>.broadcast();
      when(() => mockFbp.scanResults).thenAnswer((_) => controller.stream);

      // Act
      final stream = service.rawScanResults;

      // 1. Registra a expectativa ANTES de disparar o evento
      // 2. Usa isEmpty no lugar de []
      final expectation = expectLater(
        stream,
        emits(isEmpty),
      );

      // Dispara o evento e fecha o fluxo
      controller.add([]);
      await controller.close();

      // Aguarda a resolução da asserção
      await expectation;
    });

    test('isScanning repassa o stream do wrapper', () async {
      // Arrange
      when(() => mockFbp.isScanning)
          .thenAnswer((_) => Stream.fromIterable([false, true, false]));

      // Act & Assert
      await expectLater(
        service.isScanning,
        emitsInOrder([false, true, false]),
      );
    });
  });
}
