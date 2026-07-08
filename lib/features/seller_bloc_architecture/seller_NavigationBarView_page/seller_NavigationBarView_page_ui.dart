import 'dart:ui';
import 'package:flutter/material.dart';
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

class SellerNavigationBarViewPageUI extends StatelessWidget {
  const SellerNavigationBarViewPageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerNavigationBarViewPageBloc(),
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

    return BlocBuilder<SellerNavigationBarViewPageBloc, SellerNavigationBarViewPageState>(
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
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                );
              },
              child: pages[currentIndex],
            );

            if (isDesktop) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8F9FA),
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Row(
                      children: [
                        _DesktopSideMenu(
                          currentIndex: currentIndex,
                          onTap: (index) {
                            context.read<SellerNavigationBarViewPageBloc>().add(TabChangedEvent(index));
                          },
                        ),
                        const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE5E7EB)),
                        Expanded(child: pageContent),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              extendBody: true,
              body: pageContent,
              bottomNavigationBar: _MobileFloatingNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  context.read<SellerNavigationBarViewPageBloc>().add(TabChangedEvent(index));
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
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.white.withOpacity(0.9),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  indicatorColor: const Color(0x22E52929),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE52929));
                    }
                    return const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0xFF6B7280));
                  }),
                ),
                child: NavigationBar(
                  height: 65,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onTap,
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFFE52929)),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        label: const Text('3'),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.shopping_bag_outlined),
                      ),
                      selectedIcon: Badge(
                        label: const Text('3'),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFFE52929)),
                      ),
                      label: 'Orders',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        label: const Text('2'),
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.inventory_2_outlined),
                      ),
                      selectedIcon: Badge(
                        label: const Text('2'),
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.inventory_rounded, color: Color(0xFFE52929)),
                      ),
                      label: 'Products',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded, color: Color(0xFFE52929)),
                      label: 'More',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopSideMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _DesktopSideMenu({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Seller Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE52929),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Picarhub',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    Text(
                      'Seller Portal',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          _HoverableMenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_rounded,
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          const SizedBox(height: 8),
          _HoverableMenuItem(
            title: 'Orders',
            icon: Icons.shopping_bag_rounded,
            isSelected: currentIndex == 1,
            badgeCount: 3,
            badgeColor: Colors.red,
            onTap: () => onTap(1),
          ),
          const SizedBox(height: 8),
          _HoverableMenuItem(
            title: 'Products',
            icon: Icons.inventory_rounded,
            isSelected: currentIndex == 2,
            badgeCount: 2,
            badgeColor: Colors.orange,
            onTap: () => onTap(2),
          ),
          const SizedBox(height: 8),
          _HoverableMenuItem(
            title: 'More',
            icon: Icons.grid_view_rounded,
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          
          const Spacer(),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          
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
          const SizedBox(height: 8),
          _HoverableMenuItem(
            title: 'Logout',
            icon: Icons.logout_rounded,
            isSelected: false,
            iconColor: const Color(0xFFEF4444),
            textColor: const Color(0xFFEF4444),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HoverableMenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? textColor;

  const _HoverableMenuItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
    this.badgeColor,
    this.iconColor,
    this.textColor,
  });

  @override
  State<_HoverableMenuItem> createState() => _HoverableMenuItemState();
}

class _HoverableMenuItemState extends State<_HoverableMenuItem> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final defaultIconColor = isSelected ? const Color(0xFFE52929) : const Color(0xFF6B7280);
    final defaultTextColor = isSelected ? const Color(0xFFE52929) : const Color(0xFF4B5563);
    
    final finalIconColor = widget.iconColor ?? defaultIconColor;
    final finalTextColor = widget.textColor ?? defaultTextColor;

    final bgColor = isSelected 
        ? const Color(0x22E52929) 
        : (_isHovered ? const Color(0xFFF3F4F6) : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final double hoverScale = (!_controller.isAnimating && _isHovered && !isSelected) ? 1.02 : 1.0;
            final double finalScale = _scaleAnimation.value * hoverScale;
            
            return Transform.scale(
              scale: finalScale,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: finalIconColor, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: finalTextColor,
                    ),
                  ),
                ),
                if (widget.badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.badgeCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
