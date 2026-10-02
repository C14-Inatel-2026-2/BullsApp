import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../controllers/test_controller.dart';
import '../widgets/header.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // As linhas do terminal vivem no TestController; a tela só as exibe.
  // Guarda quantas já foram vistas para rolar quando chegar linha nova.
  int _linesSeen = 0;

  // Rola para o final automaticamente
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Função que o botão ENVIAR chama
  void _sendMessage(TestController controller) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    controller.sendCommand(text);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TestController()..init(),
      child: Builder(
        builder: (context) {
          final controller = context.watch<TestController>();
          final logs = controller.log;
          if (logs.length != _linesSeen) {
            _linesSeen = logs.length;
            _scrollToBottom();
          }

          return Scaffold(
            backgroundColor: AppColors.primary, // Fundo preto

            body: Column(
              children: [
                const CustomHeader(
                  isConnected: true, //  mudar dinamicamente
                ),
                // Área que mostra o texto
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Espaçamento externo da caixa
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card, // Cor de fundo da caixa (Preta)
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Bordas arredondadas
                        border: Border.all(
                          color: AppColors.black.withValues(
                            alpha: 0.2,
                          ), // Borda sutil (opcional)
                          width: 1,
                        ),
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          return Text(
                            logs[index],
                            style: const TextStyle(
                              color:
                                  AppColors.secondary, // Sua cor verde/dourada
                              fontFamily: 'Courier New',
                              fontSize: 15,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Área de digitação
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.primary, // Fundo
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Bordas arredondadas
                          ),
                          child: TextField(
                            controller: _inputController,
                            style: const TextStyle(
                              color: AppColors.secondary,
                            ), // Cor do texto digitado
                            decoration: const InputDecoration(
                              hintText: "Digite o comando...",
                              hintStyle: TextStyle(
                                color: AppColors.secondary,
                              ), // Cor do placeholder
                              filled: true,
                              fillColor:
                                  AppColors.card, // Cor de fundo do TextField

                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(controller),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.secondary,
                        ),
                        onPressed: controller.isBusy
                            ? null
                            : () => _sendMessage(controller),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
