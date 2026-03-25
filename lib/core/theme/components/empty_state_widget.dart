import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? actionButton;
  final bool compact;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionButton,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: compact ? 24.0 : 48.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
              ),
              child: Icon(
                icon,
                size: compact ? 40 : 64,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 32),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
