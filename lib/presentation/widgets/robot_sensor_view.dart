import 'package:flutter/material.dart';
import '../pages/sensor_page.dart';

class RobotSensorView extends StatelessWidget {
  final List<SensorModel> sensors;

  const RobotSensorView({super.key, required this.sensors});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('lib/assets/images/robot_view.png', fit: BoxFit.contain),
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
      ),
    );
  }
}
