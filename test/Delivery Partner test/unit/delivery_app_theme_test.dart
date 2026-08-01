import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/theme/delivery_app_colors.dart';
import 'package:food_delivery_app/core/theme/delivery_app_typography.dart';
import 'package:food_delivery_app/core/theme/delivery_app_theme.dart';

void main() {
  group('DeliveryAppTheme & Design System Tests', () {
    test('DeliveryAppColors tokens must have valid non-null values', () {
      expect(DeliveryAppColors.primary, isNotNull);
      expect(DeliveryAppColors.background, isNotNull);
      expect(DeliveryAppColors.surface, isNotNull);
      expect(DeliveryAppColors.textPrimary, equals(const Color(0xFFFFFFFF)));
      expect(DeliveryAppColors.error, equals(const Color(0xFFFF5252)));
    });

    test('DeliveryAppTypography font scale & legibility compliance', () {
      expect(DeliveryAppTypography.h1.fontSize, equals(24.0));
      expect(DeliveryAppTypography.h2.fontSize, equals(20.0));
      expect(DeliveryAppTypography.bodyMedium.fontSize, equals(14.0));
      expect(DeliveryAppTypography.button.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('DeliveryAppTheme provides valid dark theme configuration', (WidgetTester tester) async {
      final theme = DeliveryAppTheme.theme;
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(DeliveryAppColors.background));
      expect(theme.colorScheme.primary, equals(DeliveryAppColors.primary));
    });
  });
}
