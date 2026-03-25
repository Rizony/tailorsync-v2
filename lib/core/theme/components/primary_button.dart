import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    BoxDecoration decoration;
    if (onPressed == null) {
      decoration = BoxDecoration(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        borderRadius: BorderRadius.circular(12),
      );
    } else if (isSecondary) {
      decoration = BoxDecoration(
        color: isDark ? AppColors.secondaryLight : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      );
    } else {
      decoration = BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: 54,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: AppTypography.label.copyWith(
                      color: onPressed == null
                          ? (isDark ? AppColors.textHintDark : AppColors.textHintLight)
                          : (isSecondary
                              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                              : Colors.white),
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
