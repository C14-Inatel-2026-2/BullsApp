import 'package:flutter/material.dart';
import '../pages/sensor_page.dart';

class RobotSensorView extends StatelessWidget {
  final List<SensorModel> sensors;

  const RobotSensorView({super.key, required this.sensors});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset('assets/imagens/robotbull.png', height: 110),
        for (final sensor in sensors)
          Align(
            alignment: sensor.position,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sensors, color: sensor.status.color),
                Text(sensor.label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
      ],
    );
  }
}
