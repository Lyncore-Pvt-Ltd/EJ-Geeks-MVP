import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a dimmed scrim with a clear rounded-square cutout and corner
/// brackets over a camera preview, marking where to aim a QR code.
/// Presentation-only — no camera or scanning logic.
class QrScannerOverlay extends StatelessWidget {
  const QrScannerOverlay({
    super.key,
    this.cutOutSize,
    this.borderColor = Colors.white,
  });

  final double? cutOutSize;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _QrScannerOverlayPainter(
          cutOutSize: cutOutSize,
          borderColor: borderColor,
        ),
      ),
    );
  }
}

class _QrScannerOverlayPainter extends CustomPainter {
  _QrScannerOverlayPainter({required this.cutOutSize, required this.borderColor});

  final double? cutOutSize;
  final Color borderColor;

  static const double _cornerRadius = 16;
  static const double _cornerLength = 32;
  static const double _cornerStrokeWidth = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final boxSize = cutOutSize ?? math.min(size.width, size.height) * 0.7;
    final cutOutRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: boxSize,
      height: boxSize,
    );
    final cutOutRRect = RRect.fromRectAndRadius(
      cutOutRect,
      const Radius.circular(_cornerRadius),
    );

    final scrimPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(cutOutRRect),
    );
    canvas.drawPath(scrimPath, Paint()..color = Colors.black54);

    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cornerStrokeWidth
      ..strokeCap = StrokeCap.round;

    void drawCorner(Offset corner, Offset horizontal, Offset vertical) {
      canvas.drawLine(corner, corner + horizontal, cornerPaint);
      canvas.drawLine(corner, corner + vertical, cornerPaint);
    }

    final left = cutOutRect.left;
    final top = cutOutRect.top;
    final right = cutOutRect.right;
    final bottom = cutOutRect.bottom;

    drawCorner(Offset(left, top), const Offset(_cornerLength, 0), const Offset(0, _cornerLength));
    drawCorner(Offset(right, top), const Offset(-_cornerLength, 0), const Offset(0, _cornerLength));
    drawCorner(Offset(left, bottom), const Offset(_cornerLength, 0), const Offset(0, -_cornerLength));
    drawCorner(Offset(right, bottom), const Offset(-_cornerLength, 0), const Offset(0, -_cornerLength));
  }

  @override
  bool shouldRepaint(covariant _QrScannerOverlayPainter oldDelegate) {
    return oldDelegate.cutOutSize != cutOutSize || oldDelegate.borderColor != borderColor;
  }
}
