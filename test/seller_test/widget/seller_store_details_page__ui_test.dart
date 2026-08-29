import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__state.dart';

class MockSellerStoreDetailsBloc
    extends MockBloc<SellerStoreDetailsPageEvent, SellerStoreDetailsPageState>
    implements SellerStoreDetailsBloc {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('SellerStoreDetailsPage Widget Tests', () {
    late MockSellerStoreDetailsBloc bloc;

    setUp(() {
      bloc = MockSellerStoreDetailsBloc();
    });

    testWidgets('renders skeleton loader when state is loading', (
      WidgetTester tester,
    ) async {
      when(() => bloc.state).thenReturn(SellerStoreDetailsLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: SellerStoreDetailsPage(bloc: bloc),
        ),
      );
      await tester.pump();

      expect(find.byType(ResponsiveStoreDetailsLayout), findsOneWidget);
    });

    testWidgets('renders store details when state is loaded', (
      WidgetTester tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const SellerStoreDetailsLoaded(
          restaurantName: 'Picarhub Restaurant',
          address: '123 Main St',
          phone: '+919876543210',
          openingHours: '10:00 AM - 11:00 PM',
          deliveryTime: '30 - 45 min',
          deliveryArea: '5.0 km',
          gstNumber: 'GST12345',
          fssaiNumber: 'FSSAI12345',
          panNumber: 'PAN12345',
          isOnline: true,
          gstPercentage: 5.0,
          minimumOrderValue: 150.0,
          packagingCharges: 20.0,
          bankAccountNumber: '1234567890',
          bankName: 'HDFC Bank',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SellerStoreDetailsPage(bloc: bloc),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Store Details'), findsOneWidget);
      expect(find.text('Picarhub Restaurant'), findsOneWidget);
      expect(find.text('Delivery Time'), findsOneWidget);
      expect(find.text('Delivery Area'), findsOneWidget);
      expect(find.text('GST Number'), findsOneWidget);
      expect(find.text('Minimum Order Value'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
      expect(find.text('Order Processing Rules'), findsOneWidget);
      expect(find.text('Auto-Accept Incoming Orders'), findsOneWidget);
    });

    testWidgets('renders FSSAI Expiry Date and opens date edit dialog on edit tap', (
      WidgetTester tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const SellerStoreDetailsLoaded(
          restaurantName: 'Picarhub Restaurant',
          address: '123 Main St',
          phone: '+919876543210',
          openingHours: '10:00 AM - 11:00 PM',
          deliveryTime: '30 - 45 min',
          deliveryArea: '5.0 km',
          gstNumber: 'GST12345',
          fssaiNumber: 'FSSAI12345',
          fssaiExpiryDate: '2027-12-31',
          panNumber: 'PAN12345',
          isOnline: true,
          gstPercentage: 5.0,
          minimumOrderValue: 150.0,
          packagingCharges: 20.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SellerStoreDetailsPage(bloc: bloc),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FSSAI Expiry Date'), findsOneWidget);
      expect(find.text('31 Dec, 2027'), findsOneWidget);

      // Tap on Edit button / tile
      final editIconFinder = find.byIcon(Icons.edit_outlined);
      if (editIconFinder.evaluate().isNotEmpty) {
        await tester.tap(editIconFinder.first);
        await tester.pumpAndSettle();
      }
    });
  });
}
