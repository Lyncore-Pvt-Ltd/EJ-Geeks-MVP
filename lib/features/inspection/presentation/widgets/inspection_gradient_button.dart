import 'package:auto_flow/core/presentation/widgets/af/af_primary_button.dart';
import 'package:flutter/material.dart';

/// Legacy name kept for existing callers. Renders the DESIGN.md primary
/// button ([AfPrimaryButton]: 48px, radius 10, accent fill). A null [onTap]
/// shows [AfPrimaryButton]'s built-in disabled look; [isLoading] swaps in
/// the busy label + spinner.
class InspectionGradientButton extends StatelessWidget {
  const InspectionGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AfPrimaryButton(label: label, onPressed: onTap, busy: isLoading),
    );
  }
}
