import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_service.dart';

class MockBusinessHoursService extends Mock implements BusinessHoursService {}

void main() {
  group('BusinessHoursRepository', () {
    late BusinessHoursRepository repository;
    late MockBusinessHoursService mockService;

    setUp(() {
      mockService = MockBusinessHoursService();
      repository = BusinessHoursRepository(service: mockService);
    });

    test('getSchedule calls service', () async {
      when(() => mockService.fetchSchedule(any())).thenAnswer((_) async => {});
      await repository.getSchedule('seller1');
      verify(() => mockService.fetchSchedule('seller1')).called(1);
    });
  });
}
