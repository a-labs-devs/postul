import 'package:flutter/material.dart';

/// 🌑 POSTUL - Elevações e Sombras
/// Design System Foundation - Shadows
class AppShadows {
  AppShadows._();

  // ========== ELEVATION 0 (sem sombra) ==========
  static const List<BoxShadow> elevation0 = [];

  // ========== ELEVATION 1 (cards sutis, inputs) ==========
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,0.05)
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  // ========== ELEVATION 2 (cards padrão, botões) ==========
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,0.08)
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  // ========== ELEVATION 3 (cards destacados, FABs) ==========
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0,0,0,0.12)
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // ========== ELEVATION 4 (modais, bottom sheets) ==========
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0x29000000), // rgba(0,0,0,0.16)
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  // ========== ELEVATION 5 (drawers, dialogs) ==========
  static const List<BoxShadow> elevation5 = [
    BoxShadow(
      color: Color(0x33000000), // rgba(0,0,0,0.20)
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: 0,
    ),
  ];

  // ========== DARK MODE (sombras mais intensas) ==========
  static const List<BoxShadow> darkElevation1 = [
    BoxShadow(
      color: Color(0x66000000), // rgba(0,0,0,0.4)
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> darkElevation2 = [
    BoxShadow(
      color: Color(0x80000000), // rgba(0,0,0,0.5)
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> darkElevation3 = [
    BoxShadow(
      color: Color(0x99000000), // rgba(0,0,0,0.6)
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> darkElevation4 = [
    BoxShadow(
      color: Color(0xB3000000), // rgba(0,0,0,0.7)
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> darkElevation5 = [
    BoxShadow(
      color: Color(0xCC000000), // rgba(0,0,0,0.8)
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: 0,
    ),
  ];
}
