import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';

void main() {
  late DeliveryNavigationBarRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = DeliveryNavigationBarRepository(prefs: prefs);
  });

  group('DeliveryNavigationBarPage Repository Tests', () {
    test(
      'fetches default navigation menu configuration with 10 items',
      () async {
        final items = await repository.getNavItems();

        expect(items, hasLength(10));
        final labels = items.map((e) => e.label).toList();
        expect(labels, [
          'Dashboard',
          'Orders',
          'Earnings',
          'Incentives',
          'Profile',
          'Documents',
          'Bank Details',
          'Settings',
          'Help & Support',
          'Navigate',
        ]);
      },
    );

    test('saves and restores selected index via local storage', () async {
      expect(await repository.getSavedSelectedIndex(), -1);

      await repository.saveSelectedIndex(5);
      expect(await repository.getSavedSelectedIndex(), 5);

      await repository.saveSelectedIndex(0);
      expect(await repository.getSavedSelectedIndex(), 0);
    });

    test('persists locale code across repository instances', () async {
      await repository.saveLocaleCode('ta');
      expect(await repository.getLocaleCode(), 'ta');

      final restored = DeliveryNavigationBarRepository();
      expect(await restored.getLocaleCode(), 'ta');
    });

    test('saves and restores partner name', () async {
      expect(await repository.getPartnerName(), 'Delivery Partner');

      await repository.savePartnerName('Arjun Kumar');
      expect(await repository.getPartnerName(), 'Arjun Kumar');
    });

    test('simulates chunked upload stream reaching 100%', () async {
      final values = <double>[];
      await for (final progress in repository.simulateChunkedUpload()) {
        values.add(progress);
      }

      expect(values, isNotEmpty);
      expect(values.first, greaterThan(0));
      expect(values.last, 1.0);
      final isIncreasing = List<double>.generate(
        values.length - 1,
        (i) => values[i],
      );
      for (var i = 0; i < isIncreasing.length; i++) {
        expect(values[i], lessThan(values[i + 1]));
      }
    });
  });
}
