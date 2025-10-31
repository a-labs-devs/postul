import 'package:flutter/material.dart';

/// 🎨 POSTUL - Paleta de Cores
/// Design System Foundation - Cores
class AppColors {
  AppColors._();

  // ========== CORES PRIMÁRIAS (DINÂMICAS) ==========
  static Color _primary = const Color(0xFF0066FF);
  static Color _primaryDark = const Color(0xFF003099);
  static Color _primaryLight = const Color(0xFF4D94FF);
  static Color _primaryContainer = const Color(0xFFE6F0FF);

  // Getters para cores primárias
  static Color get primary => _primary;
  static Color get primaryDark => _primaryDark;
  static Color get primaryLight => _primaryLight;
  static Color get primaryContainer => _primaryContainer;

  /// Atualiza a cor primária do tema
  static void setPrimaryColor(Color color) {
    _primary = color;
    _primaryDark = Color.lerp(color, Colors.black, 0.3)!;
    _primaryLight = Color.lerp(color, Colors.white, 0.3)!;
    _primaryContainer = Color.lerp(color, Colors.white, 0.9)!;
  }

  static const Color secondary = Color(0xFF00C853);
  static const Color secondaryDark = Color(0xFF00A843);
  static const Color secondaryLight = Color(0xFF69F0AE);
  static const Color secondaryContainer = Color(0xFFE8F5E9);

  // ========== SUPERFÍCIES ==========
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA);
  static const Color background = Color(0xFFFAFBFC);
  static const Color outline = Color(0xFFE0E4E8);
  static const Color divider = Color(0xFFECEFF3);

  // ========== TEXTO ==========
  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ========== COMBUSTÍVEIS ==========
  static const Color gasolinaComum = Color(0xFF00C853);
  static const Color gasolinaAditivada = Color(0xFF00E676);
  static const Color etanol = Color(0xFFFF9800);
  static const Color diesel = Color(0xFF2196F3);
  static const Color gnv = Color(0xFF9C27B0);

  // ========== ESTADOS ==========
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static const Color precoBaixo = Color(0xFF00C853);
  static const Color precoMedio = Color(0xFFFFA726);
  static const Color precoAlto = Color(0xFFF44336);

  // ========== INTERAÇÃO ==========
  static const Color hover = Color(0x140066FF); // 8% opacity
  static const Color pressed = Color(0x290066FF); // 16% opacity
  static const Color focused = Color(0x1F0066FF); // 12% opacity
  static const Color disabled = Color(0x61000000); // 38% opacity
  static const Color disabledBg = Color(0x1F000000); // 12% opacity

  // ========== DARK MODE ==========
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkSurfaceVariant = Color(0xFF3A3A3C);
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkOutline = Color(0xFF48484A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkPrimary = Color(0xFF4D94FF);

  /// Helper: Retorna cor por tipo de combustível
  static Color getCombustivelColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'gasolina':
      case 'gasolina comum':
        return gasolinaComum;
      case 'gasolina aditivada':
        return gasolinaAditivada;
      case 'etanol':
        return etanol;
      case 'diesel':
      case 'diesel s10':
        return diesel;
      case 'gnv':
        return gnv;
      default:
        return textSecondary;
    }
  }

  /// Helper: Retorna cor por categoria de preço (baixo/médio/alto)
  static Color getPrecoColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'baixo':
        return precoBaixo;
      case 'medio':
      case 'médio':
        return precoMedio;
      case 'alto':
        return precoAlto;
      default:
        return textSecondary;
    }
  }
}
