import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Cart Page/cart_page.dart';
import '../Favorites_Page/favorites_bloc.dart';
import '../Favorites_Page/favorites_event.dart';
import '../Favorites_Page/favorites_state.dart';
import '../Favorites_Page/favorites_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';
import '../home_Page/home_page_models.dart';
import '../Rating_page/reviews_list_screen.dart';
import 'details_page_Bloc.dart';
import 'details_page_Event.dart';
import 'details_page_State.dart';

// ─── Details Page UI ─────────────────────────────────────────────────────────

class DetailsPageUI extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String description;
  final String sellerId;
  final String? image;
  final FirebaseAuth? auth;

  const DetailsPageUI({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.sellerId,
    this.image,
    this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DetailsBloc()..add(LoadDetailsRating(foodId: id)),
      child: _DetailsPageContent(
        id: id,
        name: name,
        price: price,
        description: description,
        sellerId: sellerId,
        image: image,
        auth: auth,
      ),
    );
  }
}

class _DetailsPageContent extends StatefulWidget {
  final String id;
  final String name;
  final double price;
  final String description;
  final String sellerId;
  final String? image;
  final FirebaseAuth? auth;

  const _DetailsPageContent({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.sellerId,
    this.image,
    this.auth,
  });

  @override
  State<_DetailsPageContent> createState() => _DetailsPageContentState();
}

