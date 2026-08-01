import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_spacing.dart';
import '../theme/delivery_app_typography.dart';

/// Reusable Standardized Input Field Component with WCAG AA compliance.
class DeliveryTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? label;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const DeliveryTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.label,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final title = labelText ?? label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: DeliveryAppTypography.titleMedium.copyWith(
              color: DeliveryAppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: DeliveryAppTypography.bodyLarge.copyWith(
            color: DeliveryAppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: DeliveryAppTypography.bodyMedium.copyWith(
              color: DeliveryAppColors.textMuted,
            ),
            errorText: errorText,
            errorStyle: const TextStyle(color: DeliveryAppColors.error, fontSize: 12),
            filled: true,
            fillColor: DeliveryAppColors.surface,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DeliveryAppSpacing.md,
              vertical: DeliveryAppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: DeliveryAppSpacing.borderRadiusMd,
              borderSide: const BorderSide(color: DeliveryAppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: DeliveryAppSpacing.borderRadiusMd,
              borderSide: const BorderSide(color: DeliveryAppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: DeliveryAppSpacing.borderRadiusMd,
              borderSide: const BorderSide(color: DeliveryAppColors.borderFocus, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: DeliveryAppSpacing.borderRadiusMd,
              borderSide: const BorderSide(color: DeliveryAppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: DeliveryAppSpacing.borderRadiusMd,
              borderSide: const BorderSide(color: DeliveryAppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
