import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/robot_sensor_view.dart';
import '../widgets/header.dart';
import 'package:provider/provider.dart';
import '../controllers/sensor_controller.dart';



class SensorPage extends StatelessWidget {
  const SensorPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SensorController()..init(),
      child: Builder(
        builder: (context) {
          final controller = context.watch<SensorController>();

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
                    controller.sensors.isEmpty
                      ? const CircularProgressIndicator(color: Colors.white)
                      : RobotSensorView(sensors: controller.sensors),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}