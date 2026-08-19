import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'buyer_sign_up_page_event.dart';
import 'buyer_sign_up_page_state.dart';
import 'buyer_sign_up_page_repository.dart';

class BuyerSignUpBloc extends Bloc<BuyerSignUpEvent, BuyerSignUpState> {
  final BuyerSignUpRepository repository;

  BuyerSignUpBloc({BuyerSignUpRepository? repository})
      : repository = repository ?? BuyerSignUpRepository(),
        super(const BuyerSignUpState()) {
    on<BuyerSignUpSubmitted>(_onSubmitted);
    on<BuyerSignUpTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<BuyerSignUpToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
  }

  void _onTogglePasswordVisibility(
    BuyerSignUpTogglePasswordVisibility event,
    Emitter<BuyerSignUpState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  void _onToggleConfirmPasswordVisibility(
    BuyerSignUpToggleConfirmPasswordVisibility event,
    Emitter<BuyerSignUpState> emit,
  ) {
    emit(state.copyWith(
        isConfirmPasswordObscured: !state.isConfirmPasswordObscured));
  }

  Future<void> _onSubmitted(
    BuyerSignUpSubmitted event,
    Emitter<BuyerSignUpState> emit,
  ) async {
    if (event.fullName.trim().isEmpty) {
      emit(state.copyWith(
        status: BuyerSignUpStatus.failure,
        errorMessage: 'Please enter your full name',
      ));
      return;
    }
    if (event.email.trim().isNotEmpty && !event.email.contains('@')) {
      emit(state.copyWith(
        status: BuyerSignUpStatus.failure,
        errorMessage: 'Please enter a valid email address',
      ));
      return;
    }
    if (event.mobileNumber.trim().isEmpty) {
      emit(state.copyWith(
        status: BuyerSignUpStatus.failure,
        errorMessage: 'Please enter your mobile number',
      ));
      return;
    }
    if (event.password.isEmpty || event.password.length < 6) {
      emit(state.copyWith(
        status: BuyerSignUpStatus.failure,
        errorMessage: 'Password must be at least 6 characters',
      ));
      return;
    }
    if (event.password != event.confirmPassword) {
      emit(state.copyWith(
        status: BuyerSignUpStatus.failure,
        errorMessage: 'Passwords do not match',
      ));
      return;
    }

    emit(state.copyWith(status: BuyerSignUpStatus.loading));

    try {
      final isRegistered =
          await repository.isPhoneRegistered(mobileNumber: event.mobileNumber);
      if (isRegistered) {
        emit(state.copyWith(
          status: BuyerSignUpStatus.failure,
          errorMessage:
              'An account with this mobile number already exists in Buyer app. Please sign in instead.',
        ));
        return;
      }

      final verificationId =
          await repository.sendOtp(mobileNumber: event.mobileNumber);
      emit(state.copyWith(
        status: BuyerSignUpStatus.otpSent,
        fullName: event.fullName.trim(),
        email: event.email.trim(),
        mobileNumber: event.mobileNumber.trim(),
        password: event.password,
        verificationId: verificationId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BuyerSignUpStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }
}
