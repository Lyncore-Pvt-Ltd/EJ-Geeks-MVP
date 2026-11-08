# Reference code

Copy-paste source for the tokens, widgets and motion patterns in `SKILL.md`.
Everything uses the `App*` prefix; rename it consistently if the project uses another.
Packages: `lucide_icons_flutter` (icons). Fonts: Geist Regular/SemiBold/Bold in
`assets/fonts/`, declared in `pubspec.yaml` under the family `Geist`.

Contents:
1. Tokens: colours (roles), motion, spacing, shadow, text, theme
2. Core widgets: Pressable, AppButton, AppSpinner, ErrorText, text controls, form fields, StatusBadge, bottom sheet, layout
3. Motion: page route, StaggerIn, status-text swap, PageIndicator, intro carousel, progress and steps
4. Decorative loops: colour cycle, staggered bars, connector link, code-box caret
5. Test helpers

---

## 1. Tokens — `lib/core/theme/`

### app_colors.dart (roles only; fill in your palette)

```dart
import 'package:flutter/painting.dart';

/// Colour ROLES used by every component. Replace `_unset` with your palette.
/// Keep the names; components depend on them.
const _unset = Color(0xFF000000);

abstract final class AppColors {
  static const ink = _unset;            // headings, primary text, dark button
  static const inkBody = _unset;        // body copy
  static const inkMuted = _unset;       // secondary text, captions
  static const inkFaint = _unset;       // placeholders, lock icon
  static const inkHover = _unset;       // dark button hover
  static const surface = _unset;        // page, cards, sheets
  static const surfaceAlt = _unset;     // field fill, empty boxes, skeleton blocks
  static const surfaceLocked = _unset;  // read-only field
  static const border = _unset;         // hairlines, borders, progress track
  static const indicatorIdle = _unset;  // idle pager dots, filled box border, spinner track
  static const primary = _unset;
  static const primaryHover = _unset;   // also errors, eyebrow, text action
  static const primaryPressed = _unset;
  static const accent = _unset;         // focus ring, focused border, flow dots
  static const tint = _unset;           // selected chip, focus halo, secondary hover
  static const tintStrong = _unset;     // secondary pressed, active pager track
  static const success = _unset;
  static const successBg = _unset;
  static const successText = _unset;
  static const scrim = _unset;          // modal barrier (ink @ ~50%)
  static const shadowTint = _unset;     // all elevation shadows (dark brand ink)
  static const white = Color(0xFFFFFFFF);

  /// 3-stop diagonal behind intro heroes.
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_unset, _unset, _unset],
    stops: [0, .55, 1],
  );
}
```

### app_motion.dart

```dart
import 'package:flutter/widgets.dart';

abstract final class AppCurves {
  /// Enter, press, UI feedback.
  static const easeOut = Cubic(0.23, 1, 0.32, 1);

  /// On-screen movement (page indicator).
  static const easeInOut = Cubic(0.77, 0, 0.175, 1);

  /// Page slides, bottom sheet, animateToPage.
  static const drawer = Cubic(0.32, 0.72, 0, 1);

  /// Decorative dots travelling along a line.
  static const flow = Cubic(.65, 0, .35, 1);
}

abstract final class AppDurations {
  static const press = Duration(milliseconds: 160);
  static const color = Duration(milliseconds: 150);
  static const crossfade = Duration(milliseconds: 200);
  static const pageSlide = Duration(milliseconds: 450);
  static const pageSlideReverse = Duration(milliseconds: 300);
  static const sheetOpen = Duration(milliseconds: 400);
  static const sheetClose = Duration(milliseconds: 250);
  static const indicator = Duration(milliseconds: 250);
  static const autoAdvance = Duration(seconds: 5);
  static const spinner = Duration(milliseconds: 600);
}

extension ReducedMotion on BuildContext {
  /// True when the OS asks for reduced motion. Keep opacity and colour
  /// transitions; drop translate/scale and looping decoration.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}
```

### app_spacing.dart

```dart
import 'package:flutter/painting.dart';

/// 8pt spacing grid (4 only for hairline gaps).
abstract final class AppSpace {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s64 = 64.0;

  /// Minimum tappable size.
  static const hit = 44.0;
  static const controlHeight = 56.0;
}

abstract final class AppRadius {
  static const badge = BorderRadius.all(Radius.circular(8));
  static const control = BorderRadius.all(Radius.circular(12));
  static const tile = BorderRadius.all(Radius.circular(16));
  static const card = BorderRadius.all(Radius.circular(20));
  static const panel = BorderRadius.vertical(top: Radius.circular(24));
  static const pill = BorderRadius.all(Radius.circular(999));
}
```

### app_shadow.dart

```dart
import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Shadows are always tinted with the brand ink, never grey or black.
abstract final class AppShadow {
  static List<BoxShadow> _s(double dy, double blur, double spread, Color c, double a) =>
      [BoxShadow(offset: Offset(0, dy), blurRadius: blur, spreadRadius: spread, color: c.withValues(alpha: a))];

  static final card = _s(24, 48, -16, AppColors.shadowTint, .20);
  static final tile = _s(12, 24, -12, AppColors.shadowTint, .20);
  static final panel = _s(-8, 24, -12, AppColors.shadowTint, .14);
  static final primary = _s(8, 16, -8, AppColors.primary, .55);
}
```

