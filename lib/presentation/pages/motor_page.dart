import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/robot_command_port.dart';
import '../controllers/test_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/header.dart';
import '../widgets/vertical_bar.dart';

class MotorPage extends StatelessWidget {
  const MotorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          TestController(port: ctx.read<RobotCommandPort>())..init(),
      child: const _MotorView(),
    );
  }
}

class _MotorView extends StatefulWidget {
  const _MotorView();

  @override
  State<_MotorView> createState() => _MotorViewState();
}

class _MotorViewState extends State<_MotorView> {
  static const double _maxPower = 100;
  static const double _horizontalPadding = 24;
  static const double _verticalSpacing = 16;

  static const String _leftMotorLabel = 'ESQ';
  static const String _rightMotorLabel = 'DIR';
  static const String _stopButtonLabel = 'PARAR';

  double _leftPower = 0;
  double _rightPower = 0;

  void _sendMotorCommand() {
    context.read<TestController>().testMotors(
      left: _leftPower.round(),
      right: _rightPower.round(),
    );
  }

  void _stopMotors() {
    setState(() {
      _leftPower = 0;
      _rightPower = 0;
    });
    context.read<TestController>().stopMotors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Column(
            children: [
              const CustomHeader(isConnected: true),
              const SizedBox(height: _verticalSpacing),
              Expanded(child: _buildMotorControls()),
              const SizedBox(height: _verticalSpacing),
              _buildStopButton(),
              const SizedBox(height: _verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotorControls() {
    return Row(
      children: [
        _buildMotorBar(
          label: _leftMotorLabel,
          value: _leftPower,
          onChanged: (value) => setState(() => _leftPower = value),
        ),
        _buildMotorBar(
          label: _rightMotorLabel,
          value: _rightPower,
          onChanged: (value) => setState(() => _rightPower = value),
        ),
      ],
    );
  }

  Widget _buildMotorBar({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Expanded(
      child: VerticalBar(
        label: label,
        value: value,
        min: -_maxPower,
        max: _maxPower,
        onChanged: onChanged,
        onChangeEnd: (_) => _sendMotorCommand(),
      ),
    );
  }

  Widget _buildStopButton() {
    return CustomButton(
      label: _stopButtonLabel,
      icon: Icons.stop,
      color: AppColors.secondary,
      onTap: _stopMotors,
    );
  }
}
