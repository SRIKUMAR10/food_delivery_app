import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../api_service/RazorpayApiService.dart';
import 'cart_models.dart';
import 'cart_page_Bloc.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

class CartPageUI extends StatefulWidget {
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToWallet;
  final RazorpayApiService? razorpayApiService;

  const CartPageUI({
    super.key,
    this.onNavigateToOrders,
    this.onNavigateToWallet,
    this.razorpayApiService,
  });

  @override
  State<CartPageUI> createState() => _CartPageUIState();
}

class _CartPageUIState extends State<CartPageUI> {
  static const _primaryRed = BuyerAppColors.primary;
  final TextEditingController _couponController = TextEditingController();
  bool _showCouponPicker = false;
  late final RazorpayApiService _razorpayApiService;

  static final _currFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _razorpayApiService = widget.razorpayApiService ?? RazorpayApiService();
    try {
      _razorpayApiService.initialize(
        onSuccess: (PaymentSuccessResponse response) {
          if (!mounted) return;
          context.read<CartBloc>().add(
            CartRazorpaySuccessReceived(
              response: response,
              onSuccess: (_) {
                if (widget.onNavigateToOrders != null) {
                  widget.onNavigateToOrders!();
                }
              },
              onFailure: (err) {
                _showErrorSnackBar(context, err ?? 'Payment verification failed.');
              },
            ),
          );
        },
        onFailure: (PaymentFailureResponse response) {
          if (!mounted) return;
          context.read<CartBloc>().add(
            CartRazorpayFailedReceived(
              response: response,
              onFailure: (err) {
                _showErrorSnackBar(context, err ?? 'Payment failed or cancelled.');
              },
            ),
          );
        },
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      _razorpayApiService.dispose();
    } catch (_) {}
    _couponController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: _primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showCheckoutSnackBar(BuildContext context) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Text(
          'Proceeding to checkout...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showRemovedSnackBar(BuildContext context, String itemName) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
        content: Text(
          '$itemName removed',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  void _showImagePreview(
    BuildContext context,
    String imageUrl,
    String heroTag,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 25,
                  child: GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddressSelectionSheet(BuildContext context, CartLoaded state) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Delivery Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    icon: const Icon(Icons.close_rounded, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAddressOption(
                context,
                title: 'Home',
                icon: Icons.home_rounded,
                address: state.homeAddress.isNotEmpty
                    ? state.homeAddress
                    : (state.selectedAddressType.toLowerCase() == 'home' && state.deliveryAddress.isNotEmpty
                        ? state.deliveryAddress
                        : 'No home address saved'),
                isSelected: state.selectedAddressType.toLowerCase() == 'home',
                onTap: () {
                  context.read<CartBloc>().add(const DeliveryAddressTypeChanged('Home'));
                  Navigator.pop(bottomSheetContext);
                },
              ),
              const SizedBox(height: 10),
              _buildAddressOption(
                context,
                title: 'Work',
                icon: Icons.work_rounded,
                address: state.workAddress.isNotEmpty
                    ? state.workAddress
                    : (state.selectedAddressType.toLowerCase() == 'work' && state.deliveryAddress.isNotEmpty
                        ? state.deliveryAddress
                        : 'No work address saved'),
                isSelected: state.selectedAddressType.toLowerCase() == 'work',
                onTap: () {
                  context.read<CartBloc>().add(const DeliveryAddressTypeChanged('Work'));
                  Navigator.pop(bottomSheetContext);
                },
              ),
              const SizedBox(height: 10),
              _buildAddressOption(
                context,
                title: 'Other',
                icon: Icons.location_on_rounded,
                address: state.otherAddress.isNotEmpty
                    ? state.otherAddress
                    : (state.selectedAddressType.toLowerCase() == 'other' && state.deliveryAddress.isNotEmpty
                        ? state.deliveryAddress
                        : 'No other address saved'),
                isSelected: state.selectedAddressType.toLowerCase() == 'other',
                onTap: () {
                  context.read<CartBloc>().add(const DeliveryAddressTypeChanged('Other'));
                  Navigator.pop(bottomSheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String address,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? _primaryRed.withValues(alpha: 0.06) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryRed : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? _primaryRed : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _primaryRed : const Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: _primaryRed,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: BlocBuilder<CartBloc, CartState>(
            buildWhen: (previous, current) =>
                previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
              if (state is CartLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: _primaryRed),
                );
              }

              if (state is CartError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<CartBloc>().add(const LoadCartStarted()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryRed,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final loadedState = state as CartLoaded;

              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return _buildWebLayout(context, loadedState);
                  }
                  return _buildPhoneLayout(context, loadedState);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Responsive Layouts ────────────────────────────────────────────────────────

  Widget _buildPhoneLayout(BuildContext context, CartLoaded loadedState) {
    final items = loadedState.items;
    final count = loadedState.totalCount;

    return Column(
      children: [
        _buildHeader(count),
        _buildDeliveryAddressCard(context, loadedState),
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCartCard(context, items[index]),
                          ),
                          childCount: items.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildCouponSection(context, loadedState),
                            const SizedBox(height: 14),
                            _buildPaymentMethodSection(context, loadedState),
                            const SizedBox(height: 14),
                            _buildBillDetailsCard(context, loadedState),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (items.isNotEmpty) _buildBottomBar(context, loadedState),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context, CartLoaded loadedState) {
    final items = loadedState.items;
    final count = loadedState.totalCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildHeader(count),
              _buildDeliveryAddressCard(context, loadedState),
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildCartCard(context, items[index], isDesktop: true),
                      ),
              ),
            ],
          ),
        ),
        if (items.isNotEmpty)
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(-4, 0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCouponSection(context, loadedState),
                  const SizedBox(height: 16),
                  _buildPaymentMethodSection(context, loadedState),
                  const SizedBox(height: 16),
                  _buildBillDetailsCard(context, loadedState),
                  const SizedBox(height: 20),
                  _buildBottomBar(context, loadedState),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ─── Header & Address Card ───────────────────────────────────────────────────

  Widget _buildHeader(int count) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text(
            'My Cart',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(width: 10),
          if (count > 0)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(count),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count item${count > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard(BuildContext context, CartLoaded state) {
    final addressText = state.deliveryAddress.isNotEmpty
        ? state.deliveryAddress
        : 'Select your delivery address';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: _primaryRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Delivery to: ${state.selectedAddressType}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '15-25 min',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  addressText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showAddressSelectionSheet(context, state),
            style: TextButton.styleFrom(
              foregroundColor: _primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Change',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: BuyerAppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: BuyerAppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse items and add delicious dishes to your cart.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // ─── Item Card ───────────────────────────────────────────────────────────────

  Widget _buildCartCard(
    BuildContext context,
    CartItem item, {
    bool isDesktop = false,
  }) {
    final subtotal = item.price * item.quantity;
    final hasImage = item.image != null && item.image!.trim().isNotEmpty;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: _primaryRed,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        context.read<CartBloc>().add(CartItemRemoved(item.id));
        _showRemovedSnackBar(context, item.name);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<CartBloc>().add(
                  CartItemSelectionToggled(item.id, !item.isSelected),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: isDesktop ? 10 : 12),
                width: isDesktop ? 20 : 24,
                height: isDesktop ? 20 : 24,
                decoration: BoxDecoration(
                  color: item.isSelected ? _primaryRed : Colors.transparent,
                  border: Border.all(
                    color: item.isSelected ? _primaryRed : Colors.grey.shade400,
                    width: isDesktop ? 1.5 : 2.0,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: item.isSelected
                    ? Icon(Icons.check_rounded, size: isDesktop ? 14 : 16, color: Colors.white)
                    : null,
              ),
            ),

            // Image
            Opacity(
              opacity: item.isSelected ? 1.0 : 0.4,
              child: GestureDetector(
                onTap: hasImage
                    ? () => _showImagePreview(context, item.image!.trim(), 'cart_${item.id}')
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: hasImage
                      ? Hero(
                          tag: 'cart_${item.id}',
                          child: Image.network(
                            item.image!.trim(),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.fastfood_rounded, color: Colors.grey, size: 32),
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: _primaryRed.withValues(alpha: 0.08),
                          child: const Icon(Icons.fastfood_rounded, color: _primaryRed, size: 32),
                        ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Opacity(
                opacity: item.isSelected ? 1.0 : 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _currFmt.format(item.price),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (item.selectedAddons.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: item.selectedAddons
                              .map(
                                (addon) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '+ $addon',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepper(context, item),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _currFmt.format(subtotal),
                            key: ValueKey(subtotal),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Close / Remove button
            GestureDetector(
              onTap: () {
                context.read<CartBloc>().add(CartItemRemoved(item.id));
                _showRemovedSnackBar(context, item.name);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(BuildContext context, CartItem item) {
    final isOne = item.quantity == 1;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus / Remove
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (isOne) {
                context.read<CartBloc>().add(CartItemRemoved(item.id));
                _showRemovedSnackBar(context, item.name);
              } else {
                context.read<CartBloc>().add(
                  CartItemQuantityUpdated(item.id, -1),
                );
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _primaryRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOne ? Icons.delete_outline_rounded : Icons.remove_rounded,
                size: 16,
                color: _primaryRed,
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                '${item.quantity}',
                key: ValueKey(item.quantity),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ),
          ),

          // Plus
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<CartBloc>().add(CartItemQuantityUpdated(item.id, 1));
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _primaryRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 16,
                color: _primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Coupon Code Section ─────────────────────────────────────────────────────

  Widget _buildCouponSection(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_offer_rounded, size: 18, color: _primaryRed),
              SizedBox(width: 8),
              Text(
                'Coupons & Offers',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Manual code entry row
          if (state.appliedCoupon == null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _couponController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _couponController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (code) {
                      if (code.trim().isNotEmpty) {
                        context.read<CartBloc>().add(ApplyCouponCodeRequested(code));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: state.isCouponLoading || _couponController.text.trim().isEmpty
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          context
                              .read<CartBloc>()
                              .add(ApplyCouponCodeRequested(_couponController.text));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: state.isCouponLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ] else ...[
            // Applied coupon banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 20, color: Colors.green.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.appliedCoupon!.code} applied',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.green.shade900,
                          ),
                        ),
                        Text(
                          'You save ${_currFmt.format(state.discountAmount)}',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<CartBloc>().add(const CouponRemoved());
                      _couponController.clear();
                    },
                    child: Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Coupon feedback message
          if (state.couponMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.couponMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: state.appliedCoupon != null ? Colors.green.shade700 : Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Available coupons dropdown toggle
          if (state.availableCoupons.isNotEmpty && state.appliedCoupon == null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _showCouponPicker = !_showCouponPicker),
              child: Row(
                children: [
                  Icon(Icons.discount_outlined, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Text(
                    '${state.availableCoupons.length} coupon${state.availableCoupons.length > 1 ? 's' : ''} available for your items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showCouponPicker ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            if (_showCouponPicker) ...[
              const SizedBox(height: 8),
              ...state.availableCoupons.map((coupon) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coupon.code,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                coupon.isPercentage
                                    ? '${coupon.discountAmount.toStringAsFixed(0)}% OFF'
                                    : '₹${coupon.discountAmount.toStringAsFixed(0)} OFF',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.read<CartBloc>().add(CouponApplied(coupon));
                            setState(() => _showCouponPicker = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  // ─── Itemized Bill Details Card ──────────────────────────────────────────────

  Widget _buildBillDetailsCard(BuildContext context, CartLoaded state) {
    final subtotal = state.totalAmount;
    final discount = state.discountAmount;
    final deliveryFee = state.deliveryFee;
    final taxes = state.taxAmount;
    final platformFee = state.platformFee;
    final grandTotal = state.finalAmount;

    final displayGrandTotal = grandTotal.roundToDouble();
    final roundOff = displayGrandTotal - grandTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 12),

          // Item Total
          _buildBillRow('Item Total', _currFmt.format(subtotal)),
          const SizedBox(height: 8),

          // Discount
          if (discount > 0) ...[
            _buildBillRow(
              'Coupon Discount',
              '-${_currFmt.format(discount)}',
              valueColor: Colors.green.shade700,
            ),
            const SizedBox(height: 8),
          ],

          // Delivery Partner Fee
          _buildBillRow(
            'Delivery Fee',
            deliveryFee == 0 ? 'FREE' : _currFmt.format(deliveryFee),
            valueColor: deliveryFee == 0 ? Colors.green.shade700 : const Color(0xFF1C1C1C),
          ),
          const SizedBox(height: 8),

          // Platform Fee
          if (platformFee > 0) ...[
            _buildBillRow('Platform Fee', _currFmt.format(platformFee)),
            const SizedBox(height: 8),
          ],

          // Taxes & Charges
          if (taxes > 0) ...[
            _buildBillRow('GST & Restaurant Charges (5%)', _currFmt.format(taxes)),
            const SizedBox(height: 8),
          ],

          // Round off
          if (roundOff != 0) ...[
            _buildBillRow(
              'Round Off',
              '${roundOff > 0 ? '+' : ''}₹${roundOff.abs().toStringAsFixed(2)}',
              valueColor: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
          ],

          const Divider(height: 20),

          // To Pay (Grand Total)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _currFmt.format(displayGrandTotal),
                  key: ValueKey(displayGrandTotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context, CartLoaded state) {
    return Container(
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
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: _primaryRed, size: 20),
              SizedBox(width: 8),
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPaymentOptionTile(
            context: context,
            title: 'Razorpay Online',
            subtitle: 'UPI, Cards, NetBanking, Wallets',
            icon: Icons.credit_card_rounded,
            iconColor: const Color(0xFF2563EB),
            isSelected: state.selectedPaymentMethod == CartPaymentMethod.razorpay,
            onTap: () {
              context.read<CartBloc>().add(
                const CartPaymentMethodSelected(CartPaymentMethod.razorpay),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildPaymentOptionTile(
            context: context,
            title: 'Cash on Delivery (COD)',
            subtitle: 'Pay cash at your doorstep',
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFF16A34A),
            isSelected: state.selectedPaymentMethod == CartPaymentMethod.cod,
            onTap: () {
              context.read<CartBloc>().add(
                const CartPaymentMethodSelected(CartPaymentMethod.cod),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildPaymentOptionTile(
            context: context,
            title: 'FoodGo Wallet',
            subtitle: 'Balance: ₹${state.walletBalance.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: const Color(0xFF9333EA),
            isSelected: state.selectedPaymentMethod == CartPaymentMethod.wallet,
            trailingWidget: state.walletBalance < state.finalAmount
                ? GestureDetector(
                    onTap: widget.onNavigateToWallet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Top-up',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _primaryRed,
                        ),
                      ),
                    ),
                  )
                : null,
            onTap: () {
              context.read<CartBloc>().add(
                const CartPaymentMethodSelected(CartPaymentMethod.wallet),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F2) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryRed : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              trailingWidget,
              const SizedBox(width: 8),
            ],
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? _primaryRed : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }

  // ─── Sticky Bottom Bar ───────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, CartLoaded state) {
    final displayAmount = state.finalAmount.roundToDouble();

    String checkoutButtonText = 'Checkout';
    if (state.selectedPaymentMethod == CartPaymentMethod.razorpay) {
      checkoutButtonText = 'Pay ${_currFmt.format(displayAmount)}';
    } else if (state.selectedPaymentMethod == CartPaymentMethod.cod) {
      checkoutButtonText = 'Place COD Order';
    } else if (state.selectedPaymentMethod == CartPaymentMethod.wallet) {
      checkoutButtonText = 'Pay from Wallet';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Payable',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _currFmt.format(displayAmount),
                    key: ValueKey(displayAmount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: state.isCheckingOut
                    ? null
                    : () {
                        _showCheckoutSnackBar(context);
                        context.read<CartBloc>().add(
                          CartCheckoutRequested(
                            onOpenRazorpay: (orderId, amount, email, phone) {
                              _razorpayApiService.startPayment(
                                amount: amount,
                                email: email,
                                phone: phone,
                                orderId: orderId,
                                description: 'Food Order Payment',
                              );
                            },
                            onSuccess: (_) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              if (widget.onNavigateToOrders != null) {
                                widget.onNavigateToOrders!();
                              }
                            },
                            onInsufficientBalance: (message) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              _showErrorSnackBar(context, message ?? 'Insufficient wallet balance.');
                              if (widget.onNavigateToWallet != null) {
                                widget.onNavigateToWallet!();
                              }
                            },
                            onFailure: (message) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              _showErrorSnackBar(context, message ?? 'Checkout failed.');
                            },
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primaryRed.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: state.isCheckingOut
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              checkoutButtonText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
