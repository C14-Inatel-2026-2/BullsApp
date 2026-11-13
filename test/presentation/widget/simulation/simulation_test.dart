import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/presentation/widgets/display_state/simulation.dart';

const physics = <String, dynamic>{
  'maxTicks': 10000,
  'maxSpeedCmPerSec': 340,
  'robotWidthCm': 20,
  'robotHeightCm': 20,
  'wheelBaseCm': 12.5,
  'dojoOuterDiameterCm': 154,
  'dojoInnerDiameterCm': 144,
  'shikiriSenLengthCm': 20,
  'shikiriSenWidthCm': 2,
  'shikiriSenGapCm': 20,
  'dtMs': 4,
  'pidDegPerSec': 540,
  'pidSettleMs': 20,
  'viewSizePx': 420,
  'clampInsideDojo': false,
  'motorInertia': 0.18,
};

Frame frame(double t, double x, double y) =>
    Frame(t: t, x: x, y: y, angle: 0, actionLabel: 'a');

void main() {
  group('helpers numéricos', () {
    test('normalizeAngleDeg mantém o ângulo entre -180 e 180', () {
      expect(normalizeAngleDeg(270), -90);
      expect(normalizeAngleDeg(-90), -90);
      expect(normalizeAngleDeg(180), 180);
    });

    test('degToRad e radToDeg são inversos', () {
      expect(radToDeg(degToRad(45)), closeTo(45, 0.0001));
    });

    test('safeNumber converte ou usa o fallback', () {
      expect(safeNumber(2), 2.0);
      expect(safeNumber('3.5'), 3.5);
      expect(safeNumber(null, 7), 7);
      expect(safeNumber('abc', 2), 2);
    });
  });

  group('posição inicial', () {
    const propStart = {'x': 1};
    const sideStart = {'x': 2};
    const stateStart = {'x': 3};

    test('resolveStartPosition prioriza prop, depois lado, depois estado', () {
      final state = <String, dynamic>{
        'ladoDir': <String, dynamic>{'startPosition': sideStart},
        'startPosition': stateStart,
      };

      expect(resolveStartPosition(state, 'ladoDir', propStart), propStart);
      expect(resolveStartPosition(state, 'ladoDir', null), sideStart);
      expect(resolveStartPosition(state, 'ladoEsc', null), stateStart);
      expect(resolveStartPosition(null, 'ladoDir', null), isNull);
    });

    test('isDesempateState ignora caixa e espaços', () {
      expect(isDesempateState({'categoria': ' desempate '}), isTrue);
      expect(isDesempateState({'category': 'BUSCA'}), isFalse);
      expect(isDesempateState(null), isFalse);
    });

    test('getDefaultStartPosition inverte o ângulo no desempate', () {
      final normal = getDefaultStartPosition(physics, null);
      final desempate = getDefaultStartPosition(physics, {
        'category': 'DESEMPATE',
      });

      expect(normal.y, -27);
      expect(normal.angle, 90);
      expect(desempate.angle, -90);
    });
  });

  group('parseMotorValue', () {
    test('resolve MAX e expressões', () {
      expect(parseMotorValue('MAX', physics), 10000);
      expect(parseMotorValue('MAX_TICKS', physics), 10000);
      expect(parseMotorValue('-MAX/2', physics), -5000);
      expect(parseMotorValue('(2+3)*2', physics), 10);
      expect(parseMotorValue('+4-1', physics), 3);
    });

    test('valores inválidos viram zero', () {
      expect(parseMotorValue(null, physics), 0);
      expect(parseMotorValue('', physics), 0);
      expect(parseMotorValue('abc', physics), 0);
      expect(parseMotorValue('1/0', physics), 0);
    });
  });

  group('ações', () {
    test('parseAction reconhece cada tipo', () {
      expect(parseAction('motorL:MAX').type, ActionType.motorL);
      expect(parseAction('motorL:MAX').value, 'MAX');
      expect(parseAction('motorR:0').type, ActionType.motorR);
      expect(parseAction('delay:100').ms, 100);
      expect(parseAction('PID:-90°').deg, -90);
      expect(parseAction('NEXT:JOGADA_0').next, 'JOGADA_0');
      expect(parseAction('(stub)').type, ActionType.stub);
      expect(parseAction('').type, ActionType.stub);
      expect(parseAction('xyz:1').type, ActionType.unknown);
    });

    test('getActionsFromState usa o lado pedido e cai nos alternativos', () {
      final porLado = <String, dynamic>{
        'ladoDir': <String, dynamic>{
          'actions': ['dir'],
        },
        'ladoEsc': <String, dynamic>{
          'actions': ['esc'],
        },
      };

      expect(getActionsFromState(porLado, 'ladoEsc'), ['esc']);
      expect(getActionsFromState(porLado, 'outro'), ['dir']);
      expect(
        getActionsFromState({
          'ladoEsc': <String, dynamic>{
            'actions': ['esc'],
          },
        }, 'outro'),
        ['esc'],
      );
      expect(
        getActionsFromState({
          'actions': ['geral'],
        }, 'ladoDir'),
        ['geral'],
      );
      expect(getActionsFromState({}, 'ladoDir'), isEmpty);
      expect(getActionsFromState(null, 'ladoDir'), isEmpty);
    });

    test('getNextFromActions acha o NEXT ou avisa que não tem', () {
      expect(getNextFromActions(['delay:1', 'NEXT:JOGADA_3']), 'JOGADA_3');
      expect(getNextFromActions(['delay:1']), 'sem NEXT');
    });
  });

  group('simulateJogada', () {
    SimulationResult simulate(
      List<String> actions, {
      Map<String, dynamic> usedPhysics = physics,
      double y = 0,
    }) => simulateJogada(
      actions: actions,
      startPosition: {'x': 0, 'y': y, 'angle': 90},
      physics: usedPhysics,
      state: null,
    );

    test('sem ações fica parado com duração mínima', () {
      final result = simulate([]);

      expect(result.durationMs, 1);
      expect(result.frames.single.actionLabel, 'início');
      expect(result.next, 'sem NEXT');
    });

    test('motores iguais andam em linha reta para a frente', () {
      final result = simulate([
        'motorL:MAX',
        'motorR:MAX',
        'delay:100',
        'NEXT:JOGADA_0',
      ]);

      expect(result.durationMs, closeTo(100, 0.001));
      expect(result.finalPose.y, greaterThan(0));
      expect(result.finalPose.x, closeTo(0, 0.001));
      expect(result.finalPose.angle, closeTo(90, 0.001));
      expect(result.next, 'JOGADA_0');
    });

    test('motores diferentes fazem o robô girar', () {
      final result = simulate(['motorL:0', 'motorR:MAX', 'delay:20']);

      expect(result.finalPose.angle, isNot(closeTo(90, 0.001)));
    });

    test('PID gira até o alvo sem sair do lugar', () {
      final result = simulate(['PID:90']);

      expect(result.finalPose.angle, closeTo(180, 0.001));
      expect(result.finalPose.y, 0);
      expect(result.durationMs, closeTo(90 / 540 * 1000 + 20, 0.001));
    });

    test('ações desconhecidas só registram um frame', () {
      final result = simulate(['(stub)', 'xyz:1']);

      expect(result.frames.map((f) => f.actionLabel), [
        'início',
        '(stub)',
        'xyz:1',
      ]);
    });

    test('clampInsideDojo segura o robô dentro do dojo', () {
      final result = simulate(
        ['motorL:MAX', 'motorR:MAX', 'delay:1000'],
        usedPhysics: {...physics, 'clampInsideDojo': true},
        y: 50,
      );

      // raio interno (72) menos metade do robô (10)
      expect(result.finalPose.y, closeTo(62, 0.001));
    });

    test('usa a posição padrão sem startPosition', () {
      final result = simulateJogada(
        actions: const [],
        startPosition: null,
        physics: physics,
        state: null,
      );

      expect(result.finalPose.y, -27);
    });
  });

  group('geometria', () {
    test('poseToScreen converte centro e borda do dojo', () {
      final centro = poseToScreen(frame(0, 0, 0), physics);
      final borda = poseToScreen(frame(0, 77, 77), physics);
      final pose = poseToScreenFromPose(
        const Pose(x: 77, y: 77, angle: 0),
        physics,
      );

      expect(centro.left, 210);
      expect(centro.top, 210);
      expect(borda.left, closeTo(420, 0.001));
      expect(borda.top, closeTo(0, 0.001));
      expect(pose.left, borda.left);
    });

    test('getFrameAtTime devolve o último frame até o instante', () {
      final frames = [frame(0, 0, 0), frame(10, 1, 0), frame(20, 2, 0)];

      expect(getFrameAtTime([], 5), isNull);
      expect(getFrameAtTime(frames, 15)!.t, 10);
      expect(getFrameAtTime(frames, 99)!.t, 20);
    });

    test('didPathLeaveDojo detecta a saída do círculo interno', () {
      expect(didPathLeaveDojo([], physics), isFalse);
      expect(didPathLeaveDojo([frame(0, 72, 0)], physics), isFalse);
      expect(didPathLeaveDojo([frame(0, 73, 0)], physics), isTrue);
    });

    test('getStartPoint usa o primeiro frame', () {
      expect(getStartPoint([], physics), isNull);
      expect(getStartPoint([frame(0, 0, 0)], physics)!.left, 210);
    });

    test('percentuais são relativos ao dojo externo', () {
      expect(getInnerDojoPercent(physics), closeTo(144 / 154 * 100, 0.001));
      expect(getRobotSizePercent(physics), closeTo(20 / 154 * 100, 0.001));
    });

    test('getShikiriSenRects cria duas faixas simétricas', () {
      final rects = getShikiriSenRects(physics);
      const scale = 420 / 154;

      expect(rects, hasLength(2));
      expect(rects[0].width, closeTo(20 * scale, 0.001));
      expect(rects[0].x, rects[1].x);
      expect(rects[0].y + rects[0].height, closeTo(210 - 10 * scale, 0.001));
      expect(rects[1].y, closeTo(210 + 10 * scale, 0.001));
    });

    test('normalizeArrowMode cai em never por padrão', () {
      expect(normalizeArrowMode('ALWAYS'), ArrowMode.always);
      expect(normalizeArrowMode('DRAW'), ArrowMode.draw);
      expect(normalizeArrowMode('NEVER'), ArrowMode.never);
      expect(normalizeArrowMode(null), ArrowMode.never);
    });

    test('getDrawableFrames remove pontos repetidos e respeita o tempo', () {
      final frames = [
        frame(0, 0, 0),
        frame(5, 0, 0),
        frame(10, 10, 0),
        frame(20, 20, 0),
      ];

      expect(getDrawableFrames([], physics, 0, ArrowMode.always), isEmpty);
      expect(
        getDrawableFrames(frames, physics, 0, ArrowMode.always),
        hasLength(3),
      );
      expect(
        getDrawableFrames(frames, physics, 10, ArrowMode.draw),
        hasLength(2),
      );
    });

    test('getPathEndAngle aponta na direção do último trecho', () {
      final direita = [frame(0, 0, 0), frame(10, 10, 0)];
      final cima = [frame(0, 0, 0), frame(10, 0, 10)];

      expect(getPathEndAngle(direita, physics, 10, ArrowMode.always), 0);
      expect(getPathEndAngle(cima, physics, 10, ArrowMode.always), -90);
      expect(
        getPathEndAngle(direita.sublist(1), physics, 10, ArrowMode.always),
        0,
      );
    });
  });
}
