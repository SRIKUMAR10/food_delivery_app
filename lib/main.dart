import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_ui.dart';

import 'features/buyer_bloc_architecture/Cart Page/cart_page_Bloc.dart';
import 'features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'features/buyer_bloc_architecture/onboarding_page/onboarding_page_UI.dart';
import 'features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';
import 'features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';
import 'features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';
import 'features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_repository.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_bloc.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_service.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_repository.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Pickup Confirmation_page/Delivery_Pickup Confirmation_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Delivery Completed_page/Delivery_Delivery Completed_page_ui.dart';
import 'features/Delivery Partner Bloc Architecture/Delivery_Navigation Screen_page/Delivery_Navigation Screen_page_ui.dart';

import 'core/services/i_auth_service.dart';
import 'core/services/auth_service.dart';
import 'core/repositories/i_product_repository.dart';
import 'core/repositories/i_cart_repository.dart';
import 'core/repositories/i_coupon_repository.dart';
import 'core/repositories/i_order_repository.dart';
import 'core/repositories/i_inventory_repository.dart';
import 'repositories/firebase_product_repository.dart';
import 'repositories/firebase_cart_repository.dart';
import 'repositories/firebase_coupon_repository.dart';
import 'repositories/firebase_order_repository.dart';
import 'repositories/firebase_inventory_repository.dart';
import 'repositories/firebase_favorites_repository.dart';
import 'repositories/firebase_rating_repository.dart';
import 'repositories/firebase_seller_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/firebase_chat_repository.dart';
import 'core/repositories/i_chat_repository.dart';
import 'core/repositories/i_app_settings_repository.dart';
import 'core/repositories/i_favorites_repository.dart';
import 'core/repositories/i_rating_repository.dart';
import 'core/repositories/i_seller_repository.dart';
import 'core/repositories/i_seller_profile_repository.dart';
import 'core/repositories/i_user_profile_repository.dart';
import 'repositories/firebase_seller_profile_repository.dart';
import 'repositories/firebase_user_profile_repository.dart';

import 'repositories/firebase_app_settings_repository.dart';
import 'core/repositories/delivery_active_order_session_repository.dart';

import 'core/services/theme_manager.dart';
import 'core/services/locale_manager.dart';

import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app_bloc_observer.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'core/services/zego_service.dart';

// Global logger instance for enterprise observability
final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.dateAndTime,
  ),
);

/// App mode enumeration to toggle between different application onboarding flows.
enum AppMode { buyer, seller, delivery }

/// Toggle this variable to switch between Buyer, Seller, and Delivery Partner App flows.
/// - AppMode.buyer   : Buyer Onboarding Page (/onboard)
/// - AppMode.seller  : Seller Onboarding Page (/selleronboard)
/// - AppMode.delivery: Delivery Partner Onboarding Page (/deliveryonboard)
const AppMode activeAppMode = AppMode.delivery;

/// Backward compatibility flag for legacy checks
const bool isBuyerApp = activeAppMode == AppMode.buyer;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    await FirebaseFirestore.instance.clearPersistence();
  }

  await FirebaseAppCheck.instance.activate(
    providerWeb: ReCaptchaV3Provider(
      dotenv.env['RECAPTCHA_SITE_KEY'] ?? '',
    ),
    providerAndroid: AndroidPlayIntegrityProvider(),
    providerApple: AppleAppAttestProvider(),
  );


  if (!kIsWeb) {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Set the global BLoC observer for logging state changes and errors
  Bloc.observer = AppBlocObserver();

  // Initialize Firebase Performance Monitoring
  if (!kIsWeb) {
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    appLogger.i('Firebase Performance Monitoring initialized');
  }

  // Listen to auth state to initialize/deinitialize ZegoCloud
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      ZegoService.init(user.uid, user.displayName ?? "User");
      appLogger.i('ZegoCloud initialized for user: ${user.uid}');
    } else {
      ZegoService.deinit();
      appLogger.i('ZegoCloud deinitialized');
    }
  });

  appLogger.i('Application starting up...');
  runApp(const MyApp());
}

