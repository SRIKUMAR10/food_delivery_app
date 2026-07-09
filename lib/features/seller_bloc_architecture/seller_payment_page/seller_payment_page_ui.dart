import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'seller_payment_page_bloc.dart';
import 'seller_payment_page_event.dart';
import 'seller_payment_page_state.dart';

class SellerPaymentPage extends StatelessWidget {
  const SellerPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerPaymentPageBloc()..add(LoadPaymentData()),
      child: const _SellerPaymentView(),
    );
  }
}

class _SellerPaymentView extends StatefulWidget {
  const _SellerPaymentView();

  @override
  State<_SellerPaymentView> createState() => _SellerPaymentViewState();
}

class _SellerPaymentViewState extends State<_SellerPaymentView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final horizontalPadding = isDesktop ? size.width * 0.15 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Payments',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF4F46E5),
          onRefresh: () async {
            context.read<SellerPaymentPageBloc>().add(RefreshPaymentData());
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                child:
                    BlocBuilder<SellerPaymentPageBloc, SellerPaymentPageState>(
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _buildStateContent(
                            context,
                            state,
                            isTablet || isDesktop,
                          ),
                        );
                      },
                    ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    SellerPaymentPageState state,
    bool isWideScreen,
  ) {
    if (state is SellerPaymentPageLoading) {
      return _buildSkeletonLoader();
    } else if (state is SellerPaymentPageError) {
      return _buildErrorState(context, state.message);
    } else if (state is SellerPaymentPageLoaded) {
      return _buildContent(context, state.data);
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, PaymentData data) {
    return Column(
      key: const ValueKey('loaded_state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWalletBalance(data.walletBalance),
        const SizedBox(height: 24),
        _buildSectionTitle("Today's Summary"),
        const SizedBox(height: 12),
        _buildSummaryCard(data.revenue, data.refunds),
        const SizedBox(height: 24),
        _buildSectionTitle('Recent Transactions'),
        const SizedBox(height: 12),
        _buildTransactionsList(data.transactions),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF334155),
      ),
    );
  }

  Widget _buildWalletBalance(double balance) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSummaryCard(double revenue, double refunds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Revenue', revenue),
          const SizedBox(height: 16),
          _buildSummaryRow('Refunds', refunds),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No recent transactions',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return _TransactionItem(transaction: tx, index: index);
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      key: const ValueKey('loading_state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: _buildShimmer(),
        ),
        const SizedBox(height: 24),
        Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: _buildShimmer(),
        ),
        const SizedBox(height: 12),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: _buildShimmer(),
        ),
        const SizedBox(height: 24),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: _buildShimmer(),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: -1.0, end: 2.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOutSine,
        builder: (context, value, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFFF1F5F9),
                  Color(0xFFF8FAFC),
                  Color(0xFFF1F5F9),
                ],
                stops: [value - 0.3, value, value + 0.3],
              ).createShader(bounds);
            },
            child: Container(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      key: const ValueKey('error_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.read<SellerPaymentPageBloc>().add(LoadPaymentData()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatefulWidget {
  final Transaction transaction;
  final int index;

  const _TransactionItem({required this.transaction, required this.index});

  @override
  State<_TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<_TransactionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = widget.transaction.isRefund
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    final amountPrefix = widget.transaction.isRefund ? '-' : '+';
    final amountFormatted =
        '₹${widget.transaction.amount.toStringAsFixed(0)}'; // The image shows +₹780, not 780.00

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.transaction.orderId,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.transaction.date,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix$amountFormatted',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.transaction.status,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.transaction.isRefund
                          ? const Color(0xFF64748B)
                          : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
