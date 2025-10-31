import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 📋 Bottom Sheet Customizado
/// Bottom sheet draggable com handle
class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final double? initialChildSize;
  final double? maxChildSize;

  const CustomBottomSheet({
    Key? key,
    required this.child,
    this.initialChildSize = 0.5,
    this.maxChildSize = 0.85,
  }) : super(key: key);

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double? initialChildSize,
    double? maxChildSize,
  }) {
    // TEMPORÁRIO: usando Dialog para testar
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HANDLE
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: AppSpacing.space16),
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // CONTEÚDO
              child,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.bottomSheetRadius,
        boxShadow: AppShadows.elevation4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HANDLE
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // CONTEÚDO
          child,
        ],
      ),
    );
  }
}