class _AppThemeWrapper extends StatefulWidget {
  final ThemeManager themeManager;
  final LocaleManager localeManager;

  const _AppThemeWrapper({
    required this.themeManager,
    required this.localeManager,
  });

  @override
  State<_AppThemeWrapper> createState() => _AppThemeWrapperState();
}

class _AppThemeWrapperState extends State<_AppThemeWrapper> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<User?>? _authSub;
  String? _lastRoute;

  @override
  void initState() {
    super.initState();
    widget.themeManager.themeModeNotifier.addListener(_onChanged);
    widget.localeManager.localeNotifier.addListener(_onChanged);

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final currentRoute =
          _navigatorKey.currentState?.widget.initialRoute ?? '';
      if (user == null) {
        _navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/deliveryonboard', (_) => false);
      } else if (currentRoute.startsWith('/deliveryonboard') ||
          currentRoute.startsWith('/deliverylogin')) {
        _navigatorKey.currentState
            ?.pushReplacementNamed('/deliveryNavigationBar');
      }
    });
  }

  @override
  void dispose() {
    widget.themeManager.themeModeNotifier.removeListener(_onChanged);
    widget.localeManager.localeNotifier.removeListener(_onChanged);
    _authSub?.cancel();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = widget.themeManager.themeMode;
    final locale = widget.localeManager.locale;

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE52121)),
      scaffoldBackgroundColor: const Color(0xFFFBF5F5),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1C1C1C),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE52121),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
        Locale('es'),
        Locale('fr'),
      ],
      initialRoute: activeAppMode == AppMode.buyer
          ? '/onboard'
          : (activeAppMode == AppMode.seller
                ? '/selleronboard'
                : '/deliveryonboard'),
      routes: {
        '/onboard': (context) => const OnboardingPage(),
        '/sellerlogin': (context) => const SellerLoginPageUI(),
        '/selleronboard': (context) => const SellerOnboardPageUI(),
        '/sellerSignUp': (context) => const SellerSignUpPageUI(),
        '/sellerDashboard': (context) => const SellerNavigationBarViewPageUI(),
        '/deliveryLogin': (context) => const DeliveryLoginPage(),
        '/deliverySignUp': (context) => const DeliverySignUpPage(),
        '/deliveryForgotPassword': (context) =>
            const DeliveryForgotPasswordPage(),
        '/deliveryNavigationBar': (context) => const DeliveryNavigationBarPage(),
        '/deliveryOrderDetails': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final orderId = args?['orderId'] as String? ?? '#ORD98234';
          return BlocProvider<DeliveryOrderDetailsPageBloc>(
            create: (_) => DeliveryOrderDetailsPageBloc(
              repository: DeliveryOrderDetailsRepository(),
            )..add(FetchOrderDetailsEvent(orderId)),
            child: DeliveryOrderDetailsPageUi(orderId: orderId),
          );
        },
        '/deliveryIncomingOrder': (context) => const DeliveryIncomingOrderPageUi(),
        '/deliveryonboard': (context) =>
            BlocProvider<DeliveryOnboardingPageBloc>(
              create: (context) => DeliveryOnboardingPageBloc(
                repository: context.read<DeliveryOnboardingRepositoryBase>(),
                service: context.read<DeliveryOnboardingServiceBase>(),
              ),
              child: const DeliveryOnboardingPageUI(),
            ),
        '/deliveryOtpVerification': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return DeliveryOtpVerificationPage(
            verificationId: args?['verificationId'] as String? ?? '',
            name: args?['name'] as String? ?? '',
            phone: args?['phone'] as String? ?? '',
            email: args?['email'] as String? ?? '',
            password: args?['password'] as String? ?? '',
          );
        },
        '/deliveryPickupConfirmation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return DeliveryPickupConfirmationPage(
            orderId: args?['orderId'] as String? ?? '#ORD98234',
          );
        },
        '/deliveryCompleted': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return DeliveryCompletedPage(
            orderId: args?['orderId'] as String? ?? '#ORD98234',
          );
        },
        '/deliveryNavigationScreen': (context) => const DeliveryNavigationScreenPage(),
      },

    );
  }
}

