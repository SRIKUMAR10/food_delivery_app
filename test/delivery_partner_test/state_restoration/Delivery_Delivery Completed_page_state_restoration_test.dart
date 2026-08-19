import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_event.dart';
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
  late DeliveryCompletedBloc bloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockRepository = MockDeliveryCompletedRepository();
    mockService = MockDeliveryCompletedService();
    registerFallbackValue('#ORD12345');

    when(
      () => mockRepository.fetchCompletedOrderDetails(any()),
    ).thenAnswer((_) async => mockModel);
    when(
      () => mockRepository.completeOrder(any()),
    ).thenAnswer((_) async => mockModel);
  });

  DeliveryCompletedBloc createBloc() {
    return DeliveryCompletedBloc(
      repository: mockRepository,
      service: mockService,
    );
  }

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(
        body: DeliveryCompletedPage(orderId: '#ORD12345', bloc: bloc),
      ),
    );
  }

  group('DeliveryCompletedPage State Restoration Tests', () {
    testWidgets('preserves loaded completed details across a widget rebuild', (
      tester,
    ) async {
      setDesktopSize(tester);
      bloc = createBloc();
      await tester.pump();
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD12345'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.text('Arun Kumar'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.text('Arun Kumar'), findsOneWidget);
      expect(find.text('Excellent (5.0/5)'), findsOneWidget);
    });

    testWidgets('preserves completed status across a widget rebuild', (
      tester,
    ) async {
      setDesktopSize(tester);
      bloc = createBloc();
      await tester.pump();
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD12345'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.byKey(const Key('dp_completed_complete_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Order Completed'), findsWidgets);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Order Completed'), findsWidgets);
      expect(
        find.byKey(const Key('dp_completed_complete_button')),
        findsNothing,
      );
    });

    testWidgets('does not refetch when the same bloc is reused', (
      tester,
    ) async {
      setDesktopSize(tester);
      bloc = createBloc();
      await tester.pump();
      bloc.add(const FetchCompletedOrderDetailsEvent('#ORD12345'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      verify(() => mockRepository.fetchCompletedOrderDetails(any())).called(1);
    });
  });
}
