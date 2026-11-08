import 'dart:async';

import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'af_motion.dart';
import 'af_spinner.dart';

enum _SaveStatus { idle, saving, saved }

/// A small 24px "Saving… ↔ Saved" pill that replaces success SnackBars.
///
/// Feed it a Bloc's [saving] flag and its [saveSucceeded] flag:
/// - [saving] turning on shows "Saving…" (hot fill + spinner);
/// - [saving] turning off with [saveSucceeded] true shows "Saved" (success
///   colours + check) for 1.5s, then the pill fades away;
/// - [saving] turning off without success just hides it (errors are reported
///   elsewhere).
///
/// Both states crossfade over 200ms and are announced as a live region.
class AfSaveStatus extends StatefulWidget {
  final bool saving;
  final bool saveSucceeded;

  const AfSaveStatus({
    super.key,
    required this.saving,
    required this.saveSucceeded,
  });

  @override
  State<AfSaveStatus> createState() => _AfSaveStatusState();
}

class _AfSaveStatusState extends State<AfSaveStatus> {
  static const _savedHold = Duration(milliseconds: 1500);

  late _SaveStatus _status = widget.saving
      ? _SaveStatus.saving
      : _SaveStatus.idle;
  Timer? _hideTimer;

  @override
  void didUpdateWidget(covariant AfSaveStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.saving && !oldWidget.saving) {
      _hideTimer?.cancel();
      _status = _SaveStatus.saving;
    } else if (!widget.saving && oldWidget.saving) {
      _hideTimer?.cancel();
      if (widget.saveSucceeded) {
        _status = _SaveStatus.saved;
        _hideTimer = Timer(_savedHold, () {
          if (mounted) setState(() => _status = _SaveStatus.idle);
        });
      } else {
        _status = _SaveStatus.idle;
      }
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final Widget pill = switch (_status) {
      _SaveStatus.idle => const SizedBox.shrink(key: ValueKey('idle')),
      _SaveStatus.saving => _Pill(
        key: const ValueKey('saving'),
        background: tokens.hot,
        foreground: tokens.ink,
        label: 'Saving…',
        leading: AfSpinner(size: 12, color: tokens.ink, track: tokens.line),
      ),
      _SaveStatus.saved => const _Pill(
        key: ValueKey('saved'),
        background: AutoFlowTokens.successBg,
        foreground: AutoFlowTokens.successFg,
        label: 'Saved',
        leading: Icon(
          Icons.check_rounded,
          size: 14,
          color: AutoFlowTokens.successFg,
        ),
      ),
    };
    return Semantics(
      liveRegion: true,
      child: AnimatedSwitcher(
        duration: afDuration(context, 200),
        switchInCurve: AutoFlowTokens.easeOut,
        switchOutCurve: AutoFlowTokens.easeOut,
        child: pill,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Color background;
  final Color foreground;
  final String label;
  final Widget leading;

  const _Pill({
    super.key,
    required this.background,
    required this.foreground,
    required this.label,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: AfSpace.s12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AfRadius.chipAll,
        boxShadow: AutoFlowTokens.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: AfSpace.s8),
          Text(
            label,
            style: AutoFlowTokens.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: foreground,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
