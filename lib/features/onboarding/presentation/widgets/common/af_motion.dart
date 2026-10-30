import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';

/// Collapses a duration to zero when the OS asks for reduced motion.
Duration afDuration(BuildContext context, int milliseconds) =>
    MediaQuery.of(context).disableAnimations
    ? Duration.zero
    : Duration(milliseconds: milliseconds);

/// Scales its child to 0.97 while pressed (every AutoFlow button does this).
class AfPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const AfPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
  });

  @override
  State<AfPressable> createState() => _AfPressableState();
}

class _AfPressableState extends State<AfPressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: afDuration(context, 160),
        curve: AutoFlowTokens.easeOut,
        child: widget.child,
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

  const AfGlow({
    super.key,
    required this.width,
    required this.height,
    required this.blur,
    required this.opacity,
    this.period = const Duration(seconds: 4),
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
    if (MediaQuery.of(context).disableAnimations) {
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
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades + slides its child in from [dy] whenever [visible] flips on, after
/// [delay]. Used for the staggered entrances.
class AfReveal extends StatelessWidget {
  final bool visible;
  final int delayMs;
  final double dy;
  final Widget child;

  const AfReveal({
    super.key,
    required this.visible,
    required this.child,
    this.delayMs = 0,
    this.dy = 8,
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      key: ValueKey(visible),
      tween: Tween(begin: visible ? 0 : 1, end: visible ? 1 : 0),
      duration: reduced || !visible
          ? Duration.zero
          : Duration(milliseconds: 400 + delayMs),
      curve: Interval(
        visible && !reduced ? delayMs / (400 + delayMs) : 0,
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
