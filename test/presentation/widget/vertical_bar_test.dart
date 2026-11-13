import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bullsapp/presentation/widgets/vertical_bar.dart';

Widget montar({double value = 0, ValueChanged<double>? onChanged}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 400,
        child: VerticalBar(
          label: 'ESQ',
          value: value,
          min: -100,
          max: 100,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('VerticalBar - exibição', () {
    testWidgets('mostra o label recebido', (tester) async {
      await tester.pumpWidget(montar());

      expect(find.text('ESQ'), findsOneWidget);
    });

    testWidgets('mostra o valor arredondado', (tester) async {
      await tester.pumpWidget(montar(value: 42.6));

      expect(find.text('43'), findsOneWidget);
    });

    testWidgets('repassa o valor ao slider', (tester) async {
      await tester.pumpWidget(montar(value: 30));

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 30);
    });
  });

  group('VerticalBar - interação', () {
    testWidgets('avisa o novo valor por onChanged', (tester) async {
      double? recebido;
      await tester.pumpWidget(montar(onChanged: (v) => recebido = v));

      tester.widget<Slider>(find.byType(Slider)).onChanged!(25);

      expect(recebido, 25);
    });
  });

  group('VerticalBar - valores inválidos', () {
    testWidgets('valor acima do máximo é limitado e não quebra', (
      tester,
    ) async {
      await tester.pumpWidget(montar(value: 999));

      expect(tester.takeException(), isNull);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 100);
    });

    testWidgets('valor abaixo do mínimo é limitado e não quebra', (
      tester,
    ) async {
      await tester.pumpWidget(montar(value: -999));

      expect(tester.takeException(), isNull);
      expect(tester.widget<Slider>(find.byType(Slider)).value, -100);
    });
  });
}
