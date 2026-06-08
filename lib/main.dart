import 'package:flutter/material.dart';
import 'package:food_delivery_app/Sign_Up_Page/SignUpPage.dart';
import 'package:food_delivery_app/home_Page/home_Page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'details_Page/details_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE52121)),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFFBF5F5),
      ),
      debugShowCheckedModeBanner: false,
      home: const SignUpPage(),
    );
  }
}
