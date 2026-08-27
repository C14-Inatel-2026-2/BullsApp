import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/header.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Lista que guarda as linhas do terminal
  final List<String> _logs = [
    "Terminal iniciado...",
    "Aguardando entrada...",
  ];

  // Método público para adicionar linhas (você vai chamar isso do backend depois)
  void addLog(String text) {
    setState(() {
      _logs.add(text);
    });
    _scrollToBottom();
  }

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
  void _sendMessage() {
    String text = _inputController.text.trim();
    if (text.isEmpty) return;

    // Mostra o que o usuário enviou
    addLog("> $text");

    // Limpa o campo
    _inputController.clear();

    // AQUI VOCÊ VAI CHAMAR O SEU BACKEND DEPOIS
    // Exemplo: meuBackend.enviar(text);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16.0), // Espaçamento externo da caixa
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card, // Cor de fundo da caixa (Preta)
                  borderRadius: BorderRadius.circular(12), // Bordas arredondadas
                  border: Border.all(
                    color: AppColors.black.withOpacity(0.2), // Borda sutil (opcional)
                    width: 1,
                  ),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _logs[index],
                      style: const TextStyle(
                        color: AppColors.secondary, // Sua cor verde/dourada
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
                      borderRadius: BorderRadius.circular(8), // Bordas arredondadas
                    ),
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: AppColors.secondary), // Cor do texto digitado
                      decoration: const InputDecoration(
                        hintText: "Digite o comando...",
                        hintStyle: TextStyle(color: AppColors.secondary), // Cor do placeholder
                        filled: true,
                        fillColor: AppColors.card, // Cor de fundo do TextField
                        
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.secondary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}