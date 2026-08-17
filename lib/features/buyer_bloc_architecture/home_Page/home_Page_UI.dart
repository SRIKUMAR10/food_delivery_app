// lib/Buyer Bloc Architecture/home_Page/home_Page_UI.dart
//
// Pure UI layer for the Home Page.
// This file contains zero business logic — it reads state from HomePageBloc
// and dispatches events back to it. All Firebase calls are inside the BLoC.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../Details_Page/details_page_UI.dart';
import '../Favorites_Page/favorites_UI.dart';
import '../Favorites_Page/favorites_bloc.dart';
import '../Favorites_Page/favorites_event.dart';
import '../Favorites_Page/favorites_state.dart';
import '../Favorites_Page/favorites_models.dart';
import '../Chat_Page/buyer_chat_ui.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/repositories/i_user_profile_repository.dart';
import '../../../core/services/seller_status_service.dart';
import '../../../repositories/firebase_product_repository.dart';
import '../../../repositories/category_repository.dart';
import 'home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import '../user_profile_image/user_profile_image.dart';
import '../buyer_login_page/buyer_login_page_ui.dart';
import '../Notifications_page/widgets/notification_bell_button.dart';

// ─── HomePage (entry point) ────────────────────────────────────────────────────

/// Root widget for the Home Page.
/// Provides [HomePageBloc] to the subtree and dispatches [HomePageStarted]
/// on first build to trigger initial data loading.
class HomePage extends StatelessWidget {
  /// Callback invoked after a successful "Add to Cart" action in DetailsPageUI.
  /// Causes the bottom navigation bar to switch to the Cart tab.
  final VoidCallback? onNavigateToCart;

  /// Optional BLoC instance provided for widget testing or custom scoping.
  final HomePageBloc? bloc;

  const HomePage({super.key, this.onNavigateToCart, this.bloc});

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<HomePageBloc>.value(
        value: bloc!,
        child: _HomePageContentView(onNavigateToCart: onNavigateToCart),
      );
    }

    try {
      final existingBloc = BlocProvider.of<HomePageBloc>(context, listen: false);
      return BlocProvider<HomePageBloc>.value(
        value: existingBloc,
        child: _HomePageContentView(onNavigateToCart: onNavigateToCart),
      );
    } catch (_) {
      return BlocProvider<HomePageBloc>(
        create: (context) => HomePageBloc(
          productRepository: FirebaseProductRepository(),
          categoryRepository: CategoryRepository(),
        ),
        child: _HomePageContentView(onNavigateToCart: onNavigateToCart),
      );
    }
  }
}

class _HomePageContentView extends StatefulWidget {
  final VoidCallback? onNavigateToCart;

  const _HomePageContentView({this.onNavigateToCart});

  @override
  State<_HomePageContentView> createState() => _HomePageContentViewState();
}

