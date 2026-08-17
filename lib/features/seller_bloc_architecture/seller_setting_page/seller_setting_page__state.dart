import 'package:equatable/equatable.dart';

class SellerSettingState extends Equatable {
  // 1. Restaurant Information
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

  // 2. Business Hours
  final Map<String, dynamic> businessHours;
  final bool isOpen;
  final bool isAcceptingOrders;
  final bool isEmergencyClosed;

  // 3. Delivery Settings
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

  // 4. Order Settings
  final bool autoAcceptOrders;
  final int prepBufferTimeMinutes;
  final int maxActiveOrdersLimit;
  final bool allowScheduledOrders;
  final bool allowSpecialInstructions;
  final int cancellationWindowMinutes;

  // 5. Notification Settings (Backward Compatible)
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

  // 6. Payment Settings
  final bool acceptCashOnDelivery;
  final bool acceptOnlinePayments;
  final bool acceptWalletPayments;
  final String payoutSchedule; // 'Daily', 'Weekly', 'Instant'
  final double minPayoutThreshold;
  final bool autoSettlementEnabled;

  // 7. Bank / UPI Settings
  final String accountHolderName;
  final String bankName;
  final String bankAccountNumber;
  final String ifscCode;
  final String bankBranch;
  final String upiId;
  final String primaryPayoutMethod; // 'bank' or 'upi'
  final bool isBankVerified;

  // 8. Tax Information
  final String gstNumber;
  final double gstPercentage;
  final bool isTaxIncludedInPrice;
  final String panNumber;
  final String fssaiNumber;
  final String fssaiExpiryDate;
  final String invoicePrefix;

  // 9. Account Settings (Backward Compatible)
  final String registeredEmail;
  final String registeredPhone;
  final bool isPhoneVerified;
  final String appTheme; // 'Light', 'Dark', 'System Default'
  final String language; // 'English', 'Tamil', etc.

  // 10. Privacy Settings
  final bool isPubliclyVisible;
  final bool showRatingsPublicly;
  final bool showPhoneNumberPublicly;
  final bool allowAnalyticsTelemetry;
  final bool receiveMarketingEmails;

  // 11. Security Settings
  final bool twoFactorAuthEnabled;
  final String twoFactorMethod; // 'sms', 'email', 'authenticator'
  final bool appPinLockEnabled;
  final bool biometricLockEnabled;
  final List<Map<String, dynamic>> activeSessions;
  final DateTime? lastPasswordChanged;
  final DateTime? lastLoginAt;

  // UI / Status Tracking
  final int selectedSectionIndex;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final bool isDeactivated;
  final String? deactivationReason;

  const SellerSettingState({
    // 1. Restaurant Info
    this.restaurantName = '',
    this.ownerName = '',
    this.phoneNumber = '',
    this.email = '',
    this.restaurantDescription = '',
    this.address = '',
    this.cuisines = const [],
    this.profileImageUrl = '',
    this.coverImageUrl = '',
    this.latitude,
    this.longitude,

    // 2. Business Hours
    this.businessHours = const {},
    this.isOpen = true,
    this.isAcceptingOrders = true,
    this.isEmergencyClosed = false,

    // 3. Delivery Settings
    this.deliveryRadius = 10.0,
    this.minimumOrderValue = 150.0,
    this.baseDeliveryFee = 25.0,
    this.perKmDeliveryFee = 5.0,
    this.freeDeliveryThreshold = 500.0,
    this.estimatedPrepTimeMinutes = 20,
    this.deliveryTimeEstimate = '30-45 mins',
    this.packagingCharges = 15.0,
    this.allowSelfPickup = true,
    this.isSelfDelivery = false,

    // 4. Order Settings
    this.autoAcceptOrders = false,
    this.prepBufferTimeMinutes = 15,
    this.maxActiveOrdersLimit = 20,
    this.allowScheduledOrders = true,
    this.allowSpecialInstructions = true,
    this.cancellationWindowMinutes = 2,

    // 5. Notification Settings
    this.pushNotifications = true,
    this.newOrderSound = true,
    this.soundLoopUntilAccepted = true,
    this.orderAlertRingtone = 'Bell Chime',
    this.soundVolume = 0.8,
    this.promoAndOffers = false,
    this.lowStockAlerts = true,
    this.orderUpdates = true,
    this.whatsappNotifications = true,
    this.smsNotifications = false,

    // 6. Payment Settings
    this.acceptCashOnDelivery = true,
    this.acceptOnlinePayments = true,
    this.acceptWalletPayments = true,
    this.payoutSchedule = 'Daily',
    this.minPayoutThreshold = 500.0,
    this.autoSettlementEnabled = true,

    // 7. Bank / UPI Settings
    this.accountHolderName = '',
    this.bankName = '',
    this.bankAccountNumber = '',
    this.ifscCode = '',
    this.bankBranch = '',
    this.upiId = '',
    this.primaryPayoutMethod = 'bank',
    this.isBankVerified = false,

    // 8. Tax Information
    this.gstNumber = '',
    this.gstPercentage = 5.0,
    this.isTaxIncludedInPrice = true,
    this.panNumber = '',
    this.fssaiNumber = '',
    this.fssaiExpiryDate = '',
    this.invoicePrefix = 'INV-',

    // 9. Account Settings
    this.registeredEmail = '',
    this.registeredPhone = '',
    this.isPhoneVerified = false,
    this.appTheme = 'Light',
    this.language = 'English',

    // 10. Privacy Settings
    this.isPubliclyVisible = true,
    this.showRatingsPublicly = true,
    this.showPhoneNumberPublicly = false,
    this.allowAnalyticsTelemetry = true,
    this.receiveMarketingEmails = false,

    // 11. Security Settings
    this.twoFactorAuthEnabled = false,
    this.twoFactorMethod = 'sms',
    this.appPinLockEnabled = false,
    this.biometricLockEnabled = false,
    this.activeSessions = const [],
    this.lastPasswordChanged,
    this.lastLoginAt,

    // UI / Status Tracking
    this.selectedSectionIndex = 0,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.isDeactivated = false,
    this.deactivationReason,
  });

