import 'package:flutter/material.dart';

/// Centralized Design System Color Tokens for Delivery Partner Module.
/// Formulated with WCAG AA compliance (Contrast ratio >= 4.5:1 for standard text, >= 3:1 for graphical elements).
abstract class DeliveryAppColors {
  // Brand & Core Accents
  static const Color primary = Color(0xFF00E676); // Emerald Green Accent
  static const Color primaryDark = Color(0xFF00C853);
  static const Color primaryLight = Color(0xFF69F0AE);

  // Backgrounds & Surface Containers
  static const Color background = Color(0xFF0D131E); // Deep Slate/Charcoal Background
  static const Color backgroundDark = Color(0xFF0D131E);
  static const Color surface = Color(0xFF161B22);    // Card & Elevated Surface
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF1E2631); // Interactive / Hover Surface
  static const Color surfaceMedium = Color(0xFF1E2631);
  static const Color surfaceElevated = Color(0xFF28313F);

  // Text Colors (High Contrast on Dark Surfaces)
  static const Color textPrimary = Color(0xFFFFFFFF);         // 100% White (Contrast 14:1+)
  static const Color textSecondary = Color(0xE6FFFFFF);       // ~90% White (High readability)
  static const Color textMuted = Color(0xB3FFFFFF);           // ~70% White (Subtitles/Captions)
  static const Color textDisabled = Color(0x66FFFFFF);        // ~40% White
  static const Color textInverse = Color(0xFF0D131E);         // Dark text on bright elements

  // Status & Feedback Colors (WCAG AA Compliant)
  static const Color success = Color(0xFF00E676);
  static const Color successBg = Color(0xFF0D281C);
  static const Color successBorder = Color(0x4000E676);

  static const Color error = Color(0xFFFF5252);
  static const Color errorBg = Color(0xFF2E1517);
  static const Color errorBorder = Color(0x40FF5252);

  static const Color warning = Color(0xFFFFB74D);
  static const Color warningBg = Color(0xFF2C220E);
  static const Color warningBorder = Color(0x40FFB74D);

  static const Color info = Color(0xFF4FC3F7);
  static const Color infoBg = Color(0xFF0F2533);
  static const Color infoBorder = Color(0x404FC3F7);

  // Borders & Dividers
  static const Color border = Color(0x26FFFFFF);       // 15% White
  static const Color borderSubtle = Color(0x14FFFFFF); // 8% White
  static const Color borderFocus = Color(0xFF00E676);   // Active Focus ring

  // Interactive Components (Buttons, Toggles, Chips)
  static const Color buttonPrimary = Color(0xFF00E676);
  static const Color buttonPrimaryText = Color(0xFF06150D);
  static const Color buttonSecondary = Color(0xFF1C3842);
  static const Color buttonSecondaryText = Color(0xFFFFFFFF);
  static const Color buttonDanger = Color(0xFFFF5252);
  static const Color buttonDangerText = Color(0xFFFFFFFF);

  // Overlays & Glassmorphism
  static const Color overlayDark = Color(0xB3000000);
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
