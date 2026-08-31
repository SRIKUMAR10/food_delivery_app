import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/buyer_bloc_architecture/CurvedNavigationBarView/CurvedNavigationBarView.dart';
import '../../features/buyer_bloc_architecture/onboarding_page/onboarding_page_UI.dart';
import '../../features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_ui.dart';
import '../../features/buyer_bloc_architecture/Cart%20Page/cart_page_UI.dart';
import '../../features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart';
import '../../features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';
import '../../features/seller_bloc_architecture/seller_login_page/seller_login_page_ui.dart';
import '../../features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';
import '../../features/seller_bloc_architecture/seller_profile_page/seller_verification_form_page.dart';
import '../../features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__ui.dart';
import '../../features/seller_bloc_architecture/business_hours_page_/business_hours_page_ui.dart';
import '../../features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';
import '../../features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_ui.dart';
import '../../features/seller_bloc_architecture/seller_payment_page/seller_payment_page_ui.dart';
import '../../features/seller_bloc_architecture/seller_setting_page/seller_logistics_alerts_page.dart';
import '../../features/seller_bloc_architecture/seller_dashboard_page/seller_store_launch_page.dart';
import '../../features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Pickup Confirmation_page/Delivery_Pickup Confirmation_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Navigation Screen_page/Delivery_Navigation Screen_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Delivery Completed_page/Delivery_Delivery Completed_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_ui.dart';
import '../../features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_ui.dart';

/// Centralized Application Router with Type-Safe Deep Linking & Navigation
class AppRouter {
  AppRouter._();

  // Route Names
  static const String initial = '/';
  
  // Buyer Routes
  static const String buyerHome = '/buyerHome';
  static const String buyerLogin = '/buyerLogin';
  static const String buyerOnboarding = '/buyerOnboarding';
  static const String buyerCart = '/buyerCart';
  static const String trackOrder = '/trackOrder';

  // Seller Routes
  static const String sellerLogin = '/sellerLogin';
  static const String login = '/login';
  static const String sellerSignUp = '/sellerSignUp';
  static const String sellerOnboarding = '/sellerOnboarding';
  static const String sellerDashboard = '/sellerDashboard';
  static const String sellerVerificationForm = '/sellerVerificationForm';
  static const String sellerStoreDetails = '/sellerStoreDetails';
  static const businessHours = '/businessHours';
  static const String sellerProfile = '/sellerProfile';
  static const String menuCategories = '/menuCategories';
  static const String sellerPayment = '/sellerPayment';
  static const String sellerLogisticsAlerts = '/sellerLogisticsAlerts';
  static const String sellerStoreLaunch = '/sellerStoreLaunch';

  // Delivery Partner Routes
  static const String deliveryLogin = '/deliveryLogin';
  static const String deliverySignUp = '/deliverySignUp';
  static const String deliveryForgotPassword = '/deliveryForgotPassword';
  static const String deliveryNavigationBar = '/deliveryNavigationBar';
  static const String deliveryIncomingOrder = '/deliveryIncomingOrder';
  static const String deliveryPickupConfirmation = '/deliveryPickupConfirmation';
  static const String deliveryNavigationScreen = '/deliveryNavigationScreen';
  static const String deliveryOrderDetails = '/deliveryOrderDetails';
  static const String deliveryCompleted = '/deliveryCompleted';
  static const String deliveryOtpVerification = '/deliveryOtpVerification';
  static const String deliveryOnboardingVerification = '/deliveryOnboardingVerification';
  static const String deliveryChat = '/deliveryChat';

  /// Generates type-safe MaterialPageRoutes for all screens with dynamic argument extraction.
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    final path = uri.path;
    final queryParams = uri.queryParameters;
    final dynamic rawArgs = settings.arguments;
    final Map<String, dynamic> args = (rawArgs is Map<String, dynamic>)
        ? rawArgs
        : (queryParams.isNotEmpty ? queryParams : {});

