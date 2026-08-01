import 'package:flutter/material.dart';
import 'delivery_app_colors.dart';
import 'delivery_app_typography.dart';

/// Centralized ThemeData Provider for Delivery Partner App with WCAG AA compliance.
abstract class DeliveryAppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DeliveryAppColors.background,
      primaryColor: DeliveryAppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: DeliveryAppColors.primary,
        onPrimary: DeliveryAppColors.buttonPrimaryText,
        surface: DeliveryAppColors.surface,
        onSurface: DeliveryAppColors.textPrimary,
        error: DeliveryAppColors.error,
        onError: DeliveryAppColors.buttonDangerText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: DeliveryAppTypography.h2,
        iconTheme: IconThemeData(color: DeliveryAppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: DeliveryAppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DeliveryAppColors.borderSubtle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DeliveryAppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: DeliveryAppTypography.bodyMedium.copyWith(color: DeliveryAppColors.textMuted),
        labelStyle: DeliveryAppTypography.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DeliveryAppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DeliveryAppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DeliveryAppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DeliveryAppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DeliveryAppColors.primary,
          foregroundColor: DeliveryAppColors.buttonPrimaryText,
          minimumSize: const Size(double.infinity, 48), // WCAG AA minimum 48dp target
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: DeliveryAppTypography.button,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DeliveryAppColors.primary,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: DeliveryAppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: DeliveryAppTypography.button.copyWith(color: DeliveryAppColors.primary),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DeliveryAppColors.buttonPrimaryText;
          }
          return DeliveryAppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DeliveryAppColors.primary;
          }
          return DeliveryAppColors.surfaceLight;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: DeliveryAppColors.borderSubtle,
        space: 24,
        thickness: 1,
      ),
    );
  }
}
