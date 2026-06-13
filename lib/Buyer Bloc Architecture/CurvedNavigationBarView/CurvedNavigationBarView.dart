// lib/Buyer Bloc Architecture/CurvedNavigationBarView/CurvedNavigationBarView.dart
//
// Root navigation shell that hosts the four main app tabs:
//   0 — Home      (HomePageBloc provided here)
//   1 — Wallet
//   2 — Cart
//   3 — Orders
//
// HomePageBloc is provided at this level so the bloc survives tab switches.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../home_Page/home_Page.dart';
import '../Order Page/order_UI.dart';
import '../WalletScreen/WalletScreen_UI.dart';
import '../Cart Page/cart_page_UI.dart';

class CurvedNavigationBarView extends StatefulWidget {
  const CurvedNavigationBarView({super.key});

  @override
  State<CurvedNavigationBarView> createState() =>
      _CurvedNavigationBarViewState();
}

class _CurvedNavigationBarViewState extends State<CurvedNavigationBarView> {
  // Currently active tab index.
  int _selectedIndex = 0;

  // Pages are created once in initState so their state is preserved
  // across tab switches (IndexedStack-like behaviour via AnimatedSwitcher).
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Wrap HomePage in BlocProvider so HomePageBloc is scoped to the home tab.
      BlocProvider(
        create: (_) => HomePageBloc(),
        child: HomePage(onNavigateToCart: _navigateToCart),
      ),
      const WalletScreen_UI(),
      const CartPageUI(),
      const OrderPageUI(),
    ];
  }

  /// Switches the bottom navigation bar to the Cart tab (index 2).
  void _navigateToCart() {
    if (!mounted) return;
    setState(() => _selectedIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5),
      // AnimatedSwitcher provides a smooth crossfade between tabs.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: <Widget>[
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.account_balance_wallet_outlined, 'Wallet', 1),
          _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 2),
          _buildNavItem(Icons.receipt_long_outlined, 'Orders', 3),
        ],
        color: Colors.white,
        // Selected tab button uses the primary brand colour as background.
        buttonBackgroundColor: const Color(0xFFE52121),
        backgroundColor: const Color(0xFFFBF5F5),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  /// Builds a nav bar item — icon only when selected, icon + label otherwise.
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return isSelected
        ? Icon(icon, size: 30, color: Colors.white)
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: Colors.black54),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          );
  }
}
