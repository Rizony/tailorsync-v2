import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? suffixText;
  final String? errorText;
  final int maxLines;
  final bool isDense;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.errorText,
    this.maxLines = 1,
    this.isDense = false,
    this.initialValue,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: isDense ? 12 : 14,
            ),
          ),
          SizedBox(height: isDense ? 4 : 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          validator: validator,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: isDense ? 14 : 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            suffixText: suffixText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            isDense: isDense,
            contentPadding: isDense ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : null,
          ),
        ),
      ],
    );
  }
}
