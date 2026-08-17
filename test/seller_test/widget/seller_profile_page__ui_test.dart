import 'dart:convert';
import 'dart:typed_data';
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
  group('SellerProfilePageUI Widget Tests', () {
    late MockSellerProfilePageBloc mockBloc;

    setUp(() {
      mockBloc = MockSellerProfilePageBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('displays Skeleton Loader when ProfileLoading', (tester) async {
      when(() => mockBloc.state).thenReturn(ProfileLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerProfilePageBloc>.value(
            value: mockBloc,
            child: const Scaffold(body: ProfileContent()),
          ),
        ),
      );

      expect(find.byType(ProfileSkeletonLoader), findsOneWidget);
    });

    testWidgets('renders all restaurant profile sections and real-time operational switches', (tester) async {
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'Royal Biryani Hub',
        ownerName: 'Chef Ramesh',
        restaurantDescription: 'Authentic Hyderabadi Dum Biryani & Kebabs',
        email: 'ramesh@royalbiryani.com',
        phone: '+91 9876543210',
        address: '123 Food Street, T. Nagar, Chennai',
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
        deliveryRadius: 15.0,
        minimumOrderValue: 200.0,
        estimatedPrepTimeMinutes: 25,
        cuisines: const ['Biryani', 'South Indian', 'Fast Food'],
        openingHours: '10:00 AM',
        closingTime: '11:00 PM',
        weeklyHoliday: const ['Tuesday'],
        deliveryFeeSettings: const DeliveryFeeSettings(
          baseFee: 25.0,
          perKmFee: 5.0,
          freeDeliveryThreshold: 500.0,
        ),
      ));

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

      // Check Header & Identity
      expect(find.text('Restaurant Profile'), findsOneWidget);
      expect(find.text('Royal Biryani Hub'), findsWidgets);
      expect(find.text('Owner: Chef Ramesh'), findsOneWidget);
      expect(find.text('ramesh@royalbiryani.com'), findsOneWidget);

      // Check Operational Controls
      expect(find.text('Accepting Orders (Rush Mode)'), findsOneWidget);
      expect(find.text('Store Status'), findsOneWidget);
      expect(find.text('Open for Customers'), findsOneWidget);

      // Check Section Cards
      expect(find.text('Branding & Description'), findsOneWidget);
      expect(find.text('Location & Delivery Logistics'), findsOneWidget);
      expect(find.text('Cuisine Categories'), findsOneWidget);
      expect(find.text('Operating Hours & Schedule'), findsOneWidget);

      // Check Cuisines Tags
      expect(find.text('Biryani'), findsWidgets);
      expect(find.text('South Indian'), findsWidgets);

      // Check Menu Grid
      expect(find.text('Store Management & Operations'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Bank Details'), findsOneWidget);
      expect(find.text('Promotions & Coupons'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('shows Error state with retry button when ProfileError', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileError('Network connection failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerProfilePageBloc>.value(
            value: mockBloc,
            child: const Scaffold(body: ProfileContent()),
          ),
        ),
      );

      expect(find.text('Error: Network connection failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
