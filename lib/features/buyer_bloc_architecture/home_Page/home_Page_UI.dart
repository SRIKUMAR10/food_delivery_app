// lib/Buyer Bloc Architecture/home_Page/home_Page_UI.dart
//
// Pure UI layer for the Home Page.
// This file contains zero business logic — it reads state from HomePageBloc
// and dispatches events back to it. All Firebase calls are inside the BLoC.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Details_Page/details_page_UI.dart';
import '../Favorites_Page/favorites_UI.dart';
import '../Favorites_Page/favorites_bloc.dart';
import '../Favorites_Page/favorites_event.dart';
import '../Favorites_Page/favorites_state.dart';
import '../Favorites_Page/favorites_models.dart';
import '../FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';
import 'home_Page_Bloc.dart';
import 'home_page_models.dart';
import '../user_profile_image/user_profile_image.dart';

// ─── HomePage (entry point) ────────────────────────────────────────────────────

/// Root widget for the Home Page.
/// Provides [HomePageBloc] to the subtree and dispatches [HomePageStarted]
/// on first build to trigger initial data loading.
class HomePage extends StatefulWidget {
  /// Callback invoked after a successful "Add to Cart" action in DetailsPageUI.
  /// Causes the bottom navigation bar to switch to the Cart tab.
  final VoidCallback? onNavigateToCart;

  const HomePage({super.key, this.onNavigateToCart});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;

                // Determine layout type based on viewport width.
                final bool isMobile = maxWidth < 600;
                final bool isTablet = maxWidth >= 600 && maxWidth < 1024;
                final bool isWeb = maxWidth >= 1024;

                // Column count: 2 on mobile, 3 on tablet, 4 on web.
                final int crossAxisCount = isWeb ? 4 : (isTablet ? 3 : 2);
                final double horizontalPadding = isWeb
                    ? 48.0
                    : (isTablet ? 32.0 : 16.0);

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 20.0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Top bar (logo + search on web, logo + avatar on mobile) ──
                            _TopBar(
                              isMobile: isMobile,
                              isWeb: isWeb,
                              maxWidth: maxWidth,
                              searchController: _searchController,
                              onNavigateToCart: widget.onNavigateToCart,
                            ),

                            // ── Mobile: tagline + search bar below the top bar ──
                            if (isMobile) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Order your favourite food!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xDE000000),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _SearchBar(controller: _searchController),
                            ],

                            // ── Web/tablet: centred tagline only (search is in the top bar) ──
                            if (!isMobile) ...[
                              const SizedBox(height: 32),
                              Center(
                                child: Text(
                                  'Order your favourite food!',
                                  style: TextStyle(
                                    fontSize: isWeb ? 36 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1C1C1C),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // ── Horizontal category filter row ──
                            _CategoryRow(state: state),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // ── Product grid (content depends on current BLoC state) ──
                    _ProductGrid(
                      state: state,
                      horizontalPadding: horizontalPadding,
                      crossAxisCount: crossAxisCount,
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

/// Renders the app logo, search bar (web only), and profile avatar.
class _TopBar extends StatelessWidget {
  final bool isMobile;
  final bool isWeb;
  final double maxWidth;
  final TextEditingController searchController;
  final VoidCallback? onNavigateToCart;

  const _TopBar({
    required this.isMobile,
    required this.isWeb,
    required this.maxWidth,
    required this.searchController,
    this.onNavigateToCart,
  });

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _ProfileAvatar(onNavigateToCart: onNavigateToCart);

    final favoritesIcon = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPageUI()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFEF2A39),
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Favorite',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );

    if (isMobile) {
      // Mobile layout: logo on the left, avatar on the right.
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Display SVG logo with original colours (no colour filter applied).
          Flexible(
            child: SvgPicture.asset(
              'assets/images/FoodGo.svg',
              height: 50,
              fit: BoxFit.contain,
              semanticsLabel: 'FoodGo Logo',
            ),
          ),
          Row(
            children: [
              favoritesIcon,
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              avatarWidget,
            ],
          ),
        ],
      );
    }

    // Web / tablet layout: logo on the left, search bar takes remaining space, then icons.
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/FoodGo.svg',
          height: 70,
          width: 160, // Slightly reduced to ensure it fits nicely on tablets
          fit: BoxFit.contain,
          semanticsLabel: 'FoodGo Logo',
        ),
        const SizedBox(width: 24),
        // Search bar takes up the remaining available space gracefully.
        Expanded(child: _SearchBar(controller: searchController)),
        const SizedBox(width: 16),
        favoritesIcon,
        Container(
          height: 40,
          width: 1,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        avatarWidget,
      ],
    );
  }
}

// ─── Profile Avatar ────────────────────────────────────────────────────────────

/// Displays the logged-in user's profile photo (or a placeholder icon).
/// Tapping opens the profile drawer if logged in, or redirects to the login screen.
class _ProfileAvatar extends StatelessWidget {
  final VoidCallback? onNavigateToCart;

  const _ProfileAvatar({this.onNavigateToCart});

