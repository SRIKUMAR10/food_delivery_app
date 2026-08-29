import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_auth_shared/onboarding_back_handler.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_verification_form_page.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_logistics_alerts_page.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_store_launch_page.dart';

class MockSellerStoreDetailsBloc extends Mock implements SellerStoreDetailsBloc {}
class MockBusinessHoursBloc extends Mock implements BusinessHoursBloc {}
class MockSellerProfilePageBloc extends Mock implements SellerProfilePageBloc {}
class MockMenuCategoryManagementBloc extends Mock implements MenuCategoryManagementBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Unified Step 1 to Step 8: Onboarding Wizard & Validation Test Suite', () {
    late MockSellerStoreDetailsBloc mockStoreDetailsBloc;
    late MockBusinessHoursBloc mockBusinessHoursBloc;
    late MockSellerProfilePageBloc mockProfileBloc;
    late MockMenuCategoryManagementBloc mockMenuCategoryBloc;

    setUp(() {
      mockStoreDetailsBloc = MockSellerStoreDetailsBloc();
      mockBusinessHoursBloc = MockBusinessHoursBloc();
      mockProfileBloc = MockSellerProfilePageBloc();
      mockMenuCategoryBloc = MockMenuCategoryManagementBloc();

      when(() => mockStoreDetailsBloc.close()).thenAnswer((_) async {});
      when(() => mockBusinessHoursBloc.close()).thenAnswer((_) async {});
      when(() => mockProfileBloc.close()).thenAnswer((_) async {});
      when(() => mockMenuCategoryBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('OnboardingBackHandler shows exit confirmation pop-up modal correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));

      bool? userResponse;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  userResponse = await OnboardingBackHandler.showExitConfirmationDialog(ctx);
                },
                child: const Text('Trigger Back'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Back'));
      await tester.pumpAndSettle();

      // Verify exit confirmation pop-up is shown
      expect(find.text('Exit Store Setup?'), findsOneWidget);
      expect(find.text('Stay & Continue'), findsOneWidget);
      expect(find.text('Save & Exit'), findsOneWidget);

      // Tap Stay & Continue
      await tester.tap(find.text('Stay & Continue'));
      await tester.pumpAndSettle();

      expect(userResponse, isFalse);
      expect(find.text('Exit Store Setup?'), findsNothing);
    });

    testWidgets('Step 2: SellerStoreDetailsPage validates empty restaurant name before continuing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      final invalidState = SellerStoreDetailsLoaded(
        restaurantName: '', // empty!
        address: '123 Food Street',
        phone: '+91 9876543210',
        openingHours: '09:00 AM - 10:00 PM',
        deliveryTime: '30 mins',
        deliveryArea: 'Area 1',
        gstNumber: '',
        fssaiNumber: '10019042000001',
        isOnline: true,
        gstPercentage: 5.0,
        minimumOrderValue: 100.0,
        packagingCharges: 20.0,
        bankAccountNumber: '1234567890',
        bankName: 'HDFC Bank',
        panNumber: 'ABCDE1234F',
        fssaiExpiryDate: '2028-12-31',
        isTaxIncludedInPrice: true,
        invoicePrefix: 'INV-',
        autoAcceptOrders: false,
        prepBufferTimeMinutes: 15,
        maxActiveOrdersLimit: 20,
        allowScheduledOrders: true,
        allowSpecialInstructions: true,
        cancellationWindowMinutes: 2,
      );

      when(() => mockStoreDetailsBloc.state).thenReturn(invalidState);
      when(() => mockStoreDetailsBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerStoreDetailsBloc>.value(
            value: mockStoreDetailsBloc,
            child: const Scaffold(
              body: StoreDetailsContent(isOnboardingFlow: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Save & Continue
      await tester.tap(find.byKey(const ValueKey('continue_to_business_hours_btn')));
      await tester.pumpAndSettle();

      // Should show validation snackbar error
      expect(find.text('Please enter Restaurant/Store Name before proceeding.'), findsOneWidget);
    });

    testWidgets('Step 3: BusinessHoursPage validates at least 1 open day before continuing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      final allClosedState = BusinessHoursLoaded(
        schedule: [
          BusinessDayModel(dayOfWeek: 'Monday', openTime: '09:00 AM', closeTime: '10:00 PM', isOpen: false),
          BusinessDayModel(dayOfWeek: 'Tuesday', openTime: '09:00 AM', closeTime: '10:00 PM', isOpen: false),
        ],
        isEmergencyClosed: false,
      );

      when(() => mockBusinessHoursBloc.state).thenReturn(allClosedState);
      when(() => mockBusinessHoursBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BusinessHoursBloc>.value(
            value: mockBusinessHoursBloc,
            child: const BusinessHoursView(sellerId: 'test_seller', isOnboardingFlow: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Save & Continue
      await tester.tap(find.byKey(const ValueKey('continue_to_profile_live_btn')));
      await tester.pumpAndSettle();

      // Should show validation snackbar error
      expect(find.text('Please enable at least 1 operating day for your store before proceeding.'), findsOneWidget);
    });

    testWidgets('Step 4: SellerProfilePageUI validates store name before continuing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      final emptyStoreNameState = ProfileLoaded(
        storeName: '',
        ownerName: 'Chef Ramesh',
        email: 'royal@biryani.com',
        phone: '+91 9876543210',
        profileImageUrl: '',
        coverImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
        isOpen: true,
        isAcceptingOrders: true,
        deliveryRadius: 10.0,
        deliveryFeeSettings: const DeliveryFeeSettings(),
      );

      when(() => mockProfileBloc.state).thenReturn(emptyStoreNameState);
      when(() => mockProfileBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerProfilePageBloc>.value(
            value: mockProfileBloc,
            child: const Scaffold(body: ProfileContent(isOnboardingFlow: true)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Save & Continue
      await tester.tap(find.byKey(const ValueKey('continue_to_menu_categories_btn')));
      await tester.pumpAndSettle();

      // Should show validation snackbar error
      expect(find.text('Please provide your Store Name before proceeding.'), findsOneWidget);
    });

    testWidgets('Step 5: MenuCategoryManagementPage validates at least 1 category selected', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      final noSelectedCatState = MenuCategoryManagementLoaded(
        categories: [
          MenuCategoryModel(id: '1', name: 'Fried Chicken', isSelected: false, sortOrder: 0),
          MenuCategoryModel(id: '2', name: 'Burgers', isSelected: false, sortOrder: 1),
        ],
        hasUnsavedChanges: false,
      );

      when(() => mockMenuCategoryBloc.state).thenReturn(noSelectedCatState);
      when(() => mockMenuCategoryBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MenuCategoryManagementBloc>.value(
            value: mockMenuCategoryBloc,
            child: const MenuCategoryManagementView(sellerId: 'test_seller', isOnboardingFlow: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Save & Continue
      await tester.tap(find.byKey(const ValueKey('continue_to_bank_setup_btn')));
      await tester.pumpAndSettle();

      // Should show validation snackbar error
      expect(find.text('Please select at least 1 menu category for your store before proceeding.'), findsOneWidget);
    });

    testWidgets('Step 7: SellerLogisticsAlertsPage renders logistics and audio settings correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      await tester.pumpWidget(
        const MaterialApp(
          home: SellerLogisticsAlertsPage(
            sellerId: 'test_seller',
            isOnboardingFlow: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Delivery Logistics Rules'), findsOneWidget);
      expect(find.text('Delivery Radius'), findsOneWidget);
      expect(find.text('Auto-Accept Incoming Orders'), findsOneWidget);
      expect(find.text('Audio Alert & Chime Preferences'), findsOneWidget);
      expect(find.text('Order Alert Ringtone Chime'), findsOneWidget);
      expect(find.byKey(const ValueKey('continue_to_store_launch_btn')), findsOneWidget);
    });

    testWidgets('Step 8: SellerStoreLaunchPage renders 100% readiness checklist and 1-Click Launch button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));

      await tester.pumpWidget(
        const MaterialApp(
          home: SellerStoreLaunchPage(
            sellerId: 'test_seller',
            isOnboardingFlow: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('100% READY FOR LAUNCH'), findsOneWidget);
      expect(find.text('Launch Readiness Checklist (8/8 Complete)'), findsOneWidget);
      expect(find.text('Step 1: KYC Legal & Tax Compliance'), findsOneWidget);
      expect(find.text('Step 2: Store Address & Map Coordinates'), findsOneWidget);
      expect(find.text('Step 7: Delivery Logistics & Order Audio Alerts'), findsOneWidget);
      expect(find.byKey(const ValueKey('launch_store_live_btn')), findsOneWidget);
    });
  });
}
