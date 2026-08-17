import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/delivery_partner_model.dart';
import '../../../repositories/delivery_partner_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTH STATUS & STATE
// ─────────────────────────────────────────────────────────────────────────────

enum DeliveryAuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  otpSent,
  passwordResetSent,
  error,
}

class DeliveryAuthState extends Equatable {
  final DeliveryAuthStatus status;
  final DeliveryPartnerModel? partner;
  final User? firebaseUser;
  final String? verificationId;
  final String? errorMessage;
  final String? successMessage;

  const DeliveryAuthState({
    this.status = DeliveryAuthStatus.initial,
    this.partner,
    this.firebaseUser,
    this.verificationId,
    this.errorMessage,
    this.successMessage,
  });

  DeliveryAuthState copyWith({
    DeliveryAuthStatus? status,
    DeliveryPartnerModel? partner,
    User? firebaseUser,
    String? verificationId,
    String? errorMessage,
    String? successMessage,
    bool clearPartner = false,
  }) {
    return DeliveryAuthState(
      status: status ?? this.status,
      partner: clearPartner ? null : (partner ?? this.partner),
      firebaseUser: clearPartner ? null : (firebaseUser ?? this.firebaseUser),
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        partner,
        firebaseUser,
        verificationId,
        errorMessage,
        successMessage,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH EVENTS
// ─────────────────────────────────────────────────────────────────────────────

abstract class DeliveryAuthEvent extends Equatable {
  const DeliveryAuthEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryAuthCheckSessionRequested extends DeliveryAuthEvent {
  const DeliveryAuthCheckSessionRequested();
}

class DeliveryAuthLoginRequested extends DeliveryAuthEvent {
  final String emailOrPhone;
  final String password;
  final bool rememberMe;

  const DeliveryAuthLoginRequested({
    required this.emailOrPhone,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [emailOrPhone, password, rememberMe];
}

class DeliveryAuthGoogleSignInRequested extends DeliveryAuthEvent {
  const DeliveryAuthGoogleSignInRequested();
}

class DeliveryAuthSendOtpRequested extends DeliveryAuthEvent {
  final String phone;
  const DeliveryAuthSendOtpRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}

class DeliveryAuthVerifyOtpRequested extends DeliveryAuthEvent {
  final String verificationId;
  final String smsCode;
  final String? name;
  final String? phone;
  final String? email;
  final String? password;

  const DeliveryAuthVerifyOtpRequested({
    required this.verificationId,
    required this.smsCode,
    this.name,
    this.phone,
    this.email,
    this.password,
  });

  @override
  List<Object?> get props => [verificationId, smsCode, name, phone, email, password];
}

class DeliveryAuthSignUpRequested extends DeliveryAuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String vehicleType;
  final String vehicleNumber;

  const DeliveryAuthSignUpRequested({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.vehicleType,
    required this.vehicleNumber,
  });

  @override
  List<Object?> get props => [name, phone, email, password, vehicleType, vehicleNumber];
}

class DeliveryAuthResetPasswordRequested extends DeliveryAuthEvent {
  final String email;
  const DeliveryAuthResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class DeliveryAuthSignOutRequested extends DeliveryAuthEvent {
  const DeliveryAuthSignOutRequested();
}

// ─────────────────────────────────────────────────────────────────────────────
// DELIVERY AUTH BLOC
// ─────────────────────────────────────────────────────────────────────────────

class DeliveryAuthBloc extends Bloc<DeliveryAuthEvent, DeliveryAuthState> {
  final DeliveryPartnerRepository _repository;

  DeliveryAuthBloc({
    DeliveryPartnerRepository? repository,
  })  : _repository = repository ?? DeliveryPartnerRepository(),
        super(const DeliveryAuthState()) {
    on<DeliveryAuthCheckSessionRequested>(_onCheckSession);
    on<DeliveryAuthLoginRequested>(_onLoginRequested);
    on<DeliveryAuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<DeliveryAuthSendOtpRequested>(_onSendOtpRequested);
    on<DeliveryAuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<DeliveryAuthSignUpRequested>(_onSignUpRequested);
    on<DeliveryAuthResetPasswordRequested>(_onResetPasswordRequested);
    on<DeliveryAuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onCheckSession(
    DeliveryAuthCheckSessionRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryAuthStatus.authenticating));
    try {
      final user = _repository.currentUser;
      if (user != null) {
        final partner = await _repository.getDeliveryPartner(user.uid);
        if (partner != null) {
          emit(state.copyWith(
            status: DeliveryAuthStatus.authenticated,
            partner: partner,
            firebaseUser: user,
          ));
          return;
        }
      }
      emit(state.copyWith(status: DeliveryAuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryAuthStatus.unauthenticated,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoginRequested(
    DeliveryAuthLoginRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryAuthStatus.authenticating, errorMessage: null));
    try {
      final isEmail = event.emailOrPhone.contains('@');
      UserCredential credential;

      if (isEmail) {
        credential = await _repository.signInWithEmailPassword(
          event.emailOrPhone.trim(),
          event.password,
        );
      } else {
        final partner = await _repository.getDeliveryPartnerByPhone(event.emailOrPhone.trim());
        if (partner == null || partner.email == null || partner.email!.isEmpty) {
          throw Exception('No delivery partner account found for phone ${event.emailOrPhone}');
        }
        credential = await _repository.signInWithEmailPassword(
          partner.email!,
          event.password,
        );
      }

      final uid = credential.user?.uid;
      if (uid != null) {
        if (event.rememberMe) {
          await _repository.saveSavedPhone(event.emailOrPhone.trim());
        }
        final partner = await _repository.getDeliveryPartner(uid);
        emit(state.copyWith(
          status: DeliveryAuthStatus.authenticated,
          partner: partner,
          firebaseUser: credential.user,
        ));
      } else {
        throw Exception('Login failed: user ID not returned.');
      }
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryAuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onGoogleSignInRequested(
    DeliveryAuthGoogleSignInRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryAuthStatus.authenticating, errorMessage: null));
    try {
      final cred = await _repository.signInWithGoogle();
      final uid = cred.user?.uid;
      if (uid != null) {
        final partner = await _repository.getDeliveryPartner(uid);
        emit(state.copyWith(
          status: DeliveryAuthStatus.authenticated,
          partner: partner,
          firebaseUser: cred.user,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryAuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSendOtpRequested(
    DeliveryAuthSendOtpRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryAuthStatus.authenticating, errorMessage: null));
    try {
      final completer = Completer<String>();
      await _repository.sendPhoneOtp(
        phoneNumber: event.phone,
        onCodeSent: (verId, [resendToken]) {
          if (!completer.isCompleted) completer.complete(verId);
        },
        onVerificationFailed: (e) {
          if (!completer.isCompleted) completer.completeError(e);
        },
        onVerificationCompleted: (_) {},
        onCodeAutoRetrievalTimeout: (_) {},
      );

      final verId = await completer.future;
      emit(state.copyWith(
        status: DeliveryAuthStatus.otpSent,
        verificationId: verId,
        successMessage: 'OTP sent successfully to ${event.phone}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryAuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onVerifyOtpRequested(
    DeliveryAuthVerifyOtpRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryAuthStatus.authenticating, errorMessage: null));
    try {
      final partner = await _repository.completeOtpVerificationAndCreateAccount(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
        name: event.name ?? '',
        phone: event.phone ?? '',
        email: event.email ?? '',
        password: event.password ?? '',
      );

      emit(state.copyWith(
        status: DeliveryAuthStatus.authenticated,
        partner: partner,
        firebaseUser: _repository.currentUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryAuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSignUpRequested(
    DeliveryAuthSignUpRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryAuthStatus.authenticating, errorMessage: null));
    try {
      final cred = await _repository.createUserWithEmailPassword(event.email, event.password);
      final uid = cred.user?.uid;
      if (uid != null) {
        final now = DateTime.now();
        final partner = DeliveryPartnerModel(
          id: uid,
          phoneNumber: event.phone,
          displayName: event.name,
          email: event.email,
          vehicleType: event.vehicleType,
          vehicleNumber: event.vehicleNumber,
          isOnline: true,
          isAvailable: true,
          status: 'online',
          createdAt: now,
          updatedAt: now,
        );
        await _repository.createDeliveryPartner(uid, partner);
        emit(state.copyWith(
          status: DeliveryAuthStatus.authenticated,
          partner: partner,
          firebaseUser: cred.user,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryAuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onResetPasswordRequested(
    DeliveryAuthResetPasswordRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryAuthStatus.authenticating, errorMessage: null));
    try {
      await _repository.sendPasswordResetEmail(event.email);
      emit(state.copyWith(
        status: DeliveryAuthStatus.passwordResetSent,
        successMessage: 'Password reset email sent to ${event.email}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryAuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSignOutRequested(
    DeliveryAuthSignOutRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryAuthStatus.authenticating));
    try {
      await _repository.signOut();
      emit(state.copyWith(
        status: DeliveryAuthStatus.unauthenticated,
        clearPartner: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryAuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
