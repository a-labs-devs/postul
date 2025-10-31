import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 📝 Dropdown Customizado
/// Dropdown estilizado seguindo design system
class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final IconData? prefixIcon;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.inputRadius,
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        icon: Icon(Icons.expand_more),
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: 4,
      ),
    );
  }
}
