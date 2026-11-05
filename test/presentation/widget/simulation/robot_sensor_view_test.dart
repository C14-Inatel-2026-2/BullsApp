import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/core/theme/app_colors.dart';
import 'package:bullsapp/data/models/sensor_model.dart';
import 'package:bullsapp/data/models/sensor_status.dart';
import 'package:bullsapp/presentation/widgets/robot_sensor_view.dart';

void main() {
  Future<void> pumpView(WidgetTester tester, List<SensorModel> sensors) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RobotSensorView(sensors: sensors)),
        ),
      );

  testWidgets('mostra a imagem do robô mesmo sem sensores', (tester) async {
    await pumpView(tester, const []);

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.sensors), findsNothing);
  });

  testWidgets('mostra o nome e a cor de status de cada sensor', (tester) async {
    await pumpView(tester, const [
      SensorModel(
        id: '1',
        label: 'Sensor 1',
        status: SensorStatus.vendo,
        position: Alignment.topLeft,
      ),
      SensorModel(
        id: '2',
        label: 'Sensor 2',
        status: SensorStatus.semSinal,
        position: Alignment.topRight,
      ),
    ]);

    expect(find.text('Sensor 1'), findsOneWidget);
    expect(find.text('Sensor 2'), findsOneWidget);

    final icons = tester.widgetList<Icon>(find.byIcon(Icons.sensors)).toList();
    expect(icons[0].color, AppColors.success);
    expect(icons[1].color, AppColors.error);
  });
}
