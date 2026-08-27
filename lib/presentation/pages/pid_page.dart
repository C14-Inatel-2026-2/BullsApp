import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '/core/theme/app_colors.dart';

class PIDControllerPage extends StatefulWidget {
  const PIDControllerPage({super.key});

  @override
  State<PIDControllerPage> createState() => _PIDControllerPageState();
}

class _PIDControllerPageState extends State<PIDControllerPage> {
  double _kp = 45.0, _kd = 50.1, _ki = 5.2;
  final double _min = 0.0000001, _max = 10.0;

  void _salvar() {
    print('KP: $_kp, KD: $_kd, KI: $_ki');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CustomHeader(
              isConnected: true, //  mudar dinamicamente
            ),
            const SizedBox(height: 20),
            _buildCard(
              'KP',
              _kp,
              AppColors.secondary,
              (v) => setState(() => _kp = v),
            ),
            const SizedBox(height: 20),
            _buildCard(
              'KD',
              _kd,
              AppColors.secondary,
              (v) => setState(() => _kd = v),
            ),
            const SizedBox(height: 20),
            _buildCard(
              'KI',
              _ki,
              AppColors.secondary,
              (v) => setState(() => _ki = v),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save, color: AppColors.primary),
              label: const Text(
                'SALVAR',
                style: TextStyle(color: AppColors.primary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    key: ValueKey(value.toString()),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value.toStringAsFixed(7),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: () => _showDialog(label, value, onChanged, color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 40,

                        child: Center(
                          child: Text(
                            'Clique para ajustar',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (value - _min) / (_max - _min),
              backgroundColor: AppColors.primary,
              color: color,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(
    String label,
    double value,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    final controller = TextEditingController(text: value.toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card2,
            title: Text(
              'Ajustar $label',
              style: TextStyle(color: AppColors.secondary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.secondary),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    filled: true,
                    hintStyle: TextStyle(color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Valor entre 0.0000001 e 10',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newValue =
                              double.tryParse(controller.text) ?? value;
                          if (newValue >= _min && newValue <= _max) {
                            onChanged(newValue);
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: color),
                        child: const Text(
                          'Aplicar',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
