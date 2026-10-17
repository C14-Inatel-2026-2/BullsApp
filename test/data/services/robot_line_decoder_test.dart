import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:bullsapp/data/services/robot_line_decoder.dart';

void main() {
  const flushDelay = Duration(milliseconds: 10);

  late List<String> lines;
  late RobotLineDecoder decoder;

  setUp(() {
    lines = [];
    decoder = RobotLineDecoder(onLine: lines.add, flushDelay: flushDelay);
  });

  test('junta uma linha que chegou em dois pacotes', () {
    decoder.add(utf8.encode('sensor'));
    decoder.add(utf8.encode('D2 vendo\n'));

    expect(lines, ['sensorD2 vendo']);
  });

  test('separa várias linhas de um pacote e aceita CRLF', () {
    decoder.add(utf8.encode('OK D22\r\nsensorE0 cego\r\n'));

    expect(lines, ['OK D22', 'sensorE0 cego']);
  });

  test('ignora linhas vazias', () {
    decoder.add(utf8.encode('\n\r\n  \nOK\n'));

    expect(lines, ['OK']);
  });

  test('texto sem fim de linha é entregue após o silêncio', () async {
    decoder.add(utf8.encode('OK'));
    expect(lines, isEmpty);

    await Future<void>.delayed(flushDelay * 3);
    expect(lines, ['OK']);
  });

  test('reset descarta a linha pela metade', () async {
    decoder.add(utf8.encode('meia lin'));
    decoder.reset();

    await Future<void>.delayed(flushDelay * 3);
    expect(lines, isEmpty);
  });
}
