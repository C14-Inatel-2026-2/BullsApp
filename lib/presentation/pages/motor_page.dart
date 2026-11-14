import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/test_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/header.dart';
import '../widgets/vertical_bar.dart';
import '../../data/repositories/robot_command_port.dart';

class MotorPage extends StatefulWidget {
  const MotorPage({super.key});

  @override
  State<MotorPage> createState() => _MotorPageState();
}

class _MotorPageState extends State<MotorPage> {
  static const double _maxTicks = 100;

  double _esq = 0;
  double _dir = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          TestController(port: ctx.read<RobotCommandPort>())..init(),
      child: Builder(
        builder: (context) {
          final controller = context.read<TestController>();

          void enviar() =>
              controller.testMotors(left: _esq.round(), right: _dir.round());

          void parar() {
            setState(() {
              _esq = 0;
              _dir = 0;
            });
            controller.stopMotors();
          }

          return Scaffold(
            backgroundColor: AppColors.primary,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const CustomHeader(isConnected: true),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: VerticalBar(
                              label: 'ESQ',
                              value: _esq,
                              min: -_maxTicks,
                              max: _maxTicks,
                              onChanged: (v) => setState(() => _esq = v),
                              onChangeEnd: (_) => enviar(),
                            ),
                          ),
                          Expanded(
                            child: VerticalBar(
                              label: 'DIR',
                              value: _dir,
                              min: -_maxTicks,
                              max: _maxTicks,
                              onChanged: (v) => setState(() => _dir = v),
                              onChangeEnd: (_) => enviar(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'PARAR',
                      icon: Icons.stop,
                      color: AppColors.secondary,
                      onTap: parar,
                    ),
                    const SizedBox(height: 16),
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