    switch (path) {
      // Buyer Navigation
      case buyerHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CurvedNavigationBarView(),
        );
      case buyerLogin:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BuyerLoginPageUI(),
        );
      case buyerOnboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingPage(),
        );
      case buyerCart:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CartPageUI(),
        );
      case trackOrder:
        final orderId = (args['orderId'] as String?) ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => TrackOrderPageUI(orderId: orderId),
        );

      // Seller Navigation
      case sellerLogin:
      case '/sellerlogin':
      case '/login':
      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SellerLoginPageUI(),
        );
      case sellerSignUp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SellerSignUpPageUI(),
        );
      case sellerOnboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SellerOnboardPageUI(),
        );
      case sellerDashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SellerNavigationBarViewPageUI(),
        );
      case sellerVerificationForm:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SellerVerificationFormPage(),
        );
      case sellerStoreDetails:
        final isOnboardingFlow = args['isOnboardingFlow'] == true || args['onboarding'] == 'true';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SellerStoreDetailsPage(isOnboardingFlow: isOnboardingFlow),
        );
      case businessHours:
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final sellerId = (args['sellerId'] as String?)?.isNotEmpty == true
            ? (args['sellerId'] as String)
            : currentUid;
        final isOnboardingFlow = args['isOnboardingFlow'] == true || args['onboarding'] == 'true';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BusinessHoursPage(sellerId: sellerId, isOnboardingFlow: isOnboardingFlow),
        );
      case sellerProfile:
        final isOnboardingFlow = args['isOnboardingFlow'] == true || args['onboarding'] == 'true';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SellerProfilePageUI(isOnboardingFlow: isOnboardingFlow),
        );
      case menuCategories:
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final sellerId = (args['sellerId'] as String?)?.isNotEmpty == true
            ? (args['sellerId'] as String)
            : currentUid;
        final isOnboardingFlow = args['isOnboardingFlow'] == true || args['onboarding'] == 'true';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MenuCategoryManagementPage(sellerId: sellerId, isOnboardingFlow: isOnboardingFlow),
        );
      case sellerPayment:
        final isOnboardingFlow = args['isOnboardingFlow'] == true || args['onboarding'] == 'true';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SellerPaymentPageUI(isOnboardingFlow: isOnboardingFlow),
        );
      case sellerLogisticsAlerts:
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final sellerId = (args['sellerId'] as String?)?.isNotEmpty == true
            ? (args['sellerId'] as String)
            : currentUid;
        final isOnboardingFlow = args['isOnboardingFlow'] == true || args['onboarding'] == 'true';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SellerLogisticsAlertsPage(sellerId: sellerId, isOnboardingFlow: isOnboardingFlow),
        );
      case sellerStoreLaunch:
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final sellerId = (args['sellerId'] as String?)?.isNotEmpty == true
            ? (args['sellerId'] as String)
            : currentUid;
        final isOnboardingFlow = args['isOnboardingFlow'] == true || args['onboarding'] == 'true';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SellerStoreLaunchPage(sellerId: sellerId, isOnboardingFlow: isOnboardingFlow),
        );

      // Delivery Partner Navigation
      case deliveryLogin:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DeliveryLoginPage(),
        );
      case deliverySignUp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DeliverySignUpPage(),
        );
      case deliveryForgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DeliveryForgotPasswordPage(),
        );
      case deliveryNavigationBar:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DeliveryNavigationBarPage(),
        );
      case deliveryIncomingOrder:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DeliveryIncomingOrderPageUi(),
        );
      case deliveryPickupConfirmation:
        final orderId = (args['orderId'] as String?) ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DeliveryPickupConfirmationPage(orderId: orderId),
        );
      case deliveryNavigationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DeliveryNavigationScreenPage(
            orderId: args['orderId'] as String?,
            pickupAddress: args['pickupAddress'] as String?,
            dropoffAddress: args['dropoffAddress'] as String?,
            restaurantName: args['restaurantName'] as String?,
            customerName: args['customerName'] as String?,
            destinationLatitude: (args['destinationLatitude'] as num?)?.toDouble(),
            destinationLongitude: (args['destinationLongitude'] as num?)?.toDouble(),
            isStoreRoute: args['isStoreRoute'] as bool?,
          ),
        );
      case deliveryOrderDetails:
        final orderId = (args['orderId'] as String?) ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DeliveryOrderDetailsPageUi(orderId: orderId),
        );
      case deliveryCompleted:
        final orderId = (args['orderId'] as String?) ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DeliveryCompletedPage(orderId: orderId),
        );
      case deliveryOtpVerification:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DeliveryOtpVerificationPage(
            verificationId: (args['verificationId'] as String?) ?? '',
            name: (args['name'] as String?) ?? '',
            phone: (args['phone'] as String?) ?? '',
            email: (args['email'] as String?) ?? '',
            password: (args['password'] as String?) ?? '',
          ),
        );
      case deliveryOnboardingVerification:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DeliveryOnboardingVerificationPage(
            initialFullName: args['fullName'] as String?,
            initialDisplayName: args['displayName'] as String?,
            initialEmail: args['email'] as String?,
            initialPhone: args['phone'] as String?,
            initialAvatarUrl: args['avatarUrl'] as String?,
            initialIsPhoneVerified: args['isPhoneVerified'] == true,
          ),
        );
      case deliveryChat:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DeliveryChatPage(
            orderId: (args['orderId'] as String?) ?? '',
            customerId: (args['customerId'] as String?) ?? '',
            customerName: (args['customerName'] as String?) ?? '',
            customerPhone: args['customerPhone'] as String?,
            sellerId: args['sellerId'] as String?,
            sellerName: args['sellerName'] as String?,
            sellerPhone: args['sellerPhone'] as String?,
            orderTitle: args['orderTitle'] as String?,
            orderTotal: (args['orderTotal'] as num?)?.toDouble(),
            recipientRole: (args['recipientRole'] as String?) ?? 'customer',
          ),
        );

      default:
        return null;
    }
  }

  /// Fallback route when an unknown URI is requested
  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                '404 · Route "${settings.name}" does not exist.',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(sellerLogin);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Return Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
