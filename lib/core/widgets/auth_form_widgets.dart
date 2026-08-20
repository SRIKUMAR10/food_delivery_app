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
    fillColor: const Color(0xFFEEF0F5),
    contentPadding: contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    counterText: counterText,
    errorText: errorText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: showErrorStyles
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