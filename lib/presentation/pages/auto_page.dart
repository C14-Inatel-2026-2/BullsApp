import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/theme/app_colors.dart';
import '../controllers/auto_status.dart';
import '../widgets/header.dart';
import '../widgets/toggle_button.dart';
import '../widgets/dropdown.dart';
import '../widgets/display_state/simulation.dart' show getActionsFromState;
import '../widgets/display_state/display_state.dart';

class CommandPage extends StatefulWidget {
  final Map<String, dynamic>? startPosition;
  final void Function(String jogadaKey, String side, List<String> actions)?
  onSendCommand;

  /// Estado do último envio, vindo do AutoController.
  final AutoStatus status;

  /// Última mensagem que o robô mandou depois do envio.
  final String? robotResponse;
  final String? errorMessage;

  const CommandPage({
    super.key,
    this.startPosition,
    this.onSendCommand,
    this.status = AutoStatus.idle,
    this.robotResponse,
    this.errorMessage,
  });

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  static const _sendColor = Color(0xFFF2A08C);

  late Future<_JogadaData> _dataFuture;

  String? _selectedKey;
  String _selectedSide = 'ladoDir'; // 'ladoDir' = DIREITA, 'ladoEsc' = ESQUERDA

  /// Seleção ("JOGADA_16-ladoDir") do último envio. Ao trocar a jogada ou o
  /// lado, o botão volta a "ENVIAR COMANDO".
  String? _sentSelection;

  String get _currentSelection => '$_selectedKey-$_selectedSide';

  bool get _isSent =>
      widget.status == AutoStatus.running &&
      _sentSelection == _currentSelection;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_JogadaData> _loadData() async {
    final physicsString = await rootBundle.loadString(
      'lib/assets/json/PHYSICS.json',
    );
    final jogadasString = await rootBundle.loadString(
      'lib/assets/json/JOGADAS.json',
    );

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
    setState(() => _sentSelection = _currentSelection);
    widget.onSendCommand?.call(_selectedKey!, _selectedSide, actions);
  }

  /// Resposta do robô (verde) ou erro do envio (vermelho), abaixo do botão.
  Widget? _buildSendFeedback() {
    if (_sentSelection != _currentSelection) return null;
    final (text, color) = switch (widget.status) {
      AutoStatus.error => (widget.errorMessage, Colors.redAccent),
      AutoStatus.running => (widget.robotResponse, AppColors.success),
      _ => (null, Colors.transparent),
    };
    if (text == null) return null;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
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

            final rawJogada =
                data.jogadas[_selectedKey!] as Map<String, dynamic>;
            final actionsForSide = getActionsFromState(
              rawJogada,
              _selectedSide,
            );

            final flattenedState = {
              'category': rawJogada['category'],
              'actions': actionsForSide,
            };

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomHeader(),
                  const SizedBox(height: 16),

                  const Text(
                    'SELECIONAR JOGADA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SEQUÊNCIA AUTÔNOMA TÁTICA',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  JogadaSelectorDropdown(
                    selectedKey: _selectedKey!,
                    options: data.orderedKeys,
                    onSelected: (key) => setState(() => _selectedKey = key),
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
                        backgroundColor: _isSent
                            ? AppColors.success
                            : _sendColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _isSent ? 'COMANDO ENVIADO' : 'ENVIAR COMANDO',
                        style: TextStyle(
                          color: _isSent ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_buildSendFeedback() case final feedback?) ...[
                    const SizedBox(height: 12),
                    Center(child: feedback),
                  ],
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
