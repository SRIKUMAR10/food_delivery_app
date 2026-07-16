import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_repository.dart';

class MockDisputesRefundsRepository extends Mock implements DisputesRefundsRepository {}

void main() {
  group('DisputesRefundsPage Error Handling Test', () {
    late DisputesRefundsBloc bloc;
    late MockDisputesRefundsRepository mockRepository;

    setUp(() {
      mockRepository = MockDisputesRefundsRepository();
      bloc = DisputesRefundsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<DisputesRefundsBloc, DisputesRefundsState>(
      'Handles network errors gracefully',
      build: () {
        when(() => mockRepository.getDisputes(any())).thenThrow(Exception('TimeoutException'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDisputesEvent('seller1')),
      expect: () => [
        isA<DisputesRefundsLoading>(),
        isA<DisputesRefundsError>().having((s) => s.message, 'message', contains('TimeoutException')),
      ],
    );
  });
}
