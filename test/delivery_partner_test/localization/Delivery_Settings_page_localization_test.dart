import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_ui.dart';

void main() {
  group('DeliverySettingsStrings Localization Tests', () {
    test('English localization strings resolve correctly', () {
      expect(DeliverySettingsStrings.of('title', 'en'), 'Delivery Settings');
      expect(DeliverySettingsStrings.of('radius', 'en'), 'Delivery Radius');
      expect(DeliverySettingsStrings.of('save', 'en'), 'Save Settings');
      expect(DeliverySettingsStrings.of('logout', 'en'), 'Log Out');
    });

    test('Tamil localization strings resolve correctly', () {
      expect(DeliverySettingsStrings.of('title', 'ta'), 'டெலிவரி அமைப்புகள்');
      expect(DeliverySettingsStrings.of('radius', 'ta'), 'டெலிவரி ஆரம்');
      expect(DeliverySettingsStrings.of('save', 'ta'), 'அமைப்புகளை சேமிக்கவும்');
      expect(DeliverySettingsStrings.of('logout', 'ta'), 'வெளியேறு');
    });

    test('formatDeliveryCurrency handles INR currency symbol and formatting', () {
      final formatted = formatDeliveryCurrency(1200.0, 'en');
      expect(formatted, contains('1,200.00'));
      expect(formatted, contains('\u20B9'));
    });
  });
}
