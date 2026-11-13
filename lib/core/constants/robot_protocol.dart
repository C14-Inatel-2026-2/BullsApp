import '../../data/models/lado.dart';

class RobotProtocol {
  RobotProtocol._();

  /// "D22" = executar a JOGADA_22 pelo lado direito; "E08" = JOGADA_8 pelo
  /// lado esquerdo. O número sempre tem pelo menos 2 dígitos.
  /// Com [teste], ganha o prefixo "T": "TD08".
  static String jogada(Lado lado, int numero, {bool teste = false}) =>
      '${teste ? 'T' : ''}${lado.prefixo}${numero.toString().padLeft(2, '0')}';

  static String rc(Lado lado) => '${lado.prefixo}RC';

  static const String parar = 'STOP';
  static const String testarSensores = 'SENSORES';

  static String testarMotores(int esquerdo, int direito) =>
      'MOTOR $esquerdo $direito';

  static String pid(double kp, double ki, double kd) => 'PID $kp $ki $kd';

  static final RegExp respostaSensor = RegExp(
    r'^sensor(\w+)\s+(vendo|cego)$',
    caseSensitive: false,
  );
}
