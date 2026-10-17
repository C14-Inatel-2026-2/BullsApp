import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/core/theme/app_colors.dart';
import 'package:bullsapp/data/models/sensor_model.dart';
import 'package:bullsapp/data/models/sensor_status.dart';

void main() {
  group('SensorStatusColor', () {
    test('vendo retorna a cor de sucesso', () {
      expect(SensorStatus.vendo.color, equals(AppColors.success));
    });
    test('cego retorna a cor de aviso', () {
      expect(SensorStatus.cego.color, equals(AppColors.warning));
    });
    test('semSinal retorna a cor de erro', () {
      expect(SensorStatus.semSinal.color, equals(AppColors.error));
    });
  });
}
