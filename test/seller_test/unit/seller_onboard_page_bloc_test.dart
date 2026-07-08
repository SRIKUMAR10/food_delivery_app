import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_state.dart';

void main() {
  group('SellerOnboardPageBloc', () {
    late SellerOnboardPageBloc sellerOnboardPageBloc;

    setUp(() {
      sellerOnboardPageBloc = SellerOnboardPageBloc();
    });

    tearDown(() {
      sellerOnboardPageBloc.close();
    });

    test('initial state is SellerOnboardInitial', () {
      expect(sellerOnboardPageBloc.state, SellerOnboardInitial());
    });

    blocTest<SellerOnboardPageBloc, SellerOnboardPageState>(
      'emits [SellerOnboardLoading, SellerOnboardSuccess] when SellerOnboardGetStartedPressed is added',
      build: () => sellerOnboardPageBloc,
      act: (bloc) => bloc.add(SellerOnboardGetStartedPressed()),
      wait: const Duration(seconds: 2), // Since the BLoC has a 2 second delay
      expect: () => [SellerOnboardLoading(), SellerOnboardSuccess()],
    );
  });
}
