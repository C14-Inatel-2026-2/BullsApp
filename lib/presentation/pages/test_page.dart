import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/header.dart';
import 'terminal_page.dart';
import 'pid_page.dart';


// presentation/pages/home_page.dart
class TestPage extends StatelessWidget {

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
              const SizedBox(height: 5),
              Image.asset('assets/images/robotbull.png', height: 130),
              const SizedBox(height: 20),
              Text(
                "ESCOLHA UM TESTE",
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),            
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    CustomButton(
                      label: 'TESTAR MOTORES',
                      icon: Icons.settings,
                      color: AppColors.secondary,
                      onTap: () {}, 
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'TESTAR SENSORES',
                      icon: Icons.sensors,
                      color: AppColors.secondary,
                      onTap: () {}, 
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'CALIBRAR PID',
                      icon: Icons.tune,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PIDControllerPage()),
                        );
                      }, 
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}