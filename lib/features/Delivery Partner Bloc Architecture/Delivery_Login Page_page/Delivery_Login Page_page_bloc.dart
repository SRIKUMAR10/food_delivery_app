import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Login Page_page_event.dart';
import 'Delivery_Login Page_page_state.dart';
import 'Delivery_Login Page_page_repository.dart';
import 'Delivery_Login Page_page_service.dart';

class DeliveryLoginPageBloc extends Bloc<DeliveryLoginPageEvent, DeliveryLoginPageState> {
  final DeliveryLoginRepositoryBase repository;
  final DeliveryLoginServiceBase service;
  StreamSubscription<double>? _uploadSubscription;

  DeliveryLoginPageBloc({
    required this.repository,
    required this.service,
  }) : super(const DeliveryLoginPageState()) {
    on<DeliveryLoginInitEvent>(_onInit);
    on<DeliveryLoginPhoneChangedEvent>(_onPhoneChanged);
    on<DeliveryLoginPasswordChangedEvent>(_onPasswordChanged);
    on<DeliveryLoginTogglePasswordVisibilityEvent>(_onTogglePasswordVisibility);
    on<DeliveryLoginToggleRememberMeEvent>(_onToggleRememberMe);
    on<DeliveryLoginSubmittedEvent>(_onSubmitted);
    on<DeliveryLoginGoogleSubmittedEvent>(_onGoogleSubmitted);
    on<DeliveryLoginAppleSubmittedEvent>(_onAppleSubmitted);
    on<DeliveryLoginLanguageChangedEvent>(_onLanguageChanged);
    on<DeliveryLoginSimulateVideoUploadEvent>(_onSimulateVideoUpload);
  }

  Future<void> _onInit(
    DeliveryLoginInitEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryLoginStatus.loading));
    try {
      final isOnline = await service.checkNetworkConnectivity();
      if (!isOnline) {
        emit(
          state.copyWith(
            status: DeliveryLoginStatus.error,
            errorMessage: 'Network connection unavailable',
          ),
        );
        return;
      }

      final lang = await repository.getSelectedLanguage();
      final savedPhone = await repository.getSavedPhone();

      emit(
        state.copyWith(
          status: DeliveryLoginStatus.initial,
          selectedLanguage: lang,
          phone: savedPhone ?? '',
          isRememberMeChecked: savedPhone != null && savedPhone.isNotEmpty,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryLoginStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onPhoneChanged(
    DeliveryLoginPhoneChangedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    emit(state.copyWith(phone: event.phone, errorMessage: null));
  }

  void _onPasswordChanged(
    DeliveryLoginPasswordChangedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    emit(state.copyWith(password: event.password, errorMessage: null));
  }

  void _onTogglePasswordVisibility(
    DeliveryLoginTogglePasswordVisibilityEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleRememberMe(
    DeliveryLoginToggleRememberMeEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) {
    emit(state.copyWith(isRememberMeChecked: !state.isRememberMeChecked));
  }

  Future<void> _onSubmitted(
    DeliveryLoginSubmittedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    if (!state.isFormValid) {
      emit(
        state.copyWith(
          status: DeliveryLoginStatus.error,
          errorMessage: 'Please enter a valid 10-digit phone number and at least 6-character password',
        ),
      );
      return;
    }

    emit(state.copyWith(status: DeliveryLoginStatus.loading));
    try {
      final success = await repository.loginWithPhone(state.phone, state.password);
      if (success) {
        if (state.isRememberMeChecked) {
          await repository.saveSavedPhone(state.phone);
        } else {
          await repository.saveSavedPhone('');
        }
        emit(
          state.copyWith(
            status: DeliveryLoginStatus.success,
            isLoggedIn: true,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DeliveryLoginStatus.error,
            errorMessage: 'Login failed. Please check credentials.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryLoginStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onGoogleSubmitted(
    DeliveryLoginGoogleSubmittedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryLoginStatus.loading));
    try {
      final success = await repository.loginWithGoogle();
      if (success) {
        emit(
          state.copyWith(
            status: DeliveryLoginStatus.success,
            isLoggedIn: true,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryLoginStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAppleSubmitted(
    DeliveryLoginAppleSubmittedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryLoginStatus.loading));
    try {
      final success = await repository.loginWithApple();
      if (success) {
        emit(
          state.copyWith(
            status: DeliveryLoginStatus.success,
            isLoggedIn: true,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryLoginStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLanguageChanged(
    DeliveryLoginLanguageChangedEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    await repository.saveSelectedLanguage(event.languageCode);
    emit(state.copyWith(selectedLanguage: event.languageCode));
  }

  Future<void> _onSimulateVideoUpload(
    DeliveryLoginSimulateVideoUploadEvent event,
    Emitter<DeliveryLoginPageState> emit,
  ) async {
    await _uploadSubscription?.cancel();
    final completer = Completer<void>();

    _uploadSubscription = service.uploadVideoChunked(event.videoPath).listen(
      (progress) {
        if (!isClosed) {
          emit(state.copyWith(uploadProgress: progress));
        }
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
      onError: (err) {
        if (!isClosed) {
          emit(state.copyWith(errorMessage: err.toString()));
        }
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }

  @override
  Future<void> close() {
    _uploadSubscription?.cancel();
    return super.close();
  }
}
