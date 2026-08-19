import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';

import '../../font_loader_helper.dart';

class MockPickupConfirmationRepository extends Mock
    implements DeliveryPickupConfirmationRepositoryBase {}

class MockPickupConfirmationService extends Mock
    implements DeliveryPickupConfirmationServiceBase {}

const mockModel = PickupConfirmationModel(
  orderId: '#ORD12345',
  pickupLocationName: 'Green Mart',
  pickupAddress: '24, Anna Salai, Chennai - 600002',
  pickupContactName: 'Priya Sharma',
  pickupContactPhone: '+919876543210',
  pickupInstructions: 'Show the order code at the counter.',
  customerName: 'Mike Johnson',
  customerAddress: '12, Beach Road, Chennai - 600001',
  customerPhone: '+919876543211',
  pickupTime: '12:05 PM',
  paymentType: 'Cash on Delivery',
  orderAmount: 486.50,
  walletBalance: 2450.00,
);

void main() {
  late MockPickupConfirmationRepository mockRepository;
  late MockPickupConfirmationService mockService;
  late DeliveryPickupConfirmationPageBloc bloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockRepository = MockPickupConfirmationRepository();
    mockService = MockPickupConfirmationService();
    registerFallbackValue('#ORD12345');

    when(
      () => mockRepository.fetchPickupConfirmationDetails(any()),
    ).thenAnswer((_) async => mockModel);
    when(
      () => mockRepository.startDelivery(any()),
    ).thenAnswer((_) async => mockModel);
  });

  DeliveryPickupConfirmationPageBloc createBloc() {
    return DeliveryPickupConfirmationPageBloc(
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
      onGenerateRoute: (settings) {
        if (settings.name == '/deliveryNavigationScreen') {
          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: SizedBox()),
          );
        }
        return null;
      },
      home: Scaffold(
        body: DeliveryPickupConfirmationPage(orderId: '#ORD12345', bloc: bloc),
      ),
    );
  }

  group('DeliveryPickupConfirmationPage State Restoration Tests', () {
    testWidgets('preserves loaded pickup details across a widget rebuild', (
      tester,
    ) async {
      setDesktopSize(tester);
      bloc = createBloc();
      await tester.pump();
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD12345'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('Green Mart'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('Green Mart'), findsOneWidget);
      expect(find.text('Mike Johnson'), findsOneWidget);
    });

    testWidgets('preserves delivery started status across a widget rebuild', (
      tester,
    ) async {
      setDesktopSize(tester);
      bloc = createBloc();
      await tester.pump();
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD12345'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.byKey(const Key('dp_pickup_start_delivery')));
      await tester.pump();

      expect(find.text('Delivery Started'), findsWidgets);

      await tester.pump(const Duration(milliseconds: 400));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Delivery Started'), findsWidgets);
      expect(find.text('Start Delivery'), findsNothing);
    });

    testWidgets('does not refetch when the same bloc is reused', (
      tester,
    ) async {
      setDesktopSize(tester);
      bloc = createBloc();
      await tester.pump();
      bloc.add(const FetchPickupConfirmationDetailsEvent('#ORD12345'));

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

      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      verify(
        () => mockRepository.fetchPickupConfirmationDetails(any()),
      ).called(1);
    });
  });
}
