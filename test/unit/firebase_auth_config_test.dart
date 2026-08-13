import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/firebase_auth_config.dart';

void main() {
  group('FirebaseAuthConfig Unit Tests', () {
    test('defaultActionCodeSettings contains authorized primary hosting domain', () {
      final settings = FirebaseAuthConfig.defaultActionCodeSettings;

      expect(settings.url, equals('https://food-delivery-app-cd4ca.firebaseapp.com'));
      expect(settings.handleCodeInApp, isTrue);
      expect(settings.androidPackageName, equals('com.example.food_delivery_app'));
      expect(settings.androidInstallApp, isTrue);
      expect(settings.androidMinimumVersion, equals('1'));
      expect(settings.iOSBundleId, equals('com.example.foodDeliveryApp'));
      expect(settings.linkDomain, equals('food-delivery-app-cd4ca.firebaseapp.com'));
      expect(settings.dynamicLinkDomain, isNull);
    });

    test('getActionCodeSettings allows custom URL and secondary hosting domain', () {
      final settings = FirebaseAuthConfig.getActionCodeSettings(
        url: 'https://food-delivery-app-cd4ca.web.app/auth',
        linkDomain: 'food-delivery-app-cd4ca.web.app',
      );

      expect(settings.url, equals('https://food-delivery-app-cd4ca.web.app/auth'));
      expect(settings.linkDomain, equals('food-delivery-app-cd4ca.web.app'));
      expect(settings.androidPackageName, equals('com.example.food_delivery_app'));
      expect(settings.dynamicLinkDomain, isNull);
    });

    test('hosting domains constants are properly configured', () {
      expect(FirebaseAuthConfig.primaryHostingDomain, equals('food-delivery-app-cd4ca.firebaseapp.com'));
      expect(FirebaseAuthConfig.secondaryHostingDomain, equals('food-delivery-app-cd4ca.web.app'));
      expect(FirebaseAuthConfig.defaultRedirectUrl, equals('https://food-delivery-app-cd4ca.firebaseapp.com'));
    });
  });
}
