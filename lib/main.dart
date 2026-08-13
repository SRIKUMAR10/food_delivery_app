import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

import 'core/services/i_auth_service.dart';
import 'core/services/auth_service.dart';
import 'core/repositories/i_user_profile_repository.dart';
import 'repositories/firebase_user_profile_repository.dart';
import 'core/repositories/i_order_repository.dart';
import 'repositories/firebase_order_repository.dart';
import 'core/repositories/i_product_repository.dart';
import 'repositories/firebase_product_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/firebase_cart_repository.dart';
import 'repositories/firebase_coupon_repository.dart';
import 'repositories/firebase_favorites_repository.dart';
import 'core/repositories/i_chat_repository.dart';
import 'repositories/firebase_chat_repository.dart';

import 'features/buyer_bloc_architecture/CurvedNavigationBarView/CurvedNavigationBarView.dart';
import 'features/buyer_bloc_architecture/onboarding_page/onboarding_page_UI.dart';
import 'features/buyer_bloc_architecture/Cart Page/cart_page_Bloc.dart';
import 'features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';

import 'features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';
import 'features/seller_bloc_architecture/seller_login_page/seller_login_page_ui.dart';
import 'features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_bloc.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_service.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_ui.dart';
import 'core/utils/app_role_helper.dart';

// Global Role Toggle Switch (Default fallback when no tab session or URL param is present)
const AppRole activeRole = AppRole.delivery;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await FirebaseAppCheck.instance.activate(
      providerWeb: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  } catch (e) {
    debugPrint('AppCheck initialization note: $e');
  }

  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final CartBloc? cartBloc;
  final FavoritesBloc? favoritesBloc;
  final HomePageBloc? homePageBloc;
  final IAuthService? authService;
  final IUserProfileRepository? userProfileRepository;
  final IOrderRepository? orderRepository;
  final IChatRepository? chatRepository;

  const MyApp({
    super.key,
    this.cartBloc,
    this.favoritesBloc,
    this.homePageBloc,
    this.authService,
    this.userProfileRepository,
    this.orderRepository,
    this.chatRepository,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAuthService = authService ?? FirebaseAuthService();
    final effectiveUserProfileRepo =
        userProfileRepository ?? FirebaseUserProfileRepository();
    final effectiveOrderRepo = orderRepository ?? FirebaseOrderRepository();
    final effectiveProductRepo = FirebaseProductRepository();
    final effectiveCategoryRepo = CategoryRepository();
    final effectiveChatRepo = chatRepository ?? FirebaseChatRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthService>.value(value: effectiveAuthService),
        RepositoryProvider<IUserProfileRepository>.value(
          value: effectiveUserProfileRepo,
        ),
        RepositoryProvider<IOrderRepository>.value(value: effectiveOrderRepo),
        RepositoryProvider<IProductRepository>.value(
          value: effectiveProductRepo,
        ),
        RepositoryProvider<CategoryRepository>.value(
          value: effectiveCategoryRepo,
        ),
        RepositoryProvider<IChatRepository>.value(value: effectiveChatRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          if (cartBloc != null)
            BlocProvider<CartBloc>.value(value: cartBloc!)
          else
            BlocProvider<CartBloc>(
              create: (context) => CartBloc(
                cartRepository: FirebaseCartRepository(),
                couponRepository: FirebaseCouponRepository(),
                productRepository: effectiveProductRepo,
                authService: effectiveAuthService,
              ),
            ),
          if (favoritesBloc != null)
            BlocProvider<FavoritesBloc>.value(value: favoritesBloc!)
          else
            BlocProvider<FavoritesBloc>(
              create: (context) => FavoritesBloc(
                favoritesRepository: FirebaseFavoritesRepository(),
                authService: effectiveAuthService,
              ),
            ),
          if (homePageBloc != null)
            BlocProvider<HomePageBloc>.value(value: homePageBloc!)
          else
            BlocProvider<HomePageBloc>(
              create: (context) => HomePageBloc(
                productRepository: effectiveProductRepo,
                categoryRepository: effectiveCategoryRepo,
              )..add(const HomePageStarted()),
            ),
        ],
        child: MaterialApp(
          title: 'FoodGo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFFE52121),
            scaffoldBackgroundColor: const Color(0xFFFBF5F5),
            useMaterial3: true,
          ),
          home: _getHomeWidget(),
          routes: {
            '/sellerlogin': (context) => const SellerLoginPageUI(),
            '/sellerDashboard': (context) =>
                const SellerNavigationBarViewPageUI(),
            '/deliveryLogin': (context) => const DeliveryLoginPage(),
            '/deliveryNavigationBar': (context) =>
                const DeliveryNavigationBarPage(),
            '/deliverySignUp': (context) => const DeliverySignUpPage(),
            '/deliveryForgotPassword': (context) =>
                const DeliveryForgotPasswordPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/deliveryOtpVerification') {
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (context) => DeliveryOtpVerificationPage(
                  verificationId: args['verificationId'] as String? ?? '',
                  name: args['name'] as String? ?? '',
                  phone: args['phone'] as String? ?? '',
                  email: args['email'] as String? ?? '',
                  password: args['password'] as String? ?? '',
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _getHomeWidget() {
    final effectiveRole = getEffectiveAppRole(activeRole);
    switch (effectiveRole) {
      case AppRole.buyer:
        return const OnboardingPage();
      case AppRole.seller:
        return const SellerOnboardPageUI();
      case AppRole.delivery:
        return BlocProvider<DeliveryOnboardingPageBloc>(
          create: (context) => DeliveryOnboardingPageBloc(
            repository: DeliveryOnboardingRepository(),
            service: DeliveryOnboardingService(),
          ),
          child: const DeliveryOnboardingPageUI(),
        );
    }
  }
}