### app_text.dart

```dart
import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Geist type scale. Letter-spacing is in logical pixels (em × fontSize).
abstract final class AppText {
  static const family = 'Geist';

  static const display = TextStyle(fontFamily: family, fontSize: 44, height: 1, fontWeight: FontWeight.w700, letterSpacing: -1.76, color: AppColors.ink);
  static const title = TextStyle(fontFamily: family, fontSize: 28, height: 32 / 28, fontWeight: FontWeight.w700, letterSpacing: -0.84, color: AppColors.ink);
  static const heading = TextStyle(fontFamily: family, fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: AppColors.ink);
  static const action = TextStyle(fontFamily: family, fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: AppColors.primaryHover);
  static const body = TextStyle(fontFamily: family, fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.inkBody);
  static const button = TextStyle(fontFamily: family, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const label = TextStyle(fontFamily: family, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const eyebrow = TextStyle(fontFamily: family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: AppColors.primaryHover);
  static const caption = TextStyle(fontFamily: family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, color: AppColors.inkMuted);
  static const badge = TextStyle(fontFamily: family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: AppColors.successText);
}
```

### app_theme.dart

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppText.family,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.primaryHover,
      ),
    );
    return base.copyWith(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.tint,
        selectionHandleColor: AppColors.primary,
      ),
      focusColor: AppColors.accent.withValues(alpha: .12),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBarrierColor: AppColors.scrim,
      ),
    );
  }
}

/// Optional: runtime brand (white-label) injected into a subtree.
@immutable
class BrandTheme extends ThemeExtension<BrandTheme> {
  const BrandTheme({required this.brand, required this.name, required this.shortName});

  final Color brand;
  final String name;
  final String shortName;

  @override
  BrandTheme copyWith({Color? brand, String? name, String? shortName}) =>
      BrandTheme(brand: brand ?? this.brand, name: name ?? this.name, shortName: shortName ?? this.shortName);

  @override
  BrandTheme lerp(BrandTheme? other, double t) {
    if (other == null) return this;
    return BrandTheme(
      brand: Color.lerp(brand, other.brand, t)!,
      name: t < .5 ? name : other.name,
      shortName: t < .5 ? shortName : other.shortName,
    );
  }
}
```

---

## 2. Core widgets — `lib/core/widgets/`

### pressable.dart: the base for every custom tappable

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

@immutable
class PressState {
  const PressState({this.hovered = false, this.pressed = false});
  final bool hovered;
  final bool pressed;
}

/// Tap target with press scale, pointer-only hover, keyboard activation and a
/// 2dp accent focus ring (offset 4). Base for every custom control.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.builder,
    this.pressedScale = .97,
    this.focusRadius = const BorderRadius.all(Radius.circular(12)),
    this.semanticLabel,
    this.selected,
    this.excludeSemantics = false,
  });

  final VoidCallback? onTap;
  final Widget Function(BuildContext context, PressState state) builder;
  final double pressedScale;
  final BorderRadius focusRadius;
  final String? semanticLabel;
  final bool? selected;
  final bool excludeSemantics;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed && !context.reduceMotion ? widget.pressedScale : 1.0;
    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: widget.excludeSemantics,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap?.call();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: scale,
            duration: AppDurations.press,
            curve: AppCurves.easeOut,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.builder(context, PressState(hovered: _hovered, pressed: _pressed)),
                if (_focused)
                  Positioned(
                    left: -4, top: -4, right: -4, bottom: -4,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.accent, width: 2),
                          borderRadius: widget.focusRadius + const BorderRadius.all(Radius.circular(4)),
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
```

### app_spinner.dart

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// 18dp ring: track = [color] @ 35%, quarter-arc head = [color]. 600ms linear.
/// Keeps turning under reduced motion, since it signals progress.
class AppSpinner extends StatefulWidget {
  const AppSpinner({super.key, required this.color, this.size = 18, this.stroke = 2, this.trackColor});

