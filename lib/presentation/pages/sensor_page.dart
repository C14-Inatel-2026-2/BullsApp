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
                    const CustomHeader(),
                    const SizedBox(height: 16),
                    controller.sensors.isEmpty
                        ? AspectRatio(
                            aspectRatio: 2.5,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            ),
                          )
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
