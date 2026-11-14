import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import 'header.dart';

/// Layout comum das telas de menu (Home, Modo e Testes): logo, título e
/// uma coluna de botões com o mesmo espaçamento entre eles.
class MenuLayout extends StatelessWidget {
  const MenuLayout({
    super.key,
    required this.title,
    required this.buttons,
    this.subtitle,
    this.showHeader = true,
  });

  /// Texto em destaque abaixo do logo.
  final String title;

  /// Conteúdo opcional logo abaixo do título (ex.: status da conexão).
  final Widget? subtitle;

  /// Botões do menu, na ordem em que aparecem.
  final List<Widget> buttons;

  /// Mostra o [CustomHeader] no topo. A Home não usa, por ser a tela inicial.
  final bool showHeader;

  static const double buttonSpacing = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              if (showHeader) ...[
                const CustomHeader(),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 50),
              Image.asset(AppAssets.logo, height: 130),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              if (subtitle case final subtitle?) ...[
                const SizedBox(height: 6),
                subtitle,
              ],
              const SizedBox(height: 32),
              for (final (index, button) in buttons.indexed) ...[
                if (index > 0) const SizedBox(height: buttonSpacing),
                button,
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
