import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_repository.dart';

class MockBusinessHoursRepository extends Mock implements BusinessHoursRepository {}

void main() {
  group('BusinessHoursPage Error Handling Test', () {
    late BusinessHoursBloc bloc;
    late MockBusinessHoursRepository mockRepository;

    setUp(() {
      mockRepository = MockBusinessHoursRepository();
      when(() => mockRepository.watchSchedule(any())).thenAnswer((_) => const Stream.empty());
      bloc = BusinessHoursBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<BusinessHoursBloc, BusinessHoursState>(
      'Gracefully handles network timeout errors',
      build: () {
        when(() => mockRepository.getSchedule(any())).thenThrow(Exception('TimeoutException'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadBusinessHoursEvent('seller1')),
      expect: () => [
        isA<BusinessHoursLoading>(),
        isA<BusinessHoursError>().having((s) => s.message, 'message', contains('TimeoutException')),
      ],
    );
  });
}