  final Color color;
  final Color? trackColor;
  final double size;
  final double stroke;

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: AppDurations.spinner)..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _RingPainter(
          color: widget.color,
          track: widget.trackColor ?? widget.color.withValues(alpha: .35),
          stroke: widget.stroke,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.color, required this.track, required this.stroke});

  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    canvas.drawArc(rect, -math.pi * 3 / 4, math.pi / 2, false, paint..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color || old.track != track || old.stroke != stroke;
}
```

### app_button.dart: 56dp button with a loading crossfade

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_shadow.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'app_spinner.dart';
import 'pressable.dart';

enum AppButtonVariant { primary, secondary, dark, brand }

/// 56dp full-width button. Label flush left, trailing icon right.
/// While [loading], the label crossfades to [loadingLabel] with a spinner.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.loadingLabel,
    this.leading,
    this.trailingIcon = LucideIcons.arrowRight,
    this.brandColor,
  }) : assert(variant != AppButtonVariant.brand || brandColor != null);

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final String? loadingLabel;
  final Widget? leading;
  final IconData? trailingIcon;
  final Color? brandColor;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !loading;
    final reduce = context.reduceMotion;
    return AnimatedOpacity(
      opacity: disabled ? .5 : 1,
      duration: AppDurations.crossfade,
      child: Pressable(
        onTap: loading ? null : onPressed,
        semanticLabel: loading ? (loadingLabel ?? label) : label,
        excludeSemantics: true,
        builder: (context, state) {
          final s = _style(state);
          return AnimatedContainer(
            duration: AppDurations.color,
            height: AppSpace.controlHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s24),
            decoration: BoxDecoration(
              color: s.background,
              borderRadius: AppRadius.control,
              border: s.border,
              boxShadow: s.shadow,
            ),
            // 1dp inner top highlight (Flutter has no inset shadow).
            foregroundDecoration: s.highlight == null
                ? null
                : BoxDecoration(
                    borderRadius: AppRadius.control,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [s.highlight!, s.highlight!, Colors.transparent, Colors.transparent],
                      stops: const [0, 1 / 56, 1 / 56, 1],
                    ),
                  ),
            child: DefaultTextStyle.merge(
              style: AppText.button.copyWith(color: s.foreground),
              child: IconTheme.merge(
                data: IconThemeData(color: s.foreground, size: 20),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    _Layer(visible: !loading, offset: -.25, reduce: reduce, child: _idle()),
                    if (loadingLabel != null)
                      _Layer(
                        visible: loading,
                        offset: .25,
                        reduce: reduce,
                        child: Row(children: [
                          Expanded(child: Text(loadingLabel!, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          AppSpinner(color: s.foreground),
                        ]),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _idle() => Row(children: [
        if (leading != null) ...[leading!, const SizedBox(width: AppSpace.s12)],
        Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (trailingIcon != null) Icon(trailingIcon),
      ]);

  _ButtonStyle _style(PressState state) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _ButtonStyle(
          background: state.pressed ? AppColors.primaryPressed : state.hovered ? AppColors.primaryHover : AppColors.primary,
          foreground: AppColors.surface,
          shadow: AppShadow.primary,
          highlight: AppColors.white.withValues(alpha: .22),
        );
      case AppButtonVariant.secondary:
        return _ButtonStyle(
          background: state.pressed ? AppColors.tintStrong : state.hovered ? AppColors.tint : AppColors.surface.withValues(alpha: 0),
          foreground: AppColors.primaryHover,
          border: Border.all(color: AppColors.primary, width: 1.5),
        );
      case AppButtonVariant.dark:
        return _ButtonStyle(
          background: state.hovered || state.pressed ? AppColors.inkHover : AppColors.ink,
          foreground: AppColors.surface,
          highlight: AppColors.white.withValues(alpha: .14),
        );
      case AppButtonVariant.brand:
        // 8% darker on hover/press.
        final darker = Color.lerp(brandColor, AppColors.ink, .08)!;
        return _ButtonStyle(
          background: state.hovered || state.pressed ? darker : brandColor!,
          foreground: AppColors.white,
          highlight: AppColors.white.withValues(alpha: .22),
        );
    }
  }
}

class _ButtonStyle {
  const _ButtonStyle({required this.background, required this.foreground, this.border, this.shadow, this.highlight});
  final Color background;
  final Color foreground;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final Color? highlight;
}

/// Label ↔ loading crossfade: opacity + translateY ±0.25 over 200ms.
class _Layer extends StatelessWidget {
  const _Layer({required this.visible, required this.offset, required this.reduce, required this.child});

  final bool visible;
  final double offset;
  final bool reduce;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible || reduce ? Offset.zero : Offset(0, offset),
      duration: AppDurations.crossfade,
      curve: AppCurves.easeOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: AppDurations.crossfade,
        curve: AppCurves.easeOut,
        child: IgnorePointer(ignoring: !visible, child: child),
      ),
    );
  }
}
```

