import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

const Color _kCalColor = Color(0xFFFF6B6B);
const Color _kStandColor = Color(0xFF66BB6A);

/// Triple activity rings from Figma `home-screen.tsx` SVG.
class HomeActivityRings extends StatelessWidget {
  const HomeActivityRings({
    super.key,
    this.progress = 0.68,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      height: 155,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(155, 155),
            painter: _TripleRingsPainter(
              outerFrac: 1 - 0.32,
              midFrac: 1 - 0.25,
              innerFrac: 1 - 0.42,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'home_daily_goal'.tr(),
                style: const TextStyle(
                  color: AppColors.creamDim,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripleRingsPainter extends CustomPainter {
  _TripleRingsPainter({
    required this.outerFrac,
    required this.midFrac,
    required this.innerFrac,
  });

  final double outerFrac;
  final double midFrac;
  final double innerFrac;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const stroke = 9.0;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-c.dx, -c.dy);

    void ring(double radius, Color track, Color active, double frac) {
      final rect = Rect.fromCircle(center: c, radius: radius);
      final bg = Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke;
      final fg = Paint()
        ..color = active
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(c, radius, bg);
      final sweep = 2 * math.pi * frac.clamp(0.0, 1.0);
      canvas.drawArc(rect, 0, sweep, false, fg);
    }

    ring(
      72,
      const Color.fromRGBO(255, 107, 107, 0.15),
      _kCalColor,
      outerFrac,
    );
    ring(
      58,
      const Color.fromRGBO(212, 175, 55, 0.15),
      AppColors.accentGold,
      midFrac,
    );
    ring(
      44,
      const Color.fromRGBO(102, 187, 106, 0.15),
      _kStandColor,
      innerFrac,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TripleRingsPainter oldDelegate) =>
      oldDelegate.outerFrac != outerFrac ||
      oldDelegate.midFrac != midFrac ||
      oldDelegate.innerFrac != innerFrac;
}
