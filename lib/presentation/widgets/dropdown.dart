import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// presentation/widgets/jogada_selector_dropdown.dart
//
// Dropdown "JOGADA 67 ⌄" — mostra a jogada selecionada e, ao tocar,
// expande uma lista com todas as opções disponíveis (chaves do JOGADAS.json).
class JogadaSelectorDropdown extends StatefulWidget {
  final String selectedKey;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const JogadaSelectorDropdown({
    super.key,
    required this.selectedKey,
    required this.options,
    required this.onSelected,
  });

  @override
  State<JogadaSelectorDropdown> createState() => _JogadaSelectorDropdownState();
}

class _JogadaSelectorDropdownState extends State<JogadaSelectorDropdown> {
  bool _isOpen = false;

  void _toggle() => setState(() => _isOpen = !_isOpen);

  void _select(String key) {
    widget.onSelected(key);
    setState(() => _isOpen = false);
  }

  String _format(String key) => key.replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _format(widget.selectedKey),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: () {
              final availableOptions = widget.options
                  .where((key) => key != widget.selectedKey)
                  .toList();

              if (availableOptions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhuma jogada disponível',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return Material(
                color: Colors.transparent,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableOptions.length,
                  itemBuilder: (context, i) {
                    final key = availableOptions[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        _format(key),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () => _select(key),
                    );
                  },
                ),
              );
            }(),
          ),
      ],
    );
  }
}