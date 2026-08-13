import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/utils/app_role_helper.dart';

void main() {
  group('AppRoleHelper Unit Tests', () {
    test('Non-web platform returns fallback AppRole.buyer', () {
      final role = getEffectiveAppRole(AppRole.buyer);
      expect(role, AppRole.buyer);
    });

    test('Non-web platform returns fallback AppRole.seller', () {
      final role = getEffectiveAppRole(AppRole.seller);
      expect(role, AppRole.seller);
    });

    test('Non-web platform returns fallback AppRole.delivery', () {
      final role = getEffectiveAppRole(AppRole.delivery);
      expect(role, AppRole.delivery);
    });
  });
}
