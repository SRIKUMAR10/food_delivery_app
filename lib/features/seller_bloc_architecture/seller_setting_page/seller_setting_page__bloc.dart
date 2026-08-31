import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/services/audio_notification_service.dart';
import 'seller_setting_page__event.dart';
import 'seller_setting_page__state.dart';

// Interface for Seller Setting Repository
abstract class SellerSettingRepository {
  Future<SellerSettingState> loadSettings();
  Stream<SellerSettingState> watchSettings();
  Future<void> saveSettings(SellerSettingState state);
  Future<void> changePassword(String currentPassword, String newPassword, {bool signOutOtherDevices = false});
  Future<void> deactivateAccount(String reason, int durationDays);
  Future<void> reactivateAccount();
  Future<void> deleteAccount(String password);
  Future<void> logout();
}

class SellerSettingBloc extends Bloc<SellerSettingEvent, SellerSettingState> {
  final SellerSettingRepository repository;
  StreamSubscription<SellerSettingState>? _streamSubscription;

  SellerSettingBloc({required this.repository}) : super(const SellerSettingState()) {
    on<LoadSellerSettings>(_onLoadSettings);
    on<WatchSellerSettings>(_onWatchSettings);
    on<SettingsUpdatedFromStream>(_onSettingsUpdatedFromStream);
    on<SelectSettingsSection>(_onSelectSettingsSection);
    on<ClearSettingMessages>(_onClearSettingMessages);

    // Backward-Compatible Events
    on<UpdatePushNotifications>(_onUpdatePushNotifications);
    on<UpdateNewOrderSound>(_onUpdateNewOrderSound);
    on<UpdatePromoAndOffers>(_onUpdatePromoAndOffers);
    on<UpdateLowStockAlerts>(_onUpdateLowStockAlerts);
    on<UpdateOrderUpdates>(_onUpdateOrderUpdates);
    on<UpdateAppTheme>(_onUpdateAppTheme);
    on<UpdateLanguage>(_onUpdateLanguage);

    // 14 Category Events
    on<UpdateRestaurantInfo>(_onUpdateRestaurantInfo);
    on<UpdateBusinessHoursSchedule>(_onUpdateBusinessHoursSchedule);
    on<ToggleEmergencyClosure>(_onToggleEmergencyClosure);
    on<ToggleAcceptingOrders>(_onToggleAcceptingOrders);
    on<UpdateDeliverySettings>(_onUpdateDeliverySettings);
    on<UpdateOrderSettings>(_onUpdateOrderSettings);
    on<UpdateNotificationAdvancedSettings>(_onUpdateNotificationAdvancedSettings);
    on<UpdatePaymentSettings>(_onUpdatePaymentSettings);
    on<UpdateBankUpiSettings>(_onUpdateBankUpiSettings);
    on<UpdateTaxSettings>(_onUpdateTaxSettings);
    on<UpdateAccountSettings>(_onUpdateAccountSettings);
    on<UpdatePrivacySettings>(_onUpdatePrivacySettings);
    on<UpdateSecuritySettings>(_onUpdateSecuritySettings);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<DeactivateAccountRequested>(_onDeactivateAccountRequested);
    on<ReactivateAccountRequested>(_onReactivateAccountRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadSettings(LoadSellerSettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final settings = await repository.loadSettings();
      emit(settings.copyWith(
        isLoading: false,
        selectedSectionIndex: state.selectedSectionIndex,
      ));
      add(WatchSellerSettings());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onWatchSettings(WatchSellerSettings event, Emitter<SellerSettingState> emit) async {
    await _streamSubscription?.cancel();
    _streamSubscription = repository.watchSettings().listen(
      (liveSettings) {
        add(SettingsUpdatedFromStream(liveSettings));
      },
      onError: (err) {
        // Automatically reconnect after a transient network drop (e.g. QUIC timeout)
        Future.delayed(const Duration(seconds: 3), () {
          if (!isClosed) {
            add(WatchSellerSettings());
          }
        });
      },
    );
  }

  void _onSettingsUpdatedFromStream(SettingsUpdatedFromStream event, Emitter<SellerSettingState> emit) {
    if (state.isSaving) return; // Prevent local overwrite during active user edit
    emit(event.state.copyWith(
      selectedSectionIndex: state.selectedSectionIndex,
      isLoading: false,
    ));
  }

  void _onSelectSettingsSection(SelectSettingsSection event, Emitter<SellerSettingState> emit) {
    emit(state.copyWith(
      selectedSectionIndex: event.sectionIndex,
      error: null,
      successMessage: null,
    ));
  }

  void _onClearSettingMessages(ClearSettingMessages event, Emitter<SellerSettingState> emit) {
    emit(state.copyWith(error: null, successMessage: null));
  }

  // ----------------------------------------------------
  // Backward-Compatible Handlers
  // ----------------------------------------------------
  Future<void> _onUpdatePushNotifications(UpdatePushNotifications event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(pushNotifications: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateNewOrderSound(UpdateNewOrderSound event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(newOrderSound: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdatePromoAndOffers(UpdatePromoAndOffers event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(promoAndOffers: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateLowStockAlerts(UpdateLowStockAlerts event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(lowStockAlerts: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateOrderUpdates(UpdateOrderUpdates event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(orderUpdates: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateAppTheme(UpdateAppTheme event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(appTheme: event.theme);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateLanguage(UpdateLanguage event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(language: event.language);
    emit(newState);
    await repository.saveSettings(newState);
  }

  // ----------------------------------------------------
  // 14 Comprehensive Category Handlers
  // ----------------------------------------------------
  Future<void> _onUpdateRestaurantInfo(UpdateRestaurantInfo event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        restaurantName: event.restaurantName,
        ownerName: event.ownerName,
        phoneNumber: event.phoneNumber,
        email: event.email,
        restaurantDescription: event.restaurantDescription,
        address: event.address,
        cuisines: event.cuisines,
        profileImageUrl: event.profileImageUrl,
        coverImageUrl: event.coverImageUrl,
        latitude: event.latitude,
        longitude: event.longitude,
        isSaving: false,
        successMessage: 'Restaurant information updated successfully.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update restaurant info: $e'));
    }
  }

  Future<void> _onUpdateBusinessHoursSchedule(UpdateBusinessHoursSchedule event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        businessHours: event.businessHours,
        isSaving: false,
        successMessage: 'Business hours saved successfully.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to save business hours: $e'));
    }
  }

  Future<void> _onToggleEmergencyClosure(ToggleEmergencyClosure event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(
      isEmergencyClosed: event.isClosed,
      isOpen: !event.isClosed,
      successMessage: event.isClosed ? 'Store marked as temporarily closed.' : 'Store is now active.',
    );
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onToggleAcceptingOrders(ToggleAcceptingOrders event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(
      isAcceptingOrders: event.isAccepting,
      successMessage: event.isAccepting ? 'Now accepting online orders.' : 'Paused online orders.',
    );
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateDeliverySettings(UpdateDeliverySettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        deliveryRadius: event.deliveryRadius,
        minimumOrderValue: event.minimumOrderValue,
        baseDeliveryFee: event.baseDeliveryFee,
        perKmDeliveryFee: event.perKmDeliveryFee,
        freeDeliveryThreshold: event.freeDeliveryThreshold,
        estimatedPrepTimeMinutes: event.estimatedPrepTimeMinutes,
        deliveryTimeEstimate: event.deliveryTimeEstimate,
        packagingCharges: event.packagingCharges,
        allowSelfPickup: event.allowSelfPickup,
        isSelfDelivery: event.isSelfDelivery,
        isSaving: false,
        successMessage: 'Delivery settings updated successfully.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update delivery settings: $e'));
    }
  }

  Future<void> _onUpdateOrderSettings(UpdateOrderSettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        autoAcceptOrders: event.autoAcceptOrders,
        prepBufferTimeMinutes: event.prepBufferTimeMinutes,
        maxActiveOrdersLimit: event.maxActiveOrdersLimit,
        allowScheduledOrders: event.allowScheduledOrders,
        allowSpecialInstructions: event.allowSpecialInstructions,
        cancellationWindowMinutes: event.cancellationWindowMinutes,
        isSaving: false,
        successMessage: 'Order preferences updated.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update order settings: $e'));
    }
  }

  Future<void> _onUpdateNotificationAdvancedSettings(UpdateNotificationAdvancedSettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      AudioNotificationService.setGlobalAudioConfig(
        volume: event.soundVolume,
        ringtone: event.orderAlertRingtone,
      );
      final newState = state.copyWith(
        pushNotifications: event.pushNotifications,
        newOrderSound: event.newOrderSound,
        soundLoopUntilAccepted: event.soundLoopUntilAccepted,
        orderAlertRingtone: event.orderAlertRingtone,
        soundVolume: event.soundVolume,
        promoAndOffers: event.promoAndOffers,
        lowStockAlerts: event.lowStockAlerts,
        orderUpdates: event.orderUpdates,
        whatsappNotifications: event.whatsappNotifications,
        smsNotifications: event.smsNotifications,
        isSaving: false,
        successMessage: 'Notification preferences saved.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update notifications: $e'));
    }
  }

  Future<void> _onUpdatePaymentSettings(UpdatePaymentSettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        acceptCashOnDelivery: event.acceptCashOnDelivery,
        acceptOnlinePayments: event.acceptOnlinePayments,
        acceptWalletPayments: event.acceptWalletPayments,
        payoutSchedule: event.payoutSchedule,
        minPayoutThreshold: event.minPayoutThreshold,
        autoSettlementEnabled: event.autoSettlementEnabled,
        isSaving: false,
        successMessage: 'Payment configuration saved.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update payment settings: $e'));
    }
  }

  Future<void> _onUpdateBankUpiSettings(UpdateBankUpiSettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        accountHolderName: event.accountHolderName,
        bankName: event.bankName,
        bankAccountNumber: event.bankAccountNumber,
        ifscCode: event.ifscCode,
        bankBranch: event.bankBranch,
        upiId: event.upiId,
        primaryPayoutMethod: event.primaryPayoutMethod,
        isSaving: false,
        successMessage: 'Bank & UPI details updated successfully.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update bank details: $e'));
    }
  }

  Future<void> _onUpdateTaxSettings(UpdateTaxSettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        gstNumber: event.gstNumber,
        gstPercentage: event.gstPercentage,
        isTaxIncludedInPrice: event.isTaxIncludedInPrice,
        panNumber: event.panNumber,
        fssaiNumber: event.fssaiNumber,
        fssaiExpiryDate: event.fssaiExpiryDate,
        invoicePrefix: event.invoicePrefix,
        isSaving: false,
        successMessage: 'Tax and compliance info saved.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update tax details: $e'));
    }
  }

  Future<void> _onUpdateAccountSettings(UpdateAccountSettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        registeredEmail: event.registeredEmail,
        registeredPhone: event.registeredPhone,
        appTheme: event.appTheme,
        language: event.language,
        isSaving: false,
        successMessage: 'Account settings updated.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update account settings: $e'));
    }
  }

  Future<void> _onUpdatePrivacySettings(UpdatePrivacySettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        isPubliclyVisible: event.isPubliclyVisible,
        showRatingsPublicly: event.showRatingsPublicly,
        showPhoneNumberPublicly: event.showPhoneNumberPublicly,
        allowAnalyticsTelemetry: event.allowAnalyticsTelemetry,
        receiveMarketingEmails: event.receiveMarketingEmails,
        isSaving: false,
        successMessage: 'Privacy settings saved.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update privacy settings: $e'));
    }
  }

  Future<void> _onUpdateSecuritySettings(UpdateSecuritySettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      final newState = state.copyWith(
        twoFactorAuthEnabled: event.twoFactorAuthEnabled,
        twoFactorMethod: event.twoFactorMethod,
        appPinLockEnabled: event.appPinLockEnabled,
        biometricLockEnabled: event.biometricLockEnabled,
        isSaving: false,
        successMessage: 'Security settings updated.',
      );
      emit(newState);
      await repository.saveSettings(newState);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Failed to update security settings: $e'));
    }
  }

  Future<void> _onChangePasswordRequested(ChangePasswordRequested event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    try {
      await repository.changePassword(
        event.currentPassword,
        event.newPassword,
        signOutOtherDevices: event.signOutOtherDevices,
      );
      emit(state.copyWith(
        isSaving: false,
        lastPasswordChanged: DateTime.now(),
        successMessage: 'Password changed successfully.',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Password change failed: $e'));
    }
  }

  Future<void> _onDeactivateAccountRequested(DeactivateAccountRequested event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null));
    try {
      await repository.deactivateAccount(event.reason, event.durationDays);
      emit(state.copyWith(
        isSaving: false,
        isDeactivated: true,
        deactivationReason: event.reason,
        isOpen: false,
        isAcceptingOrders: false,
        successMessage: 'Account temporarily deactivated for ${event.durationDays} days.',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Deactivation failed: $e'));
    }
  }

  Future<void> _onReactivateAccountRequested(ReactivateAccountRequested event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isSaving: true, error: null));
    try {
      await repository.reactivateAccount();
      emit(state.copyWith(
        isSaving: false,
        isDeactivated: false,
        deactivationReason: null,
        isOpen: true,
        isAcceptingOrders: true,
        successMessage: 'Account reactivated successfully.',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Reactivation failed: $e'));
    }
  }

  Future<void> _onDeleteAccountRequested(DeleteAccountRequested event, Emitter<SellerSettingState> emit) async {
    if (event.confirmationKeyword != 'DELETE') {
      emit(state.copyWith(error: 'Please type DELETE to confirm permanent account deletion.'));
      return;
    }
    emit(state.copyWith(isSaving: true, error: null));
    try {
      await repository.deleteAccount(event.password);
      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Account deleted successfully. Logging out...',
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: 'Account deletion failed: $e'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.logout();
      emit(const SellerSettingState(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Logout failed: $e'));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}

// ----------------------------------------------------
// Implementation of SellerSettingRepository with Cloud Firestore
// ----------------------------------------------------
class SellerSettingRepositoryImpl implements SellerSettingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions? _functions;

  SellerSettingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions;

  @override
  Future<SellerSettingState> loadSettings() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      return const SellerSettingState();
    }

    final docSnap = await _firestore.collection('sellers').doc(sellerId).get();
    final notifSnap = await _firestore.collection('seller_notification_settings').doc(sellerId).get();

    return _mapSnapshotsToState(docSnap, notifSnap);
  }

  @override
  Stream<SellerSettingState> watchSettings() {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      return Stream.value(const SellerSettingState());
    }

    final sellerStream = _firestore.collection('sellers').doc(sellerId).snapshots();
    final notifStream = _firestore
        .collection('seller_notification_settings')
        .doc(sellerId)
        .snapshots();

    return Rx.combineLatest2<DocumentSnapshot<Map<String, dynamic>>,
        DocumentSnapshot<Map<String, dynamic>>, SellerSettingState>(
      sellerStream,
      notifStream,
      (docSnap, notifSnap) => _mapSnapshotsToState(docSnap, notifSnap),
    );
  }

  SellerSettingState _mapSnapshotsToState(
    DocumentSnapshot<Map<String, dynamic>> docSnap,
    DocumentSnapshot<Map<String, dynamic>>? notifSnap,
  ) {
    final data = docSnap.exists ? (docSnap.data() ?? {}) : <String, dynamic>{};
    final notifData = notifSnap != null && notifSnap.exists ? (notifSnap.data() ?? {}) : <String, dynamic>{};

    List<String> parsedCuisines = [];
    if (data['cuisines'] is List) {
      parsedCuisines = (data['cuisines'] as List).map((e) => e.toString()).toList();
    }

    final deliverySettings = (data['deliveryFeeSettings'] as Map<String, dynamic>?) ?? {};

    return SellerSettingState(
      // 1. Restaurant Info
      restaurantName: data['shopName'] as String? ?? data['name'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? _auth.currentUser?.phoneNumber ?? '',
      email: data['email'] as String? ?? _auth.currentUser?.email ?? '',
      restaurantDescription: data['restaurantDescription'] as String? ?? data['businessDetails'] as String? ?? '',
      address: data['address'] as String? ?? '',
      cuisines: parsedCuisines,
      profileImageUrl: data['profileImageUrl'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),

      // 2. Business Hours
      businessHours: (data['businessHours'] as Map<String, dynamic>?) ?? {},
      isOpen: data['isOpen'] as bool? ?? true,
      isAcceptingOrders: data['isAcceptingOrders'] as bool? ?? true,
      isEmergencyClosed: data['isEmergencyClosed'] as bool? ?? !(data['isOpen'] as bool? ?? true),

      // 3. Delivery Settings
      deliveryRadius: (data['deliveryRadius'] as num?)?.toDouble() ?? 10.0,
      minimumOrderValue: (data['minimumOrderValue'] as num?)?.toDouble() ?? 150.0,
      baseDeliveryFee: (deliverySettings['baseFee'] as num?)?.toDouble() ?? 25.0,
      perKmDeliveryFee: (deliverySettings['perKmFee'] as num?)?.toDouble() ?? 5.0,
      freeDeliveryThreshold: (deliverySettings['freeDeliveryThreshold'] as num?)?.toDouble() ?? 500.0,
      estimatedPrepTimeMinutes: (data['estimatedPrepTimeMinutes'] as num?)?.toInt() ?? 20,
      deliveryTimeEstimate: data['deliveryTime'] as String? ?? '30-45 mins',
      packagingCharges: (data['packagingCharges'] as num?)?.toDouble() ?? 15.0,
      allowSelfPickup: data['allowSelfPickup'] as bool? ?? true,
      isSelfDelivery: data['isSelfDelivery'] as bool? ?? false,

      // 4. Order Settings
      autoAcceptOrders: data['autoAcceptOrders'] as bool? ?? false,
      prepBufferTimeMinutes: (data['prepBufferTimeMinutes'] as num?)?.toInt() ?? 15,
      maxActiveOrdersLimit: (data['maxActiveOrdersLimit'] as num?)?.toInt() ?? 20,
      allowScheduledOrders: data['allowScheduledOrders'] as bool? ?? true,
      allowSpecialInstructions: data['allowSpecialInstructions'] as bool? ?? true,
      cancellationWindowMinutes: (data['cancellationWindowMinutes'] as num?)?.toInt() ?? 2,

      // 5. Notifications
      pushNotifications: notifData['pushNotifications'] ?? data['pushNotifications'] ?? true,
      newOrderSound: notifData['newOrderSound'] ?? data['newOrderSound'] ?? true,
      soundLoopUntilAccepted: notifData['soundLoopUntilAccepted'] ?? data['soundLoopUntilAccepted'] ?? true,
      orderAlertRingtone: notifData['orderAlertRingtone'] as String? ?? data['orderAlertRingtone'] as String? ?? 'Bell Chime',
      soundVolume: (notifData['soundVolume'] as num?)?.toDouble() ?? (data['soundVolume'] as num?)?.toDouble() ?? 0.8,
      promoAndOffers: notifData['promoAndOffers'] ?? data['promoAndOffers'] ?? false,
      lowStockAlerts: notifData['lowStockAlerts'] ?? data['lowStockAlerts'] ?? true,
      orderUpdates: notifData['orderUpdates'] ?? data['orderUpdates'] ?? true,
      whatsappNotifications: data['whatsappNotifications'] as bool? ?? true,
      smsNotifications: data['smsNotifications'] as bool? ?? false,

      // 6. Payment Settings
      acceptCashOnDelivery: data['acceptCashOnDelivery'] as bool? ?? true,
      acceptOnlinePayments: data['acceptOnlinePayments'] as bool? ?? true,
      acceptWalletPayments: data['acceptWalletPayments'] as bool? ?? true,
      payoutSchedule: data['payoutSchedule'] as String? ?? 'Daily',
      minPayoutThreshold: (data['minPayoutThreshold'] as num?)?.toDouble() ?? 500.0,
      autoSettlementEnabled: data['autoSettlementEnabled'] as bool? ?? true,

      // 7. Bank / UPI Settings
      accountHolderName: data['accountHolderName'] as String? ?? '',
      bankName: data['bankName'] as String? ?? '',
      bankAccountNumber: data['bankAccountNumber'] as String? ?? '',
      ifscCode: data['ifscCode'] as String? ?? '',
      bankBranch: data['bankBranch'] as String? ?? '',
      upiId: data['upiId'] as String? ?? '',
      primaryPayoutMethod: data['primaryPayoutMethod'] as String? ?? 'bank',
      isBankVerified: data['isBankVerified'] as bool? ?? false,

      // 8. Tax Information
      gstNumber: data['gstNumber'] as String? ?? '',
      gstPercentage: (data['gstPercentage'] as num?)?.toDouble() ?? 5.0,
      isTaxIncludedInPrice: data['isTaxIncludedInPrice'] as bool? ?? true,
      panNumber: data['panNumber'] as String? ?? '',
      fssaiNumber: data['fssaiNumber'] as String? ?? '',
      fssaiExpiryDate: data['fssaiExpiryDate'] as String? ?? '',
      invoicePrefix: data['invoicePrefix'] as String? ?? 'INV-',

      // 9. Account Settings
      registeredEmail: (data['email'] as String?)?.isNotEmpty == true
          ? data['email'] as String
          : ((data['contactEmail'] as String?)?.isNotEmpty == true
              ? data['contactEmail'] as String
              : (_auth.currentUser?.email ?? '')),
      registeredPhone: (data['phoneNumber'] as String?)?.isNotEmpty == true
          ? data['phoneNumber'] as String
          : ((data['phone'] as String?)?.isNotEmpty == true
              ? data['phone'] as String
              : (_auth.currentUser?.phoneNumber ?? '')),
      isPhoneVerified: _auth.currentUser?.phoneNumber != null && _auth.currentUser!.phoneNumber!.isNotEmpty,
      appTheme: notifData['appTheme'] as String? ?? data['appTheme'] as String? ?? 'Light',
      language: notifData['language'] as String? ?? data['language'] as String? ?? 'English',

      // 10. Privacy Settings
      isPubliclyVisible: data['isPubliclyVisible'] as bool? ?? true,
      showRatingsPublicly: data['showRatingsPublicly'] as bool? ?? true,
      showPhoneNumberPublicly: data['showPhoneNumberPublicly'] as bool? ?? false,
      allowAnalyticsTelemetry: data['allowAnalyticsTelemetry'] as bool? ?? true,
      receiveMarketingEmails: data['receiveMarketingEmails'] as bool? ?? false,

      // 11. Security Settings
      twoFactorAuthEnabled: data['twoFactorAuthEnabled'] as bool? ?? false,
      twoFactorMethod: data['twoFactorMethod'] as String? ?? 'sms',
      appPinLockEnabled: data['appPinLockEnabled'] as bool? ?? false,
      biometricLockEnabled: data['biometricLockEnabled'] as bool? ?? false,
      activeSessions: (data['activeSessions'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],

      // Deactivation
      isDeactivated: data['isDeactivated'] as bool? ?? false,
      deactivationReason: data['deactivationReason'] as String?,
    );
  }

  @override
  Future<void> saveSettings(SellerSettingState state) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('Seller is not authenticated. Please sign in again.');
    }

    final sellerRef = _firestore.collection('sellers').doc(sellerId);
    final notifRef = _firestore
        .collection('seller_notification_settings')
        .doc(sellerId);

    final sellerData = _buildSellerDocData(state);
    final notifData = _buildNotificationDocData(state);

    await _commitSettingsWithFallback(sellerRef, notifRef, sellerData, notifData);
  }

  Map<String, dynamic> _buildSellerDocData(SellerSettingState state) {
    return {
      'shopName': state.restaurantName,
      'ownerName': state.ownerName,
      'phoneNumber': state.phoneNumber,
      'email': state.email,
      'restaurantDescription': state.restaurantDescription,
      'address': state.address,
      'cuisines': state.cuisines,
      'profileImageUrl': state.profileImageUrl,
      'coverImageUrl': state.coverImageUrl,
      'latitude': state.latitude,
      'longitude': state.longitude,
      'businessHours': state.businessHours,
      'isOpen': state.isOpen,
      'isAcceptingOrders': state.isAcceptingOrders,
      'isEmergencyClosed': state.isEmergencyClosed,
      'deliveryRadius': state.deliveryRadius,
      'minimumOrderValue': state.minimumOrderValue,
      'deliveryFeeSettings': {
        'baseFee': state.baseDeliveryFee,
        'perKmFee': state.perKmDeliveryFee,
        'freeDeliveryThreshold': state.freeDeliveryThreshold,
      },
      'estimatedPrepTimeMinutes': state.estimatedPrepTimeMinutes,
      'deliveryTime': state.deliveryTimeEstimate,
      'packagingCharges': state.packagingCharges,
      'allowSelfPickup': state.allowSelfPickup,
      'isSelfDelivery': state.isSelfDelivery,
      'autoAcceptOrders': state.autoAcceptOrders,
      'prepBufferTimeMinutes': state.prepBufferTimeMinutes,
      'maxActiveOrdersLimit': state.maxActiveOrdersLimit,
      'allowScheduledOrders': state.allowScheduledOrders,
      'allowSpecialInstructions': state.allowSpecialInstructions,
      'cancellationWindowMinutes': state.cancellationWindowMinutes,
      'whatsappNotifications': state.whatsappNotifications,
      'smsNotifications': state.smsNotifications,
      'acceptCashOnDelivery': state.acceptCashOnDelivery,
      'acceptOnlinePayments': state.acceptOnlinePayments,
      'acceptWalletPayments': state.acceptWalletPayments,
      'payoutSchedule': state.payoutSchedule,
      'minPayoutThreshold': state.minPayoutThreshold,
      'autoSettlementEnabled': state.autoSettlementEnabled,
      'accountHolderName': state.accountHolderName,
      'bankName': state.bankName,
      'bankAccountNumber': state.bankAccountNumber,
      'ifscCode': state.ifscCode,
      'bankBranch': state.bankBranch,
      'upiId': state.upiId,
      'primaryPayoutMethod': state.primaryPayoutMethod,
      'gstNumber': state.gstNumber,
      'gstPercentage': state.gstPercentage,
      'isTaxIncludedInPrice': state.isTaxIncludedInPrice,
      'panNumber': state.panNumber,
      'fssaiNumber': state.fssaiNumber,
      'fssaiExpiryDate': state.fssaiExpiryDate,
      'invoicePrefix': state.invoicePrefix,
      'appTheme': state.appTheme,
      'language': state.language,
      'isPubliclyVisible': state.isPubliclyVisible,
      'showRatingsPublicly': state.showRatingsPublicly,
      'showPhoneNumberPublicly': state.showPhoneNumberPublicly,
      'allowAnalyticsTelemetry': state.allowAnalyticsTelemetry,
      'receiveMarketingEmails': state.receiveMarketingEmails,
      'twoFactorAuthEnabled': state.twoFactorAuthEnabled,
      'twoFactorMethod': state.twoFactorMethod,
      'appPinLockEnabled': state.appPinLockEnabled,
      'biometricLockEnabled': state.biometricLockEnabled,
      'isDeactivated': state.isDeactivated,
      'deactivationReason': state.deactivationReason,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _buildNotificationDocData(SellerSettingState state) {
    return {
      'pushNotifications': state.pushNotifications,
      'newOrderSound': state.newOrderSound,
      'soundLoopUntilAccepted': state.soundLoopUntilAccepted,
      'orderAlertRingtone': state.orderAlertRingtone,
      'soundVolume': state.soundVolume,
      'promoAndOffers': state.promoAndOffers,
      'lowStockAlerts': state.lowStockAlerts,
      'orderUpdates': state.orderUpdates,
      'appTheme': state.appTheme,
      'language': state.language,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Persists settings with retry + independent-document fallback so a
  /// transient network disruption never wipes either half of the settings.
  Future<void> _commitSettingsWithFallback(
    DocumentReference<Map<String, dynamic>> sellerRef,
    DocumentReference<Map<String, dynamic>> notifRef,
    Map<String, dynamic> sellerData,
    Map<String, dynamic> notifData,
  ) async {
    try {
      final batch = _firestore.batch();
      batch.set(sellerRef, sellerData, SetOptions(merge: true));
      batch.set(notifRef, notifData, SetOptions(merge: true));
      await batch.commit();
      return;
    } catch (_) {
      // Retry once after a short delay to survive transient network failures.
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    try {
      final batch = _firestore.batch();
      batch.set(sellerRef, sellerData, SetOptions(merge: true));
      batch.set(notifRef, notifData, SetOptions(merge: true));
      await batch.commit();
      return;
    } catch (_) {
      // Final fallback: write each document independently so one failing
      // write never loses the other half of the settings.
    }

    Object? sellerError;
    Object? notifError;
    try {
      await sellerRef.set(sellerData, SetOptions(merge: true));
    } catch (e) {
      sellerError = e;
    }
    try {
      await notifRef.set(notifData, SetOptions(merge: true));
    } catch (e) {
      notifError = e;
    }
    if (sellerError != null && notifError != null) {
      throw Exception('Failed to save settings: $sellerError');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword, {bool signOutOtherDevices = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated. Please sign in again.');
    }

    final uid = user.uid;
    final email = user.email;
    final phone = user.phoneNumber;

    // 1. Primary: Call Cloud Function changeSellerPassword to securely update Admin Auth, Firestore, and active sessions
    bool cloudFunctionSucceeded = false;
    try {
      final functionsInstance = _functions ?? FirebaseFunctions.instance;
      final callable = functionsInstance.httpsCallable('changeSellerPassword');
      final resp = await callable.call({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'signOutOtherDevices': signOutOtherDevices,
        'role': 'seller',
        'uid': uid,
        'email': email,
        'phoneNumber': phone,
      });
      if (resp.data != null) {
        cloudFunctionSucceeded = true;
      }
    } catch (cfErr) {
      debugPrint('Cloud Function changeSellerPassword info/error: $cfErr');
      final errStr = cfErr.toString().toLowerCase();
      if (errStr.contains('incorrect') || errStr.contains('current password') || errStr.contains('mismatch') || errStr.contains('unauthenticated')) {
        throw Exception('Current password is incorrect. Please try again.');
      }
      // If network or offline, fallback to client update
    }

    // 2. Client-side Auth re-authentication & update
    if (email != null && email.isNotEmpty) {
      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } catch (authErr) {
        debugPrint('Client reauthenticateWithCredential error: $authErr');
        if (!cloudFunctionSucceeded) {
          final authStr = authErr.toString().toLowerCase();
          if (authStr.contains('wrong-password') || authStr.contains('invalid-credential') || authStr.contains('credential')) {
            throw Exception('Current password is incorrect. Please try again.');
          }
        }
      }
    } else {
      try {
        await user.updatePassword(newPassword);
      } catch (_) {}
    }

    // 3. Instant Real-Time Firestore Sync (Updates password, hashedPassword, plainPassword, lastPasswordChanged, updatedAt)
    final updateData = <String, dynamic>{
      'password': newPassword,
      'hashedPassword': newPassword,
      'plainPassword': newPassword,
      'lastPasswordChanged': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final sellerRef = _firestore.collection('sellers').doc(uid);
    await sellerRef.set(updateData, SetOptions(merge: true));

    // Also update seller_${uid} alias document if it exists
    try {
      final aliasDoc = await _firestore.collection('sellers').doc('seller_$uid').get();
      if (aliasDoc.exists) {
        await _firestore.collection('sellers').doc('seller_$uid').set(updateData, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  @override
  Future<void> deactivateAccount(String reason, int durationDays) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) return;
    final sellerRef = _firestore.collection('sellers').doc(sellerId);
    await sellerRef.update({
      'isDeactivated': true,
      'deactivationReason': reason,
      'deactivatedUntil': Timestamp.fromDate(DateTime.now().add(Duration(days: durationDays))),
      'isActive': false,
      'isOpen': false,
      'isAcceptingOrders': false,
      'isOnline': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reactivateAccount() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) return;
    final sellerRef = _firestore.collection('sellers').doc(sellerId);
    await sellerRef.update({
      'isDeactivated': false,
      'deactivationReason': FieldValue.delete(),
      'deactivatedUntil': FieldValue.delete(),
      'isActive': true,
      'isOpen': true,
      'isAcceptingOrders': true,
      'isOnline': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    final sellerId = user?.uid;
    if (user != null && user.email != null) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    }

    if (sellerId != null) {
      // Soft delete seller document
      final sellerRef = _firestore.collection('sellers').doc(sellerId);
      await sellerRef.update({
        'isDeleted': true,
        'status': 'deleted',
        'isActive': false,
        'isOpen': false,
        'isAcceptingOrders': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    }

    await user?.delete();
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
