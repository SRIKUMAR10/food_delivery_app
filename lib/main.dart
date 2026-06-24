import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_UI.dart';

import 'features/buyer_bloc_architecture/Cart Page/cart_page_Bloc.dart';
import 'features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(
      '6Le3Ei8tAAAAAJbDz5qr_vLKa0iZ9wm3lNTaCi3K',
    ),
  );

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
        home: const OnboardingPage(),
      ),
    );
  }
}
