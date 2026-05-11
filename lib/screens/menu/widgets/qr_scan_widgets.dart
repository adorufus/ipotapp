import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ipotapp/utils/color_utils.dart';

class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred, soft colored background (no image)
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.55),
                  AppColors.tertiary.withValues(alpha: 0.55),
                  AppColors.secondary.withValues(alpha: 0.85),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  left: -80,
                  child: _BlurBlob(
                    diameter: 360,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  right: -120,
                  child: _BlurBlob(
                    diameter: 420,
                    color: AppColors.tertiary.withValues(alpha: 0.55),
                  ),
                ),
                Positioned(
                  top: 120,
                  right: -100,
                  child: _BlurBlob(
                    diameter: 300,
                    color: AppColors.secondary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.secondary.withValues(alpha: 0.20),
                Colors.transparent,
                AppColors.secondary.withValues(alpha: 0.40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class QrPlaceholder extends StatelessWidget {
  const QrPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6F240A), Color(0xFF9B4428)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_2,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Corner accents
          const _CornerAccent(alignment: Alignment.topLeft),
          const _CornerAccent(alignment: Alignment.topRight),
          const _CornerAccent(alignment: Alignment.bottomLeft),
          const _CornerAccent(alignment: Alignment.bottomRight),
        ],
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }
}

class _CornerAccent extends StatelessWidget {
  const _CornerAccent({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    BorderRadius radius;
    if (isTop && isLeft) {
      radius = const BorderRadius.only(topLeft: Radius.circular(12));
    } else if (isTop && !isLeft) {
      radius = const BorderRadius.only(topRight: Radius.circular(12));
    } else if (!isTop && isLeft) {
      radius = const BorderRadius.only(bottomLeft: Radius.circular(12));
    } else {
      radius = const BorderRadius.only(bottomRight: Radius.circular(12));
    }

    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(isLeft ? -4 : 4, isTop ? -4 : 4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border(
              top: isTop
                  ? const BorderSide(color: AppColors.primary, width: 4)
                  : BorderSide.none,
              bottom: !isTop
                  ? const BorderSide(color: AppColors.primary, width: 4)
                  : BorderSide.none,
              left: isLeft
                  ? const BorderSide(color: AppColors.primary, width: 4)
                  : BorderSide.none,
              right: !isLeft
                  ? const BorderSide(color: AppColors.primary, width: 4)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

