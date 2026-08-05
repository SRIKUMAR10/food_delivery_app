import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import 'Delivery_NavigationBar_page_event.dart';
import 'Delivery_NavigationBar_page_state.dart';
import 'Delivery_NavigationBar_page_repository.dart';
import 'Delivery_NavigationBar_page_service.dart';

class DeliveryNavigationBarPageBloc
    extends Bloc<DeliveryNavigationBarEvent, DeliveryNavigationBarState> {
  final DeliveryNavigationBarRepositoryBase repository;
  final DeliveryNavigationBarServiceBase service;
  final DeliveryPartnerRepository _partnerRepo;

  DeliveryNavigationBarPageBloc({
    required this.repository,
    required this.service,
    DeliveryPartnerRepository? partnerRepo,
  })  : _partnerRepo = partnerRepo ?? DeliveryPartnerRepository(),
        super(const DeliveryNavigationBarState()) {
    on<DeliveryNavigationBarInitEvent>(_onInit);
    on<DeliveryNavigationBarTabChangedEvent>(_onTabChanged);
    on<DeliveryNavigationBarContactSupportClickedEvent>(_onContactSupport);
    on<DeliveryNavigationBarRefreshEvent>(_onRefresh);
    on<DeliveryNavigationBarSimulateUploadEvent>(_onSimulateUpload);
    on<DeliveryNavigationBarPermissionRequestedEvent>(_onPermissionRequested);
    on<DeliveryNavigationBarLocaleChangedEvent>(_onLocaleChanged);
    on<DeliveryNavigationBarLogoutRequestedEvent>(_onLogout);
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

      int indexToUse = savedIndex >= 0 && savedIndex < navItems.length
          ? savedIndex
          : 0;

      if (isOnline) {
        final uid = _partnerRepo.currentUser?.uid;
        if (uid != null) {
          final partner = await _partnerRepo.getDeliveryPartner(uid);
          if (partner != null) {
            final isProfileComplete = partner.displayName.trim().isNotEmpty &&
                partner.phoneNumber.trim().isNotEmpty &&
                partner.vehicleType != null && partner.vehicleType!.trim().isNotEmpty &&
                partner.vehicleNumber != null && partner.vehicleNumber!.trim().isNotEmpty &&
                partner.drivingLicense != null && partner.drivingLicense!.trim().isNotEmpty;
                
            if (!isProfileComplete) {
              indexToUse = 11;
            }
          } else {
            indexToUse = 11;
          }
        } else {
          indexToUse = 11;
        }
      }

      emit(state.copyWith(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
        selectedIndex: indexToUse,
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

    final isOnline = await service.checkConnectivity();
    if (isOnline && event.index != 11) {
      final uid = _partnerRepo.currentUser?.uid;
      if (uid != null) {
        final partner = await _partnerRepo.getDeliveryPartner(uid);
        if (partner != null) {
          final isProfileComplete = partner.displayName.trim().isNotEmpty &&
              partner.phoneNumber.trim().isNotEmpty &&
              partner.vehicleType != null && partner.vehicleType!.trim().isNotEmpty &&
              partner.vehicleNumber != null && partner.vehicleNumber!.trim().isNotEmpty &&
              partner.drivingLicense != null && partner.drivingLicense!.trim().isNotEmpty;

          if (!isProfileComplete) {
            emit(state.copyWith(
              selectedIndex: 11,
              errorMessage: 'Please fill in and save your profile details first.',
            ));
            return;
          }
        }
      }
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

      int indexToUse = state.selectedIndex;
      if (isOnline) {
        final uid = _partnerRepo.currentUser?.uid;
        if (uid != null) {
          final partner = await _partnerRepo.getDeliveryPartner(uid);
          if (partner != null) {
            final isProfileComplete = partner.displayName.trim().isNotEmpty &&
                partner.phoneNumber.trim().isNotEmpty &&
                partner.vehicleType != null && partner.vehicleType!.trim().isNotEmpty &&
                partner.vehicleNumber != null && partner.vehicleNumber!.trim().isNotEmpty &&
                partner.drivingLicense != null && partner.drivingLicense!.trim().isNotEmpty;

            if (!isProfileComplete) {
              indexToUse = 11;
            }
          } else {
            indexToUse = 11;
          }
        }
      }

      emit(state.copyWith(
        status: navItems.isEmpty
            ? DeliveryNavigationBarStatus.empty
            : DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
        selectedIndex: indexToUse,
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

  Future<void> _onLogout(
    DeliveryNavigationBarLogoutRequestedEvent event,
    Emitter<DeliveryNavigationBarState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryNavigationBarStatus.loading));
    try {
      await _partnerRepo.signOut();
      emit(state.copyWith(status: DeliveryNavigationBarStatus.loggedOut));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryNavigationBarStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
