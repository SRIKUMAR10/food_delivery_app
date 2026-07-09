// lib/Buyer Bloc Architecture/Cart Page/cart_page_UI.dart
//
// The visual layer for the Cart Feature.
// Uses BlocBuilder to listen to CartBloc and automatically rebuilds.
// Includes responsive design: a stacked layout for phones, and a side-by-side layout for web.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'cart_models.dart';
import 'cart_page_Bloc.dart';

class CartPageUI extends StatefulWidget {
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToWallet;

  const CartPageUI({
    super.key,
    this.onNavigateToOrders,
    this.onNavigateToWallet,
  });

  @override
  State<CartPageUI> createState() => _CartPageUIState();
}

class _CartPageUIState extends State<CartPageUI> {
  static const _primaryRed = Color(0xFFEF2A39);

  static final _currFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    // Ensure the cart is loaded when we open the page.
    context.read<CartBloc>().add(const LoadCartStarted());
  }

  void _showCheckoutSnackBar(BuildContext context) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
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
          style: TextStyle(color: Colors.white, fontSize: 13),
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
                    onTap: () => Navigator.pop(context),
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
        backgroundColor: const Color(0xFFF6F6F6),
        body: SafeArea(
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: _primaryRed),
                );
              }

              if (state is CartError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              final loadedState = state as CartLoaded;
              final items = loadedState.items;
              final total = loadedState.totalAmount;
              final count = loadedState.totalCount;

              return LayoutBuilder(
                builder: (context, constraints) {
                  // If the screen is wide enough (e.g., Web or Tablet landscape), use side-by-side layout.
                  if (constraints.maxWidth > 800) {
                    return _buildWebLayout(context, items, total, count);
                  }
                  // Otherwise, use standard stacked phone layout.
                  return _buildPhoneLayout(context, items, total, count);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Responsive Layouts ────────────────────────────────────────────────────────

  /// Builds the standard stacked layout for mobile phones.
  Widget _buildPhoneLayout(
    BuildContext context,
    List<CartItem> items,
    double total,
    int count,
  ) {
    return Column(
      children: [
        _buildHeader(count),
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : _buildItemList(items, isDesktop: false),
        ),
        if (items.isNotEmpty) _buildBottomBar(context, total),
      ],
    );
  }

  /// Builds a side-by-side layout for web and tablet, showing items on the left and summary on the right.
  Widget _buildWebLayout(
    BuildContext context,
    List<CartItem> items,
    double total,
    int count,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Items list
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeader(count),
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState()
                    : _buildItemList(items, isDesktop: true),
              ),
            ],
          ),
        ),
        // Right side: Order Summary sticky panel
        if (items.isNotEmpty)
          Container(
            width: 350,
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1C1C1C),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.name}',
                                style: TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _currFmt.format(item.price * item.quantity),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomBar(context, total),
              ],
            ),
          ),
      ],
    );
  }

  // ─── Component Builders ────────────────────────────────────────────────────────

  /// Header showing the title and item count pill.
  Widget _buildHeader(int count) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          Text(
            'My Cart',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(width: 10),
          if (count > 0)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(count),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count item${count > 1 ? 's' : ''}',
                  style: TextStyle(
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

  /// Empty state UI when no items exist in the cart.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEF2A39).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: const Color(0xFFEF2A39).withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse items and add them to your cart.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  /// List of cart items.
  Widget _buildItemList(List<CartItem> items, {bool isDesktop = false}) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildCartCard(context, items[index], isDesktop: isDesktop),
    );
  }

  /// Individual cart item card with swipe-to-dismiss and stepper.
  Widget _buildCartCard(
    BuildContext context,
    CartItem item, {
    bool isDesktop = false,
  }) {
    final subtotal = item.price * item.quantity;
    const fallbackImage =
        'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';

    final src = (item.image != null && item.image!.trim().isNotEmpty)
        ? item.image!.trim()
        : fallbackImage;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
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
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Selection Checkbox
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
                    ? Icon(
                        Icons.check_rounded,
                        size: isDesktop ? 14 : 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),

            // Image
            Opacity(
              opacity: item.isSelected ? 1.0 : 0.4,
              child: GestureDetector(
                onTap: () => _showImagePreview(context, src, 'cart_${item.id}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Hero(
                    tag: 'cart_${item.id}',
                    child: Image.network(
                      src,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.fastfood_rounded,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
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
                            style: TextStyle(
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

            // Delete X button
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

  /// The quantity controller (+ and - buttons).
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
          // Minus / Trash
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C1C1C),
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

  /// Sticky bottom bar with Total Amount and Checkout button.
  Widget _buildBottomBar(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _currFmt.format(total),
                  key: ValueKey(total),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C1C1C),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _showCheckoutSnackBar(context);
                context.read<CartBloc>().add(
                  CartCheckoutRequested(
                    onSuccess: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      if (widget.onNavigateToOrders != null) {
                        widget.onNavigateToOrders!();
                      }
                    },
                    onInsufficientBalance: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Insufficient balance to checkout.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFFEF2A39),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 4),
                        ),
                      );

                      if (widget.onNavigateToWallet != null) {
                        widget.onNavigateToWallet!();
                      }
                    },
                  ),
                );
              },
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
                  const Icon(Icons.bolt_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Checkout',
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
      ),
    );
  }
}