class _DetailsPageContentState extends State<_DetailsPageContent>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  static const _primaryRed = Color(0xFFEF2A39);
  static const _bgColor = Color(0xFFF8F8F8);

  final NumberFormat _currFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _addToCart(int quantity) {
    HapticFeedback.mediumImpact();
    context.read<CartBloc>().add(
      CartItemAdded(
        CartItem(
          id: widget.id,
          name: widget.name,
          price: widget.price,
          sellerId: widget.sellerId,
          image: widget.image,
          quantity: quantity,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: _primaryRed,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.name} added to cart!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DetailsBloc, DetailsState>(
      listenWhen: (previous, current) =>
          previous.ratingStatus != current.ratingStatus,
      listener: (context, state) {
        if (state.ratingStatus == RatingStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rating updated successfully! 😊',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state.ratingStatus == RatingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.ratingMessage ?? 'Failed'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Desktop/Web layout if screen width > 800px
              if (constraints.maxWidth > 800) {
                return _buildWideLayout();
              } else {
                // Mobile layout
                return _buildMobileLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  // ── Mobile Layout ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    final mediaHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Scrollable Content
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Image SliverAppBar
            SliverAppBar(
              expandedHeight: mediaHeight * 0.42,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                      size: 18,
                    ),
                  ),
                ),
              ),
              actions: [_buildFavouriteButton()],
              flexibleSpace: FlexibleSpaceBar(background: _buildHeroImage()),
            ),

            // Details Card
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          _buildTitleAndRating(),
                          const SizedBox(height: 6),
                          _buildSellerAndTimingInfo(),
                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          const SizedBox(height: 20),
                          _buildDescription(),
                          const SizedBox(height: 28),
                          _buildPriceAndQuantityRow(),
                          const SizedBox(height: 28),
                          _buildRatingsAndReviewsButton(),
                          // Extra bottom padding so FAB doesn't cover content
                          const SizedBox(height: 110),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Sticky Bottom Bar
        Positioned(bottom: 0, left: 0, right: 0, child: _buildStickyBottom()),
      ],
    );
  }

  // ── Desktop / Web Layout ─────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 750),
        margin: const EdgeInsets.all(32),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left side: Image and Back Button
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeroImage(),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildFavouriteButton(),
                  ),
                ],
              ),
            ),

            // Right side: Details
            Expanded(
              flex: 1,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleAndRating(),
                        const SizedBox(height: 12),
                        _buildSellerAndTimingInfo(),
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDescription(),
                                const SizedBox(height: 28),
                                _buildRatingsAndReviewsButton(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildPriceAndQuantityRow(),
                        const SizedBox(height: 32),
                        _buildDesktopStickyBottom(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared UI Components ─────────────────────────────────────────────────

  Widget _buildTitleAndRating() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C1C1C),
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildRatingBadge(),
      ],
    );
  }

  Widget _buildSellerAndTimingInfo() {
    return Row(
      children: [
        const Icon(Icons.store_rounded, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          'Seller ID: ${widget.sellerId.length > 10 ? widget.sellerId.substring(0, 10) + '...' : widget.sellerId}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '25–35 min',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.description.isNotEmpty
              ? widget.description
              : 'A delicious, freshly prepared dish made with premium ingredients. Perfect for any time of the day!',
          style: TextStyle(
            fontSize: 13.5,
            color: Colors.grey.shade600,
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndQuantityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              _currFmt.format(widget.price),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _primaryRed,
              ),
            ),
          ],
        ),

        // Quantity Selector mapped to state
        BlocBuilder<DetailsBloc, DetailsState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _qtyButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<DetailsBloc>().add(
                        DetailsQuantityDecreased(),
                      );
                    },
                    enabled: state.quantity > 1,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        '${state.quantity}',
                        key: ValueKey(state.quantity),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C1C1C),
                        ),
                      ),
                    ),
                  ),
                  _qtyButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<DetailsBloc>().add(
                        DetailsQuantityIncreased(),
                      );
                    },
                    enabled: true,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFavouriteButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          bool isFav = false;
          if (state is FavoritesLoaded) {
            isFav = state.favoriteIds.contains(widget.id);
          }

          return GestureDetector(
            key: const Key('details_favorite_button'),
            onTap: () {
              HapticFeedback.lightImpact();
              bool isLoggedIn = false;
              try {
                isLoggedIn =
                    (widget.auth ?? FirebaseAuth.instance).currentUser != null;
              } catch (_) {}

              if (!isLoggedIn) {
                final foodItem = FoodItem(
                  id: widget.id,
                  name: widget.name,
                  price: widget.price,
                  description: widget.description,
                  sellerId: widget.sellerId,
                  image: widget.image,
                  category:
                      'Unknown', // Details page doesn't have category directly
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FoodGoLoginScreenUI(foodItemToAccess: foodItem),
                  ),
                );
                return;
              }

              final favItem = FavoriteItem(
                id: widget.id,
                name: widget.name,
                price: widget.price,
                description: widget.description,
                sellerId: widget.sellerId,
                image: widget.image,
              );
              context.read<FavoritesBloc>().add(
                FavoritesToggleRequested(favItem),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: isFav
                    ? _primaryRed.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFav),
                  color: _primaryRed,
                  size: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroImage() {
    final url = widget.image;
    const fallbackUrl =
        'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';

    Widget imageWidget;

    if (url != null && url.trim().isNotEmpty) {
      imageWidget = Image.network(
        url.trim(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Image.network(
          fallbackUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      imageWidget = Image.network(
        fallbackUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const SizedBox(),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        // Subtle gradient at bottom for text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBadge() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showReviewsBottomSheet();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB800).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .doc(widget.id)
              .collection('reviews')
              .snapshots(),
          builder: (context, snapshot) {
            double averageRating = 0.0;
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              double total = 0;
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                total += (data['rating'] as num?)?.toDouble() ?? 0.0;
              }
              averageRating = total / snapshot.data!.docs.length;
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(5, (index) {
                  double starValue = index + 1.0;
                  if (averageRating >= starValue) {
                    return const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 15,
                    );
                  } else if (averageRating >= starValue - 0.5) {
                    return const Icon(
                      Icons.star_half_rounded,
                      color: Colors.white,
                      size: 15,
                    );
                  } else {
                    return const Icon(
                      Icons.star_border_rounded,
                      color: Colors.white,
                      size: 15,
                    );
                  }
                }),
                const SizedBox(width: 6),
                Text(
                  averageRating > 0 ? averageRating.toStringAsFixed(1) : 'New',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRatingsAndReviewsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showReviewsBottomSheet();
        },
        icon: const Icon(Icons.star_half_rounded, color: Color(0xFF1C1C1C)),
        label: const Text(
          'Show All Ratings & Reviews',
          style: TextStyle(
            color: Color(0xFF1C1C1C),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showReviewsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ReviewsListScreen(productId: widget.id, productName: widget.name),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? _primaryRed : Colors.grey.shade300,
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _primaryRed.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildStickyBottom() {
    return BlocBuilder<DetailsBloc, DetailsState>(
      builder: (context, state) {
        final totalPrice = widget.price * state.quantity;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Total price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _currFmt.format(totalPrice),
                      key: ValueKey(totalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C1C1C),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 20),

              // Add to Cart button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(state.quantity),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      shadowColor: _primaryRed.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopStickyBottom() {
    return BlocBuilder<DetailsBloc, DetailsState>(
      builder: (context, state) {
        final totalPrice = widget.price * state.quantity;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Total price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _currFmt.format(totalPrice),
                    key: ValueKey(totalPrice),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1C1C1C),
                    ),
                  ),
                ),
              ],
            ),

            // Add to Cart button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _addToCart(state.quantity),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 4,
                  shadowColor: _primaryRed.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
