import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/ForgotPasswordPage/ForgotPasswordPage_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/ForgotPasswordPage/ForgotPasswordPage_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/ForgotPasswordPage/ForgotPasswordPage_State.dart';

void main() {
  group('ForgotPasswordBloc', () {
    test('initial state is correct', () {
      final bloc = ForgotPasswordBloc();
      expect(bloc.state.email, '');
      expect(bloc.state.status, ForgotPasswordStatus.initial);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits updated email and resets status when ForgotPasswordEmailChanged is added',
      build: () => ForgotPasswordBloc(),
      act: (bloc) =>
          bloc.add(const ForgotPasswordEmailChanged('test@example.com')),
      expect: () => [
        const ForgotPasswordState(
          email: 'test@example.com',
          status: ForgotPasswordStatus.initial,
        ),
      ],
    );

    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits [loading, success] when ForgotPasswordSubmitted succeeds (mock delay)',
      build: () => ForgotPasswordBloc(),
      seed: () => const ForgotPasswordState(email: 'test@example.com'),
      act: (bloc) => bloc.add(const ForgotPasswordSubmitted()),
      wait: const Duration(seconds: 2),
      expect: () => [
        const ForgotPasswordState(
          email: 'test@example.com',
          status: ForgotPasswordStatus.loading,
        ),
        const ForgotPasswordState(
          email: 'test@example.com',
          status: ForgotPasswordStatus.success,
        ),
      ],
    );
  });
}
