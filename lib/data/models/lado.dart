enum Lado {
  esquerdo('E'),
  direito('D');

  final String prefixo;
  const Lado(this.prefixo);

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
