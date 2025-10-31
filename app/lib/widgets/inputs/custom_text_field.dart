import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 📝 Text Field Customizado
/// Input field estilizado seguindo design system
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? errorText;
  final int? maxLines;
  final int? maxLength;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? labelColor;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.backgroundColor,
    this.textColor,
    this.labelColor,
    this.hintText,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      style: AppTypography.bodyLarge.copyWith(
        color: textColor ?? AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: labelColor ?? AppColors.textSecondary,
        ),
        errorText: errorText,
        filled: true,
        fillColor: backgroundColor ?? AppColors.surfaceVariant,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, size: 20),
                onPressed: onSuffixTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