### error_text.dart: inline error, animated, announced to screen readers

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return AnimatedSwitcher(
      duration: AppDurations.crossfade,
      switchInCurve: AppCurves.easeOut,
      transitionBuilder: (child, animation) {
        final fade = FadeTransition(opacity: animation, child: child);
        if (reduce) return fade;
        return SlideTransition(
          position: Tween(begin: const Offset(0, -.2), end: Offset.zero).animate(animation),
          child: fade,
        );
      },
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, if (current != null) current],
      ),
      child: message == null
          ? const SizedBox(key: ValueKey(null), width: double.infinity)
          : Semantics(
              key: ValueKey(message),
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(LucideIcons.circleAlert, size: 16, color: AppColors.primaryHover),
                  ),
                  const SizedBox(width: AppSpace.s8),
                  Expanded(child: Text(message!, style: AppText.label.copyWith(color: AppColors.primaryHover))),
                ],
              ),
            ),
    );
  }
}
```

### text_controls.dart: text action, link, icon button, back button

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'pressable.dart';

/// "Next" / "Get started": no container, 20/28 label + trailing arrow.
class TextAction extends StatelessWidget {
  const TextAction({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      excludeSemantics: true,
      builder: (context, state) {
        final color = state.hovered || state.pressed ? AppColors.primaryPressed : AppColors.primaryHover;
        return SizedBox(
          height: AppSpace.hit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              AnimatedDefaultTextStyle(
                duration: AppDurations.color,
                style: AppText.action.copyWith(color: color),
                child: Text(label),
              ),
              const SizedBox(width: AppSpace.s8),
              Icon(LucideIcons.arrowRight, size: 22, color: color),
            ]),
          ),
        );
      },
    );
  }
}

/// Underlined inline link with a 44dp min height.
class TextLink extends StatelessWidget {
  const TextLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      excludeSemantics: true,
      builder: (context, state) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpace.hit),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: Text(
            label,
            style: AppText.label.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: state.hovered ? AppColors.primaryHover : AppColors.inkFaint,
              decorationThickness: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// 44×44 icon button (scale .94 on press).
class AppIconButton extends StatelessWidget {
  const AppIconButton({super.key, required this.icon, required this.onPressed, required this.semanticLabel, this.color = AppColors.ink});

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      pressedScale: .94,
      semanticLabel: semanticLabel,
      excludeSemantics: true,
      builder: (context, _) => SizedBox.square(dimension: AppSpace.hit, child: Icon(icon, size: 22, color: color)),
    );
  }
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Visually align the arrow with the 24dp gutter.
    return Transform.translate(
      offset: const Offset(-10, 0),
      child: AppIconButton(icon: LucideIcons.arrowLeft, onPressed: onPressed, semanticLabel: 'Back'),
    );
  }
}
```

### form_fields.dart: label, text field, locked field, choice chips

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'pressable.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(text: text, children: [
        if (optional)
          TextSpan(text: ' (optional)', style: AppText.label.copyWith(fontWeight: FontWeight.w400, color: AppColors.inkMuted)),
      ]),
      style: AppText.label,
    );
  }
}

InputDecoration appInputDecoration({String? hint, bool hasError = false}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(borderRadius: AppRadius.control, borderSide: BorderSide(color: color, width: width));
  return InputDecoration(
    hintText: hint,
    hintStyle: AppText.body.copyWith(color: AppColors.inkFaint),
    filled: true,
    fillColor: AppColors.surfaceAlt,
    contentPadding: const EdgeInsets.all(AppSpace.s16),
    border: border(AppColors.border),
    enabledBorder: hasError ? border(AppColors.primaryHover) : border(AppColors.border),
    focusedBorder: border(hasError ? AppColors.primaryHover : AppColors.accent, 2),
  );
}

/// 56dp text field with a label above it.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.optional = false,
    this.hint,
    this.hasError = false,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.semanticLabel,
  });

  final TextEditingController controller;
  final String? label;
  final bool optional;
  final String? hint;
  final bool hasError;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final field = Semantics(
      label: semanticLabel ?? label,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        style: AppText.body.copyWith(color: AppColors.ink),
        decoration: appInputDecoration(hint: hint, hasError: hasError),
      ),
    );
    if (label == null) return field;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      FieldLabel(label!, optional: optional),
      const SizedBox(height: AppSpace.s8),
      field,
    ]);
  }
}

/// Read-only value with a lock icon.
class LockedField extends StatelessWidget {
  const LockedField({super.key, required this.value, required this.semanticLabel});

  final String value;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: value,
      readOnly: true,
      excludeSemantics: true,
      child: Container(
        height: AppSpace.controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLocked,
          borderRadius: AppRadius.control,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body.copyWith(color: AppColors.inkMuted))),
          const SizedBox(width: AppSpace.s12),
          const Icon(LucideIcons.lock, size: 18, color: AppColors.inkFaint),
        ]),
      ),
    );
  }
}

