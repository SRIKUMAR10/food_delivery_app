import 'package:flutter/material.dart';

/// Shared buyer auth form primitives used by the login, sign-up,
/// forgot-password and OTP verification pages. Centralizes the previously
/// duplicated field labels, input decorations and primary buttons.

class AuthFieldLabel extends StatelessWidget {
  final String label;
  final TextStyle? style;

  const AuthFieldLabel(this.label, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: style ??
          const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
    );
  }
}

InputDecoration authFieldDecoration({
  String? hintText,
  TextStyle? hintStyle,
  IconData? prefixIcon,
  Widget? prefix,
  Widget? suffixIcon,
  String? errorText,
  double borderRadius = 12,
  EdgeInsetsGeometry? contentPadding,
  bool showErrorStyles = false,
  String? counterText,
  Color? fillColor,
  Color? enabledBorderColor,
  Color? focusedBorderColor,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: hintStyle,
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: Colors.grey)
        : null,
    prefix: prefix,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: fillColor ?? const Color(0xFFEEF0F5),
    contentPadding: contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    counterText: counterText,
    errorText: errorText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: enabledBorderColor != null
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: enabledBorderColor),
          )
        : null,
    focusedBorder: focusedBorderColor != null
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
          )
        : showErrorStyles
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(color: Color(0xFFE52121), width: 1.5),
              )
            : null,
    errorBorder: showErrorStyles
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          )
        : null,
  );
}

// ─── Shared validation helpers ──────────────────────────────────────────────

/// Validates a full name: required and at least 2 characters.
String? validateRequiredName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Full name is required';
  }
  if (value.trim().length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null;
}

/// Validates an email address: required and well-formed.
String? validateEmailAddress(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email address is required';
  }
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Please enter a valid email address';
  }
  return null;
}

/// Validates a phone number: required and at least 10 digits.
String? validatePhoneNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Phone number is required';
  }
  final digits = value.trim().replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) {
    return 'Phone number must be at least 10 digits';
  }
  return null;
}

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final double fontSize;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.height = 52,
    this.borderRadius = 28,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE52121),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
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
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}