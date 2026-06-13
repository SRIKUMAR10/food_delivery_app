import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/onboarding_page/onboarding_page_UI.dart';
import 'Repository/product_repository.dart';
import 'Seller Bloc Architecture/Seller_Add_Products/seller_product_bloc.dart';
import 'Buyer Bloc Architecture/Cart Page/cart_page_Bloc.dart';
import 'firebase_options.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (context) => ProductRepository())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SellerProductBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
          BlocProvider(create: (context) => CartBloc()),
        ],
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE52121),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
            scaffoldBackgroundColor: const Color(0xFFFBF5F5),
          ),
          debugShowCheckedModeBanner: false,
          home: const OnboardingPage(),
        ),
      ),
    );
  }
}
