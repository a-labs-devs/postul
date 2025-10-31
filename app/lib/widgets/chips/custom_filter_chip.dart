import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🏷️ Filter Chip Customizado
/// Chip selecionável para filtros
class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? avatar;

  const CustomFilterChip({
    Key? key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: avatar != null ? Icon(avatar, size: 16) : null,
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textOnPrimary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: selected ? AppColors.textOnPrimary : AppColors.textPrimary,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.chipPaddingH,
        vertical: AppSpacing.chipPaddingV,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.chipRadius,
      ),
    );
  }
}
