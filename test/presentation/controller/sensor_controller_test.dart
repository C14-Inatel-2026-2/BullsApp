import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bullsapp/data/models/sensor_model.dart';
import 'package:bullsapp/data/models/sensor_status.dart';
import 'package:bullsapp/data/repositories/sensor_repository.dart';
import 'package:bullsapp/presentation/controllers/sensor_controller.dart';

class MockSensorRepository extends Mock implements SensorRepository {}

void main() {
  late MockSensorRepository repo;
  late StreamController<List<SensorModel>> stream;
  late SensorController controller;

  setUp(() {
    repo = MockSensorRepository();
    stream = StreamController<List<SensorModel>>.broadcast();
    when(() => repo.sensorsStream).thenAnswer((_) => stream.stream);
    controller = SensorController(repository: repo);
  });

  tearDown(() => stream.close());

  // testes aqui
  group('SensorController - dados mockados', () {
    test('atualiza sensors e notifica quando o stream emite', () async {
      // Arrange
      const lista = [
        SensorModel(
          id: '1',
          label: 'Sensor 1',
          status: SensorStatus.vendo,
          position: Alignment(0, 0),
        ),
        SensorModel(
          id: '2',
          label: 'Sensor 2',
          status: SensorStatus.cego,
          position: Alignment(0.5, 0.5),
        ),
      ];
      var notificacoes = 0;
      controller.addListener(() => notificacoes++);
      controller.init();

      // Act
      stream.add(lista);
      await Future.delayed(Duration.zero); // deixa o evento chegar

      // Assert
      expect(controller.sensors, equals(lista));
      expect(notificacoes, 1);

      controller.dispose();
    });
  });

  group('SensorController - ciclo de vida', () {
    test('para de ouvir o stream quando o controller é destruído', () {
      controller.init();
      expect(stream.hasListener, isTrue);
      controller.dispose();
      expect(stream.hasListener, isFalse);
    });
  });

  group('SensorController - leituras seguidas', () {
    test('cada leitura substitui a anterior e notifica a tela', () async {
      const primeira = [
        SensorModel(
          id: '1',
          label: 'Sensor 1',
          status: SensorStatus.vendo,
          position: Alignment(0, 0),
        ),
      ];
      const segunda = [
        SensorModel(
          id: '1',
          label: 'Sensor 1',
          status: SensorStatus.cego,
          position: Alignment(0, 0),
        ),
      ];
      var notificacoes = 0;
      controller.addListener(() => notificacoes++);
      controller.init();

      stream.add(primeira);
      stream.add(segunda);
      await Future.delayed(Duration.zero);

      expect(controller.sensors, equals(segunda));
      expect(notificacoes, 2);

      controller.dispose();
    });
  });

  group('SensorController - repositório padrão', () {
    testWidgets('sem repositório injetado, usa o SensorRepository simulado', (
      tester,
    ) async {
      final padrao = SensorController()..init();

      await tester.pump(const Duration(seconds: 2));
      expect(padrao.sensors, hasLength(6));

      padrao.dispose();
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
