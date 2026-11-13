import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/presentation/widgets/display_state/display_state.dart';

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

const state = <String, dynamic>{
  'category': 'BUSCA',
  'ladoDir': <String, dynamic>{
    'actions': ['motorL:MAX', 'motorR:MAX', 'delay:100', 'NEXT:JOGADA_DIR'],
  },
  'ladoEsc': <String, dynamic>{
    'actions': ['motorL:MAX', 'motorR:0', 'delay:100', 'NEXT:JOGADA_ESC'],
  },
};

void main() {
  Future<void> pumpDisplay(WidgetTester tester, DisplayState display) async {
    // Tela alta para o palco e os controles caberem sem overflow
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: display)),
      ),
    );
  }

  Finder nextText(String next) =>
      find.text('Ao terminar, cai na $next', findRichText: true);

  double sliderValue(WidgetTester tester) =>
      tester.widget<Slider>(find.byType(Slider)).value;

  group('visual padrão', () {
    testWidgets('mostra categoria, próxima jogada e controles', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(physics: physics, state: state),
      );

      expect(find.text('BUSCA'), findsOneWidget);
      expect(nextText('JOGADA_DIR'), findsOneWidget);
      expect(find.text('Lado da jogada'), findsOneWidget);
      expect(find.text('Reiniciar'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('trocar o lado refaz a simulação', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(physics: physics, state: state),
      );

      await tester.tap(find.text('Esquerdo'));
      await tester.pump();

      expect(nextText('JOGADA_ESC'), findsOneWidget);
      expect(nextText('JOGADA_DIR'), findsNothing);
    });

    testWidgets('sem autoplay a animação fica parada no início', (
      tester,
    ) async {
      await pumpDisplay(
        tester,
        const DisplayState(physics: physics, state: state, autoplay: false),
      );

      await tester.pump(const Duration(milliseconds: 50));

      expect(sliderValue(tester), 0);
      // No instante 0 vale o último frame de t=0: a ação do segundo motor.
      expect(find.text('motorR:MAX'), findsOneWidget);
    });

    testWidgets('autoplay avança até o fim da jogada', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(physics: physics, state: state),
      );

      await tester.pumpAndSettle();

      expect(sliderValue(tester), closeTo(100, 0.001));
    });

    testWidgets('Reiniciar volta a animação para o começo', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(physics: physics, state: state),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reiniciar'));
      await tester.pump();

      expect(sliderValue(tester), 0);
    });

    testWidgets('arrastar o slider posiciona e pausa a animação', (
      tester,
    ) async {
      await pumpDisplay(
        tester,
        const DisplayState(physics: physics, state: state),
      );

      await tester.drag(find.byType(Slider), const Offset(60, 0));
      await tester.pump();
      final valueAfterDrag = sliderValue(tester);
      await tester.pump(const Duration(milliseconds: 50));

      expect(valueAfterDrag, greaterThan(0));
      expect(sliderValue(tester), valueAfterDrag);
    });

    testWidgets('com loopMs espera e reinicia a animação', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(physics: physics, state: state, loopMs: 100),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('loop em 100ms'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('loop em 100ms'), findsNothing);
    });

    testWidgets('trocar o estado do widget refaz a simulação', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(physics: physics, state: state),
      );

      await pumpDisplay(
        tester,
        const DisplayState(
          physics: physics,
          state: {
            'actions': ['NEXT:JOGADA_NOVA'],
          },
        ),
      );

      expect(nextText('JOGADA_NOVA'), findsOneWidget);
    });
  });

  group('visual compacto', () {
    testWidgets('esconde os controles e mantém o robô', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(
          physics: physics,
          state: state,
          visual: DisplayVisual.compact,
          arrow: 'ALWAYS',
          showStartPoint: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reiniciar'), findsNothing);
      expect(find.byType(Slider), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('hiddenRobot esconde a imagem do robô', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(
          physics: physics,
          state: state,
          visual: DisplayVisual.compact,
          hiddenRobot: true,
        ),
      );

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('desenha trajeto que sai do dojo sem quebrar', (tester) async {
      await pumpDisplay(
        tester,
        const DisplayState(
          physics: physics,
          state: {
            'actions': ['motorL:MAX', 'motorR:MAX', 'delay:1000'],
          },
          visual: DisplayVisual.compact,
          arrow: 'DRAW',
          startPosition: {'x': 0, 'y': 0, 'angle': 90},
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });
  });
}
