import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/robot_sensor_view.dart';
import '../widgets/header.dart';

enum Status { vendo, cego, ssinal }

extension SensorStatusX on Status {
  Color get color {
    switch (this) {
      case Status.vendo:
        return AppColors.success; // vendo
      case Status.cego:
        return AppColors.warning; // cego
      case Status.ssinal:
        return AppColors.error; // Sem Sinal
    }
  }
}

class SensorModel {
  final String id;
  final String label;
  final Status status;
  final Alignment position;

  const SensorModel({
    required this.id,
    required this.label,
    required this.status,
    required this.position,
  });
}

class SensorPage extends StatelessWidget {
  const SensorPage({super.key});

  final List<SensorModel> sensors = const [
    SensorModel(
      id: '1',
      label: 'Sensor 1',
      status: Status.vendo,
      position: Alignment(-1, -0.8),
    ),
    SensorModel(
      id: '2',
      label: 'Sensor 2',
      status: Status.cego,
      position: Alignment(0.4, -0.6),
    ),
    SensorModel(
      id: '3',
      label: 'Sensor 3',
      status: Status.ssinal,
      position: Alignment(0.0, 0.8),
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
