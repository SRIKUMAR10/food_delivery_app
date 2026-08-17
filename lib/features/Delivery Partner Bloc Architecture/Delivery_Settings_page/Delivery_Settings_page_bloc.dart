import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Settings_page_event.dart';
import 'Delivery_Settings_page_state.dart';
import 'Delivery_Settings_page_repository.dart';
import 'Delivery_Settings_page_service.dart';

class DeliverySettingsBloc
    extends Bloc<DeliverySettingsEvent, DeliverySettingsState> {
  final DeliverySettingsRepositoryBase repository;
  final DeliverySettingsServiceBase service;

  DeliverySettingsBloc({
    DeliverySettingsRepositoryBase? repository,
    DeliverySettingsServiceBase? service,
  })  : repository = repository ?? DeliverySettingsRepository(),
        service = service ?? DeliverySettingsService(),
        super(const DeliverySettingsState()) {
    on<DeliverySettingsInitEvent>(_onInit);
    on<DeliverySettingsToggleNotificationEvent>(_onToggleNotification);
    on<DeliverySettingsToggleAutoAcceptEvent>(_onToggleAutoAccept);
    on<DeliverySettingsToggleDarkModeEvent>(_onToggleDarkMode);
    on<DeliverySettingsToggleSunModeEvent>(_onToggleSunMode);
    on<DeliverySettingsToggleOledModeEvent>(_onToggleOledMode);
    on<DeliverySettingsUpdateRadiusEvent>(_onUpdateRadius);
    on<DeliverySettingsChangeLanguageEvent>(_onChangeLanguage);
    on<DeliverySettingsSaveEvent>(_onSave);
    on<DeliverySettingsRetryEvent>(_onRetry);
    on<DeliverySettingsToggleSoundAlertsEvent>(_onToggleSoundAlerts);
    on<DeliverySettingsToggleVibrationAlertsEvent>(_onToggleVibrationAlerts);
    on<DeliverySettingsToggleHighAccuracyGpsEvent>(_onToggleHighAccuracyGps);
    on<DeliverySettingsToggleBackgroundLocationEvent>(_onToggleBackgroundLocation);
    on<DeliverySettingsToggleBiometricLockEvent>(_onToggleBiometricLock);
    on<DeliverySettingsToggleTwoFactorAuthEvent>(_onToggleTwoFactorAuth);
    on<DeliverySettingsToggleDataSharingEvent>(_onToggleDataSharing);
    on<DeliverySettingsChangePasswordEvent>(_onChangePassword);
    on<DeliverySettingsDeactivateAccountEvent>(_onDeactivateAccount);
    on<DeliverySettingsDeleteAccountEvent>(_onDeleteAccount);
    on<DeliverySettingsClearCacheEvent>(_onClearCache);
  }

  Future<void> _onInit(
    DeliverySettingsInitEvent event,
    Emitter<DeliverySettingsState> emit,
  ) async {
    emit(state.copyWith(
      status: DeliverySettingsStatus.loading,
      clearError: true,
    ));
    try {
      final online = await service.checkNetworkConnectivity();
      if (!online) {
        emit(state.copyWith(
          status: DeliverySettingsStatus.error,
          errorMessage: 'Network connection unavailable',
        ));
        return;
      }

      final settings = await repository.fetchSettings();
      if (settings.items.isEmpty) {
        emit(settings.copyWith(
          status: DeliverySettingsStatus.empty,
          localeCode: state.localeCode,
        ));
        return;
      }

      emit(_syncItems(settings.copyWith(
        status: DeliverySettingsStatus.loaded,
        localeCode: state.localeCode,
        clearError: true,
      )));
    } catch (e) {
      emit(state.copyWith(
        status: DeliverySettingsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onToggleNotification(
    DeliverySettingsToggleNotificationEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(_syncItems(state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
      status: DeliverySettingsStatus.loaded,
      saveStatus: DeliverySettingsSaveStatus.idle,
      clearError: true,
    )));
  }

  void _onToggleAutoAccept(
    DeliverySettingsToggleAutoAcceptEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(_syncItems(state.copyWith(
      autoAcceptEnabled: !state.autoAcceptEnabled,
      status: DeliverySettingsStatus.loaded,
      saveStatus: DeliverySettingsSaveStatus.idle,
      clearError: true,
    )));
  }

  void _onToggleDarkMode(
    DeliverySettingsToggleDarkModeEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(_syncItems(state.copyWith(
      darkModeEnabled: !state.darkModeEnabled,
      status: DeliverySettingsStatus.loaded,
      saveStatus: DeliverySettingsSaveStatus.idle,
      clearError: true,
    )));
  }

  void _onToggleSunMode(
    DeliverySettingsToggleSunModeEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    final newSunMode = !state.sunModeEnabled;
    emit(_syncItems(state.copyWith(
      sunModeEnabled: newSunMode,
      oledModeEnabled: newSunMode ? false : state.oledModeEnabled,
      status: DeliverySettingsStatus.loaded,
      saveStatus: DeliverySettingsSaveStatus.idle,
      clearError: true,
    )));
  }

  void _onToggleOledMode(
    DeliverySettingsToggleOledModeEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    final newOledMode = !state.oledModeEnabled;
    emit(_syncItems(state.copyWith(
      oledModeEnabled: newOledMode,
      sunModeEnabled: newOledMode ? false : state.sunModeEnabled,
      status: DeliverySettingsStatus.loaded,
      saveStatus: DeliverySettingsSaveStatus.idle,
      clearError: true,
    )));
  }

  void _onUpdateRadius(
    DeliverySettingsUpdateRadiusEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    final radius = event.radius.clamp(1.0, 20.0).toDouble();
    emit(_syncItems(state.copyWith(
      deliveryRadius: radius,
      status: DeliverySettingsStatus.loaded,
      saveStatus: DeliverySettingsSaveStatus.idle,
      clearError: true,
    )));
  }

  void _onChangeLanguage(
    DeliverySettingsChangeLanguageEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(_syncItems(state.copyWith(
      languageCode: event.languageCode,
      localeCode: event.languageCode,
      status: DeliverySettingsStatus.loaded,
      saveStatus: DeliverySettingsSaveStatus.idle,
      clearError: true,
    )));
  }

  Future<void> _onSave(
    DeliverySettingsSaveEvent event,
    Emitter<DeliverySettingsState> emit,
  ) async {
    emit(state.copyWith(
      status: DeliverySettingsStatus.saving,
      saveStatus: DeliverySettingsSaveStatus.saving,
      clearError: true,
    ));
    try {
      await repository.saveSettings(state);
      emit(state.copyWith(
        status: DeliverySettingsStatus.loaded,
        saveStatus: DeliverySettingsSaveStatus.saved,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliverySettingsStatus.loaded,
        saveStatus: DeliverySettingsSaveStatus.failed,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRetry(
    DeliverySettingsRetryEvent event,
    Emitter<DeliverySettingsState> emit,
  ) async {
    add(const DeliverySettingsInitEvent());
  }

  void _onToggleSoundAlerts(
    DeliverySettingsToggleSoundAlertsEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(state.copyWith(
      soundAlertsEnabled: !state.soundAlertsEnabled,
      saveStatus: DeliverySettingsSaveStatus.idle,
    ));
  }

  void _onToggleVibrationAlerts(
    DeliverySettingsToggleVibrationAlertsEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(state.copyWith(
      vibrationAlertsEnabled: !state.vibrationAlertsEnabled,
      saveStatus: DeliverySettingsSaveStatus.idle,
    ));
  }

  void _onToggleHighAccuracyGps(
    DeliverySettingsToggleHighAccuracyGpsEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(state.copyWith(
      highAccuracyGps: !state.highAccuracyGps,
      saveStatus: DeliverySettingsSaveStatus.idle,
    ));
  }

  void _onToggleBackgroundLocation(
    DeliverySettingsToggleBackgroundLocationEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(state.copyWith(
      backgroundLocationEnabled: !state.backgroundLocationEnabled,
      saveStatus: DeliverySettingsSaveStatus.idle,
    ));
  }

  void _onToggleBiometricLock(
    DeliverySettingsToggleBiometricLockEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(state.copyWith(
      biometricLockEnabled: !state.biometricLockEnabled,
      saveStatus: DeliverySettingsSaveStatus.idle,
    ));
  }

  void _onToggleTwoFactorAuth(
    DeliverySettingsToggleTwoFactorAuthEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(state.copyWith(
      twoFactorAuthEnabled: !state.twoFactorAuthEnabled,
      saveStatus: DeliverySettingsSaveStatus.idle,
    ));
  }

  void _onToggleDataSharing(
    DeliverySettingsToggleDataSharingEvent event,
    Emitter<DeliverySettingsState> emit,
  ) {
    emit(state.copyWith(
      dataSharingConsent: !state.dataSharingConsent,
      saveStatus: DeliverySettingsSaveStatus.idle,
    ));
  }

  Future<void> _onChangePassword(
    DeliverySettingsChangePasswordEvent event,
    Emitter<DeliverySettingsState> emit,
  ) async {
    try {
      final success = await repository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      if (success) {
        emit(state.copyWith(
          actionMessage: 'Password updated successfully',
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          errorMessage: 'Failed to update password. Ensure it has at least 6 characters.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeactivateAccount(
    DeliverySettingsDeactivateAccountEvent event,
    Emitter<DeliverySettingsState> emit,
  ) async {
    try {
      await repository.deactivateAccount(reason: event.reason);
      emit(state.copyWith(
        isAccountDeactivated: true,
        actionMessage: 'Delivery partner account deactivated',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeliverySettingsDeleteAccountEvent event,
    Emitter<DeliverySettingsState> emit,
  ) async {
    try {
      await repository.deleteAccount(reason: event.reason);
      emit(state.copyWith(
        isAccountDeactivated: true,
        actionMessage: 'Delivery partner account scheduled for deletion',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onClearCache(
    DeliverySettingsClearCacheEvent event,
    Emitter<DeliverySettingsState> emit,
  ) async {
    try {
      await repository.clearCache();
      emit(state.copyWith(
        actionMessage: 'App cache cleared successfully',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  DeliverySettingsState _syncItems(DeliverySettingsState current) {
    final items = DeliverySettingsRepository.buildDefaultItems(
      notificationsEnabled: current.notificationsEnabled,
      autoAcceptEnabled: current.autoAcceptEnabled,
      darkModeEnabled: current.darkModeEnabled,
      sunModeEnabled: current.sunModeEnabled,
      oledModeEnabled: current.oledModeEnabled,
    );
    return current.copyWith(items: items);
  }
}

/// Standardized Feature-Architecture Alias for SettingsBloc
typedef SettingsBloc = DeliverySettingsBloc;


