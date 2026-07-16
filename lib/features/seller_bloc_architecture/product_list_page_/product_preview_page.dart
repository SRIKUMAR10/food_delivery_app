import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product_model.dart';
import '../../../../widgets/device_frame.dart';

class ProductPreviewPage extends StatefulWidget {
  final Product product;

  const ProductPreviewPage({super.key, required this.product});

  @override
  State<ProductPreviewPage> createState() => _ProductPreviewPageState();
}

class _ProductPreviewPageState extends State<ProductPreviewPage>
    with TickerProviderStateMixin {
  bool _isPreviewDesktop = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  static const _primaryRed = Color(0xFFEF2A39);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB), // Darker bg behind the preview container
      appBar: AppBar(
        title: const Text('Buyer View Preview', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewToggle(Icons.phone_iphone_rounded, 'Mobile', !_isPreviewDesktop, () {
                    setState(() => _isPreviewDesktop = false);
                  }),
                  _buildViewToggle(Icons.desktop_mac_rounded, 'Desktop', _isPreviewDesktop, () {
                    setState(() => _isPreviewDesktop = true);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: DeviceFrame(
            key: ValueKey(_isPreviewDesktop ? 'desktop' : 'mobile'),
            isDesktop: _isPreviewDesktop,
            child: _isPreviewDesktop ? _buildWideLayout() : _buildMobileLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? _primaryRed : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _primaryRed : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile Layout ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 400 * 0.8, // Approximation for preview
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
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
              actions: [_buildFavouriteButton()],
              flexibleSpace: FlexibleSpaceBar(background: _buildHeroImage()),
            ),
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
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeroImage(),
                  Positioned(
                    top: 20,
                    left: 20,
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
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildFavouriteButton(),
                  ),
                ],
              ),
            ),
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
            widget.product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
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
          'Seller ID: ${widget.product.sellerId.length > 10 ? '${widget.product.sellerId.substring(0, 10)}...' : widget.product.sellerId}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          widget.product.prepTime.isNotEmpty ? widget.product.prepTime : '25–35 min',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        if (widget.product.calories.isNotEmpty) ...[
          const SizedBox(width: 16),
          const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            widget.product.calories,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          widget.product.description.isNotEmpty
              ? widget.product.description
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              _currFmt.format(widget.product.discountPrice > 0 ? widget.product.discountPrice : widget.product.price),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _primaryRed,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton(
                icon: Icons.remove_rounded,
                enabled: false,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '1',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
              ),
              _qtyButton(
                icon: Icons.add_rounded,
                enabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavouriteButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
        padding: const EdgeInsets.all(10),
        child: const Icon(
          Icons.favorite_border_rounded,
          color: _primaryRed,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final url = widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : null;
    const fallbackUrl = 'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';

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
    return Container(
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            double starValue = index + 1.0;
            if (widget.product.rating >= starValue) {
              return const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 15,
              );
            } else if (widget.product.rating >= starValue - 0.5) {
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
            widget.product.rating > 0 ? widget.product.rating.toStringAsFixed(1) : 'New',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsAndReviewsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: null, // Disabled in preview
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

  Widget _qtyButton({
    required IconData icon,
    required bool enabled,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: enabled ? _primaryRed.withValues(alpha: 0.5) : Colors.grey.shade300,
        shape: BoxShape.circle,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _primaryRed.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildStickyBottom() {
    final totalPrice = widget.product.discountPrice > 0 ? widget.product.discountPrice : widget.product.price;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                _currFmt.format(totalPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: null, // Disabled in preview
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryRed.withValues(alpha: 0.5),
                  disabledBackgroundColor: _primaryRed.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_rounded, size: 20),
                    SizedBox(width: 8),
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
  }

  Widget _buildDesktopStickyBottom() {
    final totalPrice = widget.product.discountPrice > 0 ? widget.product.discountPrice : widget.product.price;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total Amount',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            Text(
              _currFmt.format(totalPrice),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1C),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: null, // Disabled in preview
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed.withValues(alpha: 0.5),
              disabledBackgroundColor: _primaryRed.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_rounded, size: 20),
                SizedBox(width: 8),
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
  }
}
