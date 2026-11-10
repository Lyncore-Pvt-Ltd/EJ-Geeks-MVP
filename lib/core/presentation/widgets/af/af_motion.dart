import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:auto_flow/core/theme/autoflow_tokens.dart';

/// Collapses a duration to zero when the OS asks for reduced motion.
Duration afDuration(BuildContext context, int milliseconds) =>
    MediaQuery.of(context).disableAnimations
    ? Duration.zero
    : Duration(milliseconds: milliseconds);

/// Open 400ms / close 250ms on [AutoFlowTokens.drawer]; no animation under
/// reduced motion. Pass as `showModalBottomSheet(sheetAnimationStyle: ...)`.
AnimationStyle afSheetAnimation(BuildContext context) =>
    MediaQuery.of(context).disableAnimations
    ? AnimationStyle.noAnimation
    : const AnimationStyle(
        duration: Duration(milliseconds: 400),
        reverseDuration: Duration(milliseconds: 250),
        curve: AutoFlowTokens.drawer,
        reverseCurve: AutoFlowTokens.drawer,
      );

/// Scales its child to 0.97 while pressed (every AutoFlow button does this).
///
/// The pressed state is set on pointer-down (not after the tap recogniser's
/// delay), so even quick taps show the scale. It is focusable and activates
/// with Enter/Space, drawing an accent focus ring while keyboard-focused.
///
/// Use [AfPressable.builder] when the child needs to restyle itself while
/// pressed (e.g. a deeper fill).
class AfPressable extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, bool pressed)? builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;

  /// Corner radius of the keyboard focus ring (drawn just outside the child).
  final BorderRadius focusRadius;

  const AfPressable({
    super.key,
    required Widget this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.focusRadius = AfRadius.controlAll,
  }) : builder = null;

  const AfPressable.builder({
    super.key,
    required Widget Function(BuildContext context, bool pressed) this.builder,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.focusRadius = AfRadius.controlAll,
  }) : child = null;

  @override
  State<AfPressable> createState() => _AfPressableState();
}

class _AfPressableState extends State<AfPressable> {
  bool _pressed = false;
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
  };

  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  void _activate() => widget.onTap?.call();

  @override
  void didUpdateWidget(covariant AfPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap == null) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final pressed = enabled && _pressed;
    final content = widget.builder?.call(context, pressed) ?? widget.child!;
    return FocusableActionDetector(
      enabled: enabled,
      actions: _actions,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (value) {
        if (_focused != value) setState(() => _focused = value);
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: enabled ? (_) => _set(true) : null,
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onLongPress: enabled ? widget.onLongPress : null,
          // A drag/scroll that wins the arena releases the press early.
          onTapCancel: enabled ? () => _set(false) : null,
          child: AnimatedScale(
            scale: pressed ? widget.pressedScale : 1,
            duration: afDuration(context, 160),
            curve: AutoFlowTokens.easeOut,
            child: Stack(
              // Passthrough keeps the child's layout exactly as without
              // the ring (e.g. full-width buttons stay full width).
              fit: StackFit.passthrough,
              clipBehavior: Clip.none,
              children: [
                content,
                if (_focused && enabled)
                  Positioned(
                    left: -4,
                    top: -4,
                    right: -4,
                    bottom: -4,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              widget.focusRadius + BorderRadius.circular(4),
                          border: Border.all(
                            color: AutoFlowTokens.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shakes its child horizontally (360ms) every time [trigger] changes.
class AfShake extends StatefulWidget {
  final int trigger;
  final Widget child;

  const AfShake({super.key, required this.trigger, required this.child});

  @override
  State<AfShake> createState() => _AfShakeState();
}

class _AfShakeState extends State<AfShake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late final Animation<double> _offset =
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -6, end: 5), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 5, end: -3), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
      ]).animate(
        CurvedAnimation(parent: _controller, curve: AutoFlowTokens.easeOut),
      );

  @override
  void didUpdateWidget(covariant AfShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger &&
        !MediaQuery.of(context).disableAnimations) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) =>
          Transform.translate(offset: Offset(_offset.value, 0), child: child),
      child: widget.child,
    );
  }
}

/// A blurred accent blob that slowly "breathes" (opacity + scale loop).
class AfGlow extends StatefulWidget {
  final double width;
  final double height;
  final double blur;
  final double opacity;
  final Duration period;

  /// When false the breathing loop pauses (e.g. on an off-screen slide).
  final bool active;

  const AfGlow({
    super.key,
    required this.width,
    required this.height,
    required this.blur,
    required this.opacity,
    this.period = const Duration(seconds: 4),
    this.active = true,
  });

  @override
  State<AfGlow> createState() => _AfGlowState();
}

class _AfGlowState extends State<AfGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period ~/ 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant AfGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  void _sync() {
    if (!widget.active || MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Opacity(
            opacity: widget.opacity * lerpDouble(0.55, 0.8, t)!,
            child: Transform.scale(scale: lerpDouble(1, 1.08, t), child: child),
          );
        },
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: widget.blur,
            sigmaY: widget.blur,
            tileMode: TileMode.decal,
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AutoFlowTokens.accent,
              borderRadius: AfRadius.chipAll,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades + slides its child in from [dy] whenever [visible] flips on, after
/// [delayMs]. Used for the staggered entrances. [duration] is the length of
/// the fade/slide itself, not counting the delay.
class AfReveal extends StatelessWidget {
  final bool visible;
  final int delayMs;
  final double dy;
  final Duration duration;
  final Widget child;

  const AfReveal({
    super.key,
    required this.visible,
    required this.child,
    this.delayMs = 0,
    this.dy = 8,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    final total = duration.inMilliseconds + delayMs;
    return TweenAnimationBuilder<double>(
      key: ValueKey(visible),
      tween: Tween(begin: visible ? 0 : 1, end: visible ? 1 : 0),
      duration: reduced || !visible
          ? Duration.zero
          : Duration(milliseconds: total),
      curve: Interval(
        visible && !reduced && total > 0 ? delayMs / total : 0,
        1,
        curve: AutoFlowTokens.easeOut,
      ),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * dy),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Staggered screen entrance: waits `120 + 60 × index` ms, then fades and
/// rises 12px over 400ms. Typical order: header 0, content 1, 2, …
///
/// Plays once when first built (and again whenever [play] flips to true).
/// It doesn't replay on ordinary rebuilds, so Bloc/Provider updates and
/// pull-to-refresh are safe. [enabled] is read only when the widget mounts:
/// pass `false` for items that mount later (e.g. list rows scrolled back into
/// view) so they appear without an entrance, while keeping the same widget
/// tree shape.
class AfStaggerIn extends StatefulWidget {
  final int index;
  final bool play;
  final bool enabled;
  final Widget child;

  const AfStaggerIn({
    super.key,
    required this.index,
    required this.child,
    this.play = true,
    this.enabled = true,
  });

  @override
  State<AfStaggerIn> createState() => _AfStaggerInState();
}

class _AfStaggerInState extends State<AfStaggerIn> {
  late final bool _animate = widget.enabled;

  @override
  Widget build(BuildContext context) {
    if (!_animate) return widget.child;
    return AfReveal(
      visible: widget.play,
      delayMs: 120 + 60 * widget.index,
      dy: 12,
      child: widget.child,
    );
  }
}
