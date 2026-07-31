import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_NavigationBar_page_event.dart';
import 'Delivery_NavigationBar_page_state.dart';
import 'Delivery_NavigationBar_page_repository.dart';
import 'Delivery_NavigationBar_page_service.dart';

class DeliveryNavigationBarPageBloc
    extends Bloc<DeliveryNavigationBarEvent, DeliveryNavigationBarState> {
  final DeliveryNavigationBarRepositoryBase repository;
  final DeliveryNavigationBarServiceBase service;

  DeliveryNavigationBarPageBloc({
    required this.repository,
    required this.service,
  }) : super(const DeliveryNavigationBarState()) {
    on<DeliveryNavigationBarInitEvent>(_onInit);
    on<DeliveryNavigationBarTabChangedEvent>(_onTabChanged);
    on<DeliveryNavigationBarContactSupportClickedEvent>(_onContactSupport);
    on<DeliveryNavigationBarRefreshEvent>(_onRefresh);
    on<DeliveryNavigationBarSimulateUploadEvent>(_onSimulateUpload);
    on<DeliveryNavigationBarPermissionRequestedEvent>(_onPermissionRequested);
    on<DeliveryNavigationBarLocaleChangedEvent>(_onLocaleChanged);
  }

  Future<void> _onInit(
    DeliveryNavigationBarInitEvent event,
    Emitter<DeliveryNavigationBarState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryNavigationBarStatus.loading));
    try {
      final isOnline = await service.checkConnectivity();
      final navItems = await repository.getNavItems();
      final savedIndex = await repository.getSavedSelectedIndex();
      final localeCode = await repository.getLocaleCode();
      final partnerName = await repository.getPartnerName();
      final hasPermission = await service.checkPermission();

      if (navItems.isEmpty) {
        emit(state.copyWith(
          status: DeliveryNavigationBarStatus.empty,
          isOffline: !isOnline,
          navItems: navItems,
          errorMessage: null,
          clearError: true,
        ));
        return;
      }

      emit(state.copyWith(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
        selectedIndex:
            savedIndex >= 0 && savedIndex < navItems.length
                ? savedIndex
                : state.selectedIndex,
        localeCode: localeCode,
        partnerName: partnerName,
        hasPermission: hasPermission,
        isOffline: !isOnline,
        errorMessage: null,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryNavigationBarStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onTabChanged(
    DeliveryNavigationBarTabChangedEvent event,
    Emitter<DeliveryNavigationBarState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.navItems.length) {
      return;
    }
    await repository.saveSelectedIndex(event.index);
    emit(state.copyWith(
      selectedIndex: event.index,
      errorMessage: null,
    ));
  }

  Future<void> _onContactSupport(
    DeliveryNavigationBarContactSupportClickedEvent event,
    Emitter<DeliveryNavigationBarState> emit,
  ) async {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null, clearError: true));
    }
  }

  Future<void> _onRefresh(
    DeliveryNavigationBarRefreshEvent event,
    Emitter<DeliveryNavigationBarState> emit,
  ) async {
    try {
      final isOnline = await service.checkConnectivity();
      final navItems = await repository.getNavItems();
      final hasPermission = await service.checkPermission();

      emit(state.copyWith(
        status: navItems.isEmpty
            ? DeliveryNavigationBarStatus.empty
            : DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
        hasPermission: hasPermission,
        isOffline: !isOnline,
        errorMessage: null,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryNavigationBarStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSimulateUpload(
    DeliveryNavigationBarSimulateUploadEvent event,
    Emitter<DeliveryNavigationBarState> emit,
  ) async {
    emit(state.copyWith(uploadProgress: 0.0));
    try {
      await for (final progress in service.simulateChunkedUpload()) {
        emit(state.copyWith(uploadProgress: progress));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryNavigationBarStatus.error,
        errorMessage: 'Upload failed: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onPermissionRequested(
    DeliveryNavigationBarPermissionRequestedEvent event,
    Emitter<DeliveryNavigationBarState> emit,
  ) async {
    try {
      final granted = await service.requestPermission();
      emit(state.copyWith(
        hasPermission: granted,
        errorMessage: null,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        hasPermission: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLocaleChanged(
    DeliveryNavigationBarLocaleChangedEvent event,
    Emitter<DeliveryNavigationBarState> emit,
  ) async {
    await repository.saveLocaleCode(event.localeCode);
    emit(state.copyWith(localeCode: event.localeCode));
  }
}
