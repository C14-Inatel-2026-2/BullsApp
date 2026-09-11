import '../../data/models/lado.dart';

/// Único lugar do app que sabe montar as strings que o firmware do robô
/// entende. Se o protocolo mudar, muda aqui e mais nada.
///
/// TODO(time): confirmar com quem faz o firmware as strings exatas dos
/// comandos de teste (sensores, motores, PID, parar). As de jogada
/// ("D22", "E11") e RC ("DRC") vieram da divisão de tarefas.
class RobotProtocol {
  RobotProtocol._();

  /// "D22" = executar a JOGADA_22 pelo lado direito.
  static String jogada(Lado lado, int numero) => '${lado.prefixo}$numero';

  /// "DRC" = entrar no modo rádio-controlado pelo lado indicado.
  static String rc(Lado lado) => '${lado.prefixo}RC';

  static const String parar = 'STOP';
  static const String testarSensores = 'SENSORES';

  /// Valores em ticks, no mesmo intervalo de `maxTicks` do PHYSICS.json.
  static String testarMotores(int esquerdo, int direito) =>
      'MOTOR $esquerdo $direito';

  static String pid(double kp, double ki, double kd) => 'PID $kp $ki $kd';

  /// Reconhece respostas do tipo "sensorD2 vendo" / "sensorE0 cego".
  /// Grupo 1 = id do sensor ("D2"), grupo 2 = estado.
  static final RegExp respostaSensor = RegExp(
    r'^sensor(\w+)\s+(vendo|cego)$',
    caseSensitive: false,
  );
}
