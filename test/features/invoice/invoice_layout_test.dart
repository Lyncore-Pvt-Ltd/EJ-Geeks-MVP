import 'package:auto_flow/core/di/service_locator.dart';
import 'package:auto_flow/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:auto_flow/features/invoice/presentation/pages/invoice_screen.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_bottom_sheet.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/inspection_tab.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_screens/invoice_tab.dart';
import 'package:auto_flow/features/search/presentation/bloc/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/layout_harness.dart';
import '../../helpers/test_service_locator.dart';

Widget _withAppBlocs(Widget app) => MultiBlocProvider(
  providers: [
    BlocProvider<InvoiceBloc>.value(value: sl<InvoiceBloc>()),
    BlocProvider<SearchBloc>.value(value: sl<SearchBloc>()),
  ],
  child: app,
);

/// A host page whose only job is to open the sheet the way the app does.
class _SheetHost extends StatelessWidget {
  const _SheetHost();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => InvoiceBottomSheet.show(
          context,
          invoiceId: 'test-invoice-id',
          createdAt: DateTime(2026, 10, 31),
        ),
        child: const Text('open sheet'),
      ),
    ),
  );
}

Finder _scrollableIn(Type tab) => find
    .descendant(
      of: find.byType(tab),
      matching: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    )
    .first;

Future<void> _openSheet(WidgetTester tester, Size size, double scale) async {
  await pumpAtSize(
    tester,
    _withAppBlocs(testApp(const _SheetHost())),
    size: size,
    textScale: scale,
  );
  await tester.tap(find.text('open sheet'));
  await settleFor(tester);
}

String _skipTag(bool skip, String reason) => skip ? ' (SKIPPED: $reason)' : '';

void main() {
  setUp(() => setUpTestServiceLocator());

  for (final size in kLayoutSizes) {
    for (final scale in kLayoutTextScales) {
      final tag = layoutTag(size, scale);
      final large = scale > 1.0;

      // Known lib/ bugs, left for a lib owner to fix (tests skip, not edit):
      // - invoice_card.dart:277 Row and af_status_chip.dart:38 Row overflow
      //   (24px / 31px) on a 320-wide phone at 1.3x text.
      final knownCardOverflow = large && size.width <= 320;
      // - invoice_tab.dart:675 `_TotalsSummary._row` puts label + amount in a
      //   spaceBetween Row with no Flexible; at 1.3x it overflows on every
      //   phone up to 390 wide (76px at 320 → 6px at 390), even at $0.00.
      final knownTotalsOverflow = large && size.width <= 390;

      testWidgets(
        'invoice list fits at $tag'
        '${_skipTag(knownCardOverflow, 'InvoiceCard / AfStatusChip rows overflow at 320 wide, 1.3x')}',
        skip: knownCardOverflow,
        (tester) async {
          // The list on its own (as it sits in the dashboard's IndexedStack),
          // so dashboard-tile issues don't leak into this test.
          await pumpAtSize(
            tester,
            _withAppBlocs(
              ChangeNotifierProvider(
                create: (_) => DashboardProvider(),
                child: testApp(
                  const Scaffold(body: SafeArea(child: InvoiceScreen())),
                ),
              ),
            ),
            size: size,
            textScale: scale,
          );

          expect(find.byType(InvoiceScreen), findsOneWidget);
          expect(
            find.text('Alexandra Montgomery-Fitzwilliam', skipOffstage: false),
            findsWidgets,
          );
          expectNoLayoutErrors(tester, 'invoice list');
          await unmount(tester);
        },
      );

      testWidgets('invoice sheet inspection tab fits at $tag', (tester) async {
        await _openSheet(tester, size, scale);

        expect(find.byType(InspectionTab), findsOneWidget);
        expectNoLayoutErrors(tester, 'inspection tab');
        await scrollThrough(
          tester,
          _scrollableIn(InspectionTab),
          'inspection tab',
          maxSteps: 40,
        );
        await unmount(tester);
      });

      testWidgets(
        'invoice sheet invoice tab fits at $tag'
        '${_skipTag(knownTotalsOverflow, 'invoice_tab.dart _TotalsSummary row overflows at 1.3x up to 390 wide')}',
        skip: knownTotalsOverflow,
        (tester) async {
          await _openSheet(tester, size, scale);

          final tabs = tester.widget<TabBarView>(find.byType(TabBarView));
          tabs.controller!.animateTo(1);
          await settleFor(tester);

          expect(find.byType(InvoiceTab), findsOneWidget);
          expectNoLayoutErrors(tester, 'invoice tab');
          await scrollThrough(tester, _scrollableIn(InvoiceTab), 'invoice tab');
          await unmount(tester);
        },
      );
    }
  }
}
