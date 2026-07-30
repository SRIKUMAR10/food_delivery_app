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
import 'features/Delivery Partner Bloc Architecture/Delivery_Login Page_page/Delivery_Login Page_page_ui.dart';

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
const bool isBuyerApp = activeAppMode == AppMode.delivery;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseFirestore.instance.clearPersistence();

  await FirebaseAppCheck.instance.activate(
    providerWeb: ReCaptchaV3Provider(
      '6Le3Ei8tAAAAAJbDz5qr_vLKa0iZ9wm3lNTaCi3K',
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
  @override
  void initState() {
    super.initState();
    widget.themeManager.themeModeNotifier.addListener(_onChanged);
    widget.localeManager.localeNotifier.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.themeManager.themeModeNotifier.removeListener(_onChanged);
    widget.localeManager.localeNotifier.removeListener(_onChanged);
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
        '/deliverylogin': (context) => const DeliveryLoginPage(),
        '/deliveryonboard': (context) =>
            BlocProvider<DeliveryOnboardingPageBloc>(
              create: (context) => DeliveryOnboardingPageBloc(
                repository: context.read<DeliveryOnboardingRepositoryBase>(),
                service: context.read<DeliveryOnboardingServiceBase>(),
              ),
              child: const DeliveryOnboardingPageUI(),
            ),
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
