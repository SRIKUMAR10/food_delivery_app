import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';

import '../../font_loader_helper.dart';
import '../helpers/delivery_test_utils.dart';

class MockDeliveryCompletedRepository extends Mock
    implements DeliveryCompletedRepositoryBase {}

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

  setUpAll(() {
    overrideFontAssetLoading();
    setupDeliveryTestChannels();
  });

  setUp(() {
    mockRepository = MockDeliveryCompletedRepository();

    when(
      () => mockRepository.watchCompletedOrder('#ORD12345'),
    ).thenAnswer((_) => Stream.value(mockModel));
    when(
      () => mockRepository.fetchCompletedOrderDetails('#ORD12345'),
    ).thenAnswer((_) async => mockModel);
    when(
      () => mockRepository.completeOrder('#ORD12345'),
    ).thenAnswer((_) async => mockModel);
  });

  group('Delivery Completed Page Integration Flow', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryCompletedPage(
            orderId: '#ORD12345',
            repository: mockRepository,
            service: DeliveryCompletedService(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('loads the completed order details end-to-end', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.text('#ORD12345'), findsWidgets);
      expect(find.text('Arun Kumar'), findsOneWidget);
      expect(find.text('12, Beach Road, Chennai - 600001'), findsOneWidget);
      expect(find.text('Paid Successfully'), findsOneWidget);
      expect(find.text('UPI • Google Pay'), findsOneWidget);
      expect(find.text('Excellent (5.0/5)'), findsOneWidget);
    });

    testWidgets('progresses from success state to completed state', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      final completeButton = find.byKey(
        const Key('dp_completed_complete_button'),
      );
      expect(completeButton, findsOneWidget);

      await tester.tap(completeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Order Completed'), findsWidgets);
      expect(
        find.byKey(const Key('dp_completed_complete_button')),
        findsNothing,
      );
      expect(find.byKey(const Key('dp_completed_return_home')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispatches rating and proof upload without crashing', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      await tester.ensureVisible(find.byKey(const Key('dp_completed_star_4')));
      await tester.tap(find.byKey(const Key('dp_completed_star_4')));
      await tester.pump();
      expect(find.text('4/5'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const Key('dp_completed_upload_proof')),
      );
      await tester.tap(find.byKey(const Key('dp_completed_upload_proof')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Proof uploaded'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}