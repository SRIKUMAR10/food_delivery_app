import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../home_Page/home_Page.dart';
import '../order.dart';
import '../cart.dart';
import '../WalletScreen/WalletScreen.dart';

class CurvedNavigationBarView extends StatefulWidget {
  const CurvedNavigationBarView({super.key});

  @override
  State<CurvedNavigationBarView> createState() =>
      _CurvedNavigationBarViewState();
}

class _CurvedNavigationBarViewState extends State<CurvedNavigationBarView> {
  // 1. Use setState to manage the selected tab index
  int _selectedIndex = 0;

  // 4. List of pages for the bottom navigation
  final List<Widget> _pages = [
    const HomePage(),
    const WalletScreen(),
    const CartPage(),
    const OrdersListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5), // App background color
      // 7. Use AnimatedSwitcher for page switching
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      // 2. Keep CurvedNavigationBar package
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        // 3. Add 4 tabs: Home, Wallet, Cart, Orders
        items: <Widget>[
          _buildNavItem(Icons.home_outlined, "Home", 0),
          _buildNavItem(Icons.account_balance_wallet_outlined, "Wallet", 1),
          _buildNavItem(Icons.shopping_cart_outlined, "Cart", 2),
          _buildNavItem(Icons.receipt_long_outlined, "Orders", 3),
        ],
        color: Colors.white,
        // 9. Selected item should show only icon with primary color background
        buttonBackgroundColor: const Color(0xFFE52121), // Primary color
        backgroundColor: const Color(0xFFFBF5F5), // Matches Scaffold background
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // 8 & 9. Helper to build nav items: label only for unselected items.
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
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
