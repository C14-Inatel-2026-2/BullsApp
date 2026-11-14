import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../controllers/sensor_controller.dart';
import '../widgets/header.dart';
import '../widgets/robot_sensor_view.dart';

class SensorPage extends StatelessWidget {
  const SensorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SensorController()..init(),
      child: const _SensorView(),
    );
  }
}

class _SensorView extends StatelessWidget {
  static const double _horizontalPadding = 24;
  static const double _topSpacing = 16;
  static const double _bottomSpacing = 20;
  static const double _loadingAspectRatio = 2.5;

  const _SensorView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SensorController>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Column(
            children: [
              const CustomHeader(),
              const SizedBox(height: _topSpacing),
              _buildSensorContent(controller),
              const SizedBox(height: _bottomSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorContent(SensorController controller) {
    if (controller.sensors.isEmpty) {
      return const AspectRatio(
        aspectRatio: _loadingAspectRatio,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    return RobotSensorView(sensors: controller.sensors);
  }
}
