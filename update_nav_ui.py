import os

code = """import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_NavigationBarView_page_bloc.dart';
import 'seller_NavigationBarView_page_event.dart';
import 'seller_NavigationBarView_page_state.dart';
import '../seller_dashboard_page/seller_dashboard_page_ui.dart';
import '../orders_list/orders_list_page_ui.dart';
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
import '../product_list_page_/product_repository.dart';

class SellerNavigationBarViewPageUI extends StatelessWidget {
  const SellerNavigationBarViewPageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SellerNavigationBarViewPageBloc()),
        BlocProvider(
          create: (context) =>
              ProductListBloc(repository: ProductRepositoryImpl())
                ..add(LoadProductsEvent()),
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

            final Widget pageContent = AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: pages[currentIndex],
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
                        Expanded(child: pageContent),
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
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            spreadRadius: 0,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Dashboard'),
          _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders', badgeText: '3'),
          _buildNavItem(2, Icons.inbox_outlined, Icons.inbox_rounded, 'Products', badgeText: '4'),
          _buildNavItem(3, Icons.grid_view_outlined, Icons.grid_view_rounded, 'More'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, {String? badgeText}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12) : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0x33FF3B30), Color(0x0AFF3B30)],
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
                  Icon(activeIcon, color: const Color(0xFFE52929), size: 24),
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
                      Icon(icon, color: const Color(0xFF64748B), size: 24),
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
    );
  }
}

class _DesktopSideMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _DesktopSideMenu({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            spreadRadius: 4,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Curved Red Header
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF3B30), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 48, left: 32, right: 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
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
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Seller Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              children: [
                _HoverableMenuItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _HoverableMenuItem(
                  title: 'Orders',
                  icon: Icons.shopping_bag_rounded,
                  isSelected: currentIndex == 1,
                  badgeText: '3',
                  badgeColor: const Color(0xFFE52929),
                  onTap: () => onTap(1),
                ),
                BlocBuilder<ProductListBloc, ProductListPageState>(
                  builder: (context, state) {
                    String? badgeText = '4';
                    if (state is ProductListLoaded && state.allCount > 0) {
                      badgeText = state.allCount > 99 ? '99+' : state.allCount.toString();
                    }
                    return _HoverableMenuItem(
                      title: 'Products',
                      icon: Icons.inventory_rounded,
                      isSelected: currentIndex == 2,
                      badgeText: badgeText,
                      badgeColor: const Color(0xFFE52929),
                      onTap: () => onTap(2),
                    );
                  },
                ),
                _HoverableMenuItem(
                  title: 'More',
                  icon: Icons.grid_view_rounded,
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                const Spacer(),
                
                _HoverableMenuItem(
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                  isSelected: false,
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
                  iconColor: const Color(0xFFE52929),
                  textColor: const Color(0xFFE52929),
                  onTap: () async {
                    await SellerRepository().signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SellerLoginPageUI()),
                        (route) => false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Go Premium Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium, color: Color(0xFFFF9500), size: 28),
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
                        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
        ],
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
                color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
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
  final bool isSelected;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? textColor;

  const _HoverableMenuItem({
    required this.title,
    required this.icon,
    required this.isSelected,
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
    final defaultIconColor = isSelected ? const Color(0xFFE52929) : const Color(0xFF64748B);
    final defaultTextColor = isSelected ? const Color(0xFFE52929) : const Color(0xFF4B5563);

    final finalIconColor = widget.iconColor ?? defaultIconColor;
    final finalTextColor = widget.textColor ?? defaultTextColor;

    final bgColor = isSelected ? const Color(0xFFFEF2F2) : (_isHovered ? const Color(0xFFF8FAFC) : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          splashColor: const Color(0x22E52929),
          highlightColor: const Color(0x11E52929),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                // Red indicator line for selected item
                Container(
                  width: 6,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE52929) : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Icon(widget.icon, color: finalIconColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: finalTextColor,
                    ),
                  ),
                ),
                if (widget.badgeText != null)
                  Container(
                    margin: const EdgeInsets.only(right: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  const SizedBox(width: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
"""

with open('d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print("Updated navigation bar UI successfully")
