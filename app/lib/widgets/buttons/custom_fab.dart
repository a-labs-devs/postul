import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🔘 FAB (Floating Action Button)
/// Botão flutuante customizado com variações de tamanho
class CustomFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool isLarge;
  final Color? backgroundColor;
  final Color? iconColor;

  const CustomFAB({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isLarge = true,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  const CustomFAB.small({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
  })  : isLarge = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 56.0 : 40.0;
    final iconSize = isLarge ? 24.0 : 20.0;
    final bgColor = backgroundColor ??
        (isLarge ? AppColors.primary : AppColors.surface);
    final fgColor = iconColor ??
        (isLarge ? AppColors.textOnPrimary : AppColors.primary);

    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(
            isLarge ? AppRadius.fab : AppRadius.md,
          ),
          border: !isLarge
              ? Border.all(color: AppColors.outline, width: 1)
              : null,
          boxShadow: isLarge ? AppShadows.elevation3 : AppShadows.elevation2,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(
              isLarge ? AppRadius.fab : AppRadius.md,
            ),
            child: Icon(icon, size: iconSize, color: fgColor),
          ),
        ),
      ),
    );
  }
}
