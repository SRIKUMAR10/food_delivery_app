import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';

class MockDeliverySettingsRepository extends Mock
    implements DeliverySettingsRepositoryBase {}

class MockDeliverySettingsService extends Mock
    implements DeliverySettingsServiceBase {}

void main() {
  late MockDeliverySettingsRepository mockRepository;
  late MockDeliverySettingsService mockService;

  const DeliverySettingsState defaultLoaded = DeliverySettingsState(
    status: DeliverySettingsStatus.loaded,
    notificationsEnabled: true,
    autoAcceptEnabled: true,
    darkModeEnabled: false,
    deliveryRadius: 5.0,
    languageCode: 'en',
    localeCode: 'en',
    items: [
      DeliverySettingsItem(
        id: 'notifications',
        titleKey: 'notifications',
        subtitleKey: 'notificationsSub',
        icon: Icons.notifications_outlined,
        value: true,
      ),
      DeliverySettingsItem(
        id: 'autoAccept',
        titleKey: 'autoAccept',
        subtitleKey: 'autoAcceptSub',
        icon: Icons.bolt_outlined,
        value: true,
      ),
      DeliverySettingsItem(
        id: 'darkMode',
        titleKey: 'darkMode',
        subtitleKey: 'darkModeSub',
        icon: Icons.dark_mode_outlined,
        value: false,
      ),
    ],
  );

  List<DeliverySettingsItem> itemsWith({
    bool notifications = true,
    bool autoAccept = true,
    bool darkMode = false,
  }) {
    return DeliverySettingsRepository.buildDefaultItems(
      notificationsEnabled: notifications,
      autoAcceptEnabled: autoAccept,
      darkModeEnabled: darkMode,
    );
  }

  setUp(() {
    mockRepository = MockDeliverySettingsRepository();
    mockService = MockDeliverySettingsService();
    registerFallbackValue(const DeliverySettingsState());
  });

  group('DeliverySettingsBloc Unit Tests', () {
    test('initial state starts at initial status with default settings', () {
      final bloc = DeliverySettingsBloc(
        repository: mockRepository,
        service: mockService,
      );
      expect(bloc.state.status, DeliverySettingsStatus.initial);
      expect(bloc.state.notificationsEnabled, isTrue);
      expect(bloc.state.autoAcceptEnabled, isTrue);
      expect(bloc.state.darkModeEnabled, isFalse);
      expect(bloc.state.deliveryRadius, 5.0);
      expect(bloc.state.languageCode, 'en');
      expect(bloc.state.items, isEmpty);
      bloc.close();
    });

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'emits loading then loaded state on InitEvent success',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.fetchSettings(),
        ).thenAnswer((_) async => defaultLoaded);
        return DeliverySettingsBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliverySettingsInitEvent()),
      expect: () => [
        const DeliverySettingsState(status: DeliverySettingsStatus.loading),
        defaultLoaded,
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'emits error state when network connectivity check fails',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => false);
        return DeliverySettingsBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliverySettingsInitEvent()),
      expect: () => [
        const DeliverySettingsState(status: DeliverySettingsStatus.loading),
        const DeliverySettingsState(
          status: DeliverySettingsStatus.error,
          errorMessage: 'Network connection unavailable',
        ),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'emits error state when InitEvent fails',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.fetchSettings(),
        ).thenThrow(Exception('Settings API down'));
        return DeliverySettingsBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliverySettingsInitEvent()),
      expect: () => [
        const DeliverySettingsState(status: DeliverySettingsStatus.loading),
        const DeliverySettingsState(
          status: DeliverySettingsStatus.error,
          errorMessage: 'Settings API down',
        ),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'emits empty state when settings contain no items',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => true);
        when(() => mockRepository.fetchSettings()).thenAnswer(
          (_) async => const DeliverySettingsState(
            status: DeliverySettingsStatus.loaded,
          ),
        );
        return DeliverySettingsBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliverySettingsInitEvent()),
      expect: () => [
        const DeliverySettingsState(status: DeliverySettingsStatus.loading),
        const DeliverySettingsState(status: DeliverySettingsStatus.empty),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'toggles notifications off and syncs the settings items',
      build: () => DeliverySettingsBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => defaultLoaded,
      act: (b) => b.add(const DeliverySettingsToggleNotificationEvent()),
      expect: () => [
        defaultLoaded.copyWith(
          notificationsEnabled: false,
          items: itemsWith(notifications: false),
        ),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'toggles auto-accept off and syncs the settings items',
      build: () => DeliverySettingsBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => defaultLoaded,
      act: (b) => b.add(const DeliverySettingsToggleAutoAcceptEvent()),
      expect: () => [
        defaultLoaded.copyWith(
          autoAcceptEnabled: false,
          items: itemsWith(autoAccept: false),
        ),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'toggles dark mode on and syncs the settings items',
      build: () => DeliverySettingsBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => defaultLoaded,
      act: (b) => b.add(const DeliverySettingsToggleDarkModeEvent()),
      expect: () => [
        defaultLoaded.copyWith(
          darkModeEnabled: true,
          items: itemsWith(darkMode: true),
        ),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'updates the delivery radius within the allowed range',
      build: () => DeliverySettingsBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => defaultLoaded,
      act: (b) => b.add(const DeliverySettingsUpdateRadiusEvent(8.5)),
      expect: () => [defaultLoaded.copyWith(deliveryRadius: 8.5)],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'clamps an out-of-range radius update to the maximum',
      build: () => DeliverySettingsBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => defaultLoaded,
      act: (b) => b.add(const DeliverySettingsUpdateRadiusEvent(99)),
      expect: () => [defaultLoaded.copyWith(deliveryRadius: 20.0)],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'changes the language and applies it as the locale',
      build: () => DeliverySettingsBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => defaultLoaded,
      act: (b) => b.add(const DeliverySettingsChangeLanguageEvent('ta')),
      expect: () => [
        defaultLoaded.copyWith(languageCode: 'ta', localeCode: 'ta'),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'saves settings and emits saved saveStatus on SaveEvent',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return DeliverySettingsBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => defaultLoaded,
      act: (b) => b.add(const DeliverySettingsSaveEvent()),
      expect: () => [
        defaultLoaded.copyWith(
          status: DeliverySettingsStatus.saving,
          saveStatus: DeliverySettingsSaveStatus.saving,
        ),
        defaultLoaded.copyWith(saveStatus: DeliverySettingsSaveStatus.saved),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'emits failed saveStatus when save throws',
      build: () {
        when(
          () => mockRepository.saveSettings(any()),
        ).thenThrow(Exception('Disk full'));
        return DeliverySettingsBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => defaultLoaded,
      act: (b) => b.add(const DeliverySettingsSaveEvent()),
      expect: () => [
        defaultLoaded.copyWith(
          status: DeliverySettingsStatus.saving,
          saveStatus: DeliverySettingsSaveStatus.saving,
        ),
        defaultLoaded.copyWith(
          saveStatus: DeliverySettingsSaveStatus.failed,
          errorMessage: 'Disk full',
        ),
      ],
    );

    blocTest<DeliverySettingsBloc, DeliverySettingsState>(
      'reloads the settings when RetryEvent is dispatched',
      build: () {
        when(
          () => mockService.checkNetworkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.fetchSettings(),
        ).thenAnswer((_) async => defaultLoaded);
        return DeliverySettingsBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => defaultLoaded.copyWith(status: DeliverySettingsStatus.error),
      act: (b) => b.add(const DeliverySettingsRetryEvent()),
      expect: () => [
        defaultLoaded.copyWith(status: DeliverySettingsStatus.loading),
        defaultLoaded,
      ],
    );
  });
}
