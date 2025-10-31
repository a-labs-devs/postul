/// 📚 POSTUL Design System - Exemplos de Uso
/// Este arquivo contém exemplos práticos de como usar o design system

import 'package:flutter/material.dart';
import 'package:postul/theme/theme.dart';

// ========== EXEMPLO 1: Card de Posto ==========
Widget buildPostoCard() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(AppSpacing.cardPadding),
    margin: EdgeInsets.symmetric(
      vertical: AppSpacing.cardMargin / 2,
      horizontal: AppSpacing.screenPaddingH,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.cardRadius,
      boxShadow: AppShadows.elevation1,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posto Shell',
          style: AppTypography.titleMedium,
        ),
        SizedBox(height: AppSpacing.tightSpacing),
        Text(
          'Av. Paulista, 1000',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.elementSpacing),
        // Preço
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gasolina Comum',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.gasolinaComum,
              ),
            ),
            Text(
              'R\$ 5,89',
              style: AppTypography.priceDisplay.copyWith(
                fontSize: 20,
                color: AppColors.gasolinaComum,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ========== EXEMPLO 2: Botão Primário ==========
Widget buildPrimaryButton(String label, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.buttonPaddingH,
        vertical: AppSpacing.buttonPaddingV,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.buttonRadius,
      ),
      elevation: 0,
    ),
    child: Text(label, style: AppTypography.labelLarge),
  );
}

// ========== EXEMPLO 3: Botão Secundário (Outlined) ==========
Widget buildSecondaryButton(String label, VoidCallback onPressed) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary, width: 1.5),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.buttonPaddingH,
        vertical: AppSpacing.buttonPaddingV,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.buttonRadius,
      ),
    ),
    child: Text(label, style: AppTypography.labelLarge),
  );
}

// ========== EXEMPLO 4: Chip de Combustível ==========
Widget buildCombustivelChip(String tipo, bool selected) {
  final color = AppColors.getCombustivelColor(tipo);
  
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.chipPaddingH,
      vertical: AppSpacing.chipPaddingV,
    ),
    decoration: BoxDecoration(
      color: selected ? color.withOpacity(0.15) : AppColors.surfaceVariant,
      borderRadius: AppRadius.chipRadius,
      border: Border.all(
        color: selected ? color : AppColors.outline,
        width: selected ? 1.5 : 1,
      ),
    ),
    child: Text(
      tipo,
      style: AppTypography.labelMedium.copyWith(
        color: selected ? color : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}

// ========== EXEMPLO 5: Input Field ==========
Widget buildInputField(String label, String hint) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    style: AppTypography.bodyMedium,
  );
}

// ========== EXEMPLO 6: Bottom Sheet ==========
void showPostoBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.bottomSheetRadius,
    ),
    builder: (context) => Container(
      padding: EdgeInsets.all(AppSpacing.bottomSheetPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle (barra de arrastar)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.space16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          // Conteúdo
          Text(
            'Detalhes do Posto',
            style: AppTypography.titleLarge,
          ),
          SizedBox(height: AppSpacing.elementSpacing),
          Text(
            'Informações detalhadas sobre o posto...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

// ========== EXEMPLO 7: Marcador de Preço (badge) ==========
Widget buildPrecoBadge(double preco, String categoria) {
  final color = AppColors.getPrecoColor(categoria);
  
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.space12,
      vertical: AppSpacing.space8,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.md),
      boxShadow: AppShadows.elevation2,
    ),
    child: Text(
      'R\$ ${preco.toStringAsFixed(2)}',
      style: AppTypography.labelLarge.copyWith(
        color: AppColors.textOnPrimary,
      ),
    ),
  );
}

// ========== EXEMPLO 8: Loading State ==========
Widget buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: AppColors.primary,
        ),
        SizedBox(height: AppSpacing.space16),
        Text(
          'Carregando postos...',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

// ========== EXEMPLO 9: Empty State ==========
Widget buildEmptyState() {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.space16),
          Text(
            'Nenhum posto encontrado',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.tightSpacing),
          Text(
            'Tente aumentar o raio de busca',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    ),
  );
}

// ========== EXEMPLO 10: Avaliação (estrelas) ==========
Widget buildRatingDisplay(double rating) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ...List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          size: 20,
          color: AppColors.warning,
        );
      }),
      SizedBox(width: AppSpacing.tightSpacing),
      Text(
        rating.toStringAsFixed(1),
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}
