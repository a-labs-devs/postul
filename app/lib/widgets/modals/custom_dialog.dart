import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 🗨️ Dialog Customizado
/// Modal dialog estilizado
class CustomDialog extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final List<Widget> actions;

  const CustomDialog({
    Key? key,
    required this.title,
    this.description,
    this.icon,
    required this.actions,
  }) : super(key: key);

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? description,
    IconData? icon,
    required List<Widget> actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => CustomDialog(
        title: title,
        description: description,
        icon: icon,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.modalRadius,
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.modalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48, color: AppColors.primary),
              SizedBox(height: AppSpacing.space16),
            ],
            Text(
              title,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: AppSpacing.space12),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: AppSpacing.space24),
            Row(
              children: actions
                  .map((action) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: action,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
