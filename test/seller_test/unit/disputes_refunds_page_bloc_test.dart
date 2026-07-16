import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_repository.dart';

class MockDisputesRefundsRepository extends Mock implements DisputesRefundsRepository {}

void main() {
  group('DisputesRefundsBloc', () {
    late DisputesRefundsBloc bloc;
    late MockDisputesRefundsRepository mockRepository;

    setUp(() {
      mockRepository = MockDisputesRefundsRepository();
      bloc = DisputesRefundsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is DisputesRefundsInitial', () {
      expect(bloc.state, isA<DisputesRefundsInitial>());
    });

    blocTest<DisputesRefundsBloc, DisputesRefundsState>(
      'emits [Loading, Loaded] when LoadDisputesEvent is added',
      build: () {
        when(() => mockRepository.getDisputes(any())).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDisputesEvent('seller1')),
      expect: () => [
        isA<DisputesRefundsLoading>(),
        isA<DisputesRefundsLoaded>(),
      ],
    );
  });
}
