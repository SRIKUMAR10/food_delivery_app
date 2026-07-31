import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryCompletedRepository extends Mock
    implements DeliveryCompletedRepositoryBase {}

class MockDeliveryCompletedService extends Mock
    implements DeliveryCompletedServiceBase {}

const mockModel = DeliveryCompletedModel(
  orderId: '#ORD12345',
  walletBalance: 2450.00,
  partnerName: 'Ravi Kumar',
  partnerVehicleNo: 'TN 01 AB 1234',
  customerName: 'Arun Kumar',
  deliveryAddress: '12, Beach Road, Chennai - 600001',
  timeTaken: '32 min',
  distanceCovered: 5.6,
  paymentStatus: 'Paid Successfully',
  paymentMethod: 'UPI • Google Pay',
  customerRating: 5.0,
  deliveryEarnings: 120.00,
  completedAt: 'Today, 4:15 PM',
);

void main() {
  late MockDeliveryCompletedRepository mockRepository;
  late MockDeliveryCompletedService mockService;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockRepository = MockDeliveryCompletedRepository();
    mockService = MockDeliveryCompletedService();
    registerFallbackValue('#ORD12345');
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(
        body: DeliveryCompletedPage(
          orderId: '#ORD12345',
          repository: mockRepository,
          service: mockService,
        ),
      ),
    );
  }

  group('DeliveryCompletedPage Error Handling Tests', () {
    testWidgets('shows fallback error UI when fetch fails', (tester) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.fetchCompletedOrderDetails(any()),
      ).thenThrow(Exception('Server unreachable'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_completed_error')), findsOneWidget);
      expect(find.textContaining('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_completed_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the completed order', (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.fetchCompletedOrderDetails(any())).thenAnswer((
        _,
      ) async {
        calls++;
        if (calls == 1) {
          throw Exception('Temporary failure');
        }
        return mockModel;
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_completed_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_completed_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_completed_error')), findsNothing);
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.text('Arun Kumar'), findsOneWidget);
    });

    testWidgets('shows snackbar and keeps content when completing fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.fetchCompletedOrderDetails(any()),
      ).thenAnswer((_) async => mockModel);
      when(
        () => mockRepository.completeOrder(any()),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.byKey(const Key('dp_completed_complete_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('Network error'), findsOneWidget);
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_hero_card')), findsOneWidget);
    });

    testWidgets('shows empty state when no completed order data exists', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockRepository.fetchCompletedOrderDetails(any())).thenAnswer(
        (_) async => const DeliveryCompletedModel(
          orderId: '',
          walletBalance: 0,
          partnerName: '',
          partnerVehicleNo: '',
          customerName: '',
          deliveryAddress: '',
          timeTaken: '',
          distanceCovered: 0,
          paymentStatus: 'Paid Successfully',
          paymentMethod: '',
          customerRating: 5.0,
          deliveryEarnings: 0,
          completedAt: '',
        ),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_completed_empty')), findsOneWidget);
      expect(find.text('No completed order data'), findsOneWidget);
    });
  });
}
