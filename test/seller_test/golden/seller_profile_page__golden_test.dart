import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';
import '../../font_loader_helper.dart';

class MockSellerProfilePageBloc extends Mock implements SellerProfilePageBloc {}

void main() {
  setUpAll(overrideFontAssetLoading);

  group('SellerProfilePageUI Golden Tests', () {
    late MockSellerProfilePageBloc mockBloc;

    setUp(() {
      mockBloc = MockSellerProfilePageBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('SellerProfilePageUI matches golden file', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        ProfileLoaded(
          storeName: 'Royal Biryani Hub',
          ownerName: 'Chef Ramesh',
          restaurantDescription: 'Authentic Hyderabadi Dum Biryani & Kebabs',
          email: 'ramesh@royalbiryani.com',
          phone: '+91 9876543210',
          address: '123 Food Street, T. Nagar, Chennai',
          profileImageUrl: '',
          coverImageUrl: '',
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
        ),
      );

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

      await expectLater(
        find.byType(ProfileContent),
        matchesGoldenFile('goldens/seller_profile_loaded.png'),
      );
    });
  });
}
