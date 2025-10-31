import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../chips/combustivel_chip.dart';
import '../buttons/primary_button.dart';

/// 🃏 Card de Posto Favorito
/// Card destacado com ações rápidas para favoritos
class PostoFavoritoCard extends StatelessWidget {
  final String nome;
  final String endereco;
  final double preco;
  final double distancia;
  final String combustivelPreferido;
  final VoidCallback onNavigate;
  final VoidCallback onRemove;

  const PostoFavoritoCard({
    Key? key,
    required this.nome,
    required this.endereco,
    required this.preco,
    required this.distancia,
    required this.combustivelPreferido,
    required this.onNavigate,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.space8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(color: AppColors.primary, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: AppColors.error, size: 20),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space8),
            Text(nome, style: AppTypography.titleMedium),
            SizedBox(height: 4),
            Text(
              endereco,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.space12),
            Row(
              children: [
                CombustivelChip(tipo: combustivelPreferido),
                Spacer(),
                Text(
                  'R\$ ${preco.toStringAsFixed(2)}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space12),
            PrimaryButton(
              label: "Navegar",
              icon: Icons.navigation,
              onPressed: onNavigate,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
