import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_bloc.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

void main() {
  test('Dependencies are injected correctly for Seller Sign Up Bloc', () {
    final bloc = SellerSignUpPageBloc(authRepository: SellerRepository());
    expect(bloc, isNotNull);
  });
}