class _HomePageContentViewState extends State<_HomePageContentView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Dispatch the startup event to begin loading products.
    context.read<HomePageBloc>().add(const HomePageStarted());

    // Forward every search keystroke to the BLoC as an event.
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query.isEmpty) {
        context.read<HomePageBloc>().add(const SearchCleared());
      } else {
        context.read<HomePageBloc>().add(SearchQueryChanged(query));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomePageBloc, HomePageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;

                // Determine layout type based on viewport width.
                final bool isMobile = maxWidth < 600;
                final bool isTablet = maxWidth >= 600 && maxWidth < 1024;
                final bool isDesktop = maxWidth >= 1024;

                // Column count: 1 on small mobile (<360px), 2 on mobile, 3 on tablet, 4 on desktop.
                final int crossAxisCount = isDesktop
                    ? 4
                    : (isTablet
                        ? 3
                        : (maxWidth < 360 ? 1 : 2));

                // Responsive aspect ratio to prevent card overflow
                final double childAspectRatio = isDesktop
                    ? 0.80
                    : (isTablet ? 0.76 : (maxWidth < 360 ? 1.0 : 0.74));

                final double horizontalPadding = isDesktop
                    ? 48.0
                    : (isTablet ? 32.0 : 16.0);

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16.0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Top bar (logo + search bar + profile avatar + favorites) ──
                            _TopBar(
                              isMobile: isMobile,
                              isTablet: isTablet,
                              isDesktop: isDesktop,
                              maxWidth: maxWidth,
                              searchController: _searchController,
                              onNavigateToCart: widget.onNavigateToCart,
                            ),

                            // ── Mobile & Tablet: Search Bar ──
                            if (!isDesktop) ...[
                              const SizedBox(height: 14),
                              _SearchBar(controller: _searchController),
                            ],

                            const SizedBox(height: 16),

                            // ── GPS Location Header Selection ──
                            _LocationHeader(
                              address: state.currentAddress,
                              isDesktop: isDesktop,
                            ),

                            const SizedBox(height: 20),

                            // ── Promotional Offers & Banners Carousel ──
                            if (state is HomePageLoaded || state is HomePageEmpty || state is HomePageSearchEmpty) ...[
                              _OfferBannerCarousel(
                                banners: state.banners,
                                isMobile: isMobile,
                                isDesktop: isDesktop,
                                maxWidth: maxWidth,
                              ),
                              const SizedBox(height: 24),

                              // ── "Order Again" Quick Reorder Bar ──
                              if (state.recentlyOrderedItems.isNotEmpty) ...[
                                _OrderAgainSection(
                                  items: state.recentlyOrderedItems,
                                  onNavigateToCart: widget.onNavigateToCart,
                                  isMobile: isMobile,
                                  maxWidth: maxWidth,
                                  distancesMap: state.distancesMap,
                                ),
                                const SizedBox(height: 24),
                              ],


                              // ── Popular Dishes Section ──
                              if (state.popularProducts.isNotEmpty) ...[
                                _PopularProductsSection(
                                  items: state.popularProducts,
                                  onNavigateToCart: widget.onNavigateToCart,
                                  isMobile: isMobile,
                                  distancesMap: state.distancesMap,
                                ),
                                const SizedBox(height: 24),
                              ],
                            ],

                            // ── Horizontal Category Filter Row (All, Burgers, Pizza, Drinks, etc.) ──
                            _CategoryRow(
                              state: state,
                              isMobile: isMobile,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // ── Product Grid ──
                    _ProductGrid(
                      state: state,
                      horizontalPadding: horizontalPadding,
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      onNavigateToCart: widget.onNavigateToCart,
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Top Bar ───────────────────────────────────────────────────────────────────

/// Renders the app logo, search bar (web/tablet), favorites button, and profile avatar.
class _TopBar extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final double maxWidth;
  final TextEditingController searchController;
  final VoidCallback? onNavigateToCart;

  const _TopBar({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.maxWidth,
    required this.searchController,
    this.onNavigateToCart,
  });

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _ProfileAvatar(onNavigateToCart: onNavigateToCart);

    final favoritesIcon = GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesPageUI()),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFEF2A39),
              size: 18,
            ),
            if (!isMobile) ...[
              const SizedBox(width: 6),
              const Text(
                'Favorites',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!isDesktop) {
      // Mobile & Tablet header layout: logo on left, avatar & favorites on right.
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/images/FoodGo.svg',
            height: isMobile ? 38 : 46,
            fit: BoxFit.contain,
            semanticsLabel: 'FoodGo Logo',
          ),
          Row(
            children: [
              const NotificationBellButton(),
              const SizedBox(width: 10),
              favoritesIcon,
              const SizedBox(width: 10),
              avatarWidget,
            ],
          ),
        ],
      );
    }

    // Desktop layout: logo on left, search bar expanding in middle, favorites & profile avatar on right.
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/FoodGo.svg',
          height: 52,
          width: 140,
          fit: BoxFit.contain,
          semanticsLabel: 'FoodGo Logo',
        ),
        const SizedBox(width: 24),
        Expanded(child: _SearchBar(controller: searchController)),
        const SizedBox(width: 20),
        const NotificationBellButton(),
        const SizedBox(width: 14),
        favoritesIcon,
        const SizedBox(width: 14),
        avatarWidget,
      ],
    );
  }
}

