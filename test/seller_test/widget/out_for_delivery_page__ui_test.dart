import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/widgets/app_google_map_view.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__ui.dart';

class MockOutForDeliveryPageBloc extends Mock
    implements OutForDeliveryPageBloc {}

class MockIChatRepository extends Mock implements IChatRepository {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  late MockOutForDeliveryPageBloc mockBloc;
  late MockIChatRepository mockChatRepo;

  setUp(() {
    mockBloc = MockOutForDeliveryPageBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    mockChatRepo = MockIChatRepository();
    when(() => mockChatRepo.getConversationsForUser(
        any(), isSeller: any(named: 'isSeller')))
        .thenAnswer((_) => Stream.value(const []));
    when(() => mockChatRepo.getConversationsForUser(
        any(), role: any(named: 'role')))
        .thenAnswer((_) => Stream.value(const []));
    when(() => mockChatRepo.getConversationByOrderId(any(),
            userId: any(named: 'userId'), isSeller: any(named: 'isSeller')))
        .thenAnswer((_) async => null);
  });

  Widget buildView() {
    return MaterialApp(
      home: BlocProvider<OutForDeliveryPageBloc>.value(
        value: mockBloc,
        child: const OutForDeliveryView(),
      ),
    );
  }

  Widget buildViewWithChatRepo() {
    return RepositoryProvider<IChatRepository>.value(
      value: mockChatRepo,
      child: buildView(),
    );
  }

