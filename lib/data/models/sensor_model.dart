import 'sensor_status.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Representa um sensor do robô: seu identificador, status atual
/// (reportado pelo firmware) e posição visual sobre a imagem do robô.
class SensorModel {
  final String id;
  final String label;
  final SensorStatus status;
  final Alignment position;

  const SensorModel({
    required this.id,
    required this.label,
    required this.status,
    required this.position,
  });
}

/// Cor associada a cada [SensorStatus], usada na visualização do robô.
extension SensorStatusColor on SensorStatus {
  Color get color {
    switch (this) {
      case SensorStatus.vendo:
        return AppColors.success;
      case SensorStatus.cego:
        return AppColors.warning;
      case SensorStatus.semSinal:
        return AppColors.error;
    }
  }
}