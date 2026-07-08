import 'package:equatable/equatable.dart';

class SellerSettingState extends Equatable {
  final bool pushNotifications;
  final bool newOrderSound;
  final bool promoAndOffers;
  final bool lowStockAlerts;
  final bool orderUpdates;
  final String appTheme;
  final String language;
  final bool isLoading;
  final String? error;

  const SellerSettingState({
    this.pushNotifications = true,
    this.newOrderSound = true,
    this.promoAndOffers = false,
    this.lowStockAlerts = true,
    this.orderUpdates = true,
    this.appTheme = 'Light',
    this.language = 'English',
    this.isLoading = false,
    this.error,
  });

  SellerSettingState copyWith({
    bool? pushNotifications,
    bool? newOrderSound,
    bool? promoAndOffers,
    bool? lowStockAlerts,
    bool? orderUpdates,
    String? appTheme,
    String? language,
    bool? isLoading,
    String? error,
  }) {
    return SellerSettingState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      newOrderSound: newOrderSound ?? this.newOrderSound,
      promoAndOffers: promoAndOffers ?? this.promoAndOffers,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      appTheme: appTheme ?? this.appTheme,
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        pushNotifications,
        newOrderSound,
        promoAndOffers,
        lowStockAlerts,
        orderUpdates,
        appTheme,
        language,
        isLoading,
        error,
      ];
}
