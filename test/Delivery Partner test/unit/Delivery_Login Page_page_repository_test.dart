import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_repository.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late DeliveryLoginRepository repository;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    repository = DeliveryLoginRepository(sharedPreferences: mockSharedPreferences);
  });

  group('DeliveryLoginRepository Unit Tests', () {
    test('loginWithPhone returns true for valid credentials', () async {
      final result = await repository.loginWithPhone('9876543210', 'password123');
      expect(result, isTrue);
    });

    test('loginWithPhone throws exception for invalid credentials', () async {
      expect(
        () => repository.loginWithPhone('', 'short'),
        throwsA(isA<Exception>()),
      );
    });

    test('loginWithGoogle returns true', () async {
      final result = await repository.loginWithGoogle();
      expect(result, isTrue);
    });

    test('loginWithApple returns true', () async {
      final result = await repository.loginWithApple();
      expect(result, isTrue);
    });

    test('saveSelectedLanguage saves to SharedPreferences', () async {
      when(() => mockSharedPreferences.setString('delivery_login_lang', 'ta')).thenAnswer((_) async => true);
      await repository.saveSelectedLanguage('ta');
      verify(() => mockSharedPreferences.setString('delivery_login_lang', 'ta')).called(1);
    });

    test('getSelectedLanguage fetches from SharedPreferences', () async {
      when(() => mockSharedPreferences.getString('delivery_login_lang')).thenReturn('ta');
      final lang = await repository.getSelectedLanguage();
      expect(lang, equals('ta'));
    });

    test('saveSavedPhone saves phone number', () async {
      when(() => mockSharedPreferences.setString('delivery_login_saved_phone', '9876543210')).thenAnswer((_) async => true);
      await repository.saveSavedPhone('9876543210');
      verify(() => mockSharedPreferences.setString('delivery_login_saved_phone', '9876543210')).called(1);
    });
  });
}
