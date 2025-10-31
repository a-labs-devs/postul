import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../chips/combustivel_chip.dart';

/// 🃏 Card de Posto (Lista)
/// Card completo com informações do posto para listas
class PostoCard extends StatelessWidget {
  final String nome;
  final String endereco;
  final double preco;
  final double distancia;
  final double avaliacao;
  final int totalAvaliacoes;
  final List<String> combustiveis;
  final VoidCallback onTap;
  final Color precoColor;

  const PostoCard({
    Key? key,
    required this.nome,
    required this.endereco,
    required this.preco,
    required this.distancia,
    required this.avaliacao,
    required this.totalAvaliacoes,
    required this.combustiveis,
    required this.onTap,
    required this.precoColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.cardMargin / 2),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              // COLUNA ESQUERDA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: AppTypography.titleMedium.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            endereco,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.space8),
                    Wrap(
                      spacing: 4,
                      children: combustiveis
                          .map((c) => CombustivelChip(tipo: c))
                          .toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.space16),
              // COLUNA DIREITA
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${preco.toStringAsFixed(2)}',
                    style: AppTypography.priceDisplay.copyWith(
                      fontSize: 24,
                      color: precoColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${distancia.toStringAsFixed(1)} km',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text(
                        '$avaliacao',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' ($totalAvaliacoes)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
