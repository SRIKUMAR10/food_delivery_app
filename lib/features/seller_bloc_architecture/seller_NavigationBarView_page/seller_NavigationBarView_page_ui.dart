import 'dart:ui';
import 'package:flutter/material.dart';
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
import '../../../../core/models/order_status.dart';
import '../product_list_page_/product_list_page__ui.dart';
import '../seller_profile_page/seller_profile_page__ui.dart';
import '../seller_setting_page/seller_setting_page__ui.dart';
import '../seller_setting_page/seller_setting_page__bloc.dart';
import '../seller_setting_page/seller_setting_page__event.dart';
import '../../../repositories/seller_repository.dart';
import '../seller_login_page/seller_login_page_ui.dart';
import '../product_list_page_/product_list_page__bloc.dart';
import '../product_list_page_/product_list_page__event.dart';
import '../product_list_page_/product_list_page__state.dart';
import '../../../../core/repositories/i_product_repository.dart';
import '../../../../core/services/i_auth_service.dart';
import '../../../widgets/curved_header_clipper.dart';

class SellerNavigationBarViewPageUI extends StatelessWidget {
  const SellerNavigationBarViewPageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SellerNavigationBarViewPageBloc()),
        BlocProvider(
          create: (context) =>
              ProductListBloc(
                repository: context.read<IProductRepository>(),
                authService: context.read<IAuthService>(),
              )..add(LoadProductsEvent()),
        ),
        BlocProvider(
          create: (context) {
            final authService = context.read<IAuthService>();
            final sellerId = authService.currentUserId ?? '';
            return OrdersListBloc(
              repository: context.read<IOrderRepository>(),
            )..add(LoadOrdersStream(sellerId));
          },
        ),
      ],
      child: const _SellerNavigationBarViewContent(),
    );
  }
}

