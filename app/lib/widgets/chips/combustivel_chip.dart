import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🏷️ Chip de Combustível
/// Chip estilizado por tipo de combustível
class CombustivelChip extends StatelessWidget {
  final String tipo;
  final bool showIcon;

  const CombustivelChip({
    Key? key,
    required this.tipo,
    this.showIcon = false,
  }) : super(key: key);

  Color _getColor() {
    return AppColors.getCombustivelColor(tipo);
  }

  IconData _getIcon() {
    switch (tipo.toLowerCase()) {
      case 'etanol':
        return Icons.eco;
      case 'diesel':
      case 'diesel s10':
        return Icons.local_shipping;
      case 'gnv':
        return Icons.cloud;
      default:
        return Icons.local_gas_station;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.chipPaddingH,
        vertical: AppSpacing.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppRadius.chipRadius,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getIcon(), size: 14, color: color),
            SizedBox(width: 4),
          ],
          Text(
            tipo,
            style: AppTypography.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
