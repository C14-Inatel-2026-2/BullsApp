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
  late BleRepository repository;

  // StreamControllers para as simulações
  late StreamController<List<ScanResult>> rawScanResultsController;
  late StreamController<bool> isScanningController;
  late StreamController<BluetoothConnectionState> connectionStateController;
  late StreamController<String> robotLinesController;
  late StreamController<bool> connectionChangesController;

  setUpAll(() {
    registerFallbackValue(FakeBleDeviceModel());
    
    // A linha que faltava para evitar o erro do "any()" nas Permissões
    registerFallbackValue(Permission.bluetoothScan);
    
    TestWidgetsFlutterBinding.ensureInitialized();
    
    final mockPermission = MockPermissionHandlerPlatform();
    PermissionHandlerPlatform.instance = mockPermission;
    
    when(() => mockPermission.requestPermissions(any())).thenAnswer(
      (invocation) async {
        final perms = invocation.positionalArguments.first as List<Permission>;
        final Map<Permission, PermissionStatus> result = {};
        for (var p in perms) {
          result[p] = PermissionStatus.granted;
        }
        return result;
      }
    );
    
    when(() => mockPermission.checkPermissionStatus(any()))
        .thenAnswer((_) async => PermissionStatus.granted);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_blue_plus/methods'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getBondedDevices') {
          return []; 
        }
        return null;
      },
    );
  });

  setUp(() {
    mockService = MockBleService();
    rawScanResultsController = StreamController<List<ScanResult>>.broadcast();
    isScanningController = StreamController<bool>.broadcast();
    connectionStateController = StreamController<BluetoothConnectionState>.broadcast();
    robotLinesController = StreamController<String>.broadcast();
    connectionChangesController = StreamController<bool>.broadcast();

    when(() => mockService.rawScanResults).thenAnswer((_) => rawScanResultsController.stream);
    when(() => mockService.isScanning).thenAnswer((_) => isScanningController.stream);
    when(() => mockService.robotLines).thenAnswer((_) => robotLinesController.stream);
    when(() => mockService.connectionChanges).thenAnswer((_) => connectionChangesController.stream);
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

  group('BleRepository.isScanning e devicesStream', () {
    test('isScanning repassa o stream do BleService', () async {
      final events = <bool>[];
      final sub = repository.isScanning.listen(events.add);
      
      isScanningController.add(true);
      await Future.delayed(Duration.zero);
      
      expect(events, contains(true));
      await sub.cancel();
    });

    test('devicesStream deve converter e mesclar ScanResults corretamente', () async {
      final mockScanResult = MockScanResult();
      final mockDevice = MockBluetoothDevice();
      final mockAdvData = MockAdvertisementData();

      when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier('00:11:22:33:44:55'));
      when(() => mockDevice.platformName).thenReturn('RobotBull');
      when(() => mockAdvData.advName).thenReturn('RoboAnunciado');
      when(() => mockScanResult.device).thenReturn(mockDevice);
      when(() => mockScanResult.advertisementData).thenReturn(mockAdvData);
      when(() => mockScanResult.rssi).thenReturn(-60);

      final events = <List<BleDeviceModel>>[];
      final sub = repository.devicesStream.listen(events.add);

      rawScanResultsController.add([mockScanResult]);
      await Future.delayed(Duration.zero);

      expect(events, isNotEmpty);
      expect(events.first.first.name, 'RoboAnunciado');
      expect(events.first.first.macAddress, '00:11:22:33:44:55');
      expect(events.first.first.rssi, -60);
      expect(events.first.first.isPaired, isFalse);
      
      await sub.cancel();
    });
  });

  group('BleRepository.startScan e stopScan', () {
    test('startScan chama service.startScan após sucesso nas permissões', () async {
      when(() => mockService.startScan()).thenAnswer((_) async {});

      await repository.startScan();

      verify(() => mockService.startScan()).called(1);
    });

    test('startScan propaga BleException lançada pelo service', () async {
      when(() => mockService.startScan()).thenThrow(const BleException('Bluetooth desligado.'));

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
      when(() => mockService.connectToDevice(mac))
          .thenThrow(const BleException('Falha ao conectar.'));

      final device = makeDevice(mac: mac);

      expect(() => repository.connect(device), throwsA(isA<BleException>()));
    });

    test('disconnect delega para service.disconnect', () async {
      when(() => mockService.disconnect()).thenAnswer((_) async {});

      await repository.disconnect();

      verify(() => mockService.disconnect()).called(1);
    });
    
    test('connectionStateOf mapeia BluetoothConnectionState para BleConnectionState', () async {
      const mac = 'AA:BB:CC:DD:EE:FF';
      final device = makeDevice(mac: mac);
      
      when(() => mockService.connectionStateOf(mac)).thenAnswer((_) => connectionStateController.stream);

      final events = <BleConnectionState>[];
      final sub = repository.connectionStateOf(device).listen(events.add);

      connectionStateController.add(BluetoothConnectionState.connected);
      await Future.delayed(Duration.zero);

      expect(events, contains(BleConnectionState.connected));
      await sub.cancel();
    });
  });

  group('BleRepository.send (RobotCommandPort)', () {
    test('send envia a linha pelo service', () async {
      when(() => mockService.sendLine('D22')).thenAnswer((_) async {});

      await repository.send('D22');

      verify(() => mockService.sendLine('D22')).called(1);
    });

    test('send converte BleException em RobotCommandException', () async {
      when(() => mockService.sendLine(any()))
          .thenThrow(const BleException('Nenhum robô conectado.'));

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
      when(() => mockService.sendLine(any()))
          .thenThrow(Exception('Falha estranha'));

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