import 'dart:async';
import 'dart:convert';

/// Junta os pacotes BLE que chegam do robô em linhas de texto.
///
/// Um pacote pode trazer meia linha ou várias linhas; "\r\n" e "\n" são
/// aceitos. Se o robô mandar texto sem fim de linha, o que estiver no
/// buffer é entregue depois de [flushDelay] sem novos pacotes.
class RobotLineDecoder {
  RobotLineDecoder({
    required this.onLine,
    this.flushDelay = const Duration(milliseconds: 150),
  });

  final void Function(String line) onLine;
  final Duration flushDelay;

  final _buffer = StringBuffer();
  Timer? _flushTimer;

  void add(List<int> bytes) {
    _flushTimer?.cancel();
    _buffer.write(utf8.decode(bytes, allowMalformed: true));

    final parts = _buffer.toString().split('\n');
    _buffer.clear();
    _buffer.write(parts.removeLast()); // pedaço sem \n ainda

    for (final line in parts) {
      _emit(line);
    }
    if (_buffer.isNotEmpty) {
      _flushTimer = Timer(flushDelay, _flush);
    }
  }

  /// Descarta o que estiver pela metade (ex.: a conexão caiu).
  void reset() {
    _flushTimer?.cancel();
    _buffer.clear();
  }

  void _flush() {
    final rest = _buffer.toString();
    _buffer.clear();
    _emit(rest);
  }

  void _emit(String raw) {
    final line = raw.replaceAll('\r', '').trim();
    if (line.isNotEmpty) onLine(line);
  }
}
