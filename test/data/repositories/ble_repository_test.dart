// test/data/repositories/ble_repository_test.dart

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:bullsapp/data/services/ble_service.dart';
import 'package:bullsapp/data/repositories/ble_repository.dart';
import 'package:bullsapp/data/repositories/robot_command_exception.dart';
import 'package:bullsapp/data/models/device_model.dart';

import '../../mocks/mocks.dart';

class MockPermissionHandlerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {}

void main() {
  late MockBleService mockService;
  late MockPermissionHandlerPlatform mockPermission;
  late BleRepository repository;

  late StreamController<List<ScanResult>> rawScanResultsController;
  late StreamController<bool> isScanningController;
  late StreamController<BluetoothConnectionState> connectionStateController;
  late StreamController<String> robotLinesController;
  late StreamController<bool> connectionChangesController;

  setUpAll(() {
    registerFallbackValue(FakeBleDeviceModel());
    registerFallbackValue(Permission.bluetoothScan);

    TestWidgetsFlutterBinding.ensureInitialized();

    mockPermission = MockPermissionHandlerPlatform();
    PermissionHandlerPlatform.instance = mockPermission;

    when(() => mockPermission.requestPermissions(any())).thenAnswer((
      invocation,
    ) async {
      final perms = invocation.positionalArguments.first as List<Permission>;
      final Map<Permission, PermissionStatus> result = {};
      for (var p in perms) {
        result[p] = PermissionStatus.granted;
      }
      return result;
    });

    when(
      () => mockPermission.checkPermissionStatus(any()),
    ).thenAnswer((_) async => PermissionStatus.granted);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_blue_plus/methods'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getBondedDevices') return [];
            return null;
          },
        );
  });

  setUp(() {
    mockService = MockBleService();
    rawScanResultsController = StreamController<List<ScanResult>>.broadcast();
    isScanningController = StreamController<bool>.broadcast();
    connectionStateController =
        StreamController<BluetoothConnectionState>.broadcast();
    robotLinesController = StreamController<String>.broadcast();
    connectionChangesController = StreamController<bool>.broadcast();

    when(
      () => mockService.rawScanResults,
    ).thenAnswer((_) => rawScanResultsController.stream);
    when(
      () => mockService.isScanning,
    ).thenAnswer((_) => isScanningController.stream);
    when(
      () => mockService.robotLines,
    ).thenAnswer((_) => robotLinesController.stream);
    when(
      () => mockService.connectionChanges,
    ).thenAnswer((_) => connectionChangesController.stream);
    when(() => mockService.isConnected).thenReturn(true);

    repository = BleRepository(service: mockService);
  });

  tearDown(() {
    rawScanResultsController.close();
    isScanningController.close();
    connectionStateController.close();
    robotLinesController.close();
    connectionChangesController.close();
  });

  group('BleRepository - Construtor', () {
    test('Construtor padrão inicializa BleService implicitamente', () {
      final defaultRepo = BleRepository();
      expect(defaultRepo.isScanning, isNotNull);
    });
  });

  group('BleRepository.isScanning e devicesStream', () {
    test('isScanning repassa o stream do BleService', () async {
      final events = <bool>[];
      final sub = repository.isScanning.listen(events.add);

      isScanningController.add(true);
      await Future.delayed(Duration.zero);

      expect(events, contains(true));
      await sub.cancel();
    });

    test(
      'devicesStream filtra nomes vazios, evita duplicatas e ordena por RSSI',
      () async {
        // Aparelho 1: Normal, RSSI fraco (-80)
        final res1 = MockScanResult();
        final dev1 = MockBluetoothDevice();
        final adv1 = MockAdvertisementData();
        when(
          () => dev1.remoteId,
        ).thenReturn(const DeviceIdentifier('00:00:00:00:00:01'));
        when(() => dev1.platformName).thenReturn('');
        when(() => adv1.advName).thenReturn('Robo1');
        when(() => res1.device).thenReturn(dev1);
        when(() => res1.advertisementData).thenReturn(adv1);
        when(() => res1.rssi).thenReturn(-80);

        // Aparelho 2: Mesmo MAC que o Aparelho 1 (Duplicata - deve ser ignorado)
        final res2 = MockScanResult();
        when(() => res2.device).thenReturn(dev1);
        when(() => res2.advertisementData).thenReturn(adv1);
        when(() => res2.rssi).thenReturn(-60);

        // Aparelho 3: Sem Nome algum (deve ser ignorado)
        final res3 = MockScanResult();
        final dev3 = MockBluetoothDevice();
        final adv3 = MockAdvertisementData();
        when(
          () => dev3.remoteId,
        ).thenReturn(const DeviceIdentifier('00:00:00:00:00:03'));
        when(() => dev3.platformName).thenReturn('');
        when(() => adv3.advName).thenReturn('');
        when(() => res3.device).thenReturn(dev3);
        when(() => res3.advertisementData).thenReturn(adv3);
        when(() => res3.rssi).thenReturn(-50);

        // Aparelho 4: Normal, RSSI forte (-30) (Deve aparecer em 1º lugar na ordenação)
        final res4 = MockScanResult();
        final dev4 = MockBluetoothDevice();
        final adv4 = MockAdvertisementData();
        when(
          () => dev4.remoteId,
        ).thenReturn(const DeviceIdentifier('00:00:00:00:00:04'));
        when(
          () => dev4.platformName,
        ).thenReturn('Robo4'); // Usando platformName ao invés de advName
        when(() => adv4.advName).thenReturn('');
        when(() => res4.device).thenReturn(dev4);
        when(() => res4.advertisementData).thenReturn(adv4);
        when(() => res4.rssi).thenReturn(-30);

        final events = <List<BleDeviceModel>>[];
        final sub = repository.devicesStream.listen(events.add);

        rawScanResultsController.add([res1, res2, res3, res4]);
        await Future.delayed(Duration.zero);

        final resultList = events.first;

        // Foram 4 no total: 1 duplicata removida e 1 sem nome removido = Sobram 2.
        expect(resultList.length, 2);

        // Valida ordenação (RSSI mais forte -30 vem antes do -80)
        expect(resultList[0].name, 'Robo4');
        expect(resultList[0].rssi, -30);

        expect(resultList[1].name, 'Robo1');
        expect(resultList[1].rssi, -80);

        await sub.cancel();
      },
    );
  });

  group('BleRepository.startScan e stopScan', () {
    test('startScan chama service.startScan', () async {
      when(() => mockService.startScan()).thenAnswer((_) async {});
      await repository.startScan();
      verify(() => mockService.startScan()).called(1);
    });

    test('startScan propaga BleException lançada pelo service', () async {
      when(
        () => mockService.startScan(),
      ).thenThrow(const BleException('Bluetooth desligado.'));
      expect(() => repository.startScan(), throwsA(isA<BleException>()));
    });

    test('stopScan delega para service.stopScan', () async {
      when(() => mockService.stopScan()).thenAnswer((_) async {});
      await repository.stopScan();
      verify(() => mockService.stopScan()).called(1);
    });
  });

  group('BleRepository.connect e disconnect', () {
    test('connect chama connectToDevice com o MAC correto', () async {
      const mac = 'AA:BB:CC:DD:EE:FF';
      when(() => mockService.connectToDevice(mac)).thenAnswer((_) async {});

      final device = makeDevice(mac: mac);
      await repository.connect(device);

      verify(() => mockService.connectToDevice(mac)).called(1);
    });

    test('connect propaga BleException em falha de conexão', () async {
      const mac = 'AA:BB:CC:DD:EE:FF';
      when(
        () => mockService.connectToDevice(mac),
      ).thenThrow(const BleException('Falha ao conectar.'));

      final device = makeDevice(mac: mac);
      expect(() => repository.connect(device), throwsA(isA<BleException>()));
    });

    test('disconnect delega para service.disconnect', () async {
      when(() => mockService.disconnect()).thenAnswer((_) async {});
      await repository.disconnect();
      verify(() => mockService.disconnect()).called(1);
    });

    test(
      'connectionStateOf mapeia BluetoothConnectionState para BleConnectionState.connected',
      () async {
        const mac = 'AA:BB:CC:DD:EE:FF';
        final device = makeDevice(mac: mac);

        when(
          () => mockService.connectionStateOf(mac),
        ).thenAnswer((_) => connectionStateController.stream);

        final events = <BleConnectionState>[];
        final sub = repository.connectionStateOf(device).listen(events.add);

        connectionStateController.add(BluetoothConnectionState.connected);
        await Future.delayed(Duration.zero);

        expect(events.last, BleConnectionState.connected);
        await sub.cancel();
      },
    );

    test(
      'connectionStateOf mapeia BluetoothConnectionState para BleConnectionState.disconnected',
      () async {
        const mac = 'AA:BB:CC:DD:EE:FF';
        final device = makeDevice(mac: mac);

        when(
          () => mockService.connectionStateOf(mac),
        ).thenAnswer((_) => connectionStateController.stream);

        final events = <BleConnectionState>[];
        final sub = repository.connectionStateOf(device).listen(events.add);

        // Qualquer estado que não seja "connected" deve mapear para "disconnected"
        connectionStateController.add(BluetoothConnectionState.disconnected);
        await Future.delayed(Duration.zero);

        expect(events.last, BleConnectionState.disconnected);
        await sub.cancel();
      },
    );
  });

  group('BleRepository.send (RobotCommandPort)', () {
    test('send envia a linha pelo service', () async {
      when(() => mockService.sendLine('D22')).thenAnswer((_) async {});
      await repository.send('D22');
      verify(() => mockService.sendLine('D22')).called(1);
    });

    test('send converte BleException em RobotCommandException', () async {
      when(
        () => mockService.sendLine(any()),
      ).thenThrow(const BleException('Nenhum robô conectado.'));

      expect(
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

    test('send converte Exception generica em RobotCommandException', () async {
      when(
        () => mockService.sendLine(any()),
      ).thenThrow(Exception('Falha estranha'));

      expect(
        () => repository.send('STOP'),
        throwsA(isA<RobotCommandException>()),
      );
    });

    test('responses repassa as linhas do robô', () async {
      final events = <String>[];
      final sub = repository.responses.listen(events.add);

      robotLinesController.add('sensorD2 vendo');
      await Future.delayed(Duration.zero);

      expect(events, contains('sensorD2 vendo'));
      await sub.cancel();
    });

    test('isConnected e connectionChanges repassam do service', () async {
      expect(repository.isConnected, isTrue);

      final events = <bool>[];
      final sub = repository.connectionChanges.listen(events.add);

      connectionChangesController.add(false);
      await Future.delayed(Duration.zero);

      expect(events, contains(false));
      await sub.cancel();
    });
  });

  group('Exceções e Classes Utilitárias', () {
    test('BlePermissionException valida formatacao', () {
      const exception = BlePermissionException('Negado');
      expect(exception.message, 'Negado');
      expect(exception.toString(), 'BlePermissionException: Negado');
    });
  });
}
