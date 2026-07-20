// Root navigation shell that hosts the five main app tabs:
//   0 — Home
//   1 — Wallet
//   2 — Cart
//   3 — Orders
//   4 — Support (Chat)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_ui.dart';

import '../Order%20Page/order_UI.dart';
import '../WalletScreen/WalletScreen_UI.dart';
import '../Cart%20Page/cart_page_UI.dart';

import '../home_Page/home_Page_UI.dart';

class CurvedNavigationBarView extends StatefulWidget {
  static final supportNavigation =
      ValueNotifier<SupportNavigationData?>(null);
  static final returnFromSupport = ValueNotifier<bool>(false);

  const CurvedNavigationBarView({super.key});

  @override
  State<CurvedNavigationBarView> createState() =>
      _CurvedNavigationBarViewState();
}

class _CurvedNavigationBarViewState extends State<CurvedNavigationBarView> {
  int _selectedIndex = 0;

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  SupportNavigationData? _pendingSupportData;
  List<Widget> _tabNavigators = [];
  int? _returnTabIndex;

  @override
  void initState() {
    super.initState();
    _rebuildTabNavigators();
    CurvedNavigationBarView.supportNavigation.addListener(_onSupportNavigation);
    CurvedNavigationBarView.returnFromSupport.addListener(_onReturnFromSupport);
  }

  void _rebuildTabNavigators() {
    _tabNavigators = [
      _buildTabNavigator(
        0,
        HomePage(onNavigateToCart: _navigateToCart),
      ),
      _buildTabNavigator(1, const WalletScreen_UI()),
      _buildTabNavigator(
        2,
        CartPageUI(
          onNavigateToOrders: _navigateToOrders,
          onNavigateToWallet: _navigateToWallet,
        ),
      ),
      _buildTabNavigator(
        3,
        OrderPageUI(orderRepository: context.read<IOrderRepository>()),
      ),
      _buildTabNavigator(
        4,
        BuyerChatPage(pendingOrderData: _pendingSupportData),
      ),
    ];
  }

  void _onSupportNavigation() {
    final data = CurvedNavigationBarView.supportNavigation.value;
    if (data != null) {
      CurvedNavigationBarView.supportNavigation.value = null;
      _pendingSupportData = data;
      if (_selectedIndex != 4) {
        _returnTabIndex = _selectedIndex;
      }
      _tabNavigators[4] = _buildTabNavigator(
        4,
        BuyerChatPage(pendingOrderData: data),
      );
      if (mounted) setState(() => _selectedIndex = 4);
    }
  }

  void _onReturnFromSupport() {
    if (CurvedNavigationBarView.returnFromSupport.value) {
      CurvedNavigationBarView.returnFromSupport.value = false;
      if (_returnTabIndex != null) {
        if (mounted) setState(() => _selectedIndex = _returnTabIndex!);
        _returnTabIndex = null;
      }
    }
  }

  @override
  void dispose() {
    CurvedNavigationBarView.supportNavigation.removeListener(
      _onSupportNavigation,
    );
    CurvedNavigationBarView.returnFromSupport.removeListener(
      _onReturnFromSupport,
    );
    super.dispose();
  }

  void _navigateToCart() {
    if (!mounted) return;
    setState(() => _selectedIndex = 2);
  }

  void _navigateToWallet() {
    if (!mounted) return;
    setState(() => _selectedIndex = 1);
  }

  void _navigateToOrders() {
    if (!mounted) return;
    setState(() => _selectedIndex = 3);
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: _tabNavigators,
    );
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
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

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
      child: _buildBody(),
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
              groupAlignment: 0.0,
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
