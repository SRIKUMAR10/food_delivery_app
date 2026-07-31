import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_ui.dart';

class MockDeliveryOrderHistoryPageBloc
    extends
        MockBloc<DeliveryOrderHistoryPageEvent, DeliveryOrderHistoryPageState>
    implements DeliveryOrderHistoryPageBloc {}

const order1 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1001',
  customerName: 'Priya Sharma',
  phoneNumber: '9840112233',
  pickupAddress: '42 Anna Salai, Chennai',
  dropAddress: '21 MG Road, Velachery',
  dateLabel: 'May 22, 2025 • 10:30',
  epochSeconds: 1747909800,
  distanceKm: 2.4,
  amount: 486.50,
  status: DeliveryOrderHistoryStatus.completed,
  paymentType: 'COD',
);

const order2 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1002',
  customerName: 'Arun Prakash',
  phoneNumber: '9884499001',
  pickupAddress: '108 Greams Road, Nungambakkam',
  dropAddress: '7 Lake View Road, Adyar',
  dateLabel: 'May 21, 2025 • 11:42',
  epochSeconds: 1747827720,
  distanceKm: 4.1,
  amount: 732.00,
  status: DeliveryOrderHistoryStatus.pending,
  paymentType: 'Online',
);

const allOrders = [order1, order2];

const enState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  orders: allOrders,
  filteredOrders: allOrders,
  pageOrders: allOrders,
  stats: DeliveryOrderHistoryStats(
    totalOrders: 2,
    completedCount: 1,
    cancelledCount: 0,
    pendingCount: 1,
    totalEarnings: 1218.50,
    totalOrdersDelta: 12.5,
    earningsDelta: 18.6,
  ),
  page: 1,
  pageSize: 10,
);

const taState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  localeCode: 'ta',
  orders: allOrders,
  filteredOrders: allOrders,
  pageOrders: allOrders,
  stats: DeliveryOrderHistoryStats(
    totalOrders: 2,
    completedCount: 1,
    cancelledCount: 0,
    pendingCount: 1,
    totalEarnings: 1218.50,
    totalOrdersDelta: 12.5,
    earningsDelta: 18.6,
  ),
  page: 1,
  pageSize: 10,
);

void main() {
  late MockDeliveryOrderHistoryPageBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const DeliveryOrderHistoryInitEvent());
    registerFallbackValue(const DeliveryOrderHistoryRefreshEvent());
    registerFallbackValue(const DeliveryOrderHistorySearchChangedEvent(''));
    registerFallbackValue(
      const DeliveryOrderHistoryStatusFilterChangedEvent(
        DeliveryOrderHistoryStatusFilter.all,
      ),
    );
    registerFallbackValue(
      const DeliveryOrderHistoryPaymentFilterChangedEvent(
        DeliveryOrderHistoryPaymentFilter.all,
      ),
    );
    registerFallbackValue(const DeliveryOrderHistoryPageChangedEvent(1));
    registerFallbackValue(const DeliveryOrderHistoryPageSizeChangedEvent(10));
    registerFallbackValue(const DeliveryOrderHistoryToggleSidebarEvent());
    registerFallbackValue(const DeliveryOrderHistoryDateRangeChangedEvent());
  });

  setUp(() {
    mockBloc = MockDeliveryOrderHistoryPageBloc();
    when(() => mockBloc.state).thenReturn(enState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C1017),
      ),
      home: Scaffold(body: DeliveryOrderHistoryPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrderHistoryPage Localization Tests', () {
    testWidgets('renders English UI text by default', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Order History'), findsOneWidget);
      expect(
        find.text('Track and manage all your delivery orders'),
        findsOneWidget,
      );
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Cancelled'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('History'), findsAtLeast(1));
      expect(find.text('Deliver More Earn More'), findsOneWidget);
      expect(find.text('View Incentives'), findsOneWidget);
      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('renders Tamil UI text when locale is Tamil', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('ஆர்டர் வரலாறு'), findsOneWidget);
      expect(
        find.text(
          'உங்கள் அனைத்து டெலிவரி ஆர்டர்களையும் கண்காணித்து நிர்வகிக்கவும்',
        ),
        findsOneWidget,
      );
      expect(find.text('மொத்த ஆர்டர்கள்'), findsOneWidget);
      expect(find.text('நிறைவு'), findsWidgets);
      expect(find.text('ரத்து'), findsWidgets);
      expect(find.text('நிலுவையில்'), findsWidgets);
      expect(find.text('மொத்த வருவாய்'), findsOneWidget);
      expect(find.text('டெலிவரி பார்ட்னர்'), findsOneWidget);
      expect(find.text('வரலாறு'), findsAtLeast(1));
      expect(
        find.text('அதிகம் டெலிவரி செய்யுங்கள் அதிகம் சம்பாதியுங்கள்'),
        findsOneWidget,
      );
      expect(find.text('ஊக்கத்தொகைகளை பார்க்க'), findsOneWidget);
      expect(find.text('வடிகட்டிகள்'), findsOneWidget);
    });

    testWidgets('order status badges show translated labels in Tamil', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('நிறைவு'), findsAtLeast(1));
      expect(find.text('நிலுவையில்'), findsAtLeast(1));
    });

    testWidgets('sidebar navigation items are translated in Tamil', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('டாஷ்போர்டு'), findsOneWidget);
      expect(find.text('ஆர்டர்கள்'), findsOneWidget);
      expect(find.text('வருவாய்'), findsOneWidget);
      expect(find.text('ஊக்கத்தொகை'), findsOneWidget);
      expect(find.text('வாலட்'), findsOneWidget);
      expect(find.text('சுயவிவரம்'), findsOneWidget);
      expect(find.text('வாகனம்'), findsOneWidget);
      expect(find.text('ஆவணங்கள்'), findsOneWidget);
      expect(find.text('அமைப்புகள்'), findsOneWidget);
      expect(find.text('உதவி & ஆதரவு'), findsOneWidget);
    });

    test('string lookup falls back to English for unknown locales', () {
      expect(DeliveryOrderHistoryStrings.of('title', 'fr'), 'Order History');
      expect(
        DeliveryOrderHistoryStrings.of('subtitle', 'hi'),
        'Track and manage all your delivery orders',
      );
      expect(DeliveryOrderHistoryStrings.of('navHistory', 'de'), 'History');
      expect(
        DeliveryOrderHistoryStrings.of('statEarnings', 'ja'),
        'Total Earnings',
      );
      expect(
        DeliveryOrderHistoryStrings.of('noResultsTitle', 'es'),
        'No orders found',
      );
    });
  });
}
