import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_NavigationBarView_page_bloc.dart';
import 'seller_NavigationBarView_page_event.dart';
import 'seller_NavigationBarView_page_state.dart';
import '../seller_dashboard_page/seller_dashboard_page_ui.dart';
import '../orders_list/orders_list_page_ui.dart';
import '../orders_list/orders_list_page_bloc.dart';
import '../orders_list/orders_list_page_event.dart';
import '../orders_list/orders_list_page_state.dart';
import '../../../../core/repositories/i_order_repository.dart';
import '../../../../core/repositories/i_chat_repository.dart';
import '../../../../core/models/order_status.dart';
import '../product_list_page_/product_list_page__ui.dart';
import '../product_list_page_/product_list_page__bloc.dart';
import '../product_list_page_/product_list_page__event.dart';
import '../product_list_page_/product_list_page__state.dart';
import '../seller_wallet_page/seller_wallet_page__ui.dart';
import '../seller_wallet_page/seller_wallet_page__bloc.dart';
import '../seller_wallet_page/seller_wallet_page__event.dart';
import '../seller_wallet_page/seller_wallet_page__state.dart';
import '../chat_support_page_/chat_support_page_ui.dart';
import '../chat_support_page_/chat_support_page_bloc.dart';
import '../chat_support_page_/chat_support_page_event.dart';
import '../chat_support_page_/chat_support_page_state.dart';
import '../overall_rating_page/overall_rating_page__ui.dart';
import '../overall_rating_page/overall_rating_page__bloc.dart';
import '../overall_rating_page/overall_rating_page__event.dart';
import '../overall_rating_page/overall_rating_page__state.dart';
import '../seller_customer_page/seller_customer_page__ui.dart';
import '../seller_customer_page/seller_customer_page__bloc.dart';
import '../seller_customer_page/seller_customer_page__event.dart';
import '../seller_customer_page/seller_customer_page__state.dart';
import '../seller_profile_page/seller_profile_page__ui.dart';
import '../seller_setting_page/seller_setting_page__ui.dart';
import '../seller_setting_page/seller_setting_page__bloc.dart';
import '../seller_setting_page/seller_setting_page__event.dart';
import '../../../repositories/seller_repository.dart';
import '../../../repositories/seller_wallet_repository.dart';
import '../../../repositories/seller_customer_repository.dart';

import '../../../repositories/firebase_order_repository.dart';
import '../../../repositories/firebase_product_repository.dart';
import '../../../repositories/firebase_chat_repository.dart';
import '../../../api_service/seller_wallet_service.dart';
import '../../../api_service/seller_customer_service.dart';
import '../../../api_service/seller_review_service.dart';
import '../seller_login_page/seller_login_page_ui.dart';
import '../../../../core/repositories/i_product_repository.dart';
import '../../../../core/services/i_auth_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../core/widgets/hoverable_widgets.dart';
import '../../../../core/widgets/logout_button.dart';
import '../../../widgets/curved_header_clipper.dart';

class SellerNavigationBarViewPageUI extends StatelessWidget {
  const SellerNavigationBarViewPageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IAuthService? authService;
    try {
      authService = context.read<IAuthService>();
    } catch (_) {}
    final sellerId = authService?.currentUserId ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SellerNavigationBarViewPageBloc()),
        BlocProvider(
          create: (context) {
            IProductRepository prodRepo;
            IAuthService auth;
            try {
              prodRepo = context.read<IProductRepository>();
            } catch (_) {
              prodRepo = FirebaseProductRepository();
            }
            try {
              auth = context.read<IAuthService>();
            } catch (_) {
              auth = FirebaseAuthService();
            }
            return ProductListBloc(
              repository: prodRepo,
              authService: auth,
            )..add(LoadProductsEvent());
          },
        ),
        BlocProvider(
          create: (context) {
            IOrderRepository orderRepo;
            IChatRepository chatRepo;
            try {
              orderRepo = context.read<IOrderRepository>();
            } catch (_) {
              orderRepo = FirebaseOrderRepository();
            }
            try {
              chatRepo = context.read<IChatRepository>();
            } catch (_) {
              chatRepo = FirebaseChatRepository();
            }
            return OrdersListBloc(
              repository: orderRepo,
              chatRepository: chatRepo,
            )..add(LoadOrdersStream(sellerId));
          },
        ),
        BlocProvider(
          create: (context) => SellerWalletBloc(
            repository: SellerWalletRepository(service: SellerWalletService()),
          )..add(const LoadWalletData()),
        ),
        BlocProvider(
          create: (context) {
            IChatRepository chatRepo;
            try {
              chatRepo = context.read<IChatRepository>();
            } catch (_) {
              chatRepo = FirebaseChatRepository();
            }
            return ChatSupportBloc(repository: chatRepo)
              ..add(LoadChatSessionsEvent(sellerId));
          },
        ),
        BlocProvider(
          create: (context) => OverallRatingBloc(
            service: SellerReviewService(),
          )..add(LoadOverallRatingEvent()),
        ),
        BlocProvider(
          create: (context) => SellerCustomerBloc(
            repository: SellerCustomerRepository(service: SellerCustomerService()),
          )..add(const LoadCustomerData()),
        ),
      ],
      child: const _SellerNavigationBarViewContent(),
    );
  }
}

