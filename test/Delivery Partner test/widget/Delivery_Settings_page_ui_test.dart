import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliverySettingsBloc
    extends MockBloc<DeliverySettingsEvent, DeliverySettingsState>
    implements DeliverySettingsBloc {}

void main() {
  late MockDeliverySettingsBloc mockBloc;

  const DeliverySettingsState loadedState = DeliverySettingsState(
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

  setUpAll(() {
    overrideFontAssetLoading();

    registerFallbackValue(const DeliverySettingsInitEvent());
    registerFallbackValue(const DeliverySettingsToggleNotificationEvent());
    registerFallbackValue(const DeliverySettingsToggleAutoAcceptEvent());
    registerFallbackValue(const DeliverySettingsToggleDarkModeEvent());
    registerFallbackValue(const DeliverySettingsUpdateRadiusEvent(0));
    registerFallbackValue(const DeliverySettingsChangeLanguageEvent(''));
    registerFallbackValue(const DeliverySettingsSaveEvent());
    registerFallbackValue(const DeliverySettingsRetryEvent());
  });

  setUp(() {
    mockBloc = MockDeliverySettingsBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(body: DeliverySettingsPage(bloc: mockBloc)),
    );
  }

  group('DeliverySettingsPage Widget Tests', () {
    testWidgets('renders settings sections, toggles and save button', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dp_settings_page')), findsOneWidget);
      expect(find.text('Delivery Settings'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_settings_preferences_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_settings_toggle_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_settings_radius_slider')),
        findsOneWidget,
      );
      expect(find.text('5.0 km'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_settings_language_dropdown')),
        findsOneWidget,
      );
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Auto-Accept Orders'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_settings_earnings_card')),
        findsOneWidget,
      );
      expect(find.text('\u20B91,200.00'), findsOneWidget);
      expect(find.byKey(const Key('dp_settings_save_button')), findsOneWidget);
      expect(find.text('Save Settings'), findsOneWidget);
    });

    testWidgets(
      'dispatches ToggleNotificationEvent when notification switch is tapped',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('dp_settings_toggle_notifications')),
        );
        await tester.pump();

        verify(
          () => mockBloc.add(const DeliverySettingsToggleNotificationEvent()),
        ).called(1);
      },
    );

    testWidgets(
      'dispatches ToggleAutoAcceptEvent when auto-accept switch is tapped',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('dp_settings_toggle_autoAccept')),
        );
        await tester.pump();

        verify(
          () => mockBloc.add(const DeliverySettingsToggleAutoAcceptEvent()),
        ).called(1);
      },
    );

    testWidgets(
      'dispatches ToggleDarkModeEvent when dark mode switch is tapped',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('dp_settings_toggle_darkMode')));
        await tester.pump();

        verify(
          () => mockBloc.add(const DeliverySettingsToggleDarkModeEvent()),
        ).called(1);
      },
    );

    testWidgets(
      'dispatches UpdateRadiusEvent when the radius slider is dragged',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.drag(
          find.byKey(const Key('dp_settings_radius_slider')),
          const Offset(80, 0),
        );
        await tester.pump();

        verify(
          () => mockBloc.add(any<DeliverySettingsUpdateRadiusEvent>()),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    testWidgets('dispatches ChangeLanguageEvent when Tamil is selected', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dp_settings_language_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tamil').last);
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(const DeliverySettingsChangeLanguageEvent('ta')),
      ).called(1);
    });

    testWidgets('dispatches SaveEvent when save button is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dp_settings_save_button')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliverySettingsSaveEvent())).called(1);
    });

    testWidgets('shows skeleton loader during loading state', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliverySettingsState(status: DeliverySettingsStatus.loading),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_settings_skeleton')), findsOneWidget);
    });

    testWidgets('shows error state with retry action', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliverySettingsState(
          status: DeliverySettingsStatus.error,
          errorMessage: 'Settings API down',
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_settings_error')), findsOneWidget);
      expect(find.text('Settings API down'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_settings_retry')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliverySettingsRetryEvent())).called(1);
    });

    testWidgets('shows empty state with refresh action', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliverySettingsState(status: DeliverySettingsStatus.empty),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_settings_empty')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_settings_refresh')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliverySettingsRetryEvent())).called(1);
    });

    testWidgets('lays out single column on a mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Delivery Settings'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_settings_preferences_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_settings_toggle_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_settings_earnings_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_settings_save_button')), findsOneWidget);
    });

    testWidgets('shows Tamil strings when the locale is set to Tamil', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockBloc.state,
      ).thenReturn(loadedState.copyWith(languageCode: 'ta', localeCode: 'ta'));
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('டெலிவரி அமைப்புகள்'), findsOneWidget);
    });
  });
}
