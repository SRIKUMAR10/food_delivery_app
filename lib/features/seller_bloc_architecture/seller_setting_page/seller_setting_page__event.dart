import 'package:equatable/equatable.dart';
import 'seller_setting_page__state.dart';

abstract class SellerSettingEvent extends Equatable {
  const SellerSettingEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings once or start stream
class LoadSellerSettings extends SellerSettingEvent {}

class WatchSellerSettings extends SellerSettingEvent {}

/// Triggered when Firestore snapshot yields fresh data
class SettingsUpdatedFromStream extends SellerSettingEvent {
  final SellerSettingState state;

  const SettingsUpdatedFromStream(this.state);

  @override
  List<Object?> get props => [state];
}

/// Select active tab in responsive sidebar
class SelectSettingsSection extends SellerSettingEvent {
  final int sectionIndex;

  const SelectSettingsSection(this.sectionIndex);

  @override
  List<Object?> get props => [sectionIndex];
}

/// Clear success/error snackbars or alerts
class ClearSettingMessages extends SellerSettingEvent {}

// ----------------------------------------------------
// 1. Restaurant Information
// ----------------------------------------------------
class UpdateRestaurantInfo extends SellerSettingEvent {
  final String restaurantName;
  final String ownerName;
  final String phoneNumber;
  final String email;
  final String restaurantDescription;
  final String address;
  final List<String> cuisines;
  final String profileImageUrl;
  final String coverImageUrl;
  final double? latitude;
  final double? longitude;

  const UpdateRestaurantInfo({
    required this.restaurantName,
    required this.ownerName,
    required this.phoneNumber,
    required this.email,
    required this.restaurantDescription,
    required this.address,
    required this.cuisines,
    this.profileImageUrl = '',
    this.coverImageUrl = '',
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        restaurantName,
        ownerName,
        phoneNumber,
        email,
        restaurantDescription,
        address,
        cuisines,
        profileImageUrl,
        coverImageUrl,
        latitude,
        longitude,
      ];
}

// ----------------------------------------------------
// 2. Business Hours
// ----------------------------------------------------
class UpdateBusinessHoursSchedule extends SellerSettingEvent {
  final Map<String, dynamic> businessHours;

  const UpdateBusinessHoursSchedule(this.businessHours);

  @override
  List<Object?> get props => [businessHours];
}

class ToggleEmergencyClosure extends SellerSettingEvent {
  final bool isClosed;

  const ToggleEmergencyClosure(this.isClosed);

  @override
  List<Object?> get props => [isClosed];
}

class ToggleAcceptingOrders extends SellerSettingEvent {
  final bool isAccepting;

  const ToggleAcceptingOrders(this.isAccepting);

  @override
  List<Object?> get props => [isAccepting];
}

// ----------------------------------------------------
// 3. Delivery Settings
// ----------------------------------------------------
class UpdateDeliverySettings extends SellerSettingEvent {
  final double deliveryRadius;
  final double minimumOrderValue;
  final double baseDeliveryFee;
  final double perKmDeliveryFee;
  final double freeDeliveryThreshold;
  final int estimatedPrepTimeMinutes;
  final String deliveryTimeEstimate;
  final double packagingCharges;
  final bool allowSelfPickup;
  final bool isSelfDelivery;

  const UpdateDeliverySettings({
    required this.deliveryRadius,
    required this.minimumOrderValue,
    required this.baseDeliveryFee,
    required this.perKmDeliveryFee,
    required this.freeDeliveryThreshold,
    required this.estimatedPrepTimeMinutes,
    required this.deliveryTimeEstimate,
    required this.packagingCharges,
    required this.allowSelfPickup,
    required this.isSelfDelivery,
  });

  @override
  List<Object?> get props => [
        deliveryRadius,
        minimumOrderValue,
        baseDeliveryFee,
        perKmDeliveryFee,
        freeDeliveryThreshold,
        estimatedPrepTimeMinutes,
        deliveryTimeEstimate,
        packagingCharges,
        allowSelfPickup,
        isSelfDelivery,
      ];
}

// ----------------------------------------------------
// 4. Order Settings
// ----------------------------------------------------
class UpdateOrderSettings extends SellerSettingEvent {
  final bool autoAcceptOrders;
  final int prepBufferTimeMinutes;
  final int maxActiveOrdersLimit;
  final bool allowScheduledOrders;
  final bool allowSpecialInstructions;
  final int cancellationWindowMinutes;

