import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/data/models/lado.dart';

void main() {
  group('Lado.fromSide', () {
    test('converte ladoDir em direito', () {
      expect(Lado.fromSide('ladoDir'), Lado.direito);
    });

    test('converte ladoEsc em esquerdo', () {
      expect(Lado.fromSide('ladoEsc'), Lado.esquerdo);
    });

    test('devolve null para valor desconhecido', () {
      expect(Lado.fromSide('xpto'), isNull);
    });

    test('devolve null para string vazia', () {
      expect(Lado.fromSide(''), isNull);
    });

    test('não aceita variação de caixa', () {
      expect(Lado.fromSide('LADODIR'), isNull);
      expect(Lado.fromSide('ladodir'), isNull);
    });
  });

  group('Lado.prefixo', () {
    test('direito usa D', () {
      expect(Lado.direito.prefixo, 'D');
    });

    test('esquerdo usa E', () {
      expect(Lado.esquerdo.prefixo, 'E');
    });
  });
}
