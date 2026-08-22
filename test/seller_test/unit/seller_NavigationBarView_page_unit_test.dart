import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_state.dart';

void main() {
  group('Seller NavigationBarView Page Unit Tests', () {
    test('SellerNavigationBarViewPageInitial equality and props', () {
      const state1 = SellerNavigationBarViewPageInitial(tabIndex: 0);
      const state2 = SellerNavigationBarViewPageInitial(tabIndex: 0);
      const state3 = SellerNavigationBarViewPageInitial(tabIndex: 1);

      expect(state1, equals(state2));
      expect(state1 == state3, isFalse);
      expect(state1.currentTabIndex, 0);
      expect(state3.currentTabIndex, 1);
    });

    test('SellerNavigationBarViewPageUpdated equality and props', () {
      const state1 = SellerNavigationBarViewPageUpdated(3);
      const state2 = SellerNavigationBarViewPageUpdated(3);
      const state3 = SellerNavigationBarViewPageUpdated(4);

      expect(state1, equals(state2));
      expect(state1 == state3, isFalse);
      expect(state1.currentTabIndex, 3);
      expect(state3.currentTabIndex, 4);
    });

    test('TabChangedEvent equality and props', () {
      const event1 = TabChangedEvent(2);
      const event2 = TabChangedEvent(2);
      const event3 = TabChangedEvent(5);

      expect(event1, equals(event2));
      expect(event1 == event3, isFalse);
      expect(event1.props, [2]);
    });
  });
}

