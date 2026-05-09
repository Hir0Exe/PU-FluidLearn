import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/fluidlearn_colors.dart';
import '../../widgets/fluidlearn_logo_image.dart';

/// Intro de presentación inspirada en intros tipo streaming (p. ej. Disney+):
/// fondo muy oscuro, brillo en arco y logo centrado que escala.
/// No reproduce el intro de terceros; solo evoca la misma sensación con la marca FluidLearn.
class FluidLearnIntroSplash extends StatefulWidget {
  const FluidLearnIntroSplash({super.key, required this.onIntroComplete});

  /// Se llama una vez terminada la secuencia visual principal (~2.8s).
  final VoidCallback onIntroComplete;

  @override
  State<FluidLearnIntroSplash> createState() => _FluidLearnIntroSplashState();
}

class _FluidLearnIntroSplashState extends State<FluidLearnIntroSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _controller.forward().whenComplete(() {
      if (mounted) widget.onIntroComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scaleT =
            Curves.easeOutCubic.transform((t / 0.42).clamp(0.0, 1.0));
        final logoScale = 0.22 + 0.78 * scaleT;
        final logoOpacity =
            Curves.easeOut.transform((t / 0.18).clamp(0.0, 1.0));
        final arcOpacity = Curves.easeIn.transform(
          ((t - 0.1) / 0.55).clamp(0.0, 1.0),
        );
        final sweep = Curves.easeInOut.transform(
          ((t - 0.06) / 0.7).clamp(0.0, 1.0),
        );

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D1B2E),
                FluidLearnColors.brandNavy,
                Color(0xFF0A1528),
              ],
              stops: [0.0, 0.42, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _ArcGlowPainter(
                  sweep: sweep,
                  opacity: arcOpacity * 0.9,
                ),
              ),
              Center(
                child: Opacity(
                  opacity: logoOpacity,
                  child: Transform.scale(
                    scale: logoScale,
                    child: const FluidLearnLogoImage(size: 148),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArcGlowPainter extends CustomPainter {
  _ArcGlowPainter({required this.sweep, required this.opacity});

  final double sweep;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.02) return;

    final w = size.width;
    final h = size.height;
    final arcRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.36),
      width: w * 2.4,
      height: h * 0.95,
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    final startAngle = -math.pi * (0.92 - sweep * 0.35);
    final sweepAngle = math.pi * (0.55 + sweep * 0.45);

    final arcGradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      tileMode: TileMode.clamp,
      colors: [
        FluidLearnColors.brandCyan.withValues(alpha: 0.0),
        FluidLearnColors.brandCyan.withValues(alpha: 0.12 * opacity),
        FluidLearnColors.brandCyan.withValues(alpha: 0.45 * opacity),
        FluidLearnColors.brandBlue.withValues(alpha: 0.35 * opacity),
        FluidLearnColors.brandCyan.withValues(alpha: 0.12 * opacity),
        FluidLearnColors.brandCyan.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.2, 0.38, 0.5, 0.62, 1.0],
    );

    glowPaint.shader = arcGradient.createShader(arcRect);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.22 * opacity);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ArcGlowPainter oldDelegate) =>
      oldDelegate.sweep != sweep || oldDelegate.opacity != opacity;
}