class _SellerNavigationBarViewContent extends StatefulWidget {
  const _SellerNavigationBarViewContent({Key? key}) : super(key: key);

  @override
  State<_SellerNavigationBarViewContent> createState() => _SellerNavigationBarViewContentState();
}

class _SellerNavigationBarViewContentState extends State<_SellerNavigationBarViewContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    IAuthService? authService;
    try {
      authService = context.read<IAuthService>();
    } catch (_) {}
    final sellerId = authService?.currentUserId ?? '';

    final List<Widget> pages = [
      const SellerDashboardPageUI(key: ValueKey('dashboard')),
      const OrdersListPage(key: ValueKey('orders')),
      const ProductListPage(key: ValueKey('products')),
      const SellerWalletPage(key: ValueKey('wallet')),
      ChatSupportPage(key: const ValueKey('support_chat'), sellerId: sellerId),
      const OverallRatingPage(key: ValueKey('ratings_reviews')),
      const SellerCustomerPage(key: ValueKey('customer_insights')),
      const SellerProfilePageUI(key: ValueKey('profile')),
    ];

    return BlocBuilder<
      SellerNavigationBarViewPageBloc,
      SellerNavigationBarViewPageState
    >(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
      builder: (context, state) {
        int currentIndex = 0;
        if (state is SellerNavigationBarViewPageInitial) {
          currentIndex = state.tabIndex;
        } else if (state is SellerNavigationBarViewPageUpdated) {
          currentIndex = state.tabIndex;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;

            final Widget pageContent = IndexedStack(
              index: currentIndex.clamp(0, pages.length - 1),
              children: pages,
            );

            if (isDesktop) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Row(
                      children: [
                        SellerDesktopSideMenu(
                          currentIndex: currentIndex,
                          onTap: (index) {
                            context.read<SellerNavigationBarViewPageBloc>().add(
                              TabChangedEvent(index),
                            );
                          },
                        ),
                        Expanded(
                          child: pageContent,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (_scaffoldKey.currentState?.isDrawerOpen == true) {
                  _scaffoldKey.currentState?.closeDrawer();
                  return;
                }
                if (currentIndex != 0) {
                  context.read<SellerNavigationBarViewPageBloc>().add(
                    const TabChangedEvent(0),
                  );
                } else {
                  SystemNavigator.pop();
                }
              },
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: const Color(0xFFF8FAFC),
                extendBody: true,
                drawer: Drawer(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: SellerSideDrawer(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      Navigator.of(context).pop();
                      context.read<SellerNavigationBarViewPageBloc>().add(
                        TabChangedEvent(index),
                      );
                    },
                  ),
                ),
                body: SellerDrawerProvider(
                  openDrawer: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: pageContent,
                ),
                bottomNavigationBar: _MobileFloatingNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    context.read<SellerNavigationBarViewPageBloc>().add(
                      TabChangedEvent(index),
                    );
                  },
                  onMoreTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MobileFloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onMoreTap;

  const _MobileFloatingNavigationBar({
    required this.currentIndex,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            0,
            Icons.dashboard_outlined,
            Icons.dashboard_rounded,
            'Dashboard',
          ),
          BlocBuilder<OrdersListBloc, OrdersListState>(
            buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
              String? badgeText;
              if (state is OrdersListLoaded) {
                int newCount = state.allOrders.where((o) => o.status == OrderStatus.newOrder).length;
                if (newCount > 0) {
                  badgeText = newCount > 99 ? '99+' : newCount.toString();
                }
              }
              return _buildNavItem(
                1,
                Icons.shopping_bag_outlined,
                Icons.shopping_bag_rounded,
                'Orders',
                badgeText: badgeText,
              );
            },
          ),
          BlocBuilder<ProductListBloc, ProductListPageState>(
            buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
              String? badgeText;
              if (state is ProductListLoaded && state.allCount > 0) {
                badgeText = state.allCount > 99
                    ? '99+'
                    : state.allCount.toString();
              }
              return _buildNavItem(
                2,
                Icons.inventory_2_outlined,
                Icons.inventory_2_rounded,
                'Products',
                badgeText: badgeText,
              );
            },
          ),
          _buildNavItem(
            7,
            Icons.grid_view_outlined,
            Icons.grid_view_rounded,
            'More',
            customOnTap: onMoreTap,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    String? badgeText,
    VoidCallback? customOnTap,
  }) {
    final isSelected = currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: customOnTap ?? () => onTap(index),
        borderRadius: BorderRadius.circular(999),
        splashColor: const Color(0xFFE52929).withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: isSelected
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0x22FF3B30), Color(0x05FF3B30)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(999),
          ),
          child: isSelected
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        activeIcon,
                        color: const Color(0xFFE52929),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFFE52929),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            icon,
                            color: const Color(0xFF64748B),
                            size: 24,
                          ),
                        ),
                        if (badgeText != null)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE52929),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                badgeText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SellerDesktopSideMenu extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SellerDesktopSideMenu({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  State<SellerDesktopSideMenu> createState() => _SellerDesktopSideMenuState();
}

class _SellerDesktopSideMenuState extends State<SellerDesktopSideMenu> {
  bool _isExpanded = true;

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isExpanded ? 280 : 90,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: Border(
              right: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 32,
                spreadRadius: 8,
                offset: Offset(4, 0),
              ),
            ],
          ),
          child: ClipRect(
            child: SizedBox(
              width: _isExpanded ? 280 : 90,
              child: _SellerSideNavStructure(
                currentIndex: widget.currentIndex,
                isExpanded: _isExpanded,
                onToggle: _toggleMenu,
                onTap: widget.onTap,
                showPremiumCard: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SellerDrawerProvider extends InheritedWidget {
  final VoidCallback openDrawer;

  const SellerDrawerProvider({
    Key? key,
    required this.openDrawer,
    required Widget child,
  }) : super(key: key, child: child);

  static VoidCallback? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SellerDrawerProvider>()?.openDrawer;
  }

  @override
  bool updateShouldNotify(SellerDrawerProvider oldWidget) => false;
}

class SellerSideDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SellerSideDrawer({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 32,
            spreadRadius: 8,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        child: _SellerSideNavStructure(
          currentIndex: currentIndex,
          isExpanded: true,
          onToggle: () => Navigator.of(context).pop(),
          onTap: onTap,
          showPremiumCard: false,
        ),
      ),
    );
  }
}

