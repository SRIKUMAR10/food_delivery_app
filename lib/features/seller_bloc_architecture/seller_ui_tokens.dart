import 'package:flutter/material.dart';

class SellerUiTokens {
  SellerUiTokens._();

  static const Color pageBackground = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F6FB);

  static const Color brand = Color(0xFFE52929);
  static const Color brandDark = Color(0xFFDC2626);
  static const Color brandLight = Color(0xFFFEE2E2);
  static const Color brandSurface = Color(0xFFFEF2F2);
  static const Color brandBorder = Color(0xFFFECACA);
  static const Color accent = Color(0xFF3B82F6);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textHeading = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderMuted = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  static const double radiusCard = 20.0;
  static const double radiusButton = 16.0;
  static const double radiusField = 12.0;
  static const double radiusBackButton = 12.0;
  static const double radiusDialog = 20.0;

  static const double primaryButtonHeight = 52.0;
  static const double secondaryButtonHeight = 48.0;
  static const double compactButtonHeight = 40.0;

  static const double maxWidthForm = 860.0;
  static const double maxWidthGrid = 1100.0;
  static const double maxWidthDialog = 460.0;

  static const double spacingMobile = 16.0;
  static const double spacingTablet = 20.0;
  static const double spacingDesktop = 28.0;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> dialogShadow = [
    BoxShadow(
      color: Color(0x1F0F172A),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  static double responsivePadding(double screenWidth) {
    if (screenWidth > 900) return spacingDesktop;
    if (screenWidth > 600) return spacingTablet;
    return spacingMobile;
  }
}
