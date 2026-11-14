import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class VerticalBar extends StatelessWidget {
  static const double _spacing = 8.0;
  static const double _trackHeight = 14.0;
  static const double _labelLetterSpacing = 2.0;

  final String label;
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double value)? valueFormatter;

  const VerticalBar({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = -1,
    this.max = 1,
    this.divisions,
    this.valueFormatter,
  }) : assert(min < max, 'min must be less than max');

  String get _formattedValue =>
      valueFormatter?.call(value) ?? value.round().toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            letterSpacing: _labelLetterSpacing,
          ),
        ),
        const SizedBox(height: _spacing),
        Expanded(child: _buildVerticalSlider(context)),
        const SizedBox(height: _spacing),
        Text(
          _formattedValue,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildVerticalSlider(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: _trackHeight,
          activeTrackColor: AppColors.secondary,
          inactiveTrackColor: AppColors.card,
          thumbColor: AppColors.secondary,
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ),
    );
  }
}