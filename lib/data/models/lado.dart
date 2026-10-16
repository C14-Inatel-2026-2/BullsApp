/// Lado do robô. Vira o prefixo dos comandos ("D22" / "E22", "DRC" / "ERC").
enum Lado {
  esquerdo('E'),
  direito('D');

  final String prefixo;
  const Lado(this.prefixo);

  /// Converte a chave de lado usada no JOGADAS.json e na CommandPage
  /// ('ladoDir' / 'ladoEsc') no enum.
  ///
  /// Devolve `null` para qualquer outro valor — quem chama decide o que
  /// fazer. Não existe lado padrão: assumir um em caso de erro de digitação
  /// mandaria o robô para o lado errado silenciosamente.
  static Lado? fromSide(String side) {
    switch (side) {
      case 'ladoEsc':
        return Lado.esquerdo;
      case 'ladoDir':
        return Lado.direito;
      default:
        return null;
    }
  }
}
