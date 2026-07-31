// TEMPORARY TRIAL LOCK — remove when no longer needed
import 'package:ej_geek/core/trial/trial_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_pallete.dart';

/// Hidden unlock entry point: reveal via a long-press gesture (see
/// `custom_drawer.dart`). Resolves after `context.read<TrialController>().unlock(code)`.
class UnlockCodeDialog extends StatefulWidget {
  const UnlockCodeDialog({super.key});

  @override
  State<UnlockCodeDialog> createState() => _UnlockCodeDialogState();
}

class _UnlockCodeDialogState extends State<UnlockCodeDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await context.read<TrialController>().unlock(
      _controller.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('App unlocked')));
    } else {
      setState(() => _errorText = 'Incorrect code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkPillColor = isDark
        ? AppPallete.dynamicBlack
        : AppPallete.tricornBlack;

    return AlertDialog(
      title: Text(
        'Unlock App',
        style: TextStyle(
          color: isDark ? AppPallete.cascadingWhite : AppPallete.tricornBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Unlock code',
          errorText: _errorText,
        ),
      ),
      actions: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: darkPillColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppPallete.selectionGradient,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: _submit,
            child: const Text('Unlock', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
