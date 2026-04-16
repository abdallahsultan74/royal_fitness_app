import 'package:flutter/material.dart';

/// Matches Figma `GoldShimmer` in [figma/app/components/royal-theme.tsx]: 105deg band, 4s ease-in-out.
class RoyalGoldShimmer extends StatefulWidget {
  const RoyalGoldShimmer({
    super.key,
    required this.borderRadius,
  });

  final BorderRadius borderRadius;

  @override
  State<RoyalGoldShimmer> createState() => _RoyalGoldShimmerState();
}

class _RoyalGoldShimmerState extends State<RoyalGoldShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final band = w * 0.85;
              final dx = (_controller.value * 2 - 1) * (w + band * 0.5);
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Transform.translate(
                    offset: Offset(dx, 0),
                    child: Transform.rotate(
                      angle: -0.12,
                      child: Container(
                        width: band,
                        height: h * 1.5,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Color.fromRGBO(212, 175, 55, 0.07),
                              Color.fromRGBO(212, 175, 55, 0.12),
                              Color.fromRGBO(212, 175, 55, 0.07),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.35, 0.5, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