/// Single-select chips; tapping the selected chip deselects it.
class AppChoiceChips extends StatelessWidget {
  const AppChoiceChips({super.key, required this.options, required this.selected, required this.onSelected});

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.s8,
      runSpacing: AppSpace.s8,
      children: [
        for (final option in options)
          Semantics(
            inMutuallyExclusiveGroup: true,
            checked: option == selected,
            child: Pressable(
              onTap: () => onSelected(option == selected ? null : option),
              semanticLabel: option,
              excludeSemantics: true,
              builder: (context, state) {
                final sel = option == selected;
                return AnimatedContainer(
                  duration: AppDurations.color,
                  height: AppSpace.hit,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.tint : AppColors.surface,
                    borderRadius: AppRadius.control,
                    border: Border.all(color: sel ? AppColors.primary : state.hovered ? AppColors.accent : AppColors.border),
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(option, style: AppText.label.copyWith(color: sel ? AppColors.primaryPressed : AppColors.ink)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
```

Conditional field reveal and the busy state of a form:

```dart
AnimatedOpacity(
  opacity: isSaving ? .55 : 1,
  duration: AppDurations.crossfade,
  child: IgnorePointer(ignoring: isSaving, child: form),
);

AnimatedSize(
  duration: AppDurations.crossfade,
  curve: AppCurves.easeOut,
  alignment: Alignment.topCenter,
  child: showOther
      ? Padding(padding: const EdgeInsets.only(top: AppSpace.s8), child: AppTextField(controller: c, hint: '…'))
      : const SizedBox(width: double.infinity),
);
```

### status_badge.dart: pill with an optional "live" ping

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.live = false});

  final String label;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s8, vertical: 2),
      decoration: const BoxDecoration(color: AppColors.successBg, borderRadius: AppRadius.pill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox.square(dimension: 6, child: live && !context.reduceMotion ? const _Ping() : const _Dot()),
        const SizedBox(width: AppSpace.s8),
        Text(label, style: AppText.badge),
      ]),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) =>
      const DecoratedBox(decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle));
}

/// Duplicate dot scales 1 → 2.6 and fades .6 → 0 every 1600ms.
class _Ping extends StatefulWidget {
  const _Ping();
  @override
  State<_Ping> createState() => _PingState();
}

class _PingState extends State<_Ping> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  late final _t = CurvedAnimation(parent: _controller, curve: AppCurves.easeOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, fit: StackFit.expand, children: [
      AnimatedBuilder(
        animation: _t,
        builder: (context, child) => Opacity(
          opacity: .6 * (1 - _t.value),
          child: Transform.scale(scale: 1 + 1.6 * _t.value, child: child),
        ),
        child: const _Dot(),
      ),
      const _Dot(),
    ]);
  }
}
```

### help_sheet.dart: bottom sheet

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'app_button.dart';

/// Opens in 400ms, closes in 250ms (drawer curve); tap the scrim to dismiss.
Future<void> showHelpSheet(BuildContext context, {required String eyebrow, required String title, required String body, String action = 'Got it'}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.panel),
    sheetAnimationStyle: const AnimationStyle(
      duration: AppDurations.sheetOpen,
      reverseDuration: AppDurations.sheetClose,
      curve: AppCurves.drawer,
    ),
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.s24, AppSpace.s32, AppSpace.s24, AppSpace.s40),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(eyebrow.toUpperCase(), style: AppText.eyebrow),
          const SizedBox(height: AppSpace.s16),
          Semantics(header: true, child: Text(title, style: AppText.title.copyWith(letterSpacing: -0.42))),
          const SizedBox(height: AppSpace.s16),
          Text(body, style: AppText.body),
          const SizedBox(height: AppSpace.s24),
          AppButton(label: action, variant: AppButtonVariant.dark, trailingIcon: null, onPressed: () => Navigator.of(context).pop()),
        ]),
      ),
    ),
  );
}
```

### layout.dart: screen heading, overlapping panel, monogram

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadow.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// Eyebrow / title / body header used on every screen.
class ScreenHeading extends StatelessWidget {
  const ScreenHeading({super.key, required this.eyebrow, required this.title, this.body});

  final String eyebrow;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(eyebrow.toUpperCase(), style: AppText.eyebrow),
      const SizedBox(height: AppSpace.s12),
      Semantics(header: true, child: Text(title, style: AppText.title)),
      if (body != null) ...[const SizedBox(height: AppSpace.s12), Text(body!, style: AppText.body)],
    ]);
  }
}

/// Surface sheet (top radius 24) that overlaps a hero by 24dp.
class OverlappingPanel extends StatelessWidget {
  const OverlappingPanel({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(32, 32, 32, 0)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.panel, boxShadow: AppShadow.panel),
      child: child,
    );
  }
}

/// Square initials tile; recolours over 600ms.
class MonogramTile extends StatelessWidget {
  const MonogramTile({super.key, required this.text, required this.background, required this.foreground, this.size = 40, this.fontSize = 14});

  final String text;
  final Color background;
  final Color foreground;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.control),
      child: Text(text, style: AppText.label.copyWith(fontSize: fontSize, height: 1, fontWeight: FontWeight.w700, color: foreground)),
    );
  }
}
```

---

## 3. Motion patterns

### Page route: slide with parallax, or a fade under reduced motion

```dart
Route<T> appRoute<T>(RouteSettings settings, Widget page) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: AppDurations.pageSlide,
    reverseTransitionDuration: AppDurations.pageSlideReverse,
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      if (context.reduceMotion) return FadeTransition(opacity: animation, child: child);
      final curved = CurvedAnimation(parent: animation, curve: AppCurves.drawer, reverseCurve: Curves.easeOut);
      final behind = CurvedAnimation(parent: secondary, curve: AppCurves.drawer, reverseCurve: Curves.easeOut);
      return SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
        child: SlideTransition(
          position: Tween(begin: Offset.zero, end: const Offset(-.25, 0)).animate(behind),
          child: child,
        ),
      );
    },
  );
}
// MaterialApp(onGenerateRoute: (s) => appRoute(s, pageFor(s.name)))
```

### stagger_in.dart: screen entrance