// ─── Profile Avatar ────────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final VoidCallback? onNavigateToCart;

  const _ProfileAvatar({this.onNavigateToCart});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerCtx) => GestureDetector(
        onTap: () {
          Navigator.push(
            innerCtx,
            MaterialPageRoute(builder: (_) => const user_profile_image()),
          );
        },
        child: StreamBuilder<String?>(
          stream: context.read<IAuthService>().authStateChanges,
          builder: (context, authSnapshot) {
            final uid = authSnapshot.data;
            if (uid == null) {
              return _buildAvatarRow(null);
            }

            return StreamBuilder<String?>(
              stream: context
                  .read<IUserProfileRepository>()
                  .watchProfileImageUrl(uid),
              builder: (context, imageSnapshot) {
                return _buildAvatarRow(imageSnapshot.data);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarRow(String? imageUrl) {
    final cleanUrl = (imageUrl ?? '').trim();
    final bool hasValidUrl = cleanUrl.isNotEmpty && cleanUrl.startsWith('http');

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEFEEF4),
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: hasValidUrl
              ? Image.network(
                  cleanUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/chef.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                )
              : Image.asset(
                  'assets/images/chef.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF1C1C1C),
          ),
        ),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey,
          size: 18,
        ),
      ],
    );
  }
}