class _SellerNavigationBarViewContent extends StatelessWidget {
  const _SellerNavigationBarViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SellerDashboardPageUI(key: ValueKey('dashboard')),
      const OrdersListPage(key: ValueKey('orders')),
      const ProductListPage(key: ValueKey('products')),
      const SellerProfilePageUI(key: ValueKey('profile')),
    ];

    return BlocBuilder<
      SellerNavigationBarViewPageBloc,
      SellerNavigationBarViewPageState
    >(
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
              index: currentIndex,
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
                        _DesktopSideMenu(
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

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              extendBody: true,
              body: pageContent,
              bottomNavigationBar: _MobileFloatingNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  context.read<SellerNavigationBarViewPageBloc>().add(
                    TabChangedEvent(index),
                  );
                },
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

  const _MobileFloatingNavigationBar({
    required this.currentIndex,
    required this.onTap,
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
            builder: (context, state) {
              String? badgeText;
              if (state is ProductListLoaded && state.allCount > 0) {
                badgeText = state.allCount > 99
                    ? '99+'
                    : state.allCount.toString();
              }
              return _buildNavItem(
                2,
                Icons.inventory_outlined,
                Icons.inventory_rounded,
                'Products',
                badgeText: badgeText,
              );
            },
          ),
          _buildNavItem(
            3,
            Icons.grid_view_outlined,
            Icons.grid_view_rounded,
            'More',
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
  }) {
    final isSelected = currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
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

class _DesktopSideMenu extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _DesktopSideMenu({required this.currentIndex, required this.onTap});

  @override
  State<_DesktopSideMenu> createState() => _DesktopSideMenuState();
}

class _DesktopSideMenuState extends State<_DesktopSideMenu> {
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
              child: Stack(
                children: [
                  // Scrollable Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 170),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HoverableMenuItem(
                            title: 'Dashboard',
                            icon: Icons.dashboard_outlined,
                            activeIcon: Icons.dashboard_rounded,
                            isSelected: widget.currentIndex == 0,
                            isExpanded: _isExpanded,
                            onTap: () => widget.onTap(0),
                          ),
                          BlocBuilder<OrdersListBloc, OrdersListState>(
                            builder: (context, state) {
                              String? badgeText;
                              if (state is OrdersListLoaded) {
                                int newCount = state.allOrders.where((o) => o.status == OrderStatus.newOrder).length;
                                if (newCount > 0) {
                                  badgeText = newCount > 99 ? '99+' : newCount.toString();
                                }
                              }
                              return _HoverableMenuItem(
                                title: 'Orders',
                                icon: Icons.shopping_bag_outlined,
                                activeIcon: Icons.shopping_bag_rounded,
                                isSelected: widget.currentIndex == 1,
                                isExpanded: _isExpanded,
                                badgeText: badgeText,
                                badgeColor: const Color(0xFFE52929),
                                onTap: () => widget.onTap(1),
                              );
                            },
                          ),
                          BlocBuilder<ProductListBloc, ProductListPageState>(
                            builder: (context, state) {
                              String? badgeText;
                              if (state is ProductListLoaded &&
                                  state.allCount > 0) {
                                badgeText = state.allCount > 99
                                    ? '99+'
                                    : state.allCount.toString();
                              }
                              return _HoverableMenuItem(
                                title: 'Products',
                                icon: Icons.inventory_outlined,
                                activeIcon: Icons.inventory_rounded,
                                isSelected: widget.currentIndex == 2,
                                isExpanded: _isExpanded,
                                badgeText: badgeText,
                                badgeColor: const Color(0xFFE52929),
                                onTap: () => widget.onTap(2),
                              );
                            },
                          ),
                          _HoverableMenuItem(
                            title: 'More',
                            icon: Icons.grid_view_outlined,
                            activeIcon: Icons.grid_view_rounded,
                            isSelected: widget.currentIndex == 3,
                            isExpanded: _isExpanded,
                            onTap: () => widget.onTap(3),
                          ),
                          const SizedBox(height: 48),
                          _HoverableMenuItem(
                            title: 'Settings',
                            icon: Icons.settings_outlined,
                            activeIcon: Icons.settings_rounded,
                            isSelected: false,
                            isExpanded: _isExpanded,
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
                          _HoverableMenuItem(
                            title: 'Logout',
                            icon: Icons.logout_rounded,
                            isSelected: false,
                            isExpanded: _isExpanded,
                            iconColor: const Color(0xFFE52929),
                            textColor: const Color(0xFFE52929),
                            onTap: () async {
                              await SellerRepository().signOut();
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
                          ),
                          const SizedBox(height: 16),

                          // Go Premium Card
                          if (_isExpanded)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF8F5FB), Color(0xFFF3EDF6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
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
                                    children: [
                                      const Icon(
                                        Icons.workspace_premium,
                                        color: Color(0xFFFF9500),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Go Premium',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Unlock exclusive features and grow your business',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _GoPremiumButton(),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Header with Toggle (On Top)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Stack(
                      children: [
                        // White Outline shadow effect behind the red curve
                        ClipPath(
                          clipper: HeaderClipper(),
                          child: Container(
                            height: 195, // Increased height for a thicker outline effect
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        ),
                        // Actual Red Curve
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
                                  left: _isExpanded ? 20 : 16,
                                  right: _isExpanded ? 20 : 16,
                                  top: 40,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: _isExpanded
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: _toggleMenu,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          _isExpanded ? Icons.notes : Icons.menu,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    if (_isExpanded) ...[
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
              ),
            ),
          ),
        ),
),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE52929),
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Color(0xFFE52929), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverableMenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final IconData? activeIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isExpanded;
  final String? badgeText;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? textColor;

  const _HoverableMenuItem({
    required this.title,
    required this.icon,
    this.activeIcon,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
    this.iconColor,
    this.textColor,
  });

  @override
  State<_HoverableMenuItem> createState() => _HoverableMenuItemState();
}

class _HoverableMenuItemState extends State<_HoverableMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final defaultIconColor = isSelected
        ? const Color(0xFFE52929)
        : const Color(0xFF64748B);
    final defaultTextColor = isSelected
        ? const Color(0xFFE52929)
        : const Color(0xFF4B5563);

    final finalIconColor = widget.iconColor ?? defaultIconColor;
    final finalTextColor = widget.textColor ?? defaultTextColor;

    final bgColor = isSelected
        ? Colors.white
        : (_isHovered
              ? const Color(0xFFF1F5F9).withValues(alpha: 0.5)
              : Colors.transparent);
    final shadow = isSelected
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
        : <BoxShadow>[];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(32),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            height: 56,
            transform: Matrix4.identity()
              ..scale(_isHovered && !isSelected ? 1.02 : 1.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: shadow,
            ),
            child: widget.isExpanded
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 5 : 0,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE52929),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(width: isSelected ? 12 : 17),
                      Icon(
                        isSelected ? (widget.activeIcon ?? widget.icon) : widget.icon,
                        color: finalIconColor,
                        size: isSelected ? 26 : 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: finalTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.badgeText != null)
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.badgeColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.badgeText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 16),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isSelected ? (widget.activeIcon ?? widget.icon) : widget.icon,
                            color: finalIconColor,
                            size: isSelected ? 26 : 24,
                          ),
                          if (widget.badgeText != null)
                            Positioned(
                              top: -6,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: widget.badgeColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  widget.badgeText!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