class _SellerSideNavStructure extends StatelessWidget {
  final int currentIndex;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(int) onTap;
  final bool showPremiumCard;

  const _SellerSideNavStructure({
    required this.currentIndex,
    required this.isExpanded,
    required this.onToggle,
    required this.onTap,
    this.showPremiumCard = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 170),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HoverableMenuItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  isSelected: currentIndex == 0,
                  isExpanded: isExpanded,
                  onTap: () => onTap(0),
                ),
                BlocBuilder<OrdersListBloc, OrdersListState>(
                  buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
                  builder: (context, state) {
                    String? badgeText;
                    if (state is OrdersListLoaded) {
                      int newCount = state.allOrders.where((o) => o.status == OrderStatus.newOrder).length;
                      if (newCount > 0) {
                        badgeText = newCount > 99 ? '99+' : newCount.toString();
                      }
                    }
                    return HoverableMenuItem(
                      title: 'Orders',
                      icon: Icons.shopping_bag_outlined,
                      activeIcon: Icons.shopping_bag_rounded,
                      isSelected: currentIndex == 1,
                      isExpanded: isExpanded,
                      badgeText: badgeText,
                      badgeColor: const Color(0xFFE52929),
                      onTap: () => onTap(1),
                    );
                  },
                ),
                BlocBuilder<ProductListBloc, ProductListPageState>(
                  buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
                  builder: (context, state) {
                    String? badgeText;
                    if (state is ProductListLoaded && state.allCount > 0) {
                      badgeText = state.allCount > 99
                          ? '99+'
                          : state.allCount.toString();
                    }
                    return HoverableMenuItem(
                      title: 'Products',
                      icon: Icons.inventory_2_outlined,
                      activeIcon: Icons.inventory_2_rounded,
                      isSelected: currentIndex == 2,
                      isExpanded: isExpanded,
                      badgeText: badgeText,
                      badgeColor: const Color(0xFFE52929),
                      onTap: () => onTap(2),
                    );
                  },
                ),
                BlocBuilder<SellerWalletBloc, SellerWalletState>(
                  buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
                  builder: (context, state) {
                    String? badgeText;
                    if (state is SellerWalletLoaded) {
                      int pendingCount = state.payouts.where((p) => p.status.toLowerCase() == 'pending').length;
                      if (pendingCount > 0) {
                        badgeText = pendingCount > 99 ? '99+' : pendingCount.toString();
                      }
                    }
                    return HoverableMenuItem(
                      title: 'Wallet',
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet_rounded,
                      isSelected: currentIndex == 3,
                      isExpanded: isExpanded,
                      badgeText: badgeText,
                      badgeColor: const Color(0xFFE52929),
                      onTap: () => onTap(3),
                    );
                  },
                ),
                BlocBuilder<ChatSupportBloc, ChatSupportState>(
                  buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
                  builder: (context, state) {
                    String? badgeText;
                    if (state is ChatSupportLoaded) {
                      int unread = state.conversations.fold<int>(0, (sum, c) => sum + c.sellerUnreadCount);
                      if (unread > 0) {
                        badgeText = unread > 99 ? '99+' : unread.toString();
                      }
                    }
                    return HoverableMenuItem(
                      title: 'Support Chat',
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      isSelected: currentIndex == 4,
                      isExpanded: isExpanded,
                      badgeText: badgeText,
                      badgeColor: const Color(0xFFE52929),
                      onTap: () => onTap(4),
                    );
                  },
                ),
                BlocBuilder<OverallRatingBloc, OverallRatingState>(
                  buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
                  builder: (context, state) {
                    String? badgeText;
                    if (state is OverallRatingLoaded) {
                      int unreplied = state.allReviews.where((r) => !r.hasSellerReply).length;
                      if (unreplied > 0) {
                        badgeText = unreplied > 99 ? '99+' : unreplied.toString();
                      }
                    }
                    return HoverableMenuItem(
                      title: 'Ratings & Reviews',
                      icon: Icons.star_outline_rounded,
                      activeIcon: Icons.star_rounded,
                      isSelected: currentIndex == 5,
                      isExpanded: isExpanded,
                      badgeText: badgeText,
                      badgeColor: const Color(0xFFE52929),
                      onTap: () => onTap(5),
                    );
                  },
                ),
                BlocBuilder<SellerCustomerBloc, SellerCustomerState>(
                  buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
                  builder: (context, state) {
                    String? badgeText;
                    if (state is SellerCustomerLoaded && state.customers.isNotEmpty) {
                      badgeText = state.customers.length > 99 ? '99+' : state.customers.length.toString();
                    }
                    return HoverableMenuItem(
                      title: 'Customer Insights',
                      icon: Icons.people_alt_outlined,
                      activeIcon: Icons.people_alt_rounded,
                      isSelected: currentIndex == 6,
                      isExpanded: isExpanded,
                      badgeText: badgeText,
                      badgeColor: const Color(0xFFE52929),
                      onTap: () => onTap(6),
                    );
                  },
                ),
                HoverableMenuItem(
                  title: 'More',
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  isSelected: currentIndex == 7,
                  isExpanded: isExpanded,
                  onTap: () => onTap(7),
                ),
                const SizedBox(height: 24),
                HoverableMenuItem(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  isSelected: false,
                  isExpanded: isExpanded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => SellerSettingBloc(
                            repository: SellerSettingRepositoryImpl(),
                          )..add(LoadSellerSettings()),
                          child: const SellerSettingPage(),
                        ),
                      ),
                    );
                  },
                ),
                HoverableMenuItem(
                  title: 'Logout',
                  icon: Icons.logout_rounded,
                  isSelected: false,
                  isExpanded: isExpanded,
                  iconColor: const Color(0xFFE52929),
                  textColor: const Color(0xFFE52929),
                  onTap: () {
                    showLogoutConfirmDialog(
                      context,
                      title: 'Logout',
                      message: 'Are you sure you want to log out of your restaurant seller account?',
                      confirmLabel: 'Logout',
                      confirmColor: const Color(0xFFE52929),
                      onConfirm: () async {
                        final repo = SellerRepository();
                        final uid = repo.currentUser?.uid;
                        if (uid != null) {
                          await repo.updateSellerData(uid, {'isOnline': false});
                        }
                        await repo.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SellerLoginPageUI(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (showPremiumCard && isExpanded)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF8F5FB), Color(0xFFF3EDF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.workspace_premium,
                              color: Color(0xFFFF9500),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Go Premium',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Unlock exclusive features and grow your business',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _GoPremiumButton(),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Stack(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 195,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF3B30), Color(0xFFE52929)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: isExpanded ? 20 : 16,
                        right: isExpanded ? 20 : 16,
                        top: 40,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isExpanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: onToggle,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                isExpanded ? Icons.notes : Icons.menu,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Picarhub',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Seller Portal',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoPremiumButton extends StatefulWidget {
  @override
  State<_GoPremiumButton> createState() => _GoPremiumButtonState();
}

class _GoPremiumButtonState extends State<_GoPremiumButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Upgrade Now',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE52929),
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Color(0xFFE52929), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}




