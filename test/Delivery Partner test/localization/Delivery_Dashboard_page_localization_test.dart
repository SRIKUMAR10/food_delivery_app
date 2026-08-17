import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryDashboardPageBloc
    extends MockBloc<DeliveryDashboardPageEvent, DeliveryDashboardState>
    implements DeliveryDashboardPageBloc {}

const List<DeliveryActivityItem> defaultActivities = [
  DeliveryActivityItem(
    id: 'act_1',
    time: '10:30 AM',
    title: 'Order Delivered',
    subtitle: 'Order #ORD12345',
    details: '₹120.00',
    statusType: 'delivered',
  ),
  DeliveryActivityItem(
    id: 'act_3',
    time: '09:45 AM',
    title: 'New Order Received',
    subtitle: 'Order #ORD12345',
    details: '2.4 km away',
    statusType: 'new_order',
  ),
  DeliveryActivityItem(
    id: 'act_5',
    time: '09:30 AM',
    title: 'Went Online',
    subtitle: 'You are now online and available',
    details: '',
    statusType: 'went_online',
  ),
];

void main() {
  late MockDeliveryDashboardPageBloc mockBloc;

  const DeliveryDashboardState enState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
    isOnline: true,
    partnerStatus: DeliveryPartnerStatusType.online,
    recentActivities: defaultActivities,
  );

  const DeliveryDashboardState taState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
    isOnline: true,
    partnerStatus: DeliveryPartnerStatusType.online,
    localeCode: 'ta',
    recentActivities: defaultActivities,
  );

  setUpAll(() {
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() {
    mockBloc = MockDeliveryDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(enState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryDashboardPage Localization Tests', () {
    testWidgets('renders English UI text by default', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('You are'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('Wallet Balance'), findsOneWidget);
      expect(find.text("Today's Earnings"), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('Order Delivered'), findsOneWidget);
    });

    testWidgets('renders Tamil UI text when locale is Tamil', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('நீங்கள்'), findsOneWidget);
      expect(find.text('ஆன்லைன்'), findsOneWidget);
      expect(find.text('வாலட் இருப்பு'), findsOneWidget);
      expect(find.text('இன்றைய வருமானம்'), findsOneWidget);
      expect(find.text('சமீபத்திய நடவடிக்கைகள்'), findsOneWidget);
      expect(find.text('அறிவிப்புகள்'), findsOneWidget);
    });

    testWidgets('keeps activity titles from data regardless of locale', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('Order Delivered'), findsOneWidget);
      expect(find.text('New Order Received'), findsOneWidget);
      expect(find.text('Went Online'), findsOneWidget);
    });

    test('string lookup falls back to English for unknown locales', () {
      expect(
        DeliveryDashboardStrings.of('walletBalance', 'fr'),
        'Wallet Balance',
      );
      expect(
        DeliveryDashboardStrings.of('recentActivity', 'hi'),
        'Recent Activity',
      );
      expect(
        DeliveryDashboardStrings.of('todaysDeliveries', 'ta'),
        'இன்றைய டெலிவரிகள்',
      );
      expect(
        DeliveryDashboardStrings.of('availableForOrders', 'en'),
        'Available for Orders',
      );
    });
  });
}
