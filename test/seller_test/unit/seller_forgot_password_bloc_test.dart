import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  group('SellerForgotPasswordBloc', () {
    late SellerForgotPasswordBloc bloc;
    late MockSellerRepository mockRepository;

    setUp(() {
      mockRepository = MockSellerRepository();
      bloc = SellerForgotPasswordBloc(authRepository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, const SellerForgotPasswordState());
    });

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits correct state when email changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerForgotPasswordEmailChanged('test@test.com')),
      expect: () => [
        const SellerForgotPasswordState(email: 'test@test.com'),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits [failure] on empty email submit',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerForgotPasswordSubmitted()),
      expect: () => [
        const SellerForgotPasswordState(status: SellerForgotPasswordStatus.loading),
        const SellerForgotPasswordState(status: SellerForgotPasswordStatus.failure, errorMessage: 'Please enter your email'),
      ],
    );
  });
}