```dart
import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Fades in (300ms) and rises 12dp (400ms), delayed 120ms + 60ms × [index].
/// With [scale], grows 0.9 → 1 instead. Replays whenever [play] turns true.
class StaggerIn extends StatefulWidget {
  const StaggerIn({super.key, required this.index, required this.child, this.play = true, this.scale = false});

  final int index;
  final Widget child;
  final bool play;
  final bool scale;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn> with SingleTickerProviderStateMixin {
  static const _fade = 300;
  static const _move = 400;

  late final int _delay = 120 + 60 * widget.index;
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(milliseconds: _delay + _move));
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Interval(_delay / (_delay + _move), (_delay + _fade) / (_delay + _move), curve: Curves.ease),
  );
  late final Animation<double> _motion = CurvedAnimation(
    parent: _controller,
    curve: Interval(_delay / (_delay + _move), 1, curve: AppCurves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    if (widget.play) _controller.forward();
  }

  @override
  void didUpdateWidget(StaggerIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _motion.value;
        Widget result = child!;
        if (!reduce) {
          result = widget.scale
              ? Transform.scale(scale: .9 + .1 * t, alignment: Alignment.bottomLeft, child: result)
              : Transform.translate(offset: Offset(0, 12 * (1 - t)), child: result);
        }
        return Opacity(opacity: _opacity.value, child: result);
      },
      child: widget.child,
    );
  }
}
```

Usage:

```dart
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  StaggerIn(index: 0, child: Text('STEP 1 OF 2', style: AppText.eyebrow)),
  const SizedBox(height: AppSpace.s12),
  StaggerIn(index: 1, child: Semantics(header: true, child: Text('Title', style: AppText.title))),
  const SizedBox(height: AppSpace.s12),
  const StaggerIn(index: 2, child: Text('Body…', style: AppText.body)),
]);
```

### Status-text swap: the incoming line rises 8dp, the outgoing line lifts 8dp

```dart
SizedBox(
  height: 28,
  child: AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    switchInCurve: AppCurves.easeOut,
    layoutBuilder: (current, previous) =>
        Stack(alignment: Alignment.centerLeft, children: [...previous, if (current != null) current]),
    transitionBuilder: (child, animation) {
      final incoming = child.key == ValueKey(done ? 'done' : 'working');
      final offset = Tween(begin: Offset(0, incoming ? 8 / 28 : -8 / 28), end: Offset.zero).animate(animation);
      return FadeTransition(
        opacity: animation,
        child: context.reduceMotion ? child : SlideTransition(position: offset, child: child),
      );
    },
    child: done
        ? Text('All good', key: const ValueKey('done'), style: AppText.heading)
        : Text('Checking…', key: const ValueKey('working'), style: AppText.heading.copyWith(color: AppColors.inkMuted)),
  ),
);
```

### page_indicator.dart: pill pager that fills with progress

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Active dot widens 8 → 32 and fills left → right with [progress] (0–1).
class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.count, required this.current, required this.progress, required this.onSelect});

  final int count;
  final int current;
  final Animation<double> progress;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Progress',
      container: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < count; i++)
          Semantics(
            button: true,
            selected: i == current,
            label: 'Go to card ${i + 1}',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(i),
              child: SizedBox(
                height: AppSpace.hit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.s8),
                  child: Center(child: _Pill(active: i == current, progress: progress)),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.active, required this.progress});

  final bool active;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.indicator,
      curve: AppCurves.easeOut,
      width: active ? 32 : 8,
      height: 8,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: active ? AppColors.tintStrong : AppColors.indicatorIdle, borderRadius: AppRadius.pill),
      child: active
          ? AnimatedBuilder(
              animation: progress,
              builder: (context, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.value,
                child: const DecoratedBox(decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.pill)),
              ),
            )
          : null,
    );
  }
}
```

### Intro carousel: auto-advance, pause while dragging, fixed gradient layer

```dart
class IntroCarousel extends StatefulWidget {
  const IntroCarousel({super.key, required this.cards, required this.onStart});
  final List<IntroCard> cards; // eyebrow, title, body, hero builder(bool play)
  final VoidCallback onStart;
  @override
  State<IntroCarousel> createState() => _IntroCarouselState();
}

