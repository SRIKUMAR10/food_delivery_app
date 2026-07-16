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
  group('BusinessHoursBloc', () {
    late BusinessHoursBloc bloc;
    late MockBusinessHoursRepository mockRepository;

    setUp(() {
      mockRepository = MockBusinessHoursRepository();
      bloc = BusinessHoursBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is BusinessHoursInitial', () {
      expect(bloc.state, isA<BusinessHoursInitial>());
    });

    blocTest<BusinessHoursBloc, BusinessHoursState>(
      'emits [Loading, Loaded] on LoadBusinessHoursEvent',
      build: () {
        when(() => mockRepository.getSchedule(any())).thenAnswer((_) async => {
          'isEmergencyClosed': false,
          'schedule': <BusinessDayModel>[],
        });
        return bloc;
      },
      act: (bloc) => bloc.add(LoadBusinessHoursEvent('seller1')),
      expect: () => [
        isA<BusinessHoursLoading>(),
        isA<BusinessHoursLoaded>(),
      ],
    );
  });
}
