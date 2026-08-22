import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/services/auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/repositories/firebase_user_profile_repository.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/repositories/firebase_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/repositories/firebase_product_repository.dart';
import 'package:food_delivery_app/repositories/category_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/repositories/firebase_chat_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_repository.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';
import 'package:food_delivery_app/repositories/firebase_seller_profile_repository.dart';
import 'package:food_delivery_app/core/repositories/i_inventory_repository.dart';
import 'package:food_delivery_app/repositories/firebase_inventory_repository.dart';
import 'package:food_delivery_app/core/repositories/i_seller_repository.dart';
import 'package:food_delivery_app/repositories/firebase_seller_repository.dart';
import 'package:food_delivery_app/core/repositories/i_app_settings_repository.dart';
import 'package:food_delivery_app/repositories/firebase_app_settings_repository.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/repositories/firebase_rating_repository.dart';
import 'package:food_delivery_app/core/repositories/i_buyer_notification_repository.dart';
import 'package:food_delivery_app/repositories/firebase_buyer_notification_repository.dart';
import 'package:food_delivery_app/core/repositories/i_seller_notification_repository.dart';
import 'package:food_delivery_app/repositories/firebase_seller_notification_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('SellerNavigationBarViewPageUI Widget Tests', () {
    testWidgets('renders SellerNavigationBarViewPageUI scaffold with MultiRepositoryProvider', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<IAuthService>(create: (_) => FirebaseAuthService()),
            RepositoryProvider<IUserProfileRepository>(create: (_) => FirebaseUserProfileRepository()),
            RepositoryProvider<IOrderRepository>(create: (_) => FirebaseOrderRepository()),
            RepositoryProvider<IProductRepository>(create: (_) => FirebaseProductRepository()),
            RepositoryProvider<CategoryRepository>(create: (_) => CategoryRepository()),
            RepositoryProvider<IChatRepository>(create: (_) => FirebaseChatRepository()),
            RepositoryProvider<SellerDashboardRepository>(create: (_) => FirebaseSellerDashboardRepository()),
            RepositoryProvider<ISellerProfileRepository>(create: (_) => FirebaseSellerProfileRepository()),
            RepositoryProvider<IInventoryRepository>(create: (_) => FirebaseInventoryRepository()),
            RepositoryProvider<ISellerRepository>(create: (_) => FirebaseSellerRepository()),
            RepositoryProvider<IAppSettingsRepository>(create: (_) => FirebaseAppSettingsRepository()),
            RepositoryProvider<IRatingRepository>(create: (_) => FirebaseRatingRepository()),
            RepositoryProvider<IBuyerNotificationRepository>(create: (_) => FirebaseBuyerNotificationRepository()),
            RepositoryProvider<ISellerNotificationRepository>(create: (_) => FirebaseSellerNotificationRepository()),
          ],
          child: const MaterialApp(
            home: SellerNavigationBarViewPageUI(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SellerNavigationBarViewPageUI), findsOneWidget);
    });
  });
}


