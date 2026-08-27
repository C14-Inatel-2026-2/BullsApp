import 'package:flutter/material.dart';

// presentation/widgets/custom_button.dart
class CustomButton extends StatefulWidget {
  static const defaultWidth = 300.0;

  final String label;
  final String? label2;
  final IconData? icon;
  final String? iconAsset;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final double height;
  final double? width; // null = ocupa toda a largura disponível

  const CustomButton({
    super.key,
    required this.label,
    this.label2,
    this.icon,
    this.iconAsset,
    required this.onTap,
    this.color = const Color(0xFFF0C24D),
    this.textColor = Colors.black,
    this.height = 56,
    this.width = defaultWidth,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    final hasIcon = widget.iconAsset != null || widget.icon != null;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasIcon) ...[
                widget.iconAsset != null
                    ? Image.asset(widget.iconAsset!, width: 20, height: 20)
                    : Icon(widget.icon, color: widget.textColor, size: 20),
                const SizedBox(width: 10),
              ],
              Text.rich(
                TextSpan(
                  text: widget.label,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  children: widget.label2 != null
                      ? [
                          TextSpan(
                            text: '\n${widget.label2}',
                            style: TextStyle(
                              color: widget.textColor.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]
                      : null,
                ),
                        textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}