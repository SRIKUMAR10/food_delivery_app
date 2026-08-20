import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_app_settings_repository.dart';
import 'package:food_delivery_app/core/services/theme_manager.dart';
import 'package:food_delivery_app/core/services/locale_manager.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/AppSettings_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/pages/app_settings_page.dart';

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

  late MockAuthService mockAuthService;
  late MockAppSettingsRepository mockRepository;
  late MockThemeManager mockThemeManager;
  late MockLocaleManager mockLocaleManager;

  const testSettings = AppSettingsState(
    pushNotifications: true,
    orderNotifications: true,
    offerNotifications: false,
    chatNotifications: true,
    notificationSound: true,
    vibration: false,
    theme: 'light',
    language: 'en',
    isLoading: false,
    isInitialized: true,
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockRepository = MockAppSettingsRepository();
    mockThemeManager = MockThemeManager();
    mockLocaleManager = MockLocaleManager();

    when(() => mockAuthService.currentUserId).thenReturn('test_buyer_123');
    when(() => mockRepository.watchSettings('test_buyer_123'))
        .thenAnswer((_) => Stream.value(testSettings));
    when(() => mockThemeManager.setTheme(any())).thenReturn(null);
    when(() => mockLocaleManager.setLocale(any())).thenReturn(null);
  });

  testWidgets('AppSettingsPage renders successfully when providers are present in tree', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<IAuthService>.value(value: mockAuthService),
          RepositoryProvider<IAppSettingsRepository>.value(value: mockRepository),
          RepositoryProvider<ThemeManager>.value(value: mockThemeManager),
          RepositoryProvider<LocaleManager>.value(value: mockLocaleManager),
        ],
        child: const MaterialApp(
          home: AppSettingsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('App Settings'), findsWidgets);
    expect(find.byType(AppSettingsPage), findsOneWidget);
  });

  testWidgets('AppSettingsPage renders with direct constructor parameter injection', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppSettingsPage(
          authService: mockAuthService,
          repository: mockRepository,
          themeManager: mockThemeManager,
          localeManager: mockLocaleManager,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('App Settings'), findsWidgets);
    expect(find.byType(AppSettingsPage), findsOneWidget);
  });
}
