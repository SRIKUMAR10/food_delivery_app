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
    required this.repository,
    required this.service,
  }) : super(const DeliverySettingsState()) {
    on<DeliverySettingsInitEvent>(_onInit);
    on<DeliverySettingsToggleNotificationEvent>(_onToggleNotification);
    on<DeliverySettingsToggleAutoAcceptEvent>(_onToggleAutoAccept);
    on<DeliverySettingsToggleDarkModeEvent>(_onToggleDarkMode);
    on<DeliverySettingsUpdateRadiusEvent>(_onUpdateRadius);
    on<DeliverySettingsChangeLanguageEvent>(_onChangeLanguage);
    on<DeliverySettingsSaveEvent>(_onSave);
    on<DeliverySettingsRetryEvent>(_onRetry);
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

  DeliverySettingsState _syncItems(DeliverySettingsState current) {
    final items = DeliverySettingsRepository.buildDefaultItems(
      notificationsEnabled: current.notificationsEnabled,
      autoAcceptEnabled: current.autoAcceptEnabled,
      darkModeEnabled: current.darkModeEnabled,
    );
    return current.copyWith(items: items);
  }
}
