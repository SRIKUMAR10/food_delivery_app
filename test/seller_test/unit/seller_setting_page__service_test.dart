import 'package:flutter_test/flutter_test.dart';

// Service is often an abstraction over repository or external APIs.
// For the Settings Page, a basic service might just validate settings.
class SellerSettingService {
  bool isValidLanguage(String language) {
    return ['English', 'Tamil', 'Spanish', 'French'].contains(language);
  }

  bool isValidTheme(String theme) {
    return ['Light', 'Dark', 'System Default'].contains(theme);
  }
}

void main() {
  group('SellerSettingService', () {
    late SellerSettingService service;

    setUp(() {
      service = SellerSettingService();
    });

    test('isValidLanguage returns true for supported languages', () {
      expect(service.isValidLanguage('English'), true);
      expect(service.isValidLanguage('Tamil'), true);
    });

    test('isValidLanguage returns false for unsupported languages', () {
      expect(service.isValidLanguage('German'), false);
    });

    test('isValidTheme returns true for supported themes', () {
      expect(service.isValidTheme('Light'), true);
      expect(service.isValidTheme('Dark'), true);
    });

    test('isValidTheme returns false for unsupported themes', () {
      expect(service.isValidTheme('Blue'), false);
    });
  });
}
