import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../repositories/seller_customer_repository.dart';
import '../../../api_service/seller_customer_service.dart';
import 'seller_customer_page__bloc.dart';
import 'seller_customer_page__event.dart';
import 'seller_customer_page__state.dart';

class SellerCustomerPage extends StatelessWidget {
  const SellerCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerCustomerBloc(
        repository: SellerCustomerRepository(service: SellerCustomerService()),
      )..add(const LoadCustomerData()),
      child: const SellerCustomerView(),
    );
  }
}

class SellerCustomerView extends StatefulWidget {
  const SellerCustomerView({super.key});

  @override
  State<SellerCustomerView> createState() => _SellerCustomerViewState();
}

class _SellerCustomerViewState extends State<SellerCustomerView> {
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
      context.read<SellerCustomerBloc>().add(const LoadMoreCustomers());
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
      backgroundColor: const Color(0xFFF8FAFC), // Premium light background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Orders',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              'Customer & Order Management',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFE11D48),
          onRefresh: () async {
            context.read<SellerCustomerBloc>().add(const RefreshCustomerData());
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                child: BlocBuilder<SellerCustomerBloc, SellerCustomerState>(
                  buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStateContent(context, state),
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

  Widget _buildStateContent(BuildContext context, SellerCustomerState state) {
    if (state is SellerCustomerLoading) {
      return _buildSkeletonLoader();
    } else if (state is SellerCustomerError) {
      return _buildErrorState(context, state.message);
    } else if (state is SellerCustomerLoaded) {
      return _buildContent(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, SellerCustomerLoaded state) {
    return Column(
      key: const ValueKey('loaded_customer_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards Row
        _buildStatsSection(context, state.stats),
        const SizedBox(height: 28),

        // Section Title
        Semantics(
          header: true,
          child: Text(
            'Top Customers',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Customer List
        _buildCustomerList(context, state),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, CustomerStats stats) {
    final bool isWide = MediaQuery.of(context).size.width > 500;

    final Widget totalCard = Semantics(
      label: 'Total Customers Card',
      value: stats.totalCustomers.toString(),
      child: _StatsCard(
        title: 'Total Customers',
        value: stats.totalCustomers.toString(),
        color: const Color(0xFFF4F6FB), // Light bluish background
      ),
    );

    final Widget repeatCard = Semantics(
      label: 'Repeat Customers Card',
      value: stats.repeatCustomers.toString(),
      child: _StatsCard(
        title: 'Repeat Customers',
        value: stats.repeatCustomers.toString(),
        color: const Color(0xFFF4F6FB), // Light bluish background
      ),
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: totalCard),
          const SizedBox(width: 16),
          Expanded(child: repeatCard),
        ],
      );
    } else {
      return Column(
        children: [totalCard, const SizedBox(height: 12), repeatCard],
      );
    }
  }

  Widget _buildCustomerList(BuildContext context, SellerCustomerLoaded state) {
    if (state.customers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.customers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final customer = state.customers[index];
            return _CustomerListItem(customer: customer, index: index);
          },
        ),
        if (state.isPaginatedLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFE11D48)),
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      key: const ValueKey('loading_customer_skeleton'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          width: 150,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      key: const ValueKey('error_customer_content'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load Customers',
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
            onPressed: () => context.read<SellerCustomerBloc>().add(
              const LoadCustomerData(),
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
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerListItem extends StatefulWidget {
  final CustomerItem customer;
  final int index;

  const _CustomerListItem({required this.customer, required this.index});

  @override
  State<_CustomerListItem> createState() => _CustomerListItemState();
}

class _CustomerListItemState extends State<_CustomerListItem>
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
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _delayTimer = Timer(Duration(milliseconds: 60 * widget.index), () {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Semantics(
          label: 'Customer Row for ${widget.customer.name}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: widget.customer.avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.customer.avatarUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            width: 48,
                            height: 48,
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildInitialsAvatar(),
                        )
                      : _buildInitialsAvatar(),
                ),
                const SizedBox(width: 16),

                // Name
                Expanded(
                  child: Text(
                    widget.customer.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),

                // Order Count
                Text(
                  '${widget.customer.orderCount} Orders',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final String initial = widget.customer.name.trim().isNotEmpty
        ? widget.customer.name.trim().substring(0, 1).toUpperCase()
        : '?';
    return Container(
      color: const Color(0xFFF1F5F9),
      width: 48,
      height: 48,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF475569),
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
