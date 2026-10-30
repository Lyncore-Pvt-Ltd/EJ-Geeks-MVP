import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';
import '../common/af_motion.dart';
import '../common/af_pop_in.dart';
import '../common/af_spinner.dart';
import '../common/af_status_chip.dart';

const _photoCount = 4;

/// Slide 3: a camera viewfinder, four photos uploading one by one, then the
/// report is shared with the customer.
class PhotoIllustration extends StatelessWidget {
  final bool active;
  final int tick;

  const PhotoIllustration({
    super.key,
    required this.active,
    required this.tick,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    // 0..3 = photo uploading, 4 = sharing, 5 = awaiting approval.
    final step = active ? tick % 6 : 5;

    return SizedBox(
      width: 326,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Viewfinder(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Inspection photos',
                    style: AutoFlowTokens.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: tokens.ink,
                    ),
                  ),
                ),
                Text(
                  '${step.clamp(0, _photoCount)} / $_photoCount',
                  style: AutoFlowTokens.mono(color: tokens.mute),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < _photoCount; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AfReveal(
                    visible: active,
                    delayMs: 200 + i * 60,
                    child: _Thumb(
                      uploaded: i < step,
                      uploading: active && i == step,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tokens.line),
              boxShadow: AutoFlowTokens.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: tokens.navy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.ios_share_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shared with customer',
                        style: AutoFlowTokens.caption.copyWith(
                          fontWeight: FontWeight.w500,
                          color: tokens.ink,
                        ),
                      ),
                      Text(
                        'Report with photo evidence',
                        style: AutoFlowTokens.caption.copyWith(
                          color: tokens.mute,
                        ),
                      ),
                    ],
                  ),
                ),
                if (step == 4)
                  AfSpinner(
                    size: 16,
                    color: AutoFlowTokens.accent,
                    track: tokens.line,
                    period: const Duration(milliseconds: 700),
                  )
                else if (step >= 5)
                  const AfPopIn(
                    child: AfStatusChip(
                      label: 'Awaiting approval',
                      background: AutoFlowTokens.warningBg,
                      foreground: AutoFlowTokens.warningFg,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    const corner = BorderSide(color: AutoFlowTokens.accent, width: 2);
    Widget bracket({double? top, double? bottom, double? left, double? right}) {
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              top: top != null ? corner : BorderSide.none,
              bottom: bottom != null ? corner : BorderSide.none,
              left: left != null ? corner : BorderSide.none,
              right: right != null ? corner : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.navy,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AutoFlowTokens.heroShadow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AutoFlowTokens.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Photo inspection · Wheels & Brakes',
                  style: AutoFlowTokens.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AutoFlowTokens.accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'HD',
                style: AutoFlowTokens.mono(color: AutoFlowTokens.onAccent),
              ),
            ),
          ),
          bracket(top: 40, left: 40),
          bracket(top: 40, right: 40),
          bracket(bottom: 12, left: 40),
          bracket(bottom: 12, right: 40),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: _PulsingShutter(),
          ),
        ],
      ),
    );
  }
}

class _PulsingShutter extends StatefulWidget {
  const _PulsingShutter();

  @override
  State<_PulsingShutter> createState() => _PulsingShutterState();
}

class _PulsingShutterState extends State<_PulsingShutter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shutter = Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AutoFlowTokens.accent,
        shape: BoxShape.circle,
      ),
    );
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = AutoFlowTokens.easeOut.transform(_controller.value);
              return Opacity(
                opacity: 0.7 * (1 - t),
                child: Transform.scale(scale: 1 + 1.2 * t, child: child),
              );
            },
            child: shutter,
          ),
          shutter,
          const Icon(
            Icons.photo_camera_outlined,
            size: 18,
            color: AutoFlowTokens.onAccent,
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final bool uploaded;
  final bool uploading;

  const _Thumb({required this.uploaded, required this.uploading});

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Container(
      height: 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.line,
        borderRadius: BorderRadius.circular(16),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: uploading ? AutoFlowTokens.accent : const Color(0x00FCA311),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.image_outlined, size: 18, color: tokens.mute),
          if (uploading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 3,
              child: ColoredBox(
                color: const Color(0x1F14213D),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: afDuration(context, 1400),
                  curve: AutoFlowTokens.easeOut,
                  builder: (context, t, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: t,
                    child: const ColoredBox(color: AutoFlowTokens.accent),
                  ),
                ),
              ),
            ),
          if (uploaded)
            Positioned(
              top: 4,
              right: 4,
              child: AfPopIn(
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AutoFlowTokens.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: AutoFlowTokens.onAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
