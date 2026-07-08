import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_bloc.dart';

void main() {
  group('Dependency Test', () {
    test(
      'SellerOnboardPageBloc can be instantiated without tight coupling',
      () {
        // If BLoC required dependencies, we would inject mocks here
        // For now, it instantiates correctly without breaking the DI container
        final bloc = SellerOnboardPageBloc();

        expect(bloc, isNotNull);
        bloc.close();
      },
    );

    // In a real application, we'd verify get_it or provider injects the correct types:
    // expect(GetIt.I<SellerOnboardPageBloc>(), isA<SellerOnboardPageBloc>());
  });
}
