import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_seller_repository.dart';
import '../Cart Page/cart_page.dart';
import '../Favorites_Page/favorites_bloc.dart';
import '../Favorites_Page/favorites_event.dart';
import '../Favorites_Page/favorites_state.dart';
import '../Favorites_Page/favorites_models.dart';
import '../FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';
import '../home_Page/home_page_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Rating_page/reviews_list_screen.dart';
import '../../seller_bloc_architecture/product_list_page_/product_image_carousel.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/core/services/seller_status_service.dart';
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
  final List<String>? imageUrls;
  final FoodItem? foodItem;

  const DetailsPageUI({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.sellerId,
    this.imageUrls,
    this.foodItem,
    this.detailsBloc,
  });

  final DetailsBloc? detailsBloc;

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls ??
        (foodItem != null && foodItem!.imageUrls.isNotEmpty
            ? foodItem!.imageUrls
            : foodItem?.image != null
                ? [foodItem!.image!]
                : null);

    if (detailsBloc != null) {
      return BlocProvider<DetailsBloc>.value(
        value: detailsBloc!,
        child: _DetailsPageContent(
          id: id,
          name: name,
          price: price,
          description: description,
          sellerId: sellerId,
          imageUrls: urls,
          foodItem: foodItem,
        ),
      );
    }

    return BlocProvider(
      create: (_) => DetailsBloc()..add(LoadDetailsRating(foodId: id)),
      child: _DetailsPageContent(
        id: id,
        name: name,
        price: price,
        description: description,
        sellerId: sellerId,
        imageUrls: urls,
        foodItem: foodItem,
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
  final List<String>? imageUrls;
  final FoodItem? foodItem;

  const _DetailsPageContent({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.sellerId,
    this.imageUrls,
    this.foodItem,
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
  
  final Set<String> _selectedAddons = {};
  SellerModel? _seller;
  bool _isLoadingSeller = true;
  SellerAvailability? _sellerAvailability;
  StreamSubscription<SellerAvailability>? _sellerStatusSub;

  static const _primaryRed = Color(0xFFEF2A39);
  static const _bgColor = Color(0xFFF8F8F8);

  final NumberFormat _currFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
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
    _fetchSeller();
    _watchSellerStatus();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _sellerStatusSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchSeller() async {
    try {
      final seller = await context.read<ISellerRepository>().getSeller(widget.sellerId);
      if (seller != null && mounted) {
        setState(() {
          _seller = seller;
          _isLoadingSeller = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingSeller = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSeller = false);
    }
  }

  void _watchSellerStatus() {
    _sellerStatusSub?.cancel();
    final service = SellerStatusService();
    _sellerStatusSub = service.watchSellerStatus(widget.sellerId).listen((status) {
      if (mounted) {
        setState(() => _sellerAvailability = status);
      }
    });
  }

  double get _effectivePrice {
    if (widget.foodItem != null &&
        widget.foodItem!.discountPrice > 0 &&
        widget.foodItem!.discountPrice < widget.price) {
      return widget.foodItem!.discountPrice;
    }
    return widget.price;
  }

  bool get _isActive {
    final productActive = widget.foodItem?.isActive ?? true;
    final sellerAvailable = _sellerAvailability?.isAvailable ?? true;
    return productActive && sellerAvailable;
  }

  String? get _primaryImage =>
      widget.imageUrls?.isNotEmpty == true ? widget.imageUrls!.first : null;

  void _addToCart(int quantity) {
    if (!_isActive) return;
    HapticFeedback.mediumImpact();
    context.read<CartBloc>().add(
      CartItemAdded(
        CartItem(
          id: widget.id,
          name: widget.name,
          price: _effectivePrice,
          sellerId: widget.sellerId,
          image: _primaryImage,
          imageUrls: widget.imageUrls ?? [],
          quantity: quantity,
          selectedAddons: _selectedAddons.toList(),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: _primaryRed,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                '${widget.name} added to cart!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    if (Navigator.canPop(context)) Navigator.pop(context, true);
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    'Rating updated successfully! 😊',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
              expandedHeight: mediaHeight * 0.55,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
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
                          _buildRestaurantInfo(),
                          const SizedBox(height: 16),
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 1100,
          maxHeight: screenHeight * 0.85,
        ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTitleAndRating(),
                        const SizedBox(height: 12),
                        _buildRestaurantInfo(),
                        const SizedBox(height: 20),
                        _buildDescription(),
                        const SizedBox(height: 28),
                        _buildRatingsAndReviewsButton(),
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
        if (widget.foodItem != null && widget.foodItem!.foodType.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4, right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: (widget.foodItem!.foodType.toLowerCase() == 'veg' || widget.foodItem!.foodType.toLowerCase() == 'vegetarian') ? Colors.green : Colors.red, 
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
                  (widget.foodItem!.foodType.toLowerCase() == 'veg' || widget.foodItem!.foodType.toLowerCase() == 'vegetarian') ? Icons.circle : Icons.change_history,
                  size: 8,
                  color: (widget.foodItem!.foodType.toLowerCase() == 'veg' || widget.foodItem!.foodType.toLowerCase() == 'vegetarian') ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 3),
                Text(
                  (widget.foodItem!.foodType.toLowerCase() == 'veg' || widget.foodItem!.foodType.toLowerCase() == 'vegetarian') ? 'VEG' : 'NON-VEG',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: (widget.foodItem!.foodType.toLowerCase() == 'veg' || widget.foodItem!.foodType.toLowerCase() == 'vegetarian') ? Colors.green : Colors.red,
                    letterSpacing: 0.5,
                  ),
                )
              ],
            )
          ),
        Expanded(
          child: Text(
            widget.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 0,
          child: _buildRatingBadge(),
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo() {
    if (_isLoadingSeller) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120, height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80, height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final seller = _seller;
    if (seller == null) {
      return Row(
        children: [
          const Icon(Icons.store_rounded, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            'Restaurant',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 16),
          _buildDeliveryTimeBadge(),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: seller.profileImageUrl ?? '',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.store, color: Colors.grey, size: 22),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.store, color: Colors.grey, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        seller.shopName?.isNotEmpty == true ? seller.shopName! : 'Restaurant',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (seller.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                    ],
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: _sellerAvailability?.isAvailable == true
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _sellerAvailability == null
                            ? '...'
                            : (_sellerAvailability!.isAvailable ? 'Open' : 'Closed'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _sellerAvailability?.isAvailable == true
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      seller.deliveryTime?.isNotEmpty == true
                          ? seller.deliveryTime!
                          : (widget.foodItem?.prepTime.isNotEmpty == true
                              ? widget.foodItem!.prepTime
                              : '25-35 min'),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    if (seller.businessDetails?.isNotEmpty == true) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          seller.businessDetails!,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeBadge() {
    final prepTime = widget.foodItem?.prepTime.isNotEmpty == true
        ? widget.foodItem!.prepTime
        : '25-35 min';
    return Container(
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
          Text(
            prepTime,
            style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.foodItem != null && (widget.foodItem!.calories.isNotEmpty || widget.foodItem!.spicyLevel.isNotEmpty || widget.foodItem!.portionSize.isNotEmpty)) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (widget.foodItem!.calories.isNotEmpty)
                _buildInfoChip(Icons.local_fire_department_outlined, '${widget.foodItem!.calories} Cal'),
              if (widget.foodItem!.spicyLevel.isNotEmpty)
                _buildInfoChip(Icons.whatshot_rounded, widget.foodItem!.spicyLevel, color: Colors.deepOrange),
              if (widget.foodItem!.portionSize.isNotEmpty)
                _buildInfoChip(Icons.restaurant_menu_rounded, widget.foodItem!.portionSize),
            ],
          ),
          const SizedBox(height: 16),
        ],
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
        if (widget.foodItem != null && widget.foodItem!.addons.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Add-ons Available',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.foodItem!.addons.map((addon) {
              final isSelected = _selectedAddons.contains(addon);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAddons.remove(addon);
                    } else {
                      _selectedAddons.add(addon);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryRed : Colors.white,
                    border: Border.all(color: isSelected ? _primaryRed : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    addon,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndQuantityRow() {
    final originalPrice = widget.foodItem?.price ?? widget.price;
    final discountPrice = widget.foodItem?.discountPrice ?? 0;
    final hasDiscount = discountPrice > 0 && discountPrice < originalPrice;
    final discountPercent = hasDiscount
        ? ((originalPrice - discountPrice) / originalPrice * 100).round()
        : 0;

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
            if (hasDiscount) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    _currFmt.format(originalPrice),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$discountPercent% OFF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: hasDiscount ? 0 : 2),
            Text(
              _currFmt.format(hasDiscount ? discountPrice : _effectivePrice),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _primaryRed,
              ),
            ),
          ],
        ),

        // Quantity Selector
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
                    child: SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          '${state.quantity}',
                          key: ValueKey(state.quantity),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1C),
                          ),
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
              final isLoggedIn = context.read<IAuthService>().currentUserId != null;

              if (!isLoggedIn) {
                final foodItem = FoodItem(
                  id: widget.id,
                  name: widget.name,
                  price: widget.price,
                  description: widget.description,
                  sellerId: widget.sellerId,
                  image: _primaryImage,
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
                image: _primaryImage,
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
    final urls = widget.imageUrls;
    if (urls == null || urls.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
        ),
      );
    }
    if (urls.length == 1) {
      return GestureDetector(
        onTap: () => _showSingleFullScreenImage(context, urls.first),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: urls.first,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade100,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade100,
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 48,
                ),
              ),
            ),
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
        ),
      );
    }
    return ProductImageCarousel(imageUrls: urls);
  }

  void _showSingleFullScreenImage(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: SafeArea(
              child: Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE50914),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingBadge() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showReviewsBottomSheet();
      },
      child: BlocBuilder<DetailsBloc, DetailsState>(
        builder: (context, state) {
          final averageRating = state.averageRating;
          final hasReviews = averageRating > 0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
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
            child: hasReviews
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        final starValue = index + 1.0;
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
                      const SizedBox(width: 4),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    Icons.star_border_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
          );
        },
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
        final totalPrice = _effectivePrice * state.quantity;

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
                    onPressed: _isActive ? () => _addToCart(state.quantity) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isActive ? _primaryRed : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: _isActive ? 4 : 0,
                      shadowColor: _primaryRed.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isActive ? Icons.shopping_cart_rounded : Icons.remove_shopping_cart_rounded, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isActive
                              ? 'Add to Cart'
                              : (widget.foodItem?.isActive == false
                                  ? 'Out of Stock'
                                  : 'Unavailable'),
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
        final totalPrice = _effectivePrice * state.quantity;

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
                onPressed: _isActive ? () => _addToCart(state.quantity) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isActive ? _primaryRed : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: _isActive ? 4 : 0,
                  shadowColor: _primaryRed.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isActive ? Icons.shopping_cart_rounded : Icons.remove_shopping_cart_rounded, 
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isActive
                          ? 'Add to Cart'
                          : (widget.foodItem?.isActive == false
                              ? 'Out of Stock'
                              : 'Unavailable'),
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
