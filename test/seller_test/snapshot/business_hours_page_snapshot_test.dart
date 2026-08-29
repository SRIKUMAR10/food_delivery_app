import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_model.dart';

void main() {
  group('BusinessHoursPage Snapshot Test', () {
    test('State serialization and deserialization snapshot', () {
      final model = const BusinessDayModel(
        dayOfWeek: 'Monday',
        openTime: '09:00 AM',
        closeTime: '10:00 PM',
        isOpen: true,
      );

      final map = model.toMap();
      expect(map['dayOfWeek'], 'Monday');
      expect(map['openTime'], '09:00 AM');
      expect(map['closeTime'], '10:00 PM');
      expect(map['isOpen'], isTrue);

      final deserialized = BusinessDayModel.fromMap(map);
      expect(deserialized, equals(model));
      expect(deserialized.dayOfWeek, model.dayOfWeek);
      expect(deserialized.openTime, model.openTime);
      expect(deserialized.closeTime, model.closeTime);
      expect(deserialized.isOpen, model.isOpen);
    });
  });
}

