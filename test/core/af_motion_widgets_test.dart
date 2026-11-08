import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_save_status.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_text_field.dart';
import 'package:auto_flow/core/presentation/widgets/af/af_toolbar_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/layout_harness.dart';

/// Motion primitives added by the flutter-motion-design pass. Uses
/// `settleFor` (fixed pumps) instead of `pumpAndSettle`, per the skill.
void main() {
  Widget host(Widget child) =>
      testApp(Scaffold(body: Center(child: child)));

  group('AfTextField error line', () {
    testWidgets('a changed message crossfades, then only the new one stays', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      Widget field(String? error) => host(
        AfTextField(
          label: 'Work email',
          hint: 'you@example.com',
          controller: controller,
          onChanged: (_) {},
          errorText: error,
        ),
      );

      await tester.pumpWidget(field('Error A'));
      await settleFor(tester);
      expect(find.text('Error A'), findsOneWidget);

      await tester.pumpWidget(field('Error B'));
      await tester.pump(const Duration(milliseconds: 100));
      // Mid-transition: the old line is fading out under the new one.
      expect(find.text('Error A'), findsOneWidget);
      expect(find.text('Error B'), findsOneWidget);

      await settleFor(tester);
      expect(find.text('Error A'), findsNothing);
      expect(find.text('Error B'), findsOneWidget);

      await tester.pumpWidget(field(null));
      await settleFor(tester);
      expect(find.text('Error B'), findsNothing);
    });
  });

  group('AfSaveStatus', () {
    testWidgets('shows Saving…, then Saved, then hides', (tester) async {
      Widget pill({required bool saving, required bool ok}) =>
          host(AfSaveStatus(saving: saving, saveSucceeded: ok));

      await tester.pumpWidget(pill(saving: false, ok: false));
      expect(find.text('Saving…'), findsNothing);
      expect(find.text('Saved'), findsNothing);

      await tester.pumpWidget(pill(saving: true, ok: false));
      await settleFor(tester, const Duration(milliseconds: 300));
      expect(find.text('Saving…'), findsOneWidget);
      expect(_hasLiveRegionAncestor(find.text('Saving…')), isTrue);

      await tester.pumpWidget(pill(saving: false, ok: true));
      await settleFor(tester, const Duration(milliseconds: 300));
      expect(find.text('Saving…'), findsNothing);
      expect(find.text('Saved'), findsOneWidget);

      // Announced to screen readers as it changes.
      expect(_hasLiveRegionAncestor(find.text('Saved')), isTrue);

      await settleFor(tester, const Duration(seconds: 2));
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('a failed save just hides the pill', (tester) async {
      await tester.pumpWidget(
        host(const AfSaveStatus(saving: true, saveSucceeded: false)),
      );
      await settleFor(tester, const Duration(milliseconds: 300));
      expect(find.text('Saving…'), findsOneWidget);

      await tester.pumpWidget(
        host(const AfSaveStatus(saving: false, saveSucceeded: false)),
      );
      await settleFor(tester, const Duration(milliseconds: 300));
      expect(find.text('Saving…'), findsNothing);
      expect(find.text('Saved'), findsNothing);
    });
  });

  group('AfToolbarIconButton', () {
    testWidgets('taps, is labelled, and uses no Material ink', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          AfToolbarIconButton(
            icon: Icons.save,
            tooltip: 'Save',
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(AfToolbarIconButton));
      await settleFor(tester, const Duration(milliseconds: 300));
      expect(taps, 1);
      expect(find.bySemanticsLabel('Save'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(InkResponse), findsNothing);
    });
  });

  group('AfStaggerIn', () {
    double opacityOf(WidgetTester tester) => tester
        .widget<Opacity>(
          find.descendant(
            of: find.byType(AfStaggerIn),
            matching: find.byType(Opacity),
          ),
        )
        .opacity;

    testWidgets('starts hidden and is fully shown after its delay + 400ms', (
      tester,
    ) async {
      const index = 2;
      await tester.pumpWidget(
        host(const AfStaggerIn(index: index, child: Text('Block'))),
      );
      expect(opacityOf(tester), 0);

      // 120 + 60 × 2 = 240ms delay, + 400ms reveal.
      await settleFor(tester, const Duration(milliseconds: 240 + 400 + 100));
      expect(opacityOf(tester), 1);
    });

    testWidgets('enabled: false renders the child with no entrance', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AfStaggerIn(index: 0, enabled: false, child: Text('Block')),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(AfStaggerIn),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      expect(find.text('Block'), findsOneWidget);
    });
  });
}

bool _hasLiveRegionAncestor(Finder finder) {
  return find
      .ancestor(of: finder, matching: find.byType(Semantics))
      .evaluate()
      .map((e) => e.widget as Semantics)
      .any((s) => s.properties.liveRegion == true);
}
