import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 📝 Slider Customizado
/// Slider estilizado com label e valores min/max
class CustomSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? labelFormatter;

  const CustomSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.labelFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        SizedBox(height: AppSpacing.space8),
        Text(
          labelFormatter != null
              ? labelFormatter!(value)
              : value.toStringAsFixed(0),
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.outline,
            thumbColor: AppColors.surface,
            overlayColor: AppColors.primary.withOpacity(0.2),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 2,
            ),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
            trackHeight: 4,
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: AppTypography.labelMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: labelFormatter != null
                ? labelFormatter!(value)
                : value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${min.toInt()}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${max.toInt()}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
