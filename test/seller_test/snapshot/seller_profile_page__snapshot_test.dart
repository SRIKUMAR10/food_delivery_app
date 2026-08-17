import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

class MockSellerProfilePageBloc extends Mock implements SellerProfilePageBloc {}

final _validPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPj/HwADBwIAMCbHYQAAAABJRU5ErkJggg==',
);

void main() {
  group('Seller Profile Snapshot Tests', () {
    late MockSellerProfilePageBloc mockBloc;

    setUp(() {
      mockBloc = MockSellerProfilePageBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'Royal Diner',
        ownerName: 'Chef Ramesh',
        restaurantDescription: 'Best Biryanis & Grills',
        email: 'ramesh@royaldiner.com',
        phone: '+91 9876543210',
        address: '45 Anna Salai, Chennai',
        profileImageUrl: '',
        coverImageUrl: '',
        localImageBytes: _validPng,
        localCoverBytes: _validPng,
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
        verificationStatus: 'verified',
        isOpen: true,
        isAcceptingOrders: true,
        deliveryRadius: 10.0,
        minimumOrderValue: 150.0,
        estimatedPrepTimeMinutes: 20,
        cuisines: const ['South Indian', 'Biryani'],
        openingHours: '09:00 AM',
        closingTime: '11:00 PM',
        weeklyHoliday: const ['Monday'],
        deliveryFeeSettings: const DeliveryFeeSettings(baseFee: 20, perKmFee: 5, freeDeliveryThreshold: 500),
      ));
    });

    testWidgets('ProfileContent matches full component snapshot', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerProfilePageBloc>.value(
            value: mockBloc,
            child: const Scaffold(body: ProfileContent()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all modular sections and quick actions are rendered
      expect(find.text('Restaurant Profile'), findsOneWidget);
      expect(find.text('Royal Diner'), findsWidgets);
      expect(find.text('Accepting Orders (Rush Mode)'), findsOneWidget);
      expect(find.text('Store Status'), findsOneWidget);
      expect(find.text('Branding & Description'), findsOneWidget);
      expect(find.text('Location & Delivery Logistics'), findsOneWidget);
      expect(find.text('Cuisine Categories'), findsOneWidget);
      expect(find.text('Operating Hours & Schedule'), findsOneWidget);
      expect(find.text('Store Management & Operations'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Bank Details'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
