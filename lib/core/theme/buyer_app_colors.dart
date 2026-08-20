import 'package:flutter/material.dart';

/// Centralized Brand Color Tokens for the Buyer (customer) module.
/// Replaces the previously scattered hardcoded brand reds and shared
/// neutral tones used across buyer screens.
abstract class BuyerAppColors {
  /// Primary buyer brand red (profile, home, settings, payment).
  static const Color primary = Color(0xFFEF2A39);

  /// Deeper brand red (login, wallet, order, track).
  static const Color primaryDeep = Color(0xFFE52121);

  /// Auth & form field fill background.
  static const Color fieldFill = Color(0xFFEEF0F5);

  /// Auth page scaffold background.
  static const Color pageBackground = Color(0xFFF7F7F7);
}