  testWidgets('OutForDeliveryView shows loading state', (
    WidgetTester tester,
  ) async {
    when(() => mockBloc.state).thenReturn(OutForDeliveryPageLoading());

    await tester.pumpWidget(buildView());

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  group('Customer & Destination Card', () {
    OutForDeliveryPageLoaded loadedState() {
      return const OutForDeliveryPageLoaded(
        orderId: '1025',
        rider: RiderDetails(
          id: 'rider_1',
          name: 'Raj',
          phone: '+911234567890',
          imageUrl: '',
          rating: 4.8,
        ),
        currentStatus: DeliveryStatus.outForDelivery,
        estimatedTime: '~10 mins',
        distance: '2.4 km away',
        sellerName: 'Guru Kitchen',
        customerName: 'Aarav Patel',
        customerPhone: '+919876543210',
        customerId: 'customer_1',
        deliveryAddress: 'Erode Bus Stand, Erode',
        totalAmount: 784.70,
      );
    }

    testWidgets('renders Call and Chat buttons inside customer card', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(loadedState());

      await tester.pumpWidget(buildView());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Customer & Destination'), findsOneWidget);
      expect(find.text('Aarav Patel'), findsOneWidget);
      expect(find.text('Erode Bus Stand, Erode'), findsOneWidget);
      expect(find.text('₹784.70'), findsOneWidget);
      expect(find.byTooltip('Call Customer'), findsOneWidget);
      expect(find.byTooltip('Chat with Customer'), findsOneWidget);
    });

    testWidgets('tapping Call shows snackbar when phone is unavailable', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const OutForDeliveryPageLoaded(
          orderId: '1025',
          rider: RiderDetails(
            id: 'rider_1',
            name: 'Raj',
            phone: '+911234567890',
            imageUrl: '',
            rating: 4.8,
          ),
          currentStatus: DeliveryStatus.outForDelivery,
          estimatedTime: '~10 mins',
          distance: '2.4 km away',
          customerName: 'Aarav Patel',
        ),
      );

      await tester.pumpWidget(buildView());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(find.byTooltip('Call Customer'));
      await tester.pump();
      await tester.tap(find.byTooltip('Call Customer'));
      await tester.pump();

      expect(
        find.text('Customer phone number not available'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Call with a phone number does not show snackbar', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(loadedState());

      await tester.pumpWidget(buildView());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(find.byTooltip('Call Customer'));
      await tester.pump();
      await tester.tap(find.byTooltip('Call Customer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Customer phone number not available'),
        findsNothing,
      );
    });

    testWidgets('tapping Chat navigates to ChatSupportPage for the buyer', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(loadedState());

      await tester.pumpWidget(buildViewWithChatRepo());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(find.byTooltip('Chat with Customer'));
      await tester.pump();
      await tester.tap(find.byTooltip('Chat with Customer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ChatSupportPage), findsOneWidget);
    });
  });

  group('Seller Rich Map Widget Tests', () {
    testWidgets('renders ETA chip, speed, distance and fullscreen toggle with seller props', (
      WidgetTester tester,
    ) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 480,
              width: 380,
              child: AppGoogleMapView(
                storeLocation: const LatLng(13.0827, 80.2707),
                storeName: 'Guru Kitchen',
                driverLocation: const LatLng(13.08, 80.272),
                driverHeading: 90.0,
                vehicleType: 'two_wheeler',
                customerLocation: const LatLng(13.05, 80.28),
                customerName: 'Customer',
                isPickedUp: true,
                isFullScreen: false,
                onToggleFullScreen: () {
                  toggleCalled = true;
                },
                showControls: true,
                autoFollowDriver: true,
                bottomBadgeOffset: 12.0,
                progressRatio: 0.82,
                etaText: '~10 mins',
                distanceKm: 2.4,
                driverSpeed: 25.0,
                expectedDeliveryTime: '04:15 PM',
                isArrivingSoon: false,
                isRaining: false,
                weatherAlert: null,
                driverName: 'Raj',
                driverPhone: '+911234567890',
                driverPhotoUrl: '',
                driverVehicleNumber: 'TN33 AB 1234',
                driverRating: 4.8,
                storePhone: '+919876543210',
                storeAddress: 'Bhavani Main Road',
                customerAddress: 'Erode Bus Stand',
                customerNotes: 'Call before arrival',
                onCallDriver: () {},
                onChatDriver: () {},
                onCallStore: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      final fullScreenBtn = find.byWidgetPredicate(
        (w) => w is Tooltip && (w.message?.contains('Full Screen View') ?? false),
      );
      expect(fullScreenBtn, findsOneWidget);
      expect(find.textContaining('Heading to Guru Kitchen'), findsOneWidget);
      expect(find.textContaining('km/h'), findsOneWidget);
      expect(find.textContaining('km away'), findsOneWidget);

      await tester.tap(fullScreenBtn);
      await tester.pump();
      expect(toggleCalled, isTrue);
    });

    testWidgets('shows weather banner and weather control when raining', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 480,
              width: 380,
              child: AppGoogleMapView(
                storeLocation: const LatLng(13.0827, 80.2707),
                isRaining: true,
                weatherAlert: 'Heavy rain expected',
                showControls: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Heavy rain expected'), findsOneWidget);
      expect(find.byTooltip('Weather Alert: ON'), findsOneWidget);
    });

    testWidgets('shows arriving-soon status, idle badge and meter distance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 480,
              width: 380,
              child: AppGoogleMapView(
                storeLocation: const LatLng(13.0827, 80.2707),
                driverLocation: const LatLng(13.0825, 80.271),
                vehicleType: 'two_wheeler',
                isPickedUp: true,
                isArrivingSoon: true,
                distanceKm: 0.3,
                driverSpeed: 0.0,
                showControls: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.textContaining('Arrived at'),
        findsOneWidget,
      );
      expect(find.textContaining('Arrived'), findsWidgets);
    });

    testWidgets('renders Exit Full Screen when expanded', (
      WidgetTester tester,
    ) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 540,
              width: 380,
              child: AppGoogleMapView(
                storeLocation: const LatLng(13.0827, 80.2707),
                driverLocation: const LatLng(13.08, 80.272),
                vehicleType: 'two_wheeler',
                isPickedUp: true,
                isFullScreen: true,
                onToggleFullScreen: () {
                  toggleCalled = true;
                },
                showControls: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      final exitBtn = find.byWidgetPredicate(
        (w) => w is Tooltip && (w.message?.contains('Exit Full Screen') ?? false),
      );
      expect(exitBtn, findsOneWidget);

      await tester.tap(exitBtn);
      await tester.pump();
      expect(toggleCalled, isTrue);
    });
  });
}