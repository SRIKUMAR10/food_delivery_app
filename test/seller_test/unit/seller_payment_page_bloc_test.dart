import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_state.dart';

void main() {
  group('SellerPaymentPageBloc', () {
    late SellerPaymentPageBloc paymentBloc;

    setUp(() {
      paymentBloc = SellerPaymentPageBloc();
    });

    tearDown(() {
      paymentBloc.close();
    });

    test('initial state should be SellerPaymentPageInitial', () {
      expect(paymentBloc.state, isA<SellerPaymentPageInitial>());
    });

    blocTest<SellerPaymentPageBloc, SellerPaymentPageState>(
      'emits [Loading, Loaded] when LoadPaymentData is added',
      build: () => paymentBloc,
      act: (bloc) => bloc.add(LoadPaymentData()),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<SellerPaymentPageLoading>(),
        isA<SellerPaymentPageLoaded>(),
      ],
    );

    blocTest<SellerPaymentPageBloc, SellerPaymentPageState>(
      'emits [Loading, Loaded] when RefreshPaymentData is added',
      build: () => paymentBloc,
      act: (bloc) => bloc.add(RefreshPaymentData()),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<SellerPaymentPageLoading>(),
        isA<SellerPaymentPageLoaded>(),
      ],
    );
  });
}