class _IntroCarouselState extends State<IntroCarousel> with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late final _fill = AnimationController(vsync: this);
  int _page = 0;
  bool _dragging = false;

  bool get _isLast => _page == widget.cards.length - 1;

  @override
  void initState() {
    super.initState();
    _fill.addStatusListener((s) {
      if (s == AnimationStatus.completed && !_isLast && !_dragging) _goTo(_page + 1);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartFill();
  }

  @override
  void dispose() {
    _fill.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Cards 1..n-1 fill over 5s then auto-advance; the last fills in 400ms.
  /// Reduced motion: no auto-advance, pill shown full.
  void _restartFill() {
    if (context.reduceMotion) {
      _fill.value = 1;
      return;
    }
    if (_isLast) {
      _fill
        ..duration = const Duration(milliseconds: 400)
        ..value = 0
        ..animateTo(1, curve: AppCurves.easeOut);
    } else {
      _fill.duration = AppDurations.autoAdvance;
      _fill.forward(from: 0);
    }
  }

  void _goTo(int page) =>
      _pageController.animateToPage(page, duration: AppDurations.pageSlide, curve: AppCurves.drawer);

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _dragging = true;
      _fill.stop();
    } else if (n is ScrollEndNotification && _dragging) {
      _dragging = false;
      _restartFill();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final heroHeight = math.min(464.0, media.size.height * .52);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(children: [
        // Fixed gradient behind the PageView, so swipes and overscroll show it.
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: AppColors.heroGradient))),
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (p) {
              setState(() => _page = p);
              _restartFill();
            },
            itemBuilder: (context, i) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                height: heroHeight - AppSpace.s24, // the panel overlaps by 24
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.s32, 0, AppSpace.s32, AppSpace.s40),
                  child: Align(alignment: Alignment.bottomLeft, child: widget.cards[i].hero(i == _page)),
                ),
              ),
              Expanded(
                child: OverlappingPanel(
                  padding: EdgeInsets.fromLTRB(AppSpace.s32, AppSpace.s32, AppSpace.s32, 108 + media.padding.bottom),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      StaggerIn(index: 2, play: i == _page, child: Text(widget.cards[i].eyebrow.toUpperCase(), style: AppText.eyebrow)),
                      const SizedBox(height: AppSpace.s12),
                      StaggerIn(index: 3, play: i == _page, child: Semantics(header: true, child: Text(widget.cards[i].title, style: AppText.title))),
                      const SizedBox(height: AppSpace.s12),
                      StaggerIn(index: 4, play: i == _page, child: Text(widget.cards[i].body, style: AppText.body)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
        Positioned(
          top: media.padding.top + AppSpace.s8,
          right: AppSpace.s16,
          child: Pressable(
            onTap: widget.onStart,
            pressedScale: .96,
            semanticLabel: 'Skip intro',
            excludeSemantics: true,
            builder: (context, _) => const SizedBox(
              height: AppSpace.hit,
              child: Padding(padding: EdgeInsets.symmetric(horizontal: AppSpace.s12), child: Center(child: Text('Skip', style: AppText.label))),
            ),
          ),
        ),
        Positioned(
          left: AppSpace.s24,
          right: AppSpace.s24,
          bottom: AppSpace.s40 + media.padding.bottom,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Transform.translate(
              offset: const Offset(-AppSpace.s8, 0),
              child: PageIndicator(count: widget.cards.length, current: _page, progress: _fill, onSelect: _goTo),
            ),
            TextAction(label: _isLast ? 'Get started' : 'Next', onPressed: _isLast ? widget.onStart : () => _goTo(_page + 1)),
          ]),
        ),
      ]),
    );
  }
}
```

### Progress bar and step rows

```dart
Semantics(
  label: 'Progress',
  value: '${(done / total * 100).round()}%',
  child: SizedBox(
    height: 4,
    child: ColoredBox(
      color: AppColors.border,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: done / total),
        duration: const Duration(milliseconds: 400),
        curve: AppCurves.easeOut,
        builder: (context, value, _) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: const ColoredBox(color: AppColors.primary),
        ),
      ),
    ),
  ),
);

enum StepState { pending, active, done }

