import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/core/constants/robot_protocol.dart';
import 'package:bullsapp/data/models/lado.dart';

void main() {
  group('RobotProtocol.jogada', () {
    test('monta D22 para a jogada 22 do lado direito', () {
      expect(RobotProtocol.jogada(Lado.direito, 22), 'D22');
    });

    test('monta E11 para a jogada 11 do lado esquerdo', () {
      expect(RobotProtocol.jogada(Lado.esquerdo, 11), 'E11');
    });

    test('não separa o prefixo de um número de um dígito', () {
      expect(RobotProtocol.jogada(Lado.direito, 1), 'D1');
    });

    test('não separa o prefixo de um número de dois dígitos', () {
      expect(RobotProtocol.jogada(Lado.esquerdo, 51), 'E51');
    });
  });

  group('RobotProtocol.rc', () {
    test('monta DRC para o lado direito', () {
      expect(RobotProtocol.rc(Lado.direito), 'DRC');
    });

    test('monta ERC para o lado esquerdo', () {
      expect(RobotProtocol.rc(Lado.esquerdo), 'ERC');
    });
  });

  group('RobotProtocol.testarMotores', () {
    test('envia os dois valores separados por espaço', () {
      expect(RobotProtocol.testarMotores(1000, 2000), 'MOTOR 1000 2000');
    });

    test('preserva valores negativos (marcha a ré)', () {
      expect(RobotProtocol.testarMotores(-500, 500), 'MOTOR -500 500');
    });
  });

  group('RobotProtocol.respostaSensor', () {
    test('reconhece sensor vendo e separa id e estado', () {
      final m = RobotProtocol.respostaSensor.firstMatch('sensorD2 vendo');

      expect(m, isNotNull);
      expect(m!.group(1), 'D2');
      expect(m.group(2), 'vendo');
    });

    test('reconhece sensor cego', () {
      final m = RobotProtocol.respostaSensor.firstMatch('sensorE0 cego');

      expect(m!.group(1), 'E0');
      expect(m.group(2), 'cego');
    });

    test('não casa com a confirmação de um comando', () {
      expect(RobotProtocol.respostaSensor.firstMatch('OK D22'), isNull);
    });

    test('não casa com a linha sem o estado do sensor', () {
      expect(RobotProtocol.respostaSensor.firstMatch('sensorD2'), isNull);
    });
  });
}
