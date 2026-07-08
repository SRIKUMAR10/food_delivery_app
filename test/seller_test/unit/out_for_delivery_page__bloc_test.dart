import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__state.dart';

void main() {
  group('OutForDeliveryPageBloc', () {
    late OutForDeliveryPageBloc bloc;

    setUp(() {
      bloc = OutForDeliveryPageBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is OutForDeliveryPageInitial', () {
      expect(bloc.state, OutForDeliveryPageInitial());
    });

    blocTest<OutForDeliveryPageBloc, OutForDeliveryPageState>(
      'emits [Loading, Loaded] when FetchDeliveryDetails is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const FetchDeliveryDetails(orderId: '1025')),
      wait: const Duration(seconds: 1), // matches the 800ms delay in bloc
      expect: () => [
        isA<OutForDeliveryPageLoading>(),
        isA<OutForDeliveryPageLoaded>().having(
          (s) => s.orderId,
          'orderId',
          '1025',
        ),
      ],
    );
  });
}
