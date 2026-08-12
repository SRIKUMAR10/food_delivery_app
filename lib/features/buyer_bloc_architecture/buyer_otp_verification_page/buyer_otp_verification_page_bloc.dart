import 'package:flutter_bloc/flutter_bloc.dart';
import 'buyer_otp_verification_page_event.dart';
import 'buyer_otp_verification_page_state.dart';
import 'buyer_otp_verification_page_repository.dart';

class BuyerOtpBloc extends Bloc<BuyerOtpEvent, BuyerOtpState> {
  final BuyerOtpRepository repository;

  BuyerOtpBloc({BuyerOtpRepository? repository})
      : repository = repository ?? BuyerOtpRepository(),
        super(const BuyerOtpState()) {
    on<BuyerVerifyOtpSubmitted>(_onVerifyOtpSubmitted);
  }

  Future<void> _onVerifyOtpSubmitted(
    BuyerVerifyOtpSubmitted event,
    Emitter<BuyerOtpState> emit,
  ) async {
    if (event.otpCode.trim().isEmpty) {
      emit(state.copyWith(
        status: BuyerOtpStatus.failure,
        errorMessage: 'Please enter the OTP code',
      ));
      return;
    }

    emit(state.copyWith(status: BuyerOtpStatus.loading));

    try {
      await repository.verifyOtpAndSaveProfile(
        fullName: event.fullName,
        email: event.email,
        mobileNumber: event.mobileNumber,
        password: event.password,
        otpCode: event.otpCode,
        verificationId: event.verificationId,
      );
      emit(state.copyWith(status: BuyerOtpStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: BuyerOtpStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
