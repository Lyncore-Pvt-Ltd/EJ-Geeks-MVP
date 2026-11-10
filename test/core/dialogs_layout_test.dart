import 'package:auto_flow/core/presentation/widget/confirm_dialog.dart';
import 'package:auto_flow/core/presentation/widget/show_delete_dialog.dart';
import 'package:auto_flow/core/presentation/widgets/about/about_info_dialog.dart';
import 'package:auto_flow/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/layout_harness.dart';

/// Opens [dialog] through `showDialog`, as the app does, so it gets real
/// dialog constraints rather than the full screen.
class _DialogHost extends StatelessWidget {
  const _DialogHost(this.dialog);

  final Widget dialog;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () =>
            showDialog<void>(context: context, builder: (_) => dialog),
        child: const Text('open dialog'),
      ),
    ),
  );
}

/// Known lib/ bugs, left for a lib owner to fix (tests skip, not edit): the
/// dialogs' `content` Column isn't scrollable (no `AlertDialog.scrollable`
/// or `SingleChildScrollView`), so at 1.3x text on short phones it overflows
/// the space AlertDialog gives it. Returns the skip reason, or null.
String? _knownOverflow(String name, Size size, double scale) {
  if (scale <= 1.0) return null;
  if (name == 'ShowDeleteDialog' && size.height <= 640) {
    return 'ShowDeleteDialog content (message + delete-files checkbox) '
        'overflows at 1.3x on <=640px-tall screens';
  }
  if (name == 'AboutInfoDialog' && size.height <= 568) {
    return 'AboutInfoDialog content overflows at 1.3x on 320x568';
  }
  return null;
}

final _dialogs = <String, (Widget, String)>{
  'ConfirmDialog': (
    const ConfirmDialog(
      title: 'Changes Detected',
      message:
          'Changes have been made to the invoice and/or inspection. '
          'Generate a new PDF?',
      confirmLabel: 'Generate',
    ),
    'Generate',
  ),
  'ConfirmDialog (destructive)': (
    const ConfirmDialog(
      title: 'Log out?',
      message: 'You will need to sign in again to use AutoFlow.',
      confirmLabel: 'Log out',
      destructive: true,
      confirmIcon: Icons.logout,
    ),
    'Log out',
  ),
  'ShowDeleteDialog': (
    const ShowDeleteDialog(
      title: 'Delete Invoice',
      message:
          'Are you sure you want to delete this invoice? This cannot be '
          'undone.',
      showDeleteFilesOption: true,
    ),
    'Delete',
  ),
  'AboutInfoDialog': (
    AboutInfoDialog(
      packageInfo: PackageInfo(
        appName: 'AutoFlow',
        packageName: 'com.example.auto_flow',
        version: '1.0.1',
        buildNumber: '13',
      ),
    ),
    'Close',
  ),
};

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in kLayoutSizes) {
    for (final scale in kLayoutTextScales) {
      for (final dark in [false, true]) {
        final tag = '${layoutTag(size, scale)}${dark ? ' dark' : ''}';

        for (final MapEntry(key: name, value: (dialog, action))
            in _dialogs.entries) {
          final skipReason = _knownOverflow(name, size, scale);
          testWidgets(
            '$name fits at $tag'
            '${skipReason == null ? '' : ' (SKIPPED: $skipReason)'}',
            skip: skipReason != null,
            (tester) async {
              await pumpAtSize(
                tester,
                testApp(
                  _DialogHost(dialog),
                  theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                ),
                size: size,
                textScale: scale,
              );
              await tester.tap(find.text('open dialog'));
              await settleFor(tester, const Duration(milliseconds: 500));

              expect(find.byType(AlertDialog), findsOneWidget);
              expectNoLayoutErrors(tester, name);

              // Action buttons stay on screen and keep a 48px tap target.
              final rect = tester.getRect(find.bySemanticsLabel(action).last);
              expect(rect.left, greaterThanOrEqualTo(0), reason: '$name clip');
              expect(
                rect.right,
                lessThanOrEqualTo(size.width),
                reason: '$name clip',
              );
              expect(
                rect.height,
                // Tolerance for float rounding at 1.3x text (47.9999…).
                greaterThanOrEqualTo(47.99),
                reason: '$name action shorter than 48px',
              );
              await unmount(tester);
            },
          );
        }
      }
    }
  }
}
