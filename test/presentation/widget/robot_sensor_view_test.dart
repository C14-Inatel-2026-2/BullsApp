import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/data/models/sensor_model.dart';
import 'package:bullsapp/data/models/sensor_status.dart';
import 'package:bullsapp/presentation/widgets/robot_sensor_view.dart';

const _sensores = [
  SensorModel(
    id: '1',
    label: 'Sensor 1',
    status: SensorStatus.vendo,
    position: Alignment(-0.3, -0.2),
  ),
  SensorModel(
    id: '2',
    label: 'Sensor 2',
    status: SensorStatus.cego,
    position: Alignment(0.3, -0.2),
  ),
];

Widget montar(List<SensorModel> sensores) {
  return MaterialApp(
    home: Scaffold(body: RobotSensorView(sensors: sensores)),
  );
}

void main() {
  group('RobotSensorView - dados informados', () {
    testWidgets('mostra um ícone para cada sensor', (tester) async {
      await tester.pumpWidget(montar(_sensores));

      expect(find.byIcon(Icons.sensors), findsNWidgets(2));
    });

    testWidgets('mostra o label de cada sensor', (tester) async {
      await tester.pumpWidget(montar(_sensores));

      expect(find.text('Sensor 1'), findsOneWidget);
      expect(find.text('Sensor 2'), findsOneWidget);
    });

    testWidgets('pinta cada ícone com a cor do seu status', (tester) async {
      await tester.pumpWidget(montar(_sensores));

      final cores = tester
          .widgetList<Icon>(find.byIcon(Icons.sensors))
          .map((i) => i.color)
          .toList();

      expect(cores, [SensorStatus.vendo.color, SensorStatus.cego.color]);
    });
  });

  group('RobotSensorView - entradas inválidas', () {
    testWidgets('lista vazia não mostra sensores e não quebra', (tester) async {
      await tester.pumpWidget(montar(const []));

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.sensors), findsNothing);
    });
  });
}
