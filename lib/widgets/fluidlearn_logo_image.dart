import 'package:flutter/material.dart';

/// Logo FluidLearn: recorte redondeado + ligero zoom para ocultar márgenes blancos
/// típicos del PNG (esquinas fuera de la tarjeta redondeada del diseño).
class FluidLearnLogoImage extends StatelessWidget {
  const FluidLearnLogoImage({
    super.key,
    required this.size,
    this.borderRadiusFraction = 0.24,
    this.zoom = 1.14,
  });

  final double size;
  final double borderRadiusFraction;
  /// >1 acerca el arte y recorta bordes claros del asset.
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(size * borderRadiusFraction);
    return ClipRRect(
      borderRadius: r,
      child: SizedBox(
        width: size,
        height: size,
        child: Transform.scale(
          scale: zoom,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/new_logo.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
