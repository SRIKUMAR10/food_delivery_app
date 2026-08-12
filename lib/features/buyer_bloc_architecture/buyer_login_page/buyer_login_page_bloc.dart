import 'package:flutter_bloc/flutter_bloc.dart';
import 'buyer_login_page_event.dart';
import 'buyer_login_page_state.dart';
import 'buyer_login_page_repository.dart';

class BuyerLoginBloc extends Bloc<BuyerLoginEvent, BuyerLoginState> {
  final BuyerLoginRepository repository;

  BuyerLoginBloc({BuyerLoginRepository? repository})
      : repository = repository ?? BuyerLoginRepository(),
        super(const BuyerLoginState()) {
    on<BuyerLoginPhoneChanged>(_onPhoneChanged);
    on<BuyerLoginPasswordChanged>(_onPasswordChanged);
    on<BuyerLoginTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<BuyerLoginSubmitted>(_onSubmitted);
    on<BuyerLoginGoogleSubmitted>(_onGoogleSubmitted);
  }

  void _onPhoneChanged(
    BuyerLoginPhoneChanged event,
    Emitter<BuyerLoginState> emit,
  ) {
    emit(state.copyWith(phone: event.phone));
  }

  void _onPasswordChanged(
    BuyerLoginPasswordChanged event,
    Emitter<BuyerLoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  void _onTogglePasswordVisibility(
    BuyerLoginTogglePasswordVisibility event,
    Emitter<BuyerLoginState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  Future<void> _onSubmitted(
    BuyerLoginSubmitted event,
    Emitter<BuyerLoginState> emit,
  ) async {
    if (event.phone.trim().isEmpty) {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: 'Please enter your phone number',
      ));
      return;
    }
    if (event.password.trim().isEmpty) {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: 'Please enter your password',
      ));
      return;
    }

    emit(state.copyWith(status: BuyerLoginStatus.loading));

    try {
      final userId = await repository.login(
        phone: event.phone,
        password: event.password,
      );
      emit(state.copyWith(
        status: BuyerLoginStatus.success,
        userId: userId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onGoogleSubmitted(
    BuyerLoginGoogleSubmitted event,
    Emitter<BuyerLoginState> emit,
  ) async {
    emit(state.copyWith(status: BuyerLoginStatus.loading));
    try {
      final userId = await repository.loginWithGoogle();
      if (userId != null) {
        emit(state.copyWith(
          status: BuyerLoginStatus.success,
          userId: userId,
        ));
      } else {
        emit(state.copyWith(status: BuyerLoginStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BuyerLoginStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
