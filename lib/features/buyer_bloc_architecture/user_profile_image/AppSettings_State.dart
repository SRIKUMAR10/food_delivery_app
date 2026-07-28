import 'package:equatable/equatable.dart';

class AppSettingsState extends Equatable {
  final bool pushNotifications;
  final bool orderNotifications;
  final bool offerNotifications;
  final bool chatNotifications;
  final bool notificationSound;
  final bool vibration;
  final String theme;
  final String language;
  final bool isInitialized;
  final bool isLoading;
  final bool isLoggedOut;
  final String? error;

  const AppSettingsState({
    this.pushNotifications = true,
    this.orderNotifications = true,
    this.offerNotifications = false,
    this.chatNotifications = true,
    this.notificationSound = true,
    this.vibration = true,
    this.theme = 'system',
    this.language = 'en',
    this.isInitialized = false,
    this.isLoading = false,
    this.isLoggedOut = false,
    this.error,
  });

  AppSettingsState copyWith({
    bool? pushNotifications,
    bool? orderNotifications,
    bool? offerNotifications,
    bool? chatNotifications,
    bool? notificationSound,
    bool? vibration,
    String? theme,
    String? language,
    bool? isInitialized,
    bool? isLoading,
    bool? isLoggedOut,
    String? error,
  }) {
    return AppSettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      orderNotifications: orderNotifications ?? this.orderNotifications,
      offerNotifications: offerNotifications ?? this.offerNotifications,
      chatNotifications: chatNotifications ?? this.chatNotifications,
      notificationSound: notificationSound ?? this.notificationSound,
      vibration: vibration ?? this.vibration,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      error: error,
    );
  }

  factory AppSettingsState.initial() => const AppSettingsState();

  @override
  List<Object?> get props => [
        pushNotifications,
        orderNotifications,
        offerNotifications,
        chatNotifications,
        notificationSound,
        vibration,
        theme,
        language,
        isInitialized,
        isLoading,
        isLoggedOut,
        error,
      ];
}
