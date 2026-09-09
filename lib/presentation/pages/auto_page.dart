import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/theme/app_colors.dart';
import '../widgets/header.dart';
import '../widgets/toggle_button.dart';
import '../widgets/display_state/simulation.dart' show getActionsFromState;
import '../widgets/display_state/display_state.dart';

class CommandPage extends StatefulWidget {
  final Map<String, dynamic>? startPosition; 
  final void Function(String jogadaKey, String side, List<String> actions)?
      onSendCommand;

  const CommandPage({
    super.key,
    this.startPosition,
    this.onSendCommand,
  });

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  static const _sendColor = Color(0xFFF2A08C);

  late Future<_JogadaData> _dataFuture;

  String? _selectedKey;
  String _selectedSide = 'ladoDir'; // 'ladoDir' = DIREITA, 'ladoEsc' = ESQUERDA
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_JogadaData> _loadData() async {
    final physicsString = await rootBundle.loadString('lib/assets/json/PHYSICS.json');
    final jogadasString = await rootBundle.loadString('lib/assets/json/JOGADAS.json');

    final physics = jsonDecode(physicsString) as Map<String, dynamic>;
    final jogadas = jsonDecode(jogadasString) as Map<String, dynamic>;

    final keys = jogadas.keys.toList()
      ..sort((a, b) => _jogadaNumber(a).compareTo(_jogadaNumber(b)));

    return _JogadaData(physics: physics, jogadas: jogadas, orderedKeys: keys);
  }

  int _jogadaNumber(String key) {
    final match = RegExp(r'\d+').firstMatch(key);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  void _selectSide(String side) => setState(() => _selectedSide = side);

  void _sendCommand(Map<String, dynamic> jogadas) {
    if (_selectedKey == null) return;
    final rawJogada = jogadas[_selectedKey] as Map<String, dynamic>;
    final actions = getActionsFromState(rawJogada, _selectedSide);
    widget.onSendCommand?.call(_selectedKey!, _selectedSide, actions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: FutureBuilder<_JogadaData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar dados: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            final data = snapshot.data!;
            _selectedKey ??= data.orderedKeys.first;

            final rawJogada = data.jogadas[_selectedKey!] as Map<String, dynamic>;
            final actionsForSide = getActionsFromState(rawJogada, _selectedSide);

            final flattenedState = {
              'category': rawJogada['category'],
              'actions': actionsForSide,
            };

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomHeader(
                    isConnected: true, 
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'SELECIONAR JOGADA',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SEQUÊNCIA AUTÔNOMA TÁTICA',
                    style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown "JOGADA 67 ⌄"
                  GestureDetector(
                    onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
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
                            _selectedKey!.replaceAll('_', ' '),
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          Icon(
                            _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_isDropdownOpen)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.orderedKeys.length,
                        itemBuilder: (context, i) {
                          final key = data.orderedKeys[i];
                          return ListTile(
                            dense: true,
                            title: Text(
                              key.replaceAll('_', ' '),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () => setState(() {
                              _selectedKey = key;
                              _isDropdownOpen = false;
                            }),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Caixa de simulação — reaproveita o DisplayState já pronto
                  Center(
                    child: DisplayState(
                      key: ValueKey('$_selectedKey-$_selectedSide'),
                      physics: data.physics,
                      state: flattenedState,
                      startPosition: widget.startPosition,
                      visual: DisplayVisual.compact,
                      autoplay: true,
                      arrow: 'ALWAYS',
                      showStartPoint: true,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ESQUERDA / DIREITA
                  Row(
                    children: [
                      Expanded(
                        child: SideToggleButton(
                          label: 'ESQUERDA',
                          selected: _selectedSide == 'ladoEsc',
                          onTap: () => _selectSide('ladoEsc'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SideToggleButton(
                          label: 'DIREITA',
                          selected: _selectedSide == 'ladoDir',
                          onTap: () => _selectSide('ladoDir'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _sendCommand(data.jogadas),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sendColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'ENVIAR COMANDO',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _JogadaData {
  final Map<String, dynamic> physics;
  final Map<String, dynamic> jogadas;
  final List<String> orderedKeys;

  const _JogadaData({
    required this.physics,
    required this.jogadas,
    required this.orderedKeys,
  });
}