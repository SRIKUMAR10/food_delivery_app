import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum DeliverySettingsStatus { initial, loading, loaded, saving, error, empty }

enum DeliverySettingsSaveStatus { idle, saving, saved, failed }

class DeliverySettingsItem extends Equatable {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final bool value;

  const DeliverySettingsItem({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.value,
  });

  DeliverySettingsItem copyWith({bool? value}) {
    return DeliverySettingsItem(
      id: id,
      titleKey: titleKey,
      subtitleKey: subtitleKey,
      icon: icon,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleKey': titleKey,
        'subtitleKey': subtitleKey,
        'icon': icon.codePoint,
        'value': value,
      };

  factory DeliverySettingsItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    IconData iconData;
    switch (id) {
      case 'notifications':
        iconData = Icons.notifications_outlined;
        break;
      case 'autoAccept':
        iconData = Icons.bolt_outlined;
        break;
      case 'darkMode':
        iconData = Icons.dark_mode_outlined;
        break;
      case 'sunMode':
        iconData = Icons.wb_sunny_outlined;
        break;
      case 'oledMode':
        iconData = Icons.battery_saver;
        break;
      default:
        iconData = Icons.tune;
    }
    return DeliverySettingsItem(
      id: id,
      titleKey: json['titleKey'] as String? ?? '',
      subtitleKey: json['subtitleKey'] as String? ?? '',
      icon: iconData,
      value: json['value'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, titleKey, subtitleKey, icon, value];
}

class DeliverySettingsState extends Equatable {
  final DeliverySettingsStatus status;
  final DeliverySettingsSaveStatus saveStatus;
  final String? errorMessage;
  final bool notificationsEnabled;
  final bool autoAcceptEnabled;
  final bool darkModeEnabled;
  final bool sunModeEnabled;
  final bool oledModeEnabled;
  final double deliveryRadius;
  final String languageCode;
  final String localeCode;
  final List<DeliverySettingsItem> items;
  final bool soundAlertsEnabled;
  final bool vibrationAlertsEnabled;
  final bool highAccuracyGps;
  final bool backgroundLocationEnabled;
  final bool biometricLockEnabled;
  final bool twoFactorAuthEnabled;
  final bool dataSharingConsent;
  final bool isAccountDeactivated;
  final String? actionMessage;

  const DeliverySettingsState({
    this.status = DeliverySettingsStatus.initial,
    this.saveStatus = DeliverySettingsSaveStatus.idle,
    this.errorMessage,
    this.notificationsEnabled = true,
    this.autoAcceptEnabled = true,
    this.darkModeEnabled = false,
    this.sunModeEnabled = false,
    this.oledModeEnabled = false,
    this.deliveryRadius = 5.0,
    this.languageCode = 'en',
    this.localeCode = 'en',
    this.items = const [],
    this.soundAlertsEnabled = true,
    this.vibrationAlertsEnabled = true,
    this.highAccuracyGps = true,
    this.backgroundLocationEnabled = true,
    this.biometricLockEnabled = false,
    this.twoFactorAuthEnabled = false,
    this.dataSharingConsent = true,
    this.isAccountDeactivated = false,
    this.actionMessage,
  });

  DeliverySettingsState copyWith({
    DeliverySettingsStatus? status,
    DeliverySettingsSaveStatus? saveStatus,
    String? errorMessage,
    bool clearError = false,
    bool? notificationsEnabled,
    bool? autoAcceptEnabled,
    bool? darkModeEnabled,
    bool? sunModeEnabled,
    bool? oledModeEnabled,
    double? deliveryRadius,
    String? languageCode,
    String? localeCode,
    List<DeliverySettingsItem>? items,
    bool? soundAlertsEnabled,
    bool? vibrationAlertsEnabled,
    bool? highAccuracyGps,
    bool? backgroundLocationEnabled,
    bool? biometricLockEnabled,
    bool? twoFactorAuthEnabled,
    bool? dataSharingConsent,
    bool? isAccountDeactivated,
    String? actionMessage,
    bool clearActionMessage = false,
  }) {
    return DeliverySettingsState(
      status: status ?? this.status,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoAcceptEnabled: autoAcceptEnabled ?? this.autoAcceptEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      sunModeEnabled: sunModeEnabled ?? this.sunModeEnabled,
      oledModeEnabled: oledModeEnabled ?? this.oledModeEnabled,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      languageCode: languageCode ?? this.languageCode,
      localeCode: localeCode ?? this.localeCode,
      items: items ?? this.items,
      soundAlertsEnabled: soundAlertsEnabled ?? this.soundAlertsEnabled,
      vibrationAlertsEnabled:
          vibrationAlertsEnabled ?? this.vibrationAlertsEnabled,
      highAccuracyGps: highAccuracyGps ?? this.highAccuracyGps,
      backgroundLocationEnabled:
          backgroundLocationEnabled ?? this.backgroundLocationEnabled,
      biometricLockEnabled:
          biometricLockEnabled ?? this.biometricLockEnabled,
      twoFactorAuthEnabled:
          twoFactorAuthEnabled ?? this.twoFactorAuthEnabled,
      dataSharingConsent: dataSharingConsent ?? this.dataSharingConsent,
      isAccountDeactivated:
          isAccountDeactivated ?? this.isAccountDeactivated,
      actionMessage:
          clearActionMessage ? null : (actionMessage ?? this.actionMessage),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'saveStatus': saveStatus.name,
        'errorMessage': errorMessage,
        'notificationsEnabled': notificationsEnabled,
        'autoAcceptEnabled': autoAcceptEnabled,
        'darkModeEnabled': darkModeEnabled,
        'sunModeEnabled': sunModeEnabled,
        'oledModeEnabled': oledModeEnabled,
        'deliveryRadius': deliveryRadius,
        'languageCode': languageCode,
        'localeCode': localeCode,
        'items': items.map((item) => item.toJson()).toList(),
        'soundAlertsEnabled': soundAlertsEnabled,
        'vibrationAlertsEnabled': vibrationAlertsEnabled,
        'highAccuracyGps': highAccuracyGps,
        'backgroundLocationEnabled': backgroundLocationEnabled,
        'biometricLockEnabled': biometricLockEnabled,
        'twoFactorAuthEnabled': twoFactorAuthEnabled,
        'dataSharingConsent': dataSharingConsent,
        'isAccountDeactivated': isAccountDeactivated,
      };

  factory DeliverySettingsState.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ?? 'initial';
    final saveStatusName = json['saveStatus'] as String? ?? 'idle';
    return DeliverySettingsState(
      status: DeliverySettingsStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => DeliverySettingsStatus.initial,
      ),
      saveStatus: DeliverySettingsSaveStatus.values.firstWhere(
        (s) => s.name == saveStatusName,
        orElse: () => DeliverySettingsSaveStatus.idle,
      ),
      errorMessage: json['errorMessage'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      autoAcceptEnabled: json['autoAcceptEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      sunModeEnabled: json['sunModeEnabled'] as bool? ?? false,
      oledModeEnabled: json['oledModeEnabled'] as bool? ?? false,
      deliveryRadius: (json['deliveryRadius'] as num?)?.toDouble() ?? 5.0,
      languageCode: json['languageCode'] as String? ?? 'en',
      localeCode: json['localeCode'] as String? ?? 'en',
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DeliverySettingsItem.fromJson)
          .toList(),
      soundAlertsEnabled: json['soundAlertsEnabled'] as bool? ?? true,
      vibrationAlertsEnabled: json['vibrationAlertsEnabled'] as bool? ?? true,
      highAccuracyGps: json['highAccuracyGps'] as bool? ?? true,
      backgroundLocationEnabled: json['backgroundLocationEnabled'] as bool? ?? true,
      biometricLockEnabled: json['biometricLockEnabled'] as bool? ?? false,
      twoFactorAuthEnabled: json['twoFactorAuthEnabled'] as bool? ?? false,
      dataSharingConsent: json['dataSharingConsent'] as bool? ?? true,
      isAccountDeactivated: json['isAccountDeactivated'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        saveStatus,
        errorMessage,
        notificationsEnabled,
        autoAcceptEnabled,
        darkModeEnabled,
        sunModeEnabled,
        oledModeEnabled,
        deliveryRadius,
        languageCode,
        localeCode,
        items,
        soundAlertsEnabled,
        vibrationAlertsEnabled,
        highAccuracyGps,
        backgroundLocationEnabled,
        biometricLockEnabled,
        twoFactorAuthEnabled,
        dataSharingConsent,
        isAccountDeactivated,
        actionMessage,
      ];
}