  SellerSettingState copyWith({
    String? restaurantName,
    String? ownerName,
    String? phoneNumber,
    String? email,
    String? restaurantDescription,
    String? address,
    List<String>? cuisines,
    String? profileImageUrl,
    String? coverImageUrl,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? businessHours,
    bool? isOpen,
    bool? isAcceptingOrders,
    bool? isEmergencyClosed,
    double? deliveryRadius,
    double? minimumOrderValue,
    double? baseDeliveryFee,
    double? perKmDeliveryFee,
    double? freeDeliveryThreshold,
    int? estimatedPrepTimeMinutes,
    String? deliveryTimeEstimate,
    double? packagingCharges,
    bool? allowSelfPickup,
    bool? isSelfDelivery,
    bool? autoAcceptOrders,
    int? prepBufferTimeMinutes,
    int? maxActiveOrdersLimit,
    bool? allowScheduledOrders,
    bool? allowSpecialInstructions,
    int? cancellationWindowMinutes,
    bool? pushNotifications,
    bool? newOrderSound,
    bool? soundLoopUntilAccepted,
    String? orderAlertRingtone,
    double? soundVolume,
    bool? promoAndOffers,
    bool? lowStockAlerts,
    bool? orderUpdates,
    bool? whatsappNotifications,
    bool? smsNotifications,
    bool? acceptCashOnDelivery,
    bool? acceptOnlinePayments,
    bool? acceptWalletPayments,
    String? payoutSchedule,
    double? minPayoutThreshold,
    bool? autoSettlementEnabled,
    String? accountHolderName,
    String? bankName,
    String? bankAccountNumber,
    String? ifscCode,
    String? bankBranch,
    String? upiId,
    String? primaryPayoutMethod,
    bool? isBankVerified,
    String? gstNumber,
    double? gstPercentage,
    bool? isTaxIncludedInPrice,
    String? panNumber,
    String? fssaiNumber,
    String? fssaiExpiryDate,
    String? invoicePrefix,
    String? registeredEmail,
    String? registeredPhone,
    bool? isPhoneVerified,
    String? appTheme,
    String? language,
    bool? isPubliclyVisible,
    bool? showRatingsPublicly,
    bool? showPhoneNumberPublicly,
    bool? allowAnalyticsTelemetry,
    bool? receiveMarketingEmails,
    bool? twoFactorAuthEnabled,
    String? twoFactorMethod,
    bool? appPinLockEnabled,
    bool? biometricLockEnabled,
    List<Map<String, dynamic>>? activeSessions,
    DateTime? lastPasswordChanged,
    DateTime? lastLoginAt,
    int? selectedSectionIndex,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    bool? isDeactivated,
    String? deactivationReason,
  }) {
    return SellerSettingState(
      restaurantName: restaurantName ?? this.restaurantName,
      ownerName: ownerName ?? this.ownerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      restaurantDescription: restaurantDescription ?? this.restaurantDescription,
      address: address ?? this.address,
      cuisines: cuisines ?? this.cuisines,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      businessHours: businessHours ?? this.businessHours,
      isOpen: isOpen ?? this.isOpen,
      isAcceptingOrders: isAcceptingOrders ?? this.isAcceptingOrders,
      isEmergencyClosed: isEmergencyClosed ?? this.isEmergencyClosed,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
      baseDeliveryFee: baseDeliveryFee ?? this.baseDeliveryFee,
      perKmDeliveryFee: perKmDeliveryFee ?? this.perKmDeliveryFee,
      freeDeliveryThreshold: freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      estimatedPrepTimeMinutes: estimatedPrepTimeMinutes ?? this.estimatedPrepTimeMinutes,
      deliveryTimeEstimate: deliveryTimeEstimate ?? this.deliveryTimeEstimate,
      packagingCharges: packagingCharges ?? this.packagingCharges,
      allowSelfPickup: allowSelfPickup ?? this.allowSelfPickup,
      isSelfDelivery: isSelfDelivery ?? this.isSelfDelivery,
      autoAcceptOrders: autoAcceptOrders ?? this.autoAcceptOrders,
      prepBufferTimeMinutes: prepBufferTimeMinutes ?? this.prepBufferTimeMinutes,
      maxActiveOrdersLimit: maxActiveOrdersLimit ?? this.maxActiveOrdersLimit,
      allowScheduledOrders: allowScheduledOrders ?? this.allowScheduledOrders,
      allowSpecialInstructions: allowSpecialInstructions ?? this.allowSpecialInstructions,
      cancellationWindowMinutes: cancellationWindowMinutes ?? this.cancellationWindowMinutes,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      newOrderSound: newOrderSound ?? this.newOrderSound,
      soundLoopUntilAccepted: soundLoopUntilAccepted ?? this.soundLoopUntilAccepted,
      orderAlertRingtone: orderAlertRingtone ?? this.orderAlertRingtone,
      soundVolume: soundVolume ?? this.soundVolume,
      promoAndOffers: promoAndOffers ?? this.promoAndOffers,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      whatsappNotifications: whatsappNotifications ?? this.whatsappNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      acceptCashOnDelivery: acceptCashOnDelivery ?? this.acceptCashOnDelivery,
      acceptOnlinePayments: acceptOnlinePayments ?? this.acceptOnlinePayments,
      acceptWalletPayments: acceptWalletPayments ?? this.acceptWalletPayments,
      payoutSchedule: payoutSchedule ?? this.payoutSchedule,
      minPayoutThreshold: minPayoutThreshold ?? this.minPayoutThreshold,
      autoSettlementEnabled: autoSettlementEnabled ?? this.autoSettlementEnabled,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankBranch: bankBranch ?? this.bankBranch,
      upiId: upiId ?? this.upiId,
      primaryPayoutMethod: primaryPayoutMethod ?? this.primaryPayoutMethod,
      isBankVerified: isBankVerified ?? this.isBankVerified,
      gstNumber: gstNumber ?? this.gstNumber,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      isTaxIncludedInPrice: isTaxIncludedInPrice ?? this.isTaxIncludedInPrice,
      panNumber: panNumber ?? this.panNumber,
      fssaiNumber: fssaiNumber ?? this.fssaiNumber,
      fssaiExpiryDate: fssaiExpiryDate ?? this.fssaiExpiryDate,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      registeredEmail: registeredEmail ?? this.registeredEmail,
      registeredPhone: registeredPhone ?? this.registeredPhone,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      appTheme: appTheme ?? this.appTheme,
      language: language ?? this.language,
      isPubliclyVisible: isPubliclyVisible ?? this.isPubliclyVisible,
      showRatingsPublicly: showRatingsPublicly ?? this.showRatingsPublicly,
      showPhoneNumberPublicly: showPhoneNumberPublicly ?? this.showPhoneNumberPublicly,
      allowAnalyticsTelemetry: allowAnalyticsTelemetry ?? this.allowAnalyticsTelemetry,
      receiveMarketingEmails: receiveMarketingEmails ?? this.receiveMarketingEmails,
      twoFactorAuthEnabled: twoFactorAuthEnabled ?? this.twoFactorAuthEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      appPinLockEnabled: appPinLockEnabled ?? this.appPinLockEnabled,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      activeSessions: activeSessions ?? this.activeSessions,
      lastPasswordChanged: lastPasswordChanged ?? this.lastPasswordChanged,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      selectedSectionIndex: selectedSectionIndex ?? this.selectedSectionIndex,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      isDeactivated: isDeactivated ?? this.isDeactivated,
      deactivationReason: deactivationReason ?? this.deactivationReason,
    );
  }

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
        businessHours,
        isOpen,
        isAcceptingOrders,
        isEmergencyClosed,
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
        autoAcceptOrders,
        prepBufferTimeMinutes,
        maxActiveOrdersLimit,
        allowScheduledOrders,
        allowSpecialInstructions,
        cancellationWindowMinutes,
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
        acceptCashOnDelivery,
        acceptOnlinePayments,
        acceptWalletPayments,
        payoutSchedule,
        minPayoutThreshold,
        autoSettlementEnabled,
        accountHolderName,
        bankName,
        bankAccountNumber,
        ifscCode,
        bankBranch,
        upiId,
        primaryPayoutMethod,
        isBankVerified,
        gstNumber,
        gstPercentage,
        isTaxIncludedInPrice,
        panNumber,
        fssaiNumber,
        fssaiExpiryDate,
        invoicePrefix,
        registeredEmail,
        registeredPhone,
        isPhoneVerified,
        appTheme,
        language,
        isPubliclyVisible,
        showRatingsPublicly,
        showPhoneNumberPublicly,
        allowAnalyticsTelemetry,
        receiveMarketingEmails,
        twoFactorAuthEnabled,
        twoFactorMethod,
        appPinLockEnabled,
        biometricLockEnabled,
        activeSessions,
        lastPasswordChanged,
        lastLoginAt,
        selectedSectionIndex,
        isLoading,
        isSaving,
        error,
        successMessage,
        isDeactivated,
        deactivationReason,
      ];
}
