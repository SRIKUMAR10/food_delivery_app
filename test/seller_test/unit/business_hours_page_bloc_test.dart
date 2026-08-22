import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_model.dart';

class MockBusinessHoursRepository extends Mock implements BusinessHoursRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const BusinessDayModel(
      dayOfWeek: 'Monday',
      openTime: '09:00 AM',
      closeTime: '10:00 PM',
      isOpen: true,
    ));
  });

  group('BusinessHoursBloc', () {
    late BusinessHoursBloc bloc;
    late MockBusinessHoursRepository mockRepository;

    final defaultDays = BusinessDayModel.defaultWeeklySchedule();

    setUp(() {
      mockRepository = MockBusinessHoursRepository();
      when(() => mockRepository.watchSchedule(any())).thenAnswer((_) => Stream.value({
        'isEmergencyClosed': false,
        'schedule': defaultDays,
      }));
      bloc = BusinessHoursBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is BusinessHoursInitial', () {
      expect(bloc.state, isA<BusinessHoursInitial>());
    });

    blocTest<BusinessHoursBloc, BusinessHoursState>(
      'emits [Loading, Loaded] on LoadBusinessHoursEvent with full 7-day schedule',
      build: () {
        when(() => mockRepository.getSchedule(any())).thenAnswer((_) async => {
          'isEmergencyClosed': false,
          'schedule': defaultDays,
        });
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadBusinessHoursEvent('seller1')),
      expect: () => [
        isA<BusinessHoursLoading>(),
        isA<BusinessHoursLoaded>().having(
          (s) => s.schedule.length,
          'schedule length',
          7,
        ),
      ],
    );

    blocTest<BusinessHoursBloc, BusinessHoursState>(
      'emits updated state on UpdateBusinessDayEvent',
      build: () {
        when(() => mockRepository.updateDay(any(), any())).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => BusinessHoursLoaded(
        schedule: defaultDays,
        isEmergencyClosed: false,
      ),
      act: (bloc) => bloc.add(UpdateBusinessDayEvent(defaultDays[0].copyWith(isOpen: false))),
      expect: () => [
        isA<BusinessHoursLoaded>().having((s) => s.isUpdating, 'isUpdating', true),
        isA<BusinessHoursLoaded>().having((s) => s.schedule.first.isOpen, 'isOpen', false),
      ],
      verify: (_) {
        verify(() => mockRepository.updateDay('seller1', any())).called(1);
      },
    );

    blocTest<BusinessHoursBloc, BusinessHoursState>(
      'emits updated emergency closed status on ToggleEmergencyCloseEvent',
      build: () {
        when(() => mockRepository.toggleEmergencyClose(any(), any())).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => BusinessHoursLoaded(
        schedule: defaultDays,
        isEmergencyClosed: false,
      ),
      act: (bloc) => bloc.add(const ToggleEmergencyCloseEvent(true)),
      expect: () => [
        isA<BusinessHoursLoaded>().having((s) => s.isUpdating, 'isUpdating', true),
        isA<BusinessHoursLoaded>().having((s) => s.isEmergencyClosed, 'isEmergencyClosed', true),
      ],
      verify: (_) {
        verify(() => mockRepository.toggleEmergencyClose('seller1', true)).called(1);
      },
    );
  });
}

