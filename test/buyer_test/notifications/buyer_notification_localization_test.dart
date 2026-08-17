import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_strings.dart';

void main() {
  group('BuyerNotificationStrings localization', () {
    test('English strings are non-empty and differ from Tamil', () {
      const en = BuyerNotificationStrings(languageCode: 'en');
      const ta = BuyerNotificationStrings(languageCode: 'ta');

      expect(en.pageTitle, 'Notifications');
      expect(ta.pageTitle, 'அறிவிப்புகள்');
      expect(en.pageTitle, isNot(ta.pageTitle));
      expect(en.markAllRead, isNot(ta.markAllRead));
      expect(en.filterOrders, isNot(ta.filterOrders));
    });

    test('isTamil flag reflects language code', () {
      expect(const BuyerNotificationStrings(languageCode: 'ta').isTamil, true);
      expect(const BuyerNotificationStrings(languageCode: 'en').isTamil, false);
    });

    test('filterLabel maps filter keys to localized text', () {
      const en = BuyerNotificationStrings(languageCode: 'en');
      const ta = BuyerNotificationStrings(languageCode: 'ta');

      expect(en.filterLabel('orders'), 'Orders');
      expect(ta.filterLabel('orders'), 'ஆர்டர்கள்');
      expect(en.filterLabel('all'), 'All');
      expect(en.filterLabel('unknown'), 'All');
    });

    test('action labels are localized', () {
      const en = BuyerNotificationStrings(languageCode: 'en');
      const ta = BuyerNotificationStrings(languageCode: 'ta');

      expect(en.actionTrackOrder, 'Track Order');
      expect(ta.actionTrackOrder, 'ஆர்டரை கண்காணி');
      expect(en.actionApplyCoupon, isNot(ta.actionApplyCoupon));
    });
  });
}