class StepRow extends StatelessWidget {
  const StepRow({super.key, required this.label, required this.state});
  final String label;
  final StepState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: state == StepState.pending ? .45 : 1,
      duration: AppDurations.crossfade,
      child: Container(
        height: 56,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          AnimatedContainer(
            duration: AppDurations.crossfade,
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: switch (state) {
                StepState.done => AppColors.primary,
                StepState.active => AppColors.tint,
                StepState.pending => AppColors.surfaceAlt,
              },
              borderRadius: AppRadius.badge,
            ),
            child: switch (state) {
              StepState.done => const Icon(LucideIcons.check, size: 16, color: AppColors.surface),
              StepState.active => const AppSpinner(color: AppColors.primary, trackColor: AppColors.indicatorIdle, size: 14),
              StepState.pending => null,
            },
          ),
          const SizedBox(width: AppSpace.s16),
          Expanded(child: Text(label, style: AppText.button, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}
```

---

## 4. Decorative loops (all off under reduced motion)

Start and stop controllers in `didChangeDependencies` so the OS setting is picked up live:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (context.reduceMotion) {
    _controller.value = 1; // or .stop(), and show the end state
  } else if (!_controller.isAnimating) {
    _controller.repeat();
  }
}
```

### Colour cycle (a preview card recolours itself)

```dart
Timer? _timer;
int _index = 0;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (context.reduceMotion) {
    _timer?.cancel();
    _timer = null;
  } else {
    _timer ??= Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted) setState(() => _index = (_index + 1) % samples.length);
    });
  }
}
// header: AnimatedContainer(duration: 600ms, color: samples[_index].color, height: 96, ...)
// swatches: 20dp circles; the active one gets
//   boxShadow: [BoxShadow(color: AppColors.surface, spreadRadius: 2), BoxShadow(color: c, spreadRadius: 4)]
//   animated over 200ms.
```

### Staggered bar growth, then a status flip

```dart
static const _bars = 30;
static const _ticks = 65;               // 70ms per tick per loop
static const _barTicks = 250 / 70;      // each bar grows over 250ms
late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: _ticks * 70));

// in build (AnimatedBuilder on _controller):
final tick = _controller.value * _ticks;
final finished = tick >= _bars + _barTicks; // drives the status-text swap
Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
  for (var i = 0; i < _bars; i++) ...[
    if (i > 0) const SizedBox(width: 3),
    Expanded(child: _bar(((tick - i) / _barTicks).clamp(0.0, 1.0))),
  ],
]);

Widget _bar(double t) => Opacity(
      opacity: .25 + .75 * t,
      child: Transform.scale(
        scaleY: .15 + .85 * AppCurves.easeOut.transform(t),
        alignment: Alignment.bottomCenter,
        child: DecoratedBox(decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(2))),
      ),
    );
```

### Connector link (A ⟷ B): flow dots, then fill, then the check pop

```dart
class _LinkState extends State<Link> with TickerProviderStateMixin {
  late final _flow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final _fill = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

  void _syncFlow() {
    final idle = !widget.working && !widget.done;
    if (idle && !context.reduceMotion) {
      if (!_flow.isAnimating) _flow.repeat();
    } else {
      _flow.stop();
    }
  }

  @override
  void didChangeDependencies() { super.didChangeDependencies(); _syncFlow(); }

  @override
  void didUpdateWidget(Link old) {
    super.didUpdateWidget(old);
    if (widget.working || widget.done) {
      _fill.animateTo(1, curve: AppCurves.easeOut);
    } else {
      _fill.value = 0;
    }
    _syncFlow();
  }

  @override
  void dispose() { _flow.dispose(); _fill.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    final tileScale = widget.done && !reduce ? 1.04 : 1.0;
    Widget tile(Widget child) => AnimatedScale(
          scale: tileScale,
          duration: const Duration(milliseconds: 300),
          curve: AppCurves.easeOut,
          child: Container(
            width: 64, height: 64, alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.tile,
                border: Border.all(color: AppColors.border), boxShadow: AppShadow.tile),
            child: child,
          ),
        );
    return ExcludeSemantics(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        tile(widget.left),
        const SizedBox(width: AppSpace.s12),
        SizedBox(
          width: 56, height: 24,
          child: Stack(clipBehavior: Clip.none, children: [
            const Positioned(left: 0, right: 0, top: 11, height: 2, child: ColoredBox(color: AppColors.border)),
            Positioned(left: 0, right: 0, top: 11, height: 2,
              child: AnimatedBuilder(animation: _fill, builder: (_, __) => FractionallySizedBox(
                alignment: Alignment.centerLeft, widthFactor: _fill.value,
                child: const ColoredBox(color: AppColors.primary)))),
            if (!widget.working && !widget.done && !reduce) ...[
              _FlowDot(animation: _flow, phase: 0),
              _FlowDot(animation: _flow, phase: .5),
            ],
            Positioned(left: 16, top: 0,
              child: AnimatedOpacity(
                opacity: widget.done ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: widget.done || reduce ? 1 : .9,
                  duration: const Duration(milliseconds: 300),
                  curve: AppCurves.easeOut,
                  child: Container(width: 24, height: 24,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.check, size: 14, color: AppColors.surface)),
                ),
              )),
          ]),
        ),
        const SizedBox(width: AppSpace.s12),
        tile(widget.right),
      ]),
    );
  }
}

/// Dot that travels 0 → 50dp, fading in and out over the first and last 15%.
class _FlowDot extends StatelessWidget {
  const _FlowDot({required this.animation, required this.phase});
  final Animation<double> animation;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0, top: 9,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = (animation.value + phase) % 1;
          final x = 50 * AppCurves.flow.transform(t);
          final opacity = t < .15 ? t / .15 : (t > .85 ? (1 - t) / .15 : 1.0);
          return Transform.translate(offset: Offset(x, 0), child: Opacity(opacity: opacity, child: child));
        },
        child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
      ),
    );
  }
}
```

### Code boxes: box states and caret

One invisible `TextField` (`Opacity(0)` in `Positioned.fill`, `showCursor: false`,
`autofillHints: [AutofillHints.oneTimeCode]`, an uppercasing/stripping formatter) sits on top
of a row of `_Box`es that rebuild from the controller and focus listeners.

```dart
class _Box extends StatelessWidget {
  const _Box({required this.char, required this.active, required this.hasError});
  final String char;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final filled = char.isNotEmpty;
    final (Color borderColor, double width) = hasError
        ? (AppColors.primaryHover, 2)
        : active
            ? (AppColors.primary, 2)
            : (filled ? AppColors.indicatorIdle : AppColors.border, 1);
    return AnimatedContainer(
      duration: AppDurations.color,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.surface : AppColors.surfaceAlt,
        borderRadius: AppRadius.control,
        border: Border.all(color: borderColor, width: width),
        boxShadow: active && !hasError ? const [BoxShadow(color: AppColors.tint, spreadRadius: 4)] : null,
      ),
      child: filled ? Text(char, style: AppText.heading.copyWith(letterSpacing: 0)) : active ? const _Caret() : null,
    );
  }
}

/// 2×24 caret, 1s square-wave blink; static under reduced motion.
class _Caret extends StatefulWidget {
  const _Caret();
  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(opacity: _controller.value < .5 ? 1 : 0, child: child),
      child: Container(width: 2, height: 24,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(1))),
    );
  }
}
```

---

## 5. Test helpers

```dart
/// Pages loop decorative animations, so pumpAndSettle would time out.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Reduced-motion wrapper for tests.
Widget reducedMotion(Widget child) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child,
      ),
    );
```
