import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../repositories/seller_wallet_repository.dart';
import '../../../api_service/seller_wallet_service.dart';
import 'seller_wallet_page__bloc.dart';
import 'seller_wallet_page__event.dart';
import 'seller_wallet_page__state.dart';
import '../seller_request_payout_page/seller_request_payout_page__ui.dart';
import '../seller_payout_history_page/seller_payout_history_page__ui.dart';
import '../seller_payment_page/seller_payment_page_ui.dart';

class SellerWalletPage extends StatelessWidget {
  const SellerWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerWalletBloc(
        repository: SellerWalletRepository(service: SellerWalletService()),
      )..add(const LoadWalletData()),
      child: const SellerWalletView(),
    );
  }
}

class SellerWalletView extends StatefulWidget {
  const SellerWalletView({super.key});

  @override
  State<SellerWalletView> createState() => _SellerWalletViewState();
}

class _SellerWalletViewState extends State<SellerWalletView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SellerWalletBloc>().add(const LoadMorePayoutHistory());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  String _formatCurrency(double amount, BuildContext context) {
    // Localization & Internationalization: Formats currency dynamically based on local setting
    final Locale currentLocale = Localizations.localeOf(context);
    final format = NumberFormat.simpleCurrency(
      locale: currentLocale.toString(),
      name: 'INR', // Default name as shown in the mockup
    );
    // Visual pixel-perfect matching for rupees format
    return format.format(amount);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: BlocListener<SellerWalletBloc, SellerWalletState>(
          listener: (context, state) {
            if (state is SellerWalletLoaded) {
              if (state.withdrawalSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Withdrawal request completed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state.withdrawalError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.withdrawalError!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: RefreshIndicator(
            color: const Color(0xFFE52929),
            onRefresh: () async {
              context.read<SellerWalletBloc>().add(const RefreshWalletData());
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: BlocBuilder<SellerWalletBloc, SellerWalletState>(
                        builder: (context, state) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildStateContent(context, state),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, SellerWalletState state) {
    if (state is SellerWalletLoading) {
      return _buildSkeletonLoader();
    } else if (state is SellerWalletError) {
      return _buildErrorState(context, state.message);
    } else if (state is SellerWalletLoaded) {
      return _buildContent(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, SellerWalletLoaded state) {
    return Column(
      key: const ValueKey('loaded_wallet_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your balance and withdrawals',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              color: const Color(0xFF111827),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Available Balance Card
        _buildBalanceCard(context, state),
        const SizedBox(height: 20),

        // Action Buttons Row
        _buildActionButtons(context, state),
        const SizedBox(height: 32),

        // Payout History Header
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SellerPayoutHistoryPage(),
              ),
            );
          },
          child: Text(
            'Payout History',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Payout History List
        _buildPayoutHistoryList(context, state),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, SellerWalletLoaded state) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF4F6FB,
                ), // Light bluish background matching mockup
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(state.balance, context),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, SellerWalletLoaded state) {
    return Row(
      children: [
        // Withdraw Button
        Expanded(
          child: _HoverableButton(
            height: 52,
            gradient: const LinearGradient(
              colors: [Color(0xFFE52929), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shadowColor: const Color(0xFFE52929).withValues(alpha: 0.2),
            onPressed: state.isWithdrawing
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerRequestPayoutPage(),
                    ),
                  ),
            child: state.isWithdrawing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Withdraw', 
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        // Transactions Button
        Expanded(
          child: _HoverableButton(
            height: 52,
            color: Colors.white,
            borderColor: const Color(0xFFE2E8F0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SellerPaymentPage(),
                ),
              );
            },
            child: Text(
              'Transactions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutHistoryList(
    BuildContext context,
    SellerWalletLoaded state,
  ) {
    if (state.payouts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No payout history found',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.payouts.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final payout = state.payouts[index];
              return _PayoutListItem(payout: payout, index: index);
            },
          ),
          if (state.isPaginatedLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(color: Color(0xFFE52929)),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      key: const ValueKey('loading_wallet_skeleton'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          width: 150,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      key: const ValueKey('error_wallet_content'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load Wallet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<SellerWalletBloc>().add(const LoadWalletData()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE52929),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _PayoutListItem extends StatefulWidget {
  final PayoutItem payout;
  final int index;

  const _PayoutListItem({required this.payout, required this.index});

  @override
  State<_PayoutListItem> createState() => _PayoutListItemState();
}

class _PayoutListItemState extends State<_PayoutListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _delayTimer;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _delayTimer = Timer(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic locale currency and date format
    final Locale currentLocale = Localizations.localeOf(context);
    final currencyFormatter = NumberFormat.currency(
      locale: currentLocale.toString(),
      symbol: '₹',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM, yyyy', currentLocale.toString());

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xFFF8FAFC) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Column (Payout code + Amount)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.payout.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormatter.format(widget.payout.amount),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                // Right Column (Status + Date)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.payout.status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981), // Emerald green for Paid status
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateFormatter.format(widget.payout.date),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverableButton extends StatefulWidget {
  final double height;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final VoidCallback? onPressed;
  final Widget child;

  const _HoverableButton({
    required this.height,
    this.gradient,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.onPressed,
    required this.child,
  });

  @override
  State<_HoverableButton> createState() => _HoverableButtonState();
}

class _HoverableButtonState extends State<_HoverableButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        transform: Matrix4.identity()..scale(_isHovered && widget.onPressed != null ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: widget.color,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(12),
          border: widget.borderColor != null ? Border.all(color: widget.borderColor!) : null,
          boxShadow: widget.shadowColor != null && _isHovered
              ? [BoxShadow(color: widget.shadowColor!, blurRadius: 12, offset: const Offset(0, 6))]
              : widget.shadowColor != null
                  ? [BoxShadow(color: widget.shadowColor!, blurRadius: 8, offset: const Offset(0, 4))]
                  : null,
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
