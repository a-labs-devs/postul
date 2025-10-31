import 'package:flutter/material.dart';

/// 🔲 POSTUL - Border Radius
/// Design System Foundation - Radius
class AppRadius {
  AppRadius._();

  // ========== TAMANHOS ==========
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0; // circular

  // ========== APLICAÇÕES ESPECÍFICAS ==========
  static const double button = 12.0;
  static const double card = 16.0;
  static const double bottomSheet = 24.0; // apenas top
  static const double modal = 20.0;
  static const double input = 12.0;
  static const double chip = 20.0; // pill shape
  static const double fab = 16.0;
  static const double avatar = 9999.0; // circular

  // Aliases adicionais para consistência
  static const double radiusMd = md;
  static const double radiusLg = lg;
  static const double radius2xl = xxl;

  // ========== BORDER RADIUS HELPERS ==========
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
  
  static BorderRadius get buttonRadius => BorderRadius.circular(button);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get modalRadius => BorderRadius.circular(modal);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
  static BorderRadius get fabRadius => BorderRadius.circular(fab);
  static BorderRadius get avatarRadius => BorderRadius.circular(avatar);
  
  static BorderRadius get bottomSheetRadius => BorderRadius.vertical(
    top: Radius.circular(bottomSheet),
  );
}
