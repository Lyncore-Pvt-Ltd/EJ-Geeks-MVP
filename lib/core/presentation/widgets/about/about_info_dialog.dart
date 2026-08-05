import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../theme/app_pallete.dart';

class AboutInfoDialog extends StatelessWidget {
  const AboutInfoDialog({super.key, required this.packageInfo});

  final PackageInfo packageInfo;

  static const _company = 'LYNCORE Pvt. Ltd 2026';
  static const _developer = 'Arshvin Waduge';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkPillColor = isDark
        ? AppPallete.dynamicBlack
        : AppPallete.tricornBlack;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('About'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(context, 'Company', _company),
          const SizedBox(height: 12),
          _buildRow(context, 'Developer', _developer),
          const SizedBox(height: 12),
          _buildRow(
            context,
            'Version',
            '${packageInfo.version} (${packageInfo.buildNumber})',
          ),
        ],
      ),
      actions: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: darkPillColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Close', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
