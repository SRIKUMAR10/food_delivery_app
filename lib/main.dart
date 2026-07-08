import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_ui.dart';

import 'features/buyer_bloc_architecture/Cart Page/cart_page_Bloc.dart';
import 'features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'features/buyer_bloc_architecture/onboarding_page/onboarding_page_UI.dart';
import 'features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';
import 'features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';
import 'features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';

import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:logger/logger.dart';
import 'core/app_bloc_observer.dart';

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

/// Toggle this flag to switch between the Buyer and Seller App flows.
const bool isBuyerApp = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(
      '6Le3Ei8tAAAAAJbDz5qr_vLKa0iZ9wm3lNTaCi3K',
    ),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Set the global BLoC observer for logging state changes and errors
  Bloc.observer = AppBlocObserver();

  // Initialize Firebase Performance Monitoring
  if (!kIsWeb) {
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    appLogger.i('Firebase Performance Monitoring initialized');
  }

  appLogger.i('Application starting up...');
  runApp(const MyApp());
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => cartBloc ?? CartBloc()),
        BlocProvider(
          create: (context) =>
              favoritesBloc ??
              (FavoritesBloc()..add(const LoadFavoritesStarted())),
        ),
        BlocProvider(
          create: (context) =>
              homePageBloc ?? (HomePageBloc()..add(const HomePageStarted())),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
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
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: isBuyerApp ? '/onboard' : '/selleronboard',
        routes: {
          '/onboard': (context) => const OnboardingPage(),
          '/sellerlogin': (context) => const SellerLoginPageUI(),
          '/selleronboard': (context) => const SellerOnboardPageUI(),
          '/sellerSignUp': (context) => const SellerSignUpPageUI(),
          //'/sellerForgotPassword': (context) => const SellerForgotPasswordPageUI(),
          '/sellerDashboard': (context) =>
              const SellerNavigationBarViewPageUI(),
        },
      ),
    );
  }
}
