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
import 'package:flutter/services.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_ui.dart';

import '../Order%20Page/order_UI.dart';
import '../WalletScreen/WalletScreen_UI.dart';
import '../Cart%20Page/cart_page_UI.dart';

import '../home_Page/home_Page_UI.dart';

class CurvedNavigationBarView extends StatefulWidget {
  const CurvedNavigationBarView({super.key});

  @override
  State<CurvedNavigationBarView> createState() =>
      _CurvedNavigationBarViewState();
}

class _CurvedNavigationBarViewState extends State<CurvedNavigationBarView> {
  // Currently active tab index.
  int _selectedIndex = 0;

  // Global key to prevent the navigation bar from disappearing on hot reload in Flutter Web
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Keys for nested navigators to allow independent navigation within each tab
  // while keeping the bottom navigation bar visible.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  /// Switches the bottom navigation bar to the Cart tab (index 2).
  void _navigateToCart() {
    if (!mounted) return;
    setState(() => _selectedIndex = 2);
  }

  /// Switches the bottom navigation bar to the Wallet tab (index 1).
  void _navigateToWallet() {
    if (!mounted) return;
    setState(() => _selectedIndex = 1);
  }

  /// Switches the bottom navigation bar to the Orders tab (index 3).
  void _navigateToOrders() {
    if (!mounted) return;
    setState(() => _selectedIndex = 3);
  }

  // Generate pages dynamically and lazily to avoid building all tabs at once
  Widget _buildCurrentPage(int index) {
    switch (index) {
      case 0:
        return _buildTabNavigator(
          0,
          HomePage(onNavigateToCart: _navigateToCart),
        );
      case 1:
        return _buildTabNavigator(1, const WalletScreen_UI());
      case 2:
        return _buildTabNavigator(
          2,
          CartPageUI(
            onNavigateToOrders: _navigateToOrders,
            onNavigateToWallet: _navigateToWallet,
          ),
        );
      case 3:
        return _buildTabNavigator(
          3,
          OrderPageUI(
            orderRepository: context.read<IOrderRepository>(),
          ),
        );
      case 4:
        return _buildTabNavigator(4, const BuyerChatSupportPage());
      default:
        return _buildTabNavigator(
          0,
          HomePage(onNavigateToCart: _navigateToCart),
        );
    }
  }

  Widget _buildTabNavigator(int index, Widget page) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => page);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 800;

        final Widget bodyContent = PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final currentNavigator =
                _navigatorKeys[_selectedIndex].currentState;
            if (currentNavigator != null && currentNavigator.canPop()) {
              currentNavigator.pop();
            } else {
              if (_selectedIndex != 0) {
                setState(() {
                  _selectedIndex = 0;
                });
              } else {
                SystemNavigator.pop();
              }
            }
          },
          child: _buildCurrentPage(_selectedIndex),
        );

        if (isDesktop) {
          return Scaffold(
            backgroundColor: const Color(0xFFFBF5F5),
            body: Row(
              children: [
                Expanded(child: bodyContent),
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  selectedIconTheme: const IconThemeData(
                    color: Color(0xFFE52121),
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: Colors.black54,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFFE52121),
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Colors.black54,
                  ),
                  indicatorColor: const Color(
                    0xFFE52121,
                  ).withValues(alpha: 0.1),
                  minWidth: 90,
                  groupAlignment: 0.0, // Center vertically
                  destinations: const [
                    NavigationRailDestination(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      icon: Icon(Icons.home_outlined),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      label: Text('Wallet'),
                    ),
                    NavigationRailDestination(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      icon: Icon(Icons.shopping_cart_outlined),
                      label: Text('Cart'),
                    ),
                    NavigationRailDestination(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      icon: Icon(Icons.receipt_long_outlined),
                      label: Text('Orders'),
                    ),
                    NavigationRailDestination(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      icon: Icon(Icons.support_agent_outlined),
                      label: Text('Support'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFBF5F5),
          body: bodyContent,
          bottomNavigationBar: CurvedNavigationBar(
            key: _bottomNavigationKey,
            index: _selectedIndex,
            height: 60.0,
            items: <Widget>[
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.account_balance_wallet_outlined, 'Wallet', 1),
              _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 2),
              _buildNavItem(Icons.receipt_long_outlined, 'Orders', 3),
              _buildNavItem(Icons.support_agent_outlined, 'Support', 4),
            ],
            color: Colors.white,
            buttonBackgroundColor: const Color(0xFFE52121),
            backgroundColor: const Color(0xFFFBF5F5),
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        );
      },
    );
  }

  /// Builds a nav bar item — icon only when selected, icon + label otherwise.
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.black54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: isSelected ? 30 : 26, color: color),
        if (!isSelected) const SizedBox(height: 2),
        if (!isSelected)
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.normal,
            ),
          ),
      ],
    );
  }
}
