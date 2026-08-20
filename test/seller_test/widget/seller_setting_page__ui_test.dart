import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__ui.dart';

class MockSellerSettingBloc extends MockBloc<SellerSettingEvent, SellerSettingState> implements SellerSettingBloc {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  setUpAll(() {
    registerFallbackValue(const SellerSettingState());
    registerFallbackValue(LoadSellerSettings());
  });

  group('SellerSettingPage Widget UI Tests', () {
    late MockSellerSettingBloc mockBloc;

    setUp(() {
      mockBloc = MockSellerSettingBloc();
    });

    testWidgets('renders loading state indicator when empty and loading', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const SellerSettingState(isLoading: true, restaurantName: ''));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders wide screen layout with sidebar navigation tabs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Restaurant Settings'), findsOneWidget);
      expect(find.text('The Royal Kitchen'), findsWidgets);
      expect(find.text('Notification Settings'), findsWidgets);
      expect(find.text('Account Settings'), findsWidgets);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Delete / Deactivate'), findsOneWidget);
    });

    testWidgets('renders Store Operations quick-nav cards in wide layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Business Details'), findsOneWidget);
      expect(find.text('Business Hours'), findsOneWidget);
      expect(find.text('Bank & Payout'), findsOneWidget);
      expect(find.text('Wallet & Earnings'), findsOneWidget);
    });

    testWidgets('renders compact mobile layout with category pills', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'Mobile Street Food',
        selectedSectionIndex: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Business Details'), findsOneWidget);

      final pillBar = find
          .ancestor(of: find.text('Security'), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(
        find.text('Deactivate'),
        80,
        scrollable: pillBar,
      );
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Deactivate'), findsOneWidget);
    });

    testWidgets('renders notification settings section when section index is 0', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification & Audio Alerts'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('New Order Sound Alert'), findsOneWidget);
    });

    testWidgets('notification section renders ringtone preview controls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alert Chime Ringtone'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
      expect(find.text('Tap play to preview the selected ringtone.'), findsOneWidget);
      expect(find.text('Bell Chime (Standard)'), findsOneWidget);
      expect(find.text('Alert Sound Volume: 80%'), findsOneWidget);
    });

    testWidgets('selecting a ringtone triggers an immediate audio preview indicator', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Digital Siren (Loud)').last);
      await tester.pumpAndSettle();

      expect(find.text('Digital Siren (Loud)'), findsOneWidget);
      expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);
      expect(find.textContaining('Previewing'), findsOneWidget);
    });

    testWidgets('preview button toggles between play and stop states', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_circle_fill_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.stop_circle_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
      expect(find.text('Tap play to preview the selected ringtone.'), findsOneWidget);
    });

    testWidgets('adjusting the volume slider keeps the preview active', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 0,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slider), const Offset(120, 0));
      await tester.pumpAndSettle();

      expect(find.textContaining('Alert Sound Volume:'), findsOneWidget);
      expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);
      expect(find.textContaining('volume...'), findsOneWidget);
    });

    testWidgets('renders account settings section when section index is 1', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 1,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account & App Preferences'), findsOneWidget);
      expect(find.text('Application Theme'), findsOneWidget);
    });

    testWidgets('renders privacy section when section index is 2', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 2,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Visibility'), findsOneWidget);
      expect(find.text('Public Store Visibility'), findsOneWidget);
    });

    testWidgets('renders security section when section index is 3', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 3,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Security & Active Sessions'), findsOneWidget);
      expect(find.text('Two-Factor Authentication (2FA)'), findsOneWidget);
    });

    testWidgets('renders change password section when section index is 4', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 4,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsWidgets);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
    });

    testWidgets('renders deactivate or delete section when section index is 6', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 6,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deactivate or Delete Account'), findsOneWidget);
      expect(find.text('Temporary Account Deactivation'), findsOneWidget);
      expect(find.text('Permanent Account Deletion'), findsOneWidget);
    });
  });
}