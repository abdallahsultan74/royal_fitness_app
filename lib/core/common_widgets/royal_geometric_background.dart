import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Subtle Islamic-style pattern overlay (Figma `GeometricBg`, opacity ~0.035).
class RoyalGeometricBackground extends StatelessWidget {
  const RoyalGeometricBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.035,
        child: CustomPaint(
          painter: const _IslamicPatternPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  const _IslamicPatternPainter();

  static const double _tile = 80;

  @override
  void paint(Canvas canvas, Size size) {
    Paint stroke(double w) => Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;

    for (var y = 0.0; y < size.height + _tile; y += _tile) {
      for (var x = 0.0; x < size.width + _tile; x += _tile) {
        final cx = x + _tile / 2;
        final cy = y + _tile / 2;
        final hex = Path()
          ..moveTo(cx, y)
          ..lineTo(x + _tile, y + _tile * 0.25)
          ..lineTo(x + _tile, y + _tile * 0.75)
          ..lineTo(cx, y + _tile)
          ..lineTo(x, y + _tile * 0.75)
          ..lineTo(x, y + _tile * 0.25)
          ..close();
        canvas.drawPath(hex, stroke(0.8));
        canvas.drawCircle(Offset(cx, cy), 12, stroke(0.5));
        canvas.drawCircle(Offset(cx, cy), 4, stroke(0.3));
        canvas.drawLine(Offset(cx, y), Offset(cx, y + _tile), stroke(0.2));
        canvas.drawLine(Offset(x, cy), Offset(x + _tile, cy), stroke(0.2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
