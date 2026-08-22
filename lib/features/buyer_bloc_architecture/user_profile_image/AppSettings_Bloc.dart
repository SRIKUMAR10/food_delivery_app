// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/repositories/i_app_settings_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/services/app_logout_service.dart';
import 'package:food_delivery_app/core/services/theme_manager.dart';
import 'package:food_delivery_app/core/services/locale_manager.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'AppSettings_Event.dart';
import 'AppSettings_State.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final IAuthService authService;
  final IAppSettingsRepository _repository;
  final ThemeManager _themeManager;
  final LocaleManager _localeManager;
  StreamSubscription<AppSettingsState>? _settingsSubscription;

  AppSettingsBloc({
    required this.authService,
    required IAppSettingsRepository repository,
    required ThemeManager themeManager,
    required LocaleManager localeManager,
  })  : _repository = repository,
        _themeManager = themeManager,
        _localeManager = localeManager,
        super(const AppSettingsState()) {
    on<AppSettingsLoadStarted>(_onLoadStarted);
    on<PushNotificationToggled>(_onPushNotificationToggled);
    on<OrderNotificationToggled>(_onOrderNotificationToggled);
    on<OfferNotificationToggled>(_onOfferNotificationToggled);
    on<ChatNotificationToggled>(_onChatNotificationToggled);
    on<NotificationSoundToggled>(_onNotificationSoundToggled);
    on<VibrationToggled>(_onVibrationToggled);
    on<ThemeChanged>(_onThemeChanged);
    on<LanguageChanged>(_onLanguageChanged);
    on<ClearCacheRequested>(_onClearCacheRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AppSettingsErrorDismissed>(_onErrorDismissed);
    on<AppSettingsRetryRequested>(_onRetryRequested);
  }

  String _getUserId() {
    final uid = authService.currentUserId;
    if (uid == null || uid.isEmpty) throw Exception('User not authenticated');
    return uid;
  }

  Future<void> _onLoadStarted(
    AppSettingsLoadStarted event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final userId = _getUserId();
      await emit.forEach<AppSettingsState>(
        _repository.watchSettings(userId),
        onData: (settings) {
          _themeManager.setTheme(ThemeManager.themeFromString(settings.theme));
          _localeManager.setLocale(LocaleManager.localeFromString(settings.language));
          return settings.copyWith(isLoading: false, isInitialized: true);
        },
        onError: (Object error, StackTrace stackTrace) {
          return state.copyWith(
            isLoading: false,
            error: AppExceptionFormatter.toUserFriendlyMessage(error),
            isInitialized: true,
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: AppExceptionFormatter.toUserFriendlyMessage(e),
        isInitialized: true,
      ));
    }
  }

  Future<void> _onPushNotificationToggled(
    PushNotificationToggled event,
    Emitter<AppSettingsState> emit,
  ) async {
    final newState = state.copyWith(pushNotifications: event.enabled);
    emit(newState);
    await _saveSettings(newState);
  }

  Future<void> _onOrderNotificationToggled(
    OrderNotificationToggled event,
    Emitter<AppSettingsState> emit,
  ) async {
    final newState = state.copyWith(orderNotifications: event.enabled);
    emit(newState);
    await _saveSettings(newState);
  }

  Future<void> _onOfferNotificationToggled(
    OfferNotificationToggled event,
    Emitter<AppSettingsState> emit,
  ) async {
    final newState = state.copyWith(offerNotifications: event.enabled);
    emit(newState);
    await _saveSettings(newState);
  }

  Future<void> _onChatNotificationToggled(
    ChatNotificationToggled event,
    Emitter<AppSettingsState> emit,
  ) async {
    final newState = state.copyWith(chatNotifications: event.enabled);
    emit(newState);
    await _saveSettings(newState);
  }

  Future<void> _onNotificationSoundToggled(
    NotificationSoundToggled event,
    Emitter<AppSettingsState> emit,
  ) async {
    final newState = state.copyWith(notificationSound: event.enabled);
    emit(newState);
    await _saveSettings(newState);
  }

  Future<void> _onVibrationToggled(
    VibrationToggled event,
    Emitter<AppSettingsState> emit,
  ) async {
    final newState = state.copyWith(vibration: event.enabled);
    emit(newState);
    await _saveSettings(newState);
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<AppSettingsState> emit,
  ) async {
    final newState = state.copyWith(theme: event.theme);
    emit(newState);
    _themeManager.setTheme(ThemeManager.themeFromString(event.theme));
    await _saveSettings(newState);
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<AppSettingsState> emit,
  ) async {
    final newState = state.copyWith(language: event.language);
    emit(newState);
    _localeManager.setLocale(LocaleManager.localeFromString(event.language));
    await _saveSettings(newState);
  }

  Future<void> _onClearCacheRequested(
    ClearCacheRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await DefaultCacheManager().emptyCache();
      imageCache.clear();
      imageCache.clearLiveImages();
      if (Platform.isAndroid || Platform.isIOS) {
        final tempDir = Directory.systemTemp;
        if (tempDir.existsSync()) {
          tempDir.listSync().forEach((file) {
            if (file is File) {
              try {
                file.deleteSync();
              } catch (_) {
                debugPrint('Failed to delete temp file: ${file.path}');
              }
            }
          });
        }
      }
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(error: null));
    try {
      final uid = _getUserId();
      await authService.deleteAccount(event.password);
      await _repository.deleteUserData(uid);
      add(const LogoutRequested());
    } catch (e) {
      emit(state.copyWith(error: AppExceptionFormatter.toUserFriendlyMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      await AppLogoutService.signOut(authService);
      emit(state.copyWith(isLoggedOut: true));
    } catch (e) {
      emit(state.copyWith(error: AppExceptionFormatter.toUserFriendlyMessage(e)));
    }
  }

  Future<void> _onErrorDismissed(
    AppSettingsErrorDismissed event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(error: null));
  }

  Future<void> _onRetryRequested(
    AppSettingsRetryRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    add(const AppSettingsLoadStarted());
  }

  Future<void> _saveSettings(AppSettingsState newState) async {
    try {
      await _repository.saveSettings(newState);
    } catch (e) {
      debugPrint('AppSettingsBloc._saveSettings error: $e');
    }
  }

  @override
  Future<void> close() async {
    await _settingsSubscription?.cancel();
    return super.close();
  }
}
