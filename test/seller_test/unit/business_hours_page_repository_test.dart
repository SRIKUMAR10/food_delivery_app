import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_model.dart';

class MockBusinessHoursService extends Mock implements BusinessHoursService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const BusinessDayModel(
      dayOfWeek: 'Monday',
      openTime: '09:00 AM',
      closeTime: '10:00 PM',
      isOpen: true,
    ));
  });

  group('BusinessHoursRepository', () {
    late BusinessHoursRepository repository;
    late MockBusinessHoursService mockService;

    setUp(() {
      mockService = MockBusinessHoursService();
      repository = BusinessHoursRepository(service: mockService);
    });

    test('getSchedule calls service.fetchSchedule', () async {
      when(() => mockService.fetchSchedule(any())).thenAnswer((_) async => {'schedule': []});
      await repository.getSchedule('seller1');
      verify(() => mockService.fetchSchedule('seller1')).called(1);
    });

    test('watchSchedule calls service.watchSchedule', () {
      when(() => mockService.watchSchedule(any())).thenAnswer((_) => Stream.value({'schedule': []}));
      final stream = repository.watchSchedule('seller1');
      expect(stream, isA<Stream<Map<String, dynamic>>>());
      verify(() => mockService.watchSchedule('seller1')).called(1);
    });

    test('updateDay calls service.updateSchedule', () async {
      final day = const BusinessDayModel(
        dayOfWeek: 'Monday',
        openTime: '09:00 AM',
        closeTime: '10:00 PM',
        isOpen: true,
      );
      when(() => mockService.updateSchedule(any(), any())).thenAnswer((_) async {});
      await repository.updateDay('seller1', day);
      verify(() => mockService.updateSchedule('seller1', day)).called(1);
    });

    test('toggleEmergencyClose calls service.toggleEmergencyClose', () async {
      when(() => mockService.toggleEmergencyClose(any(), any())).thenAnswer((_) async {});
      await repository.toggleEmergencyClose('seller1', true);
      verify(() => mockService.toggleEmergencyClose('seller1', true)).called(1);
    });

    test('saveFullSchedule calls service.saveFullSchedule', () async {
      final defaultSchedule = BusinessDayModel.defaultWeeklySchedule();
      when(() => mockService.saveFullSchedule(any(), any(), isEmergencyClosed: any(named: 'isEmergencyClosed')))
          .thenAnswer((_) async {});
      await repository.saveFullSchedule('seller1', defaultSchedule, isEmergencyClosed: false);
      verify(() => mockService.saveFullSchedule('seller1', defaultSchedule, isEmergencyClosed: false)).called(1);
    });
  });
}

