import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_spacing.dart';
import '../theme/delivery_app_typography.dart';
import '../utils/app_date_formatter.dart';

/// Reusable Standardized Date Input & Picker Form Field.
/// Provides a unified system DatePicker dialog and format-compliant text display.
class AppDateFormField extends StatefulWidget {
  final TextEditingController? controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? labelText;
  final String? hintText;
  final ValueChanged<DateTime>? onDateSelected;
  final String? Function(String?)? validator;
  final bool isSystemFormat; // If true: 'yyyy-MM-dd', else 'dd MMM, yyyy'
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color primaryColor;

  const AppDateFormField({
    super.key,
    this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.labelText,
    this.hintText,
    this.onDateSelected,
    this.validator,
    this.isSystemFormat = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.primaryColor = const Color(0xFFE52929),
  });

  @override
  State<AppDateFormField> createState() => _AppDateFormFieldState();
}

class _AppDateFormFieldState extends State<AppDateFormField> {
  late final TextEditingController _internalController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _selectedDate = widget.initialDate;
    if (_selectedDate != null && _internalController.text.isEmpty) {
      _updateTextFromDate(_selectedDate!);
    }
  }

  void _updateTextFromDate(DateTime date) {
    if (widget.isSystemFormat) {
      _internalController.text = AppDateFormatter.formatSystemDate(date);
    } else {
      _internalController.text = AppDateFormatter.formatDisplayDate(date);
    }
  }

  Future<void> _pickDate() async {
    if (!widget.enabled) return;
    final now = DateTime.now();
    final initial = _selectedDate ?? now;
    final first = widget.firstDate ?? DateTime(now.year - 10, 1, 1);
    final last = widget.lastDate ?? DateTime(now.year + 20, 12, 31);

    final safeInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: first,
      lastDate: last,
      builder: (pickerCtx, child) {
        return Theme(
          data: Theme.of(pickerCtx).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1E293B),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _updateTextFromDate(picked);
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: DeliveryAppTypography.titleMedium.copyWith(
              color: DeliveryAppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        InkWell(
          onTap: widget.enabled ? _pickDate : null,
          borderRadius: DeliveryAppSpacing.borderRadiusMd,
          child: IgnorePointer(
            child: TextFormField(
              controller: _internalController,
              enabled: widget.enabled,
              readOnly: true,
              validator: widget.validator,
              style: DeliveryAppTypography.bodyLarge.copyWith(
                color: DeliveryAppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText ??
                    (widget.isSystemFormat ? 'YYYY-MM-DD' : 'DD MMM, YYYY'),
                hintStyle: DeliveryAppTypography.bodyMedium.copyWith(
                  color: DeliveryAppColors.textMuted,
                ),
                filled: true,
                fillColor: DeliveryAppColors.surface,
                prefixIcon: widget.prefixIcon ??
                    Icon(
                      Icons.calendar_today_rounded,
                      color: widget.primaryColor,
                      size: 20,
                    ),
                suffixIcon: widget.suffixIcon ??
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: DeliveryAppColors.textMuted,
                      size: 24,
                    ),
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
                  borderSide: BorderSide(color: widget.primaryColor, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
