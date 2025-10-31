import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🔔 Tipos de Snackbar
enum SnackbarType { success, error, warning, info }

/// 🔔 Snackbar Customizado
/// Snackbar estilizado com ícones e cores por tipo
class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = AppColors.error;
        icon = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = AppColors.warning;
        icon = Icons.warning;
        break;
      case SnackbarType.info:
        backgroundColor = AppColors.info;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textOnPrimary),
            SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: EdgeInsets.all(AppSpacing.space16),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.textOnPrimary,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
}
