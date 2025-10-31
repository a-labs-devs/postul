import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🃏 Card de Preço
/// Card compacto para exibir preços de combustível
class PrecoCard extends StatelessWidget {
  final String tipoCombustivel;
  final double preco;
  final Color cor;
  final IconData icon;
  final bool isMelhorPreco;

  const PrecoCard({
    Key? key,
    required this.tipoCombustivel,
    required this.preco,
    required this.cor,
    required this.icon,
    this.isMelhorPreco = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 64) / 2 - 6;

    return Container(
      width: cardWidth,
      height: 80,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cor),
              Spacer(),
              if (isMelhorPreco)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MENOR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
            ],
          ),
          Spacer(),
          Text(
            tipoCombustivel,
            style: AppTypography.labelMedium.copyWith(color: cor),
          ),
          Text(
            'R\$ ${preco.toStringAsFixed(2)}',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
