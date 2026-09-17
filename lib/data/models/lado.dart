/// Lado do robô. Vira o prefixo dos comandos ("D22" / "E22", "DRC" / "ERC").
enum Lado {
  esquerdo('E'),
  direito('D');

  final String prefixo;
  const Lado(this.prefixo);
}
