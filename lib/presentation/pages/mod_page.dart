import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/robot_command_port.dart';
import '../controllers/auto_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/menu_layout.dart';
import 'auto_page.dart';

//import 'rc_page.dart';

class ModPage extends StatelessWidget {
  const ModPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuLayout(
      title: 'SELECIONE UM MODO',
      buttons: [
        CustomButton(
          label: 'AUTO',
          iconAsset: null,
          color: AppColors.secondary,
          height: 120,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (ctx) =>
                      AutoController(port: ctx.read<RobotCommandPort>())
                        ..init(),
                  child: Consumer<AutoController>(
                    builder: (ctx, auto, _) => CommandPage(
                      onSendCommand: auto.sendJogada,
                      status: auto.status,
                      robotResponse: auto.lastResponse,
                      errorMessage: auto.errorMessage,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        CustomButton(
          label: 'RC',
          label2: 'Radio Controlado',
          height: 120,
          iconAsset: null,
          color: AppColors.secondary,
          onTap:
              () {}, //Navigator.push(context, MaterialPageRoute(builder: (_) => const ));}, // navegar para tela de RC
        ),
      ],
    );
  }
}
