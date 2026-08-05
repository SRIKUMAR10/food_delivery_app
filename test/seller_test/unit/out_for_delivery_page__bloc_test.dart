import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__state.dart';

class MockOutForDeliveryRepository extends Mock
    implements OutForDeliveryRepository {}

void main() {
  group('OutForDeliveryPageBloc', () {
    late OutForDeliveryPageBloc bloc;
    late MockOutForDeliveryRepository mockRepository;

    setUp(() {
      mockRepository = MockOutForDeliveryRepository();
      bloc = OutForDeliveryPageBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is OutForDeliveryPageInitial', () {
      expect(bloc.state, OutForDeliveryPageInitial());
    });

    blocTest<OutForDeliveryPageBloc, OutForDeliveryPageState>(
      'emits [Loading, Loaded] when FetchDeliveryDetails is added',
      build: () {
        when(() => mockRepository.streamDeliveryDetails('1025')).thenAnswer(
          (_) => Stream.value(
            OutForDeliveryPageData(
              orderId: '1025',
              rider: const RiderDetails(
                id: 'rider_1',
                name: 'Raj',
                phone: '+911234567890',
                imageUrl: '',
                rating: 4.8,
              ),
              currentStatus: DeliveryStatus.outForDelivery,
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchDeliveryDetails(orderId: '1025')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<OutForDeliveryPageLoading>(),
        isA<OutForDeliveryPageLoaded>().having(
          (s) => s.orderId,
          'orderId',
          '1025',
        ),
      ],
    );

    blocTest<OutForDeliveryPageBloc, OutForDeliveryPageState>(
      'emits [Loading, Error] when the repository stream errors',
      build: () {
        when(() => mockRepository.streamDeliveryDetails('999'))
            .thenAnswer((_) => Stream.error(Exception('Order not found')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchDeliveryDetails(orderId: '999')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<OutForDeliveryPageLoading>(),
        isA<OutForDeliveryPageError>(),
      ],
    );
  });
}
