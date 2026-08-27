import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/header.dart';

class ModPage extends StatelessWidget {
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
                Image.asset('assets/images/robotbull.png', height: 130),
              const SizedBox(height: 20),
              Text('SELECIONE UM MODO',
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 30),

              Center(
                child: Column(
                  children: [
                    CustomButton(
                      label: 'AUTO',
                      iconAsset:  null,
                      color: AppColors.secondary,
                      height: 120,
                      onTap: () {}, // navegar para tela de AUTO
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'RC',
                      label2: 'Radio Controlado',
                      height: 120,
                      iconAsset:  null,
                      color: AppColors.secondary,
                      onTap: () {}, // navegar para tela de RC

                    ),
                    const SizedBox(height: 50),
                    ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
            
}