  const UpdateOrderSettings({
    required this.autoAcceptOrders,
    required this.prepBufferTimeMinutes,
    required this.maxActiveOrdersLimit,
    required this.allowScheduledOrders,
    required this.allowSpecialInstructions,
    required this.cancellationWindowMinutes,
  });

  @override
  List<Object?> get props => [
        autoAcceptOrders,
        prepBufferTimeMinutes,
        maxActiveOrdersLimit,
        allowScheduledOrders,
        allowSpecialInstructions,
        cancellationWindowMinutes,
      ];
}

// ----------------------------------------------------
// 5. Notification Settings (Backward Compatible + Advanced)
// ----------------------------------------------------
class UpdatePushNotifications extends SellerSettingEvent {
  final bool enabled;

  const UpdatePushNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateNewOrderSound extends SellerSettingEvent {
  final bool enabled;

  const UpdateNewOrderSound(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdatePromoAndOffers extends SellerSettingEvent {
  final bool enabled;

  const UpdatePromoAndOffers(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateLowStockAlerts extends SellerSettingEvent {
  final bool enabled;

  const UpdateLowStockAlerts(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateOrderUpdates extends SellerSettingEvent {
  final bool enabled;

  const UpdateOrderUpdates(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateNotificationAdvancedSettings extends SellerSettingEvent {
  final bool pushNotifications;
  final bool newOrderSound;
  final bool soundLoopUntilAccepted;
  final String orderAlertRingtone;
  final double soundVolume;
  final bool promoAndOffers;
  final bool lowStockAlerts;
  final bool orderUpdates;
  final bool whatsappNotifications;
  final bool smsNotifications;

  const UpdateNotificationAdvancedSettings({
    required this.pushNotifications,
    required this.newOrderSound,
    required this.soundLoopUntilAccepted,
    required this.orderAlertRingtone,
    required this.soundVolume,
    required this.promoAndOffers,
    required this.lowStockAlerts,
    required this.orderUpdates,
    required this.whatsappNotifications,
    required this.smsNotifications,
  });

  @override
  List<Object?> get props => [
        pushNotifications,
        newOrderSound,
        soundLoopUntilAccepted,
        orderAlertRingtone,
        soundVolume,
        promoAndOffers,
        lowStockAlerts,
        orderUpdates,
        whatsappNotifications,
        smsNotifications,
      ];
}

// ----------------------------------------------------
// 6. Payment Settings
// ----------------------------------------------------
class UpdatePaymentSettings extends SellerSettingEvent {
  final bool acceptCashOnDelivery;
  final bool acceptOnlinePayments;
  final bool acceptWalletPayments;
  final String payoutSchedule;
  final double minPayoutThreshold;
  final bool autoSettlementEnabled;

  const UpdatePaymentSettings({
    required this.acceptCashOnDelivery,
    required this.acceptOnlinePayments,
    required this.acceptWalletPayments,
    required this.payoutSchedule,
    required this.minPayoutThreshold,
    required this.autoSettlementEnabled,
  });

  @override
  List<Object?> get props => [
        acceptCashOnDelivery,
        acceptOnlinePayments,
        acceptWalletPayments,
        payoutSchedule,
        minPayoutThreshold,
        autoSettlementEnabled,
      ];
}

// ----------------------------------------------------
// 7. Bank / UPI Settings
// ----------------------------------------------------
class UpdateBankUpiSettings extends SellerSettingEvent {
  final String accountHolderName;
  final String bankName;
  final String bankAccountNumber;
  final String ifscCode;
  final String bankBranch;
  final String upiId;
  final String primaryPayoutMethod;

  const UpdateBankUpiSettings({
    required this.accountHolderName,
    required this.bankName,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.bankBranch,
    required this.upiId,
    required this.primaryPayoutMethod,
  });

  @override
  List<Object?> get props => [
        accountHolderName,
        bankName,
        bankAccountNumber,
        ifscCode,
        bankBranch,
        upiId,
        primaryPayoutMethod,
      ];
}

// ----------------------------------------------------
// 8. Tax Information
// ----------------------------------------------------
class UpdateTaxSettings extends SellerSettingEvent {
  final String gstNumber;
  final double gstPercentage;
  final bool isTaxIncludedInPrice;
  final String panNumber;
  final String fssaiNumber;
  final String fssaiExpiryDate;
  final String invoicePrefix;

  const UpdateTaxSettings({
    required this.gstNumber,
    required this.gstPercentage,
    required this.isTaxIncludedInPrice,
    required this.panNumber,
    required this.fssaiNumber,
    required this.fssaiExpiryDate,
    required this.invoicePrefix,
  });

  @override
  List<Object?> get props => [
        gstNumber,
        gstPercentage,
        isTaxIncludedInPrice,
        panNumber,
        fssaiNumber,
        fssaiExpiryDate,
        invoicePrefix,
      ];
}

// ----------------------------------------------------
// 9. Account Settings
// ----------------------------------------------------
class UpdateAppTheme extends SellerSettingEvent {
  final String theme;

  const UpdateAppTheme(this.theme);

  @override
  List<Object?> get props => [theme];
}

class UpdateLanguage extends SellerSettingEvent {
  final String language;

  const UpdateLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class UpdateAccountSettings extends SellerSettingEvent {
  final String registeredEmail;
  final String registeredPhone;
  final String appTheme;
  final String language;

  const UpdateAccountSettings({
    required this.registeredEmail,
    required this.registeredPhone,
    required this.appTheme,
    required this.language,
  });

  @override
  List<Object?> get props => [
        registeredEmail,
        registeredPhone,
        appTheme,
        language,
      ];
}

// ----------------------------------------------------
// 10. Privacy Settings
// ----------------------------------------------------
class UpdatePrivacySettings extends SellerSettingEvent {
  final bool isPubliclyVisible;
  final bool showRatingsPublicly;
  final bool showPhoneNumberPublicly;
  final bool allowAnalyticsTelemetry;
  final bool receiveMarketingEmails;

  const UpdatePrivacySettings({
    required this.isPubliclyVisible,
    required this.showRatingsPublicly,
    required this.showPhoneNumberPublicly,
    required this.allowAnalyticsTelemetry,
    required this.receiveMarketingEmails,
  });

  @override
  List<Object?> get props => [
        isPubliclyVisible,
        showRatingsPublicly,
        showPhoneNumberPublicly,
        allowAnalyticsTelemetry,
        receiveMarketingEmails,
      ];
}

// ----------------------------------------------------
// 11. Security Settings
// ----------------------------------------------------
class UpdateSecuritySettings extends SellerSettingEvent {
  final bool twoFactorAuthEnabled;
  final String twoFactorMethod;
  final bool appPinLockEnabled;
  final bool biometricLockEnabled;

  const UpdateSecuritySettings({
    required this.twoFactorAuthEnabled,
    required this.twoFactorMethod,
    required this.appPinLockEnabled,
    required this.biometricLockEnabled,
  });

  @override
  List<Object?> get props => [
        twoFactorAuthEnabled,
        twoFactorMethod,
        appPinLockEnabled,
        biometricLockEnabled,
      ];
}

// ----------------------------------------------------
// 12. Change Password
// ----------------------------------------------------
class ChangePasswordRequested extends SellerSettingEvent {
  final String currentPassword;
  final String newPassword;
  final bool signOutOtherDevices;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    this.signOutOtherDevices = false,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, signOutOtherDevices];
}

// ----------------------------------------------------
// 13. Logout
// ----------------------------------------------------
class LogoutRequested extends SellerSettingEvent {}

// ----------------------------------------------------
// 14. Delete / Deactivate Account
// ----------------------------------------------------
class DeactivateAccountRequested extends SellerSettingEvent {
  final String reason;
  final int durationDays;

  const DeactivateAccountRequested({
    required this.reason,
    this.durationDays = 30,
  });

  @override
  List<Object?> get props => [reason, durationDays];
}

class ReactivateAccountRequested extends SellerSettingEvent {}

class DeleteAccountRequested extends SellerSettingEvent {
  final String password;
  final String confirmationKeyword;

  const DeleteAccountRequested({
    required this.password,
    required this.confirmationKeyword,
  });

  @override
  List<Object?> get props => [password, confirmationKeyword];
}
