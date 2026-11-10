import 'package:auto_flow/core/presentation/widgets/af/af_animated_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(double value, {bool reduceMotion = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: AfAnimatedNumber(
          value: value,
          formatter: (v) => v.round().toString(),
          style: const TextStyle(fontSize: 20),
          semanticsPrefix: 'Total',
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('counts up to the final value', (tester) async {
    await tester.pumpWidget(_host(100));
    await tester.pump(const Duration(milliseconds: 100));
    final mid = int.parse((tester.widget<Text>(find.byType(Text)).data) ?? '0');
    expect(mid, inInclusiveRange(1, 99));

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('tweens from the previous value on update', (tester) async {
    await tester.pumpWidget(_host(100));
    await tester.pump(const Duration(milliseconds: 1100));

    await tester.pumpWidget(_host(200));
    await tester.pump(const Duration(milliseconds: 100));
    final mid = int.parse(tester.widget<Text>(find.byType(Text)).data!);
    expect(mid, inInclusiveRange(101, 199));

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('reduced motion shows the final value immediately', (
    tester,
  ) async {
    await tester.pumpWidget(_host(100, reduceMotion: true));
    await tester.pump();
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('semantics label is the final value, not the in-flight one', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(100));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.bySemanticsLabel('Total: 100'), findsOneWidget);
    handle.dispose();
  });
}
