// Root navigation shell that hosts the five main app tabs:
//   0 — Home
//   1 — Wallet
//   2 — Cart
//   3 — Orders
//   4 — Support (Chat)

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/core/models/buyer_notification_model.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/repositories/i_buyer_notification_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_ui.dart';

import '../Order%20Page/order_UI.dart';
import '../WalletScreen/WalletScreen_UI.dart';
import '../Cart%20Page/cart_page_UI.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home_Page/home_Page_UI.dart';
import '../buyer_login_page/buyer_login_page_ui.dart';
import '../buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

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
    _checkBuyerKycGate();
  }

  Future<void> _checkBuyerKycGate() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('buyer_user')
              .doc(user.uid)
              .get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            final isKyc = (data['isBuyerKycVerified'] == true) &&
                (data['onboardingCompleted'] == true);
            if (!isKyc && mounted) {
              final name = (data['fullName'] ?? data['name'] ?? data['displayName'] ?? '').toString().trim();
              final email = (data['email'] ?? data['emailAddress'] ?? '').toString().trim();
              final phone = (data['phone'] ?? data['mobile'] ?? data['phoneNumber'] ?? '').toString().trim();
              final imageUrl = (data['imageUrl'] ?? data['photoUrl'] ?? data['profilePic']) as String?;
              final isPhoneVerified = data['isPhoneVerified'] == true || phone.isNotEmpty;

              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => BuyerOnboardingVerificationPage(
                    initialFullName: name,
                    initialEmail: email,
                    initialPhone: phone,
                    initialAvatarUrl: imageUrl,
                    initialIsPhoneVerified: isPhoneVerified,
                  ),
                ),
                (route) => false,
              );
            }
          }
        } catch (_) {}
      }
    });
  }

  void _rebuildTabNavigators() {
    _tabNavigators = [
      _buildTabNavigator(
        0,
        () => HomePage(onNavigateToCart: _navigateToCart),
      ),
      _buildTabNavigator(1, () => const WalletScreen_UI()),
      _buildTabNavigator(
        2,
        () => CartPageUI(
          onNavigateToOrders: _navigateToOrders,
          onNavigateToWallet: _navigateToWallet,
        ),
      ),
      _buildTabNavigator(
        3,
        () => OrderPageUI(
          orderRepository: context.read<IOrderRepository>(),
          onNavigateToCart: _navigateToCart,
          onNavigateToHome: () {
            if (mounted) setState(() => _selectedIndex = 0);
          },
        ),
      ),

      _buildTabNavigator(
        4,
        () => BuyerChatPage(pendingOrderData: _pendingSupportData),
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
      
      final navState = _navigatorKeys[4].currentState;
      if (navState != null) {
        navState.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BuyerChatPage(pendingOrderData: data),
          ),
          (route) => false,
        );
      }
      
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

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const BuyerLoginPageUI(),
      ),
    );
  }

  void _onTabSelected(int index) {
    if (!mounted) return;
    final isLoggedIn = context.read<IAuthService>().currentUserId != null;
    if (!isLoggedIn && (index == 1 || index == 3 || index == 4)) {
      _navigateToLogin();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: _tabNavigators,
    );
  }

  Widget _buildTabNavigator(int index, Widget Function() pageBuilder) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => pageBuilder());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

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
        backgroundColor: const Color(0xFFF9FAFC),
        body: Row(
          children: [
            Expanded(child: bodyContent),
            Container(
              width: 110,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDesktopNavItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            index: 0,
                          ),
                          const SizedBox(height: 24),
                          _buildDesktopNavItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Wallet',
                            index: 1,
                          ),
                          const SizedBox(height: 24),
                          _buildDesktopNavItem(
                            icon: Icons.shopping_cart_outlined,
                            label: 'Cart',
                            index: 2,
                            badge: _buildCartBadge(),
                          ),
                          const SizedBox(height: 24),
                          _buildDesktopNavItem(
                            icon: Icons.receipt_long_outlined,
                            label: 'Orders',
                            index: 3,
                            badge: _buildOrdersBadge(),
                          ),
                          const SizedBox(height: 24),
                          _buildDesktopNavItem(
                            icon: Icons.local_offer_outlined,
                            label: 'Offers',
                            index: 0,
                            badge: _buildOffersBadge(),
                          ),
                          const SizedBox(height: 24),
                          _buildDesktopNavItem(
                            icon: Icons.support_agent_outlined,
                            label: 'Support',
                            index: 4,
                            badge: _buildSupportBadge(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Refer & Earn Promo Card
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.card_giftcard_rounded,
                          color: BuyerAppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Refer & Earn',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Invite friends &\nget ₹100',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Invite Now',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: BuyerAppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Wallet', 1),
          _buildNavItem(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 'Cart', 2, badge: _buildCartBadge()),
          _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders', 3, badge: _buildOrdersBadge()),
          _buildNavItem(Icons.support_agent_outlined, Icons.support_agent_rounded, 'Support', 4, badge: _buildSupportBadge()),
        ],
        color: Colors.white,
        buttonBackgroundColor: BuyerAppColors.primaryDeep.withValues(alpha: 0.1),
        backgroundColor: const Color(0xFFFBF5F5),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onTabSelected,
      ),
    );
  }

  /// Builds a nav bar item — icon only when selected, icon + label otherwise.
  Widget _buildNavItem(
    IconData iconOutlined,
    IconData iconFilled,
    String label,
    int index, {
    Widget? badge,
  }) {
    final bool isSelected = _selectedIndex == index;
    final color = isSelected ? BuyerAppColors.primaryDeep : Colors.black54;
    final icon = isSelected ? iconFilled : iconOutlined;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: isSelected ? 30 : 26, color: color),
            if (badge != null)
              Positioned(
                top: -6,
                right: -16,
                child: badge,
              ),
          ],
        ),
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

  Widget _buildDesktopNavItem({
    required IconData icon,
    required String label,
    required int index,
    Widget? badge,
  }) {
    final bool isSelected = _selectedIndex == index;
    final color = isSelected ? BuyerAppColors.primary : Colors.grey.shade600;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFFFF0F1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: color),
                if (badge != null)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: badge,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Real-time cart badge driven by [CartBloc] so the count always matches
  /// the live cart contents. Hidden entirely when the cart is empty.
  Widget _buildCartBadge() {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (previous, current) {
        final prevCount = previous is CartLoaded ? previous.totalCount : 0;
        final currCount = current is CartLoaded ? current.totalCount : 0;
        return prevCount != currCount;
      },
      builder: (context, state) {
        final count = state is CartLoaded ? state.totalCount : 0;
        return _NavBadge(
          badgeKey: const Key('buyer_nav_cart_badge'),
          count: count,
        );
      },
    );
  }

  /// Real-time orders badge counting active (non-terminal) in-flight orders
  /// streamed from the order repository for the signed-in buyer.
  Widget _buildOrdersBadge() {
    return StreamBuilder<String?>(
      stream: context.read<IAuthService>().authStateChanges,
      builder: (context, authSnapshot) {
        final uid = authSnapshot.data;
        if (uid == null || uid.isEmpty) return const SizedBox.shrink();
        return StreamBuilder<List<OrderModel>>(
          stream: context.read<IOrderRepository>().getBuyerOrdersStream(uid),
          builder: (context, snapshot) {
            final orders = snapshot.data ?? const <OrderModel>[];
            final activeCount =
                orders.where((order) => !order.status.isTerminal).length;
            return _NavBadge(
              badgeKey: const Key('buyer_nav_orders_badge'),
              count: activeCount,
            );
          },
        );
      },
    );
  }

  /// Real-time support badge summing unread messages across all conversations
  /// streamed for the signed-in buyer.
  Widget _buildSupportBadge() {
    return StreamBuilder<String?>(
      stream: context.read<IAuthService>().authStateChanges,
      builder: (context, authSnapshot) {
        final uid = authSnapshot.data;
        if (uid == null || uid.isEmpty) return const SizedBox.shrink();
        return StreamBuilder<List<ConversationModel>>(
          stream: context
              .read<IChatRepository>()
              .getConversationsForUser(uid, role: 'buyer'),
          builder: (context, snapshot) {
            final conversations = snapshot.data ?? const <ConversationModel>[];
            var unreadCount = 0;
            for (final conversation in conversations) {
              unreadCount += conversation.unreadCountForUser(uid);
            }
            return _NavBadge(
              badgeKey: const Key('buyer_nav_support_badge'),
              count: unreadCount,
            );
          },
        );
      },
    );
  }

  /// Real-time offers badge counting unread promotional notifications for the
  /// signed-in buyer.
  Widget _buildOffersBadge() {
    return StreamBuilder<String?>(
      stream: context.read<IAuthService>().authStateChanges,
      builder: (context, authSnapshot) {
        final uid = authSnapshot.data;
        if (uid == null || uid.isEmpty) return const SizedBox.shrink();
        return StreamBuilder<List<BuyerNotificationModel>>(
          stream: context
              .read<IBuyerNotificationRepository>()
              .watchNotifications(uid),
          builder: (context, snapshot) {
            final notifications =
                snapshot.data ?? const <BuyerNotificationModel>[];
            final offersCount = notifications
                .where((notification) =>
                    notification.category ==
                        BuyerNotificationCategory.offerPromo &&
                    notification.isUnread)
                .length;
            return _NavBadge(
              badgeKey: const Key('buyer_nav_offers_badge'),
              count: offersCount,
            );
          },
        );
      },
    );
  }
}

/// Small circular count badge with a micro pop animation whenever the count
/// changes. Renders nothing when [count] is zero so empty states stay clean.
class _NavBadge extends StatelessWidget {
  final int count;
  final Key? badgeKey;

  const _NavBadge({required this.count, this.badgeKey});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      key: ValueKey(count),
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        key: badgeKey,
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: BuyerAppColors.primaryDeep,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1.2),
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

