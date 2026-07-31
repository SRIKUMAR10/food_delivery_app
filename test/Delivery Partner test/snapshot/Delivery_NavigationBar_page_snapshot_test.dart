import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';

void main() {
  group('DeliveryNavigationBarPage Snapshot State Tests', () {
    test('initial state snapshot matches expected properties', () {
      const state = DeliveryNavigationBarState();

      expect(state.status, DeliveryNavigationBarStatus.initial);
      expect(state.selectedIndex, 4);
      expect(state.navItems, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.uploadProgress, 0.0);
      expect(state.hasPermission, isFalse);
      expect(state.localeCode, 'en');
      expect(state.partnerName, 'Delivery Partner');
      expect(state.isOffline, isFalse);
      expect(state.isUploading, isFalse);
    });

    test('loaded state snapshot exposes default navigation menu', () {
      const state = DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: DeliveryNavigationBarRepository.defaultNavItems,
      );

      expect(state.status, DeliveryNavigationBarStatus.loaded);
      expect(state.navItems, hasLength(10));
      expect(state.navItems.first.label, 'Dashboard');
      expect(state.navItems.last.label, 'Navigate');
    });

    test('copyWith preserves unmodified fields correctly', () {
      const state = DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        selectedIndex: 4,
        navItems: DeliveryNavigationBarRepository.defaultNavItems,
        localeCode: 'en',
        partnerName: 'Ravi Kumar',
      );

      final copy = state.copyWith(selectedIndex: 2);

      expect(copy.selectedIndex, 2);
      expect(copy.status, DeliveryNavigationBarStatus.loaded);
      expect(copy.navItems, DeliveryNavigationBarRepository.defaultNavItems);
      expect(copy.localeCode, 'en');
      expect(copy.partnerName, 'Ravi Kumar');
    });

    test('clearError flag resets the error message', () {
      const state = DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.error,
        errorMessage: 'Something failed',
      );

      final copy = state.copyWith(errorMessage: null, clearError: true);

      expect(copy.errorMessage, isNull);
      expect(copy.status, DeliveryNavigationBarStatus.error);
    });

    test('state equality is value based', () {
      const stateA = DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: DeliveryNavigationBarRepository.defaultNavItems,
        selectedIndex: 4,
      );
      const stateB = DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: DeliveryNavigationBarRepository.defaultNavItems,
        selectedIndex: 4,
      );
      const stateC = DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: DeliveryNavigationBarRepository.defaultNavItems,
        selectedIndex: 2,
      );

      expect(stateA, stateB);
      expect(stateA, isNot(stateC));
    });
  });
}
