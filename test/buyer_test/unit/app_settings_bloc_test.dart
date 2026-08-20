import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_app_settings_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/services/locale_manager.dart';
import 'package:food_delivery_app/core/services/theme_manager.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/AppSettings_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/AppSettings_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/AppSettings_State.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockAppSettingsRepository extends Mock implements IAppSettingsRepository {}
class MockThemeManager extends Mock implements ThemeManager {}
class MockLocaleManager extends Mock implements LocaleManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AppSettingsState());
    registerFallbackValue(ThemeMode.light);
    registerFallbackValue(const Locale('en'));
  });

  group('AppSettingsBloc Unit Tests', () {
    late MockAuthService mockAuthService;
    late MockAppSettingsRepository mockRepository;
    late MockThemeManager mockThemeManager;
    late MockLocaleManager mockLocaleManager;
    late AppSettingsBloc bloc;

    const mockSettings = AppSettingsState(
      pushNotifications: true,
      orderNotifications: true,
      offerNotifications: false,
      chatNotifications: true,
      notificationSound: true,
      vibration: false,
      theme: 'dark',
      language: 'en',
    );

    setUp(() {
      mockAuthService = MockAuthService();
      mockRepository = MockAppSettingsRepository();
      mockThemeManager = MockThemeManager();
      mockLocaleManager = MockLocaleManager();

      when(() => mockAuthService.currentUserId).thenReturn('test_buyer_99');
      when(() => mockRepository.watchSettings('test_buyer_99'))
          .thenAnswer((_) => Stream.value(mockSettings));
      when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
      when(() => mockThemeManager.setTheme(any())).thenReturn(null);
      when(() => mockLocaleManager.setLocale(any())).thenReturn(null);

      bloc = AppSettingsBloc(
        authService: mockAuthService,
        repository: mockRepository,
        themeManager: mockThemeManager,
        localeManager: mockLocaleManager,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is default AppSettingsState', () {
      expect(bloc.state.isInitialized, isFalse);
      expect(bloc.state.theme, 'system');
      expect(bloc.state.language, 'en');
    });

    test('AppSettingsLoadStarted streams settings from repository and emits live state', () async {
      bloc.add(const AppSettingsLoadStarted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AppSettingsState>().having((s) => s.isLoading, 'isLoading', true),
          isA<AppSettingsState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isInitialized, 'isInitialized', true)
              .having((s) => s.theme, 'theme', 'dark')
              .having((s) => s.pushNotifications, 'pushNotifications', true),
        ]),
      );

      verify(() => mockRepository.watchSettings('test_buyer_99')).called(1);
      verify(() => mockThemeManager.setTheme(ThemeMode.dark)).called(1);
      verify(() => mockLocaleManager.setLocale(const Locale('en'))).called(1);
    });

    test('PushNotificationToggled updates state and calls saveSettings', () async {
      bloc.add(const PushNotificationToggled(false));

      await expectLater(
        bloc.stream,
        emits(isA<AppSettingsState>().having((s) => s.pushNotifications, 'pushNotifications', false)),
      );

      verify(() => mockRepository.saveSettings(any())).called(1);
    });

    test('ThemeChanged updates state, notifies ThemeManager and calls saveSettings', () async {
      bloc.add(const ThemeChanged('light'));

      await expectLater(
        bloc.stream,
        emits(isA<AppSettingsState>().having((s) => s.theme, 'theme', 'light')),
      );

      verify(() => mockThemeManager.setTheme(ThemeMode.light)).called(1);
      verify(() => mockRepository.saveSettings(any())).called(1);
    });

    test('LanguageChanged updates state, notifies LocaleManager and calls saveSettings', () async {
      bloc.add(const LanguageChanged('ta'));

      await expectLater(
        bloc.stream,
        emits(isA<AppSettingsState>().having((s) => s.language, 'language', 'ta')),
      );

      verify(() => mockLocaleManager.setLocale(const Locale('ta'))).called(1);
      verify(() => mockRepository.saveSettings(any())).called(1);
    });

    test('LogoutRequested signs out and sets isLoggedOut to true', () async {
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      bloc.add(const LogoutRequested());

      await expectLater(
        bloc.stream,
        emits(isA<AppSettingsState>().having((s) => s.isLoggedOut, 'isLoggedOut', true)),
      );

      verify(() => mockAuthService.signOut()).called(1);
    });
  });
}