class MyApp extends StatelessWidget {
  final CartBloc? cartBloc;
  final FavoritesBloc? favoritesBloc;
  final HomePageBloc? homePageBloc;

  const MyApp({
    super.key,
    this.cartBloc,
    this.favoritesBloc,
    this.homePageBloc,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final localeManager = LocaleManager();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthService>(
          create: (context) => FirebaseAuthService(),
        ),
        RepositoryProvider<IProductRepository>(
          create: (context) => FirebaseProductRepository(),
        ),
        RepositoryProvider<ICartRepository>(
          create: (context) => FirebaseCartRepository(),
        ),
        RepositoryProvider<IOrderRepository>(
          create: (context) => FirebaseOrderRepository(),
        ),
        RepositoryProvider<IInventoryRepository>(
          create: (context) => FirebaseInventoryRepository(),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(),
        ),
        RepositoryProvider<SellerDashboardRepository>(
          create: (context) => FirebaseSellerDashboardRepository(),
        ),
        RepositoryProvider<ICouponRepository>(
          create: (context) => FirebaseCouponRepository(),
        ),
        RepositoryProvider<IChatRepository>(
          create: (context) => FirebaseChatRepository(),
        ),
        RepositoryProvider<IAppSettingsRepository>(
          create: (context) => FirebaseAppSettingsRepository(),
        ),
        RepositoryProvider<IFavoritesRepository>(
          create: (context) => FirebaseFavoritesRepository(),
        ),
        RepositoryProvider<IRatingRepository>(
          create: (context) => FirebaseRatingRepository(),
        ),
        RepositoryProvider<ISellerRepository>(
          create: (context) => FirebaseSellerRepository(),
        ),
        RepositoryProvider<ISellerProfileRepository>(
          create: (context) => FirebaseSellerProfileRepository(),
        ),
        RepositoryProvider<IUserProfileRepository>(
          create: (context) => FirebaseUserProfileRepository(),
        ),
        RepositoryProvider<DeliveryOnboardingRepositoryBase>(
          create: (context) => DeliveryOnboardingRepository(),
        ),
        RepositoryProvider<DeliveryOnboardingServiceBase>(
          create: (context) => DeliveryOnboardingService(),
        ),
        RepositoryProvider<DeliveryActiveOrderSessionRepository>(
          create: (context) => DeliveryActiveOrderSessionRepository(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
        RepositoryProvider<ThemeManager>(create: (context) => themeManager),
        RepositoryProvider<LocaleManager>(create: (context) => localeManager),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                cartBloc ??
                CartBloc(
                  cartRepository: context.read<ICartRepository>(),
                  couponRepository: context.read<ICouponRepository>(),
                  authService: context.read<IAuthService>(),
                  productRepository: context.read<IProductRepository>(),
                ),
          ),
          BlocProvider(
            create: (context) =>
                favoritesBloc ??
                (FavoritesBloc(
                  favoritesRepository: context.read<IFavoritesRepository>(),
                  authService: context.read<IAuthService>(),
                )..add(const LoadFavoritesStarted())),
          ),
          BlocProvider(
            create: (context) =>
                homePageBloc ??
                (HomePageBloc(
                  productRepository: context.read<IProductRepository>(),
                  categoryRepository: context.read<CategoryRepository>(),
                )..add(const HomePageStarted())),
          ),
        ],
        child: Builder(
          builder: (context) {
            final themeManager = context.read<ThemeManager>();
            final localeManager = context.read<LocaleManager>();
            return _AppThemeWrapper(
              themeManager: themeManager,
              localeManager: localeManager,
            );
          },
        ),
      ),
    );
  }
}
