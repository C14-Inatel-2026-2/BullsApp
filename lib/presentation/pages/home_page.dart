import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import 'scan_page.dart';
import 'mod_page.dart';
import 'test_page.dart';


// presentation/pages/home_page.dart
class HomePage extends StatelessWidget {
  final String deviceName;
  final bool isConnected;

  const HomePage({
    super.key,
    this.deviceName = 'NOME DO DISPOSITIVO',
    this.isConnected = true,
  });

  void _disconnect(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScanPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset('assets/images/robotbull.png', height: 130),
              const SizedBox(height: 20),
              Text(
                deviceName.toUpperCase(),
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? AppColors.success : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? 'CONECTADO' : 'DESCONECTADO',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    CustomButton(
                      label: 'COMBATE',
                      iconAsset: 'assets/icons/rapier.png',
                      color: AppColors.secondary,
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (_) => ModPage()));}, // navegar para tela de combate
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'TESTAR',
                      icon: Icons.build,
                      color: AppColors.secondary,
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (_) => TestPage()));}, // navegar para tela de teste
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'HISTÓRICO DE LUTAS',
                      icon: Icons.history,
                      color: AppColors.secondary,
                      onTap: () {}, // navegar para histórico
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'DISCORD',
                      iconAsset: 'assets/icons/discord.png',
                      color: AppColors.discord,
                      textColor: Colors.white,
                      onTap: () {}, // abrir link do discord
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'DESCONECTAR',
                      icon: Icons.logout,
                      color: AppColors.secondary,
                      height: 42,
                      width: CustomButton.defaultWidth * 0.65,
                      onTap: () => _disconnect(context),
                    ),
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