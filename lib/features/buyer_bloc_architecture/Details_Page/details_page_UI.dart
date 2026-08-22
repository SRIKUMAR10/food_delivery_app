import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_seller_repository.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import '../Cart Page/cart_page.dart';
import '../Favorites_Page/favorites_bloc.dart';
import '../Favorites_Page/favorites_event.dart';
import '../Favorites_Page/favorites_state.dart';
import '../Favorites_Page/favorites_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/food_item_mapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Rating_page/reviews_list_screen.dart';
import '../../seller_bloc_architecture/product_list_page_/product_image_carousel.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/core/services/seller_status_service.dart';
import 'details_page_Bloc.dart';
import 'details_page_Event.dart';
import 'details_page_State.dart';
import 'package:food_delivery_app/core/widgets/shimmer_loader.dart';
import '../buyer_login_page/buyer_login_page_ui.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

// ─── Details Page UI ─────────────────────────────────────────────────────────

class DetailsPageUI extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String description;
  final String sellerId;
  final List<String>? imageUrls;
  final FoodItem? foodItem;
  final VoidCallback? onNavigateToCart;
  final DetailsBloc? detailsBloc;
  final double? distanceKm;

  const DetailsPageUI({
    super.key,
    this.id = '',
    this.name = '',
    this.price = 0.0,
    this.description = '',
    this.sellerId = '',
    this.imageUrls,
    this.foodItem,
    this.onNavigateToCart,
    this.detailsBloc,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveId = id.isNotEmpty ? id : (foodItem?.id ?? '');
    final effectiveName = name.isNotEmpty ? name : (foodItem?.name ?? '');
    final effectivePrice = price > 0 ? price : (foodItem?.price ?? 0.0);
    final effectiveDescription = description.isNotEmpty ? description : (foodItem?.description ?? '');
    final effectiveSellerId = sellerId.isNotEmpty ? sellerId : (foodItem?.sellerId ?? '');

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
          id: effectiveId,
          name: effectiveName,
          price: effectivePrice,
          description: effectiveDescription,
          sellerId: effectiveSellerId,
          imageUrls: urls,
          foodItem: foodItem,
          onNavigateToCart: onNavigateToCart,
          distanceKm: distanceKm,
        ),
      );
    }

    return BlocProvider(
      create: (_) => DetailsBloc()..add(LoadDetailsRating(foodId: effectiveId)),
      child: _DetailsPageContent(
        id: effectiveId,
        name: effectiveName,
        price: effectivePrice,
        description: effectiveDescription,
        sellerId: effectiveSellerId,
        imageUrls: urls,
        foodItem: foodItem,
        onNavigateToCart: onNavigateToCart,
        distanceKm: distanceKm,
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
  final VoidCallback? onNavigateToCart;
  final double? distanceKm;

  const _DetailsPageContent({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.sellerId,
    this.imageUrls,
    this.foodItem,
    this.onNavigateToCart,
    this.distanceKm,
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
  StreamSubscription<DocumentSnapshot>? _productDocSub;
  FoodItem? _liveFoodItem;

  static const _primaryRed = BuyerAppColors.primary;
  static const _bgColor = Color(0xFFF8F8F8);

  final NumberFormat _currFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  FoodItem? get _currentFoodItem => _liveFoodItem ?? widget.foodItem;

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
    _watchProductDoc();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _sellerStatusSub?.cancel();
    _productDocSub?.cancel();
    super.dispose();
  }

  void _watchProductDoc() {
    final effectiveId = widget.id.isNotEmpty ? widget.id : (widget.foodItem?.id ?? '');
    if (effectiveId.isEmpty) return;

    try {
      _productDocSub?.cancel();
      _productDocSub = FirebaseFirestore.instance
          .collection('products')
          .doc(effectiveId)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null && mounted) {
          final p = Product.fromMap(doc.id, doc.data()!);
          setState(() {
            _liveFoodItem = FoodItemMapper.toViewModel(p);
          });
        }
      });
    } catch (e) {
      debugPrint('Product doc stream note: $e');
    }
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
    try {
      _sellerStatusSub?.cancel();
      final service = SellerStatusService();
      _sellerStatusSub = service.watchSellerStatus(widget.sellerId).listen((status) {
        if (mounted) {
          setState(() => _sellerAvailability = status);
        }
      });
    } catch (e) {
      debugPrint('Failed to watch seller status: $e');
    }
  }

  double _parseAddonPrice(String addon) {
    final match = RegExp(r'(?:\+|\:|\₹)\s*(\d+(?:\.\d+)?)').firstMatch(addon);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  double get _totalAddonsPrice {
    double total = 0.0;
    for (final addon in _selectedAddons) {
      total += _parseAddonPrice(addon);
    }
    return total;
  }

  double get _baseProductPrice {
    final food = _currentFoodItem;
    if (food != null &&
        food.discountPrice > 0 &&
        food.discountPrice < (food.price > 0 ? food.price : widget.price)) {
      return food.discountPrice;
    }
    return (food != null && food.price > 0) ? food.price : widget.price;
  }

  double get _effectivePrice {
    return _baseProductPrice + _totalAddonsPrice;
  }

  bool get _isActive {
    final food = _currentFoodItem;
    final productActive = (food?.status != 'outOfStock') && (food?.isActive ?? true);
    final sellerAvailable = _sellerAvailability?.isAvailable ?? true;
    return productActive && sellerAvailable;
  }

  String? get _primaryImage {
    final food = _currentFoodItem;
    if (widget.imageUrls?.isNotEmpty == true) return widget.imageUrls!.first;
    if (food?.imageUrls.isNotEmpty == true) return food!.imageUrls.first;
    return food?.image;
  }

  void _addToCart(int quantity) {
    if (!_isActive) return;
    final isLoggedIn = context.read<IAuthService>().currentUserId != null;
    if (!isLoggedIn) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const BuyerLoginPageUI()),
      );
      return;
    }
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

    widget.onNavigateToCart?.call();
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
                          const SizedBox(height: 10),
                          _buildRestaurantInfo(),
                          const SizedBox(height: 16),
                          _buildAvailabilityCard(),
                          const SizedBox(height: 18),
                          _buildDescription(),
                          const SizedBox(height: 20),
                          _buildIngredientsSection(),
                          const SizedBox(height: 20),
                          _buildAddonsSection(),
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
                        const SizedBox(height: 18),
                        _buildAvailabilityCard(),
                        const SizedBox(height: 20),
                        _buildDescription(),
                        const SizedBox(height: 20),
                        _buildIngredientsSection(),
                        const SizedBox(height: 20),
                        _buildAddonsSection(),
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
    final food = _currentFoodItem;
    final foodType = food?.foodType ?? '';
    final isVeg = foodType.toLowerCase() == 'veg' || foodType.toLowerCase() == 'vegetarian';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (foodType.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4, right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isVeg ? Colors.green : Colors.red, 
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVeg ? Icons.circle : Icons.change_history,
                  size: 8,
                  color: isVeg ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 3),
                Text(
                  isVeg ? 'VEG' : 'NON-VEG',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: isVeg ? Colors.green : Colors.red,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Text(
            food?.name.isNotEmpty == true ? food!.name : widget.name,
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
        child: const Row(
          children: [
            SkeletonBox(width: 40, height: 40, borderRadius: 8),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 12, borderRadius: 4),
                SizedBox(height: 6),
                SkeletonBox(width: 80, height: 10, borderRadius: 4),
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
                      widget.distanceKm != null
                          ? '${estimateDeliveryTimeMinutes(widget.distanceKm!)} min delivery'
                          : (seller.deliveryTime?.isNotEmpty == true
                              ? '${seller.deliveryTime!} delivery'
                              : (widget.foodItem?.prepTime.isNotEmpty == true
                                  ? '${widget.foodItem!.prepTime} prep'
                                  : '25-35 min delivery')),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    if (widget.distanceKm != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.distanceKm!.toStringAsFixed(1)} km away',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ] else if (seller.businessDetails?.isNotEmpty == true) ...[
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

  Widget _buildAvailabilityCard() {
    final food = _currentFoodItem;
    final isProductInStock = (food?.status != 'outOfStock') && (food?.isActive ?? true);
    final isSellerOpen = _sellerAvailability?.isAvailable ?? true;
    final isAvailableNow = isProductInStock && isSellerOpen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isAvailableNow ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAvailableNow ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isAvailableNow ? Colors.green.shade600 : Colors.red.shade600,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailableNow ? Icons.check_rounded : Icons.close_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAvailableNow ? 'Available for Ordering' : 'Currently Unavailable',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isAvailableNow ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAvailableNow ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isAvailableNow ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isAvailableNow ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  !isSellerOpen
                      ? 'Restaurant is currently closed for orders'
                      : (!isProductInStock
                          ? 'This dish is temporarily out of stock'
                          : 'Freshly prepared upon your order confirmation'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isAvailableNow ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final food = _currentFoodItem;
    final hasMetrics = food != null &&
        (food.calories.isNotEmpty || food.spicyLevel.isNotEmpty || food.portionSize.isNotEmpty);
    final desc = (food?.description.trim().isNotEmpty == true)
        ? food!.description.trim()
        : widget.description.trim();

    if (!hasMetrics && desc.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMetrics) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (food.calories.isNotEmpty)
                _buildInfoChip(Icons.local_fire_department_outlined, '${food.calories} Cal'),
              if (food.spicyLevel.isNotEmpty)
                _buildInfoChip(Icons.whatshot_rounded, food.spicyLevel, color: Colors.deepOrange),
              if (food.portionSize.isNotEmpty)
                _buildInfoChip(Icons.restaurant_menu_rounded, food.portionSize),
            ],
          ),
          if (desc.isNotEmpty) const SizedBox(height: 16),
        ],
        if (desc.isNotEmpty) ...[
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade600,
              height: 1.65,
            ),
          ),
        ],
      ],
    );
  }

  List<String> get _effectiveIngredients {
    final food = _currentFoodItem;
    if (food != null && food.ingredients.isNotEmpty) {
      return food.ingredients;
    }
    return const [];
  }

  Widget _buildIngredientsSection() {
    final list = _effectiveIngredients;
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.eco_rounded, size: 18, color: Colors.green),
            SizedBox(width: 6),
            Text(
              'Ingredients & Recipe',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((ingredient) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ingredient,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<String> get _effectiveAddons {
    final food = _currentFoodItem;
    if (food != null && food.addons.isNotEmpty) {
      return food.addons;
    }
    return const [];
  }

  Widget _buildAddonsSection() {
    final list = _effectiveAddons;
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune_rounded, size: 18, color: _primaryRed),
            const SizedBox(width: 6),
            const Text(
              'Add-ons & Customizations',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const Spacer(),
            if (_selectedAddons.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_selectedAddons.length} selected',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _primaryRed,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((addon) {
            final isSelected = _selectedAddons.contains(addon);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryRed : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _primaryRed : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _primaryRed.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      addon,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
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
              _currFmt.format(_effectivePrice),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _primaryRed,
              ),
            ),
            if (_totalAddonsPrice > 0) ...[
              const SizedBox(height: 2),
              Text(
                '+ ${_currFmt.format(_totalAddonsPrice)} add-ons',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ],
        ),

        // Quantity Selector
        BlocBuilder<DetailsBloc, DetailsState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
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
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
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
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const BuyerLoginPageUI()),
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
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
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
    IRatingRepository? ratingRepo;
    try {
      ratingRepo = context.read<IRatingRepository>();
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewsListScreen(
        productId: widget.id,
        productName: widget.name,
        ratingRepository: ratingRepo,
      ),
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
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
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
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
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
