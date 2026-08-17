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
      expect(find.text('Restaurant Info'), findsOneWidget);
      expect(find.text('Business Hours'), findsOneWidget);
      expect(find.text('Delivery Settings'), findsOneWidget);
      expect(find.text('Order Settings'), findsOneWidget);
      expect(find.text('Notification Settings'), findsWidgets);
      expect(find.text('Payment Settings'), findsOneWidget);
      expect(find.text('Bank / UPI Settings'), findsOneWidget);
      expect(find.text('Tax Information'), findsOneWidget);
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Delete / Deactivate'), findsOneWidget);
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

      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Delivery'), findsOneWidget);
    });

    testWidgets('renders business hours section when section index is 1', (WidgetTester tester) async {
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

      expect(find.text('Business Hours & Schedule'), findsOneWidget);
      expect(find.text('Temporary Emergency / Holiday Closure'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
    });

    testWidgets('renders delivery settings section when section index is 2', (WidgetTester tester) async {
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

      expect(find.text('Delivery & Logistics Settings'), findsOneWidget);
      expect(find.text('Minimum Order Value (₹)'), findsOneWidget);
      expect(find.text('Base Delivery Fee (₹)'), findsOneWidget);
    });

    testWidgets('renders tax section when section index is 7', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 7,
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

      expect(find.text('Tax & Compliance Information'), findsOneWidget);
      expect(find.text('GSTIN Number (15-digit)'), findsOneWidget);
      expect(find.text('FSSAI License Number (14-digit)'), findsOneWidget);
    });

    testWidgets('renders change password section when section index is 11', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const SellerSettingState(
        restaurantName: 'The Royal Kitchen',
        selectedSectionIndex: 11,
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
  });
}
