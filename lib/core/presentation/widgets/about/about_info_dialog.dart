import 'package:auto_flow/core/presentation/widgets/af/af_secondary_button.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../widget/dialog_actions.dart';

class AboutInfoDialog extends StatelessWidget {
  const AboutInfoDialog({super.key, required this.packageInfo});

  final PackageInfo packageInfo;

  static const _company = 'LYNCORE Pvt. Ltd 2026';
  static const _developer = 'Arshvin Waduge';

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    return AlertDialog(
      title: Semantics(
        header: true,
        child: Text(
          'About',
          style: AutoFlowTokens.title.copyWith(color: tokens.ink),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(tokens, 'Company', Text(_company, style: _value(tokens))),
          const SizedBox(height: AfSpace.s12),
          _buildRow(
            tokens,
            'Developer',
            Text(_developer, style: _value(tokens)),
          ),
          const SizedBox(height: AfSpace.s12),
          _buildRow(
            tokens,
            'Version',
            Text(
              '${packageInfo.version} (${packageInfo.buildNumber})',
              style: AutoFlowTokens.mono(color: tokens.ink),
            ),
          ),
        ],
      ),
      actionsPadding: kDialogActionsPadding,
      actions: [
        DialogActions(
          children: [
            AfSecondaryButton(
              label: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle _value(AutoFlowTokens tokens) =>
      AutoFlowTokens.body.copyWith(color: tokens.ink);

  Widget _buildRow(AutoFlowTokens tokens, String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AutoFlowTokens.body.copyWith(color: tokens.mute),
          ),
        ),
        Expanded(child: value),
      ],
    );
  }
}
