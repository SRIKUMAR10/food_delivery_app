import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../repositories/seller_payout_history_repository.dart';
import '../../../api_service/seller_payout_history_service.dart';
import '../seller_wallet_page/seller_wallet_page__state.dart';
import 'seller_payout_history_page__bloc.dart';
import 'seller_payout_history_page__event.dart';
import 'seller_payout_history_page__state.dart';

class SellerPayoutHistoryPage extends StatelessWidget {
  const SellerPayoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerPayoutHistoryBloc(
        repository: SellerPayoutHistoryRepository(
          service: SellerPayoutHistoryService(),
        ),
      )..add(const LoadPayoutHistory()),
      child: const SellerPayoutHistoryView(),
    );
  }
}

class SellerPayoutHistoryView extends StatefulWidget {
  const SellerPayoutHistoryView({super.key});

  @override
  State<SellerPayoutHistoryView> createState() =>
      _SellerPayoutHistoryViewState();
}

class _SellerPayoutHistoryViewState extends State<SellerPayoutHistoryView> {
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
      context.read<SellerPayoutHistoryBloc>().add(
        const LoadMorePayoutHistory(),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final horizontalPadding = isDesktop
        ? size.width * 0.25
        : (isTablet ? size.width * 0.15 : 20.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Payout History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFE11D48),
          onRefresh: () async {
            context.read<SellerPayoutHistoryBloc>().add(
              const RefreshPayoutHistory(),
            );
          },
          child: BlocBuilder<SellerPayoutHistoryBloc, SellerPayoutHistoryState>(
            buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStateContent(context, state, horizontalPadding),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    SellerPayoutHistoryState state,
    double horizontalPadding,
  ) {
    if (state is SellerPayoutHistoryLoading) {
      return _buildSkeletonLoader(horizontalPadding);
    } else if (state is SellerPayoutHistoryError) {
      return _buildErrorState(context, state.message, horizontalPadding);
    } else if (state is SellerPayoutHistoryLoaded) {
      return _buildHistoryContent(context, state, horizontalPadding);
    }
    return const SizedBox.shrink();
  }

  Widget _buildHistoryContent(
    BuildContext context,
    SellerPayoutHistoryLoaded state,
    double horizontalPadding,
  ) {
    if (state.payouts.isEmpty) {
      return _buildEmptyState(horizontalPadding);
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16.0,
      ),
      itemCount: state.payouts.length + (state.isPaginatedLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.payouts.length) {
          final payout = state.payouts[index];
          return _PayoutHistoryItem(payout: payout, index: index);
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE11D48)),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSkeletonLoader(double horizontalPadding) {
    return ListView.builder(
      key: const ValueKey('loading_skeleton'),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double horizontalPadding) {
    return Center(
      key: const ValueKey('empty_state'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Payout History',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any payout transaction records yet.",
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    double horizontalPadding,
  ) {
    return Center(
      key: const ValueKey('error_state'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load details',
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
              onPressed: () => context.read<SellerPayoutHistoryBloc>().add(
                const LoadPayoutHistory(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutHistoryItem extends StatefulWidget {
  final PayoutItem payout;
  final int index;

  const _PayoutHistoryItem({required this.payout, required this.index});

  @override
  State<_PayoutHistoryItem> createState() => _PayoutHistoryItemState();
}

class _PayoutHistoryItemState extends State<_PayoutHistoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _delayTimer;

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
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.payout.status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
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