// ─── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBECEF)),
      ),
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1C1C1C)),
              decoration: const InputDecoration(
                hintText: 'Search for food, restaurants, cuisines...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEF2A39),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}


// ─── Category Row ──────────────────────────────────────────────────────────────

/// Horizontally scrollable row of animated category filter chips.
class _CategoryRow extends StatelessWidget {
  final HomePageState state;
  final bool isMobile;

  const _CategoryRow({
    required this.state,
    this.isMobile = false,
  });

  String get _selectedId => state.selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = state.categories[index];
          final isSelected = cat.id == _selectedId;

          return GestureDetector(
            onTap: () =>
                context.read<HomePageBloc>().add(CategorySelected(cat.id)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              constraints: const BoxConstraints(minHeight: 44),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEF2A39)
                    : const Color(0xFFEFEEF4),
                borderRadius: BorderRadius.circular(isSelected ? 20 : 14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF2A39).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Text(
                    cat.emoji,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamilyFallback: [
                        'Segoe UI Emoji',
                        'Apple Color Emoji',
                        'Noto Color Emoji',
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 13 : 14,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF3A3A3A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Product Grid ──────────────────────────────────────────────────────────────

/// Sliver that renders the correct content based on the current BLoC state:
/// loading spinner, error message, empty state, or the product grid.
class _ProductGrid extends StatelessWidget {
  final HomePageState state;
  final double horizontalPadding;
  final int crossAxisCount;
  final double childAspectRatio;
  final VoidCallback? onNavigateToCart;

  const _ProductGrid({
    required this.state,
    required this.horizontalPadding,
    required this.crossAxisCount,
    this.childAspectRatio = 0.76,
    this.onNavigateToCart,
  });

  @override
  Widget build(BuildContext context) {
    // ── Loading ──
    if (state is HomePageLoading || state is HomePageInitial) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ── Error ──
    if (state is HomePageError) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            (state as HomePageError).message,
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // ── Category empty ──
    if (state is HomePageEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No products available in ${(state as HomePageEmpty).categoryName}',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // ── Search returned no results ──
    if (state is HomePageSearchEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No products match "${(state as HomePageSearchEmpty).query}"',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // ── Products loaded ──
    if (state is HomePageLoaded) {
      final items = (state as HomePageLoaded).filteredItems;
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          delegate: SliverChildBuilderDelegate(
            (ctx, index) {
              final item = items[index];
              final distance = state.distancesMap[item.sellerId];
              return FoodCard(
                item: item,
                index: index,
                onNavigateToCart: onNavigateToCart,
                distanceKm: distance,
              );
            },
            childCount: items.length,
          ),
        ),
      );
    }

    // Fallback for any unexpected state.
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

// ─── Food Card ─────────────────────────────────────────────────────────────────

/// An animated, hoverable product card displayed in the home page grid.
/// Tapping navigates to DetailsPageUI. If not logged in, redirects to login.
class FoodCard extends StatefulWidget {
  final FoodItem item;
  final int index;
  final VoidCallback? onNavigateToCart;
  final double? distanceKm;

  const FoodCard({
    super.key,
    required this.item,
    this.index = 0,
    this.onNavigateToCart,
    this.distanceKm,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool _isHovered = false;

  // Indian Rupee currency formatter consistent with WalletScreen and CartPage.
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Log the image URL at the point of rendering for debugging.
    debugPrint('DEBUG 3 (FoodCard Image URL): ${widget.item.image}');

    // Entrance animation: fade in + slide up based on card index.
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (widget.index * 50).clamp(0, 400)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: child,
        ),
      ),
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.opaque,
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () async {
            final isLoggedIn = context.read<IAuthService>().currentUserId != null;
            if (isLoggedIn) {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsPageUI(
                    id: widget.item.id,
                    name: widget.item.name,
                    price: widget.item.discountPrice > 0 ? widget.item.discountPrice : widget.item.price,
                    description: widget.item.description,
                    sellerId: widget.item.sellerId,
                    imageUrls: widget.item.imageUrls.isNotEmpty ? widget.item.imageUrls : null,
                    foodItem: widget.item,
                    distanceKm: widget.distanceKm,
                  ),
                ),
              );
              // If the user added an item to the cart, switch to the Cart tab.
              if (result == true && context.mounted) {
                widget.onNavigateToCart?.call();
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsPageUI(
                        id: widget.item.id,
                        name: widget.item.name,
                        price: widget.item.price,
                        description: widget.item.description,
                        sellerId: widget.item.sellerId,
                        foodItem: widget.item,
                        distanceKm: widget.distanceKm,
                      ),
                ),
              );
            }
          },
          child: AnimatedScale(
            scale: _isHovered ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              height: 320,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _isHovered ? 0.06 : 0.02,
                    ),
                    blurRadius: _isHovered ? 10 : 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image section.
                        Expanded(
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: _ProductImage(item: widget.item),
                                  ),
                                  if (widget.item.isBestSeller)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Best Seller',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!widget.item.isActive || widget.item.status.contains('outOfStock'))
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.7),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Out of Stock',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BuyerChatPage(
                                              foodItem: widget.item,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 16,
                                          color: Color(0xFFEF2A39),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: BlocBuilder<FavoritesBloc, FavoritesState>(
                                      builder: (context, state) {
                                        bool isFav = false;
                                        if (state is FavoritesLoaded) {
                                          isFav = state.favoriteIds.contains(widget.item.id);
                                        }
                                        return GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            final isLoggedIn = context.read<IAuthService>().currentUserId != null;
                                            if (!isLoggedIn) {
                                              Navigator.of(context, rootNavigator: true).push(
                                                MaterialPageRoute(builder: (_) => const BuyerLoginPageUI()),
                                              );
                                              return;
                                            }
                                            final favItem = FavoriteItem(
                                              id: widget.item.id,
                                              name: widget.item.name,
                                              price: widget.item.price,
                                              description: widget.item.description,
                                              sellerId: widget.item.sellerId,
                                              image: widget.item.image,
                                            );
                                            context.read<FavoritesBloc>().add(
                                              FavoritesToggleRequested(favItem),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                              key: ValueKey(isFav),
                                              color: const Color(0xFFEF2A39),
                                              size: 18,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Product name and Veg/Non-Veg
                        Row(
                          children: [
                            if (widget.item.foodType.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: (widget.item.foodType.toLowerCase() == 'veg' || widget.item.foodType.toLowerCase() == 'vegetarian') ? Colors.green : Colors.red, 
                                    width: 1.2
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (widget.item.foodType.toLowerCase() == 'veg' || widget.item.foodType.toLowerCase() == 'vegetarian') ? Icons.circle : Icons.change_history,
                                      size: 8,
                                      color: (widget.item.foodType.toLowerCase() == 'veg' || widget.item.foodType.toLowerCase() == 'vegetarian') ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      (widget.item.foodType.toLowerCase() == 'veg' || widget.item.foodType.toLowerCase() == 'vegetarian') ? 'VEG' : 'NON-VEG',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: (widget.item.foodType.toLowerCase() == 'veg' || widget.item.foodType.toLowerCase() == 'vegetarian') ? Colors.green : Colors.red,
                                        letterSpacing: 0.5,
                                      ),
                                    )
                                  ],
                                )
                              ),
                            Expanded(
                              child: Text(
                                widget.item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1C1C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Rating and Review Count
                        if (widget.item.rating > 0) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.item.rating} (${widget.item.reviewCount})',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ],
                        if (widget.item.prepTime.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, size: 12, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(widget.item.prepTime, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],

                        // Seller availability badge
                        BlocSelector<HomePageBloc, HomePageState, SellerAvailability?>(
                          selector: (state) {
                            if (state is HomePageLoaded) {
                              return state.sellerAvailabilities[widget.item.sellerId];
                            }
                            return null;
                          },
                          builder: (context, availability) {
                            if (availability == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: availability.isAvailable ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    availability.isAvailable ? 'Open' : 'Closed',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: availability.isAvailable ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 4),

                        // Formatted price with Indian Rupee symbol and Discount
                        Text(
                          _currencyFormatter.format(widget.item.discountPrice > 0 ? widget.item.discountPrice : widget.item.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow button positioned at the bottom-right corner of the card.
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 48,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF2A39),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
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

// ─── Product Image ─────────────────────────────────────────────────────────────

/// Renders a product image from its URL with smooth frameBuilder and fallback chain.
class _ProductImage extends StatelessWidget {
  final FoodItem item;
  const _ProductImage({required this.item});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = (item.image ?? '').trim();
    final imageUri = Uri.tryParse(cleanUrl);

    if (imageUri != null && imageUri.hasAbsolutePath && cleanUrl.startsWith('http')) {
      return Image.network(
        cleanUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFEF2A39),
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, error, __) {
          debugPrint('Image Load Error for ${item.name}: $error');
          return Container(
            color: Colors.grey[100],
            child: Image.asset(
              'assets/images/chef.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.fastfood, color: Colors.grey, size: 36),
              ),
            ),
          );
        },
      );
    }

    // Fallback when URL is invalid or empty
    return Container(
      color: Colors.grey[100],
      child: Image.asset(
        'assets/images/chef.png',
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.fastfood, color: Colors.grey, size: 36),
        ),
      ),
    );
  }
}

// ─── Location Header ───────────────────────────────────────────────────────────

class _LocationHeader extends StatelessWidget {
  final String address;
  final bool isDesktop;

  const _LocationHeader({
    required this.address,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFFEF2A39),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DELIVER TO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address.isNotEmpty ? address : 'No. 12, Main Street, Central Park, City',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFFEF2A39),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              context.read<HomePageBloc>().add(const FetchUserLocation());
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: const BoxConstraints(minWidth: 64, minHeight: 38),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  color: Color(0xFFEF2A39),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Offer Banner Carousel (2-Column Desktop Hero Section) ─────────────────────

class _OfferBannerCarousel extends StatefulWidget {
  final List<PromotionBanner> banners;
  final bool isMobile;
  final bool isDesktop;
  final double maxWidth;

  const _OfferBannerCarousel({
    required this.banners,
    this.isMobile = false,
    this.isDesktop = false,
    this.maxWidth = 400.0,
  });

  @override
  State<_OfferBannerCarousel> createState() => _OfferBannerCarouselState();
}

class _OfferBannerCarouselState extends State<_OfferBannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.banners.isEmpty || !mounted) return;
      final nextIndex = (_currentIndex + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = widget.isDesktop || MediaQuery.of(context).size.width >= 1024;
    final double bannerHeight = isDesktop
        ? 185.0
        : (widget.isMobile
            ? (widget.maxWidth * 0.48).clamp(165.0, 200.0)
            : 190.0);

    final mainHeroBanner = Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: widget.banners.isNotEmpty ? widget.banners.length : 1,
            itemBuilder: (context, index) {
              final banner = widget.banners.isNotEmpty
                  ? widget.banners[index]
                  : const PromotionBanner(
                      id: 'BAN-DEFAULT',
                      title: 'Free Delivery on Combos',
                      subtitle: 'Orders above ₹299',
                      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
                      code: 'WELCOME50',
                      discountPercent: 50.0,
                    );

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          banner.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1C1C1C),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(widget.isMobile ? 14 : 20),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🔥 ', style: TextStyle(fontSize: 10)),
                                  Text(
                                    'HOT DEAL',
                                    style: TextStyle(
                                      color: Color(0xFF1C1C1C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: widget.isMobile ? 18 : 22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              banner.subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF2A39),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Order Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.isNotEmpty ? widget.banners.length : 1,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? const Color(0xFFEF2A39)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );

    final secondaryOfferCard = Container(
      height: 185,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4EBE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'SUPER SAVER',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flat 20% OFF',
            style: TextStyle(
              color: Color(0xFF1B4332),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'On your first order',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: const Text(
                  'FOODGO20',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Order Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: mainHeroBanner),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: secondaryOfferCard),
        ],
      );
    }

    return mainHeroBanner;
  }
}


// ─── Order Again Section ──────────────────────────────────────────────────────

class _OrderAgainSection extends StatelessWidget {
  final List<FoodItem> items;
  final VoidCallback? onNavigateToCart;
  final bool isMobile;
  final double maxWidth;
  final Map<String, double> distancesMap;

  const _OrderAgainSection({
    required this.items,
    this.onNavigateToCart,
    this.isMobile = false,
    this.maxWidth = 400.0,
    this.distancesMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final double cardWidth = isMobile
        ? (maxWidth * 0.72).clamp(210.0, 260.0)
        : 240.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                'Order Again 🔄',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              Spacer(),
              Text(
                'View All >',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEF2A39),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: cardWidth,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.image ?? kDefaultFoodImageUrl,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 68,
                          height: 68,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1C1C1C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFEF2A39),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailsPageUI(
                                    foodItem: item,
                                    onNavigateToCart: onNavigateToCart,
                                    distanceKm: distancesMap[item.sellerId],
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 32),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Reorder',
                                    style: TextStyle(
                                      color: Color(0xFFEF2A39),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.refresh_rounded,
                                      color: Color(0xFFEF2A39), size: 14),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


// ─── Popular Products Section ──────────────────────────────────────────────────

class _PopularProductsSection extends StatelessWidget {
  final List<FoodItem> items;
  final VoidCallback? onNavigateToCart;
  final bool isMobile;
  final Map<String, double> distancesMap;

  const _PopularProductsSection({
    required this.items,
    this.onNavigateToCart,
    this.isMobile = false,
    this.distancesMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                'Popular Dishes 🔥',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              Spacer(),
              Text(
                'View All >',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEF2A39),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 155,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsPageUI(
                          foodItem: item,
                          onNavigateToCart: onNavigateToCart,
                          distanceKm: distancesMap[item.sellerId],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          item.image ?? kDefaultFoodImageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            color: Colors.grey.shade200,
                            child:
                                const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF1C1C1C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFFEF2A39),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF2A39),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_rounded,
                                      color: Colors.white, size: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


