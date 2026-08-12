import 'package:flutter/material.dart';
import 'delivery_app_colors.dart';

/// Centralized Design System Typography Tokens for Delivery Partner Module.
/// Meets WCAG AA font legibility, line height, and contrast requirements.
abstract class DeliveryAppTypography {
  static const String fontFamily = 'Roboto';

  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: DeliveryAppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: DeliveryAppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: DeliveryAppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: DeliveryAppColors.textPrimary,
    height: 1.35,
  );

  // Subtitles & Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: DeliveryAppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: DeliveryAppColors.textSecondary,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: DeliveryAppColors.textSecondary,
    height: 1.35,
  );

  // Body Texts
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: DeliveryAppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: DeliveryAppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: DeliveryAppColors.textMuted,
    height: 1.4,
  );

  // Buttons & Badges
  static const TextStyle button = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.bold,
    color: DeliveryAppColors.buttonPrimaryText,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    color: DeliveryAppColors.textMuted,
    letterSpacing: 0.2,
  );
}
