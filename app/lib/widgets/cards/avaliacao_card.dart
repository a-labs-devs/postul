import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🃏 Card de Avaliação
/// Card para exibir avaliações de usuários
class AvaliacaoCard extends StatelessWidget {
  final String nomeUsuario;
  final String iniciais;
  final double avaliacao;
  final String? comentario;
  final DateTime data;

  const AvaliacaoCard({
    Key? key,
    required this.nomeUsuario,
    required this.iniciais,
    required this.avaliacao,
    this.comentario,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      margin: EdgeInsets.symmetric(vertical: AppSpacing.cardMargin / 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  iniciais,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nomeUsuario, style: AppTypography.titleSmall),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < avaliacao.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 14,
                              color: AppColors.warning,
                            );
                          }),
                        ),
                        SizedBox(width: AppSpacing.space8),
                        Text(
                          _formatDate(data),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comentario != null) ...[
            SizedBox(height: AppSpacing.space12),
            Text(comentario!, style: AppTypography.bodyMedium),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    return '${date.day}/${date.month}/${date.year}';
  }
}
