import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/menu_layout.dart';
import 'terminal_page.dart';
import 'pid_page.dart';
import 'sensor_page.dart';

// presentation/pages/home_page.dart
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuLayout(
      title: 'ESCOLHA UM TESTE',
      buttons: [
        CustomButton(
          label: 'TESTAR MOTORES',
          icon: Icons.settings,
          color: AppColors.secondary,
          onTap: () {},
        ),
        CustomButton(
          label: 'TESTAR SENSORES',
          icon: Icons.sensors,
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SensorPage()),
            );
          },
        ),
        CustomButton(
          label: 'CALIBRAR PID',
          icon: Icons.tune,
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PIDControllerPage(),
              ),
            );
          },
        ),
        CustomButton(
          label: 'TERMINAL',
          icon: Icons.terminal,
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TerminalPage()),
            );
          },
        ),
      ],
    );
  }
}
