import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/core/theme/app_colors.dart';
import 'package:bullsapp/data/models/sensor_model.dart';
import 'package:bullsapp/data/models/sensor_status.dart';

void main() {
  group('SensorStatus', () {
    test('se a resposta for "vendo", retorna SensorStatus.vendo', () {
      expect(SensorStatus.fromResposta('vendo') ,SensorStatus.vendo);
    });
    test('se a resposta for "cego", retorna SensorStatus.cego', () {
      expect(SensorStatus.fromResposta('cego') ,SensorStatus.cego);
    });
    test('se a resposta for "semSinal", retorna SensorStatus.semSinal', () {
      expect(SensorStatus.fromResposta('careca do saldanha ') ,SensorStatus.semSinal);
    });
  });
}