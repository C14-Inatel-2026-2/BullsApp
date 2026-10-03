import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/robot_sensor_view.dart';
import '../widgets/header.dart';
import '../../data/models/sensor_model.dart';
import '../../data/models/sensor_status.dart';



class SensorPage extends StatelessWidget {
  const SensorPage({super.key});
  
  //adicionar a conexão com blecontroller para ter dados reais.
  final List<SensorModel> sensors = const [
    SensorModel(
      id: '1',
      label: 'Sensor 1',
      status: SensorStatus.vendo,
      position: Alignment(-0.37, -0.15),

    ),
    SensorModel(
      id: '2',
      label: 'Sensor 2',
      status: SensorStatus.cego,
      position: Alignment(-0.29, -0.40),

    ),
    SensorModel(
      id: '3',
      label: 'Sensor 3',
      status: SensorStatus.semSinal,
      position: Alignment(-0.06, -0.40),
    ),
    SensorModel(
      id: '4',
      label: 'Sensor 4',
      status: SensorStatus.vendo,
      position: Alignment(0.06, -0.40),
    ),
    SensorModel(
      id: '5',
      label: 'Sensor 5',
      status: SensorStatus.cego,
      position: Alignment(0.29, -0.40),
    ),
    SensorModel(
      id: '6',
      label: 'Sensor 6',
      status: SensorStatus.semSinal,
      position: Alignment(0.37, -0.15),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const CustomHeader(
                isConnected: true, //  mudar dinamicamente
              ),
              const SizedBox(height: 16),
              RobotSensorView(sensors: sensors),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
