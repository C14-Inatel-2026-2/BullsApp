import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../controllers/auto_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/header.dart';
import 'auto_page.dart';
//import 'rc_page.dart';

class ModPage extends StatelessWidget {
  const ModPage({super.key});

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
                Image.asset('lib/assets/images/robotbull.png', height: 130),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // AutoController vive só enquanto a CommandPage
                            // estiver aberta, igual ao BleController na ScanPage.
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) => AutoController()..init(),
                              child: Builder(
                                builder: (ctx) => CommandPage(
                                  onSendCommand:
                                      ctx.read<AutoController>().sendJogada,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'RC',
                      label2: 'Radio Controlado',
                      height: 120,
                      iconAsset:  null,
                      color: AppColors.secondary,
                      onTap: () {}//Navigator.push(context, MaterialPageRoute(builder: (_) => const ));}, // navegar para tela de RC

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