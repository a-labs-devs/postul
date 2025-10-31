import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🔘 Botão de Texto
/// Botão minimalista sem borda ou preenchimento
class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;

  const CustomTextButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.primary;
    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveTextColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: effectiveTextColor,
        ),
      ),
    );
  }
}
