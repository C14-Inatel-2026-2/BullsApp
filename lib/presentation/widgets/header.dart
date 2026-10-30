import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/robot_command_port.dart';

// Widget reutilizável do Header
class CustomHeader extends StatelessWidget {
  /// Força o status mostrado. Se for null (padrão), o header acompanha a
  /// conexão real pelo [RobotCommandPort] do Provider.
  final bool? isConnected;
  final VoidCallback? onBackPressed;

  const CustomHeader({
    super.key,
    this.isConnected,
    this.onBackPressed, // Opcional: função para voltar
  });

  @override
  Widget build(BuildContext context) {
    final fixed = isConnected;
    if (fixed != null) return _build(context, fixed);

    final port = context.read<RobotCommandPort>();
    return StreamBuilder<bool>(
      stream: port.connectionChanges,
      initialData: port.isConnected,
      builder: (context, snapshot) =>
          _build(context, snapshot.data ?? port.isConnected),
    );
  }

  Widget _build(BuildContext context, bool isConnected) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.primary, // Bordô
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão Voltar
          InkWell(
            onTap:
                onBackPressed ??
                () => Navigator.pop(
                  context,
                ), // Se não passar função, volta automaticamente
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  "VOLTAR",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Status
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? AppColors.success
                      : AppColors
                            .error, // Verde se conectado, vermelho se desconectado
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isConnected ? "Conectado" : "Desconectado",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
