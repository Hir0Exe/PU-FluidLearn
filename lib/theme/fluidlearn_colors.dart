import 'package:flutter/material.dart';

/// Paleta FluidLearn: logo (navy + cyan) y azul de interfaz alineado con login.
abstract final class FluidLearnColors {
  FluidLearnColors._();

  /// Azul principal — títulos “FluidLearn”, botón Entrar, enlaces (como en login).
  static const Color brandBlue = Color(0xFF1967D2);

  /// Azul marino del logo con tipografía cyan.
  static const Color brandNavy = Color(0xFF162A4E);

  /// Acento claro del branding.
  static const Color brandCyan = Color(0xFF98E7FF);

  /// Fondo común login / home (gris-azul muy claro).
  static const Color scaffold = Color(0xFFF8FAFC);

  /// Texto principal sobre fondo claro.
  static const Color textPrimary = Color(0xFF162A4E);

  /// Texto secundario / subtítulos.
  static const Color textSecondary = Color(0xFF5F6368);

  /// Borde suave en campos y divisores.
  static const Color borderSubtle = Color(0xFFCBD5E1);

  /// Texto secundario en home (mismo azul con transparencia).
  static Color brandBlueMuted(double alpha) => brandBlue.withValues(alpha: alpha);
}
