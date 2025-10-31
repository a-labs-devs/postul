import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🏷️ Badge Numérico
/// Badge circular com contador
class CustomBadge extends StatelessWidget {
  final String? label;
  final int? count;
  final Color backgroundColor;
  final Color textColor;

  const CustomBadge({
    Key? key,
    this.label,
    this.count,
    this.backgroundColor = const Color(0xFFF44336),
    this.textColor = const Color(0xFFFFFFFF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayText = label ?? (count != null ? count.toString() : '');

    return Container(
      constraints: BoxConstraints(minWidth: 18, minHeight: 18),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 🏷️ Badge Label
/// Badge retangular com texto
class BadgeLabel extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const BadgeLabel({
    Key? key,
    required this.label,
    this.backgroundColor = const Color(0xFF00C853),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }
}