  Stream<User?>? get _authStream {
    try {
      return FirebaseAuth.instance.authStateChanges();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          // Builder provides a context that is a descendant of Scaffold,
          // which is required to call Scaffold.of(context).openEndDrawer().
          builder: (innerCtx) => GestureDetector(
            onTap: () {
              bool isLoggedIn = false;
              try {
                isLoggedIn = FirebaseAuth.instance.currentUser != null;
              } catch (_) {
                // Firebase not initialized — treat as not logged in.
              }
              if (!isLoggedIn) {
                // Redirect unauthenticated users to the login screen.
                Navigator.push(
                  innerCtx,
                  MaterialPageRoute(
                    builder: (_) => const FoodGoLoginScreenUI(),
                  ),
                );
              } else {
                // Navigate to the profile screen for authenticated users.
                Navigator.push(
                  innerCtx,
                  MaterialPageRoute(builder: (_) => const user_profile_image()),
                );
              }
            },
            child: StreamBuilder<User?>(
              stream: _authStream,
              builder: (context, authSnapshot) {
                final user = authSnapshot.data;

                if (user == null) {
                  return _buildAvatarContainer(null);
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (_, snapshot) {
                    String? imageUrl;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      imageUrl =
                          (snapshot.data!.data()
                              as Map<String, dynamic>?)?['imageUrl'];
                    }

                    return _buildAvatarContainer(imageUrl);
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContainer(String? imageUrl) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEF4),
        borderRadius: BorderRadius.circular(12),
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              )
            : null,
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFFEF2A39),
              size: 24,
            )
          : null,
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────────

/// Text input field used to filter the product list by name.
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEEF4),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Search food item...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Search icon button (visual only; filtering is driven by the text field listener).
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEF2A39),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 22),
        ),
      ],
    );
  }
}

// ─── Category Row ──────────────────────────────────────────────────────────────

/// Horizontally scrollable row of animated category filter chips.
class _CategoryRow extends StatelessWidget {
  final HomePageState state;

  const _CategoryRow({required this.state});

  String get _selectedId => state.selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = state.categories[index];
          final isSelected = cat.id == _selectedId;

          return GestureDetector(
            // Dispatch a category change event to the BLoC when a chip is tapped.
            onTap: () =>
                context.read<HomePageBloc>().add(CategorySelected(cat.id)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEF2A39)
                    : const Color(0xFFEFEEF4),
                borderRadius: BorderRadius.circular(isSelected ? 20 : 14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF2A39).withValues(alpha: 0.2),
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
                      fontSize: 14,
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
  final VoidCallback? onNavigateToCart;

  const _ProductGrid({
    required this.state,
    required this.horizontalPadding,
    required this.crossAxisCount,
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
            childAspectRatio: 0.76,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          delegate: SliverChildBuilderDelegate(
            (ctx, index) => FoodCard(
              item: items[index],
              index: index,
              onNavigateToCart: onNavigateToCart,
            ),
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

  const FoodCard({
    super.key,
    required this.item,
    this.index = 0,
    this.onNavigateToCart,
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
    decimalDigits: 2,
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
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () async {
            bool isLoggedIn = false;
            try {
              isLoggedIn = FirebaseAuth.instance.currentUser != null;
            } catch (_) {
              // Firebase not initialized — treat as not logged in.
            }
            if (isLoggedIn) {
              // Navigate to DetailsPageUI for authenticated users.
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsPageUI(
                    id: widget.item.id,
                    name: widget.item.name,
                    price: widget.item.price,
                    description: widget.item.description,
                    sellerId: widget.item.sellerId,
                    image: widget.item.image,
                    foodItem: widget.item,
                  ),
                ),
              );
              // If the user added an item to the cart, switch to the Cart tab.
              if (result == true && context.mounted) {
                widget.onNavigateToCart?.call();
              }
            } else {
              // Redirect unauthenticated users to the login screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FoodGoLoginScreenUI(foodItemToAccess: widget.item),
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
                                    top: 8,
                                    right: 8,
                                    child:
                                        BlocBuilder<
                                          FavoritesBloc,
                                          FavoritesState
                                        >(
                                          builder: (context, state) {
                                            bool isFav = false;
                                            if (state is FavoritesLoaded) {
                                              isFav = state.favoriteIds
                                                  .contains(widget.item.id);
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                bool isLoggedIn = false;
                                                try {
                                                  isLoggedIn =
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser !=
                                                      null;
                                                } catch (_) {}

                                                if (!isLoggedIn) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          FoodGoLoginScreenUI(
                                                            foodItemToAccess:
                                                                widget.item,
                                                          ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final favItem = FavoriteItem(
                                                  id: widget.item.id,
                                                  name: widget.item.name,
                                                  price: widget.item.price,
                                                  description:
                                                      widget.item.description,
                                                  sellerId:
                                                      widget.item.sellerId,
                                                  image: widget.item.image,
                                                );
                                                context
                                                    .read<FavoritesBloc>()
                                                    .add(
                                                      FavoritesToggleRequested(
                                                        favItem,
                                                      ),
                                                    );
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isFav
                                                      ? const Color(
                                                          0xFFEF2A39,
                                                        ).withValues(alpha: 0.1)
                                                      : Colors.white.withValues(
                                                          alpha: 0.9,
                                                        ),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  child: Icon(
                                                    isFav
                                                        ? Icons.favorite_rounded
                                                        : Icons
                                                              .favorite_border_rounded,
                                                    key: ValueKey(isFav),
                                                    color: const Color(
                                                      0xFFEF2A39,
                                                    ),
                                                    size: 18,
                                                  ),
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

/// Renders a product image from its URL with a loading spinner and fallback chain.
class _ProductImage extends StatelessWidget {
  final FoodItem item;
  const _ProductImage({required this.item});

  @override
  Widget build(BuildContext context) {
    // Strip extra whitespace or newline characters from the URL before parsing.
    final imageUri = Uri.tryParse(item.image ?? '');

    if (imageUri != null && imageUri.hasAbsolutePath) {
      return Image.network(
        imageUri.toString(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, error, __) {
          debugPrint('Image Load Error: $error');
          // First fallback: use the default food image stored in Firebase Storage.
          return Image.network(
            kDefaultFoodImageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/chef.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        },
      );
    }

    // No valid URL — show the default food image directly.
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Image.network(
        kDefaultFoodImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(),
      ),
    );
  }
}
