import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/widgets/shimmer_loader.dart';
import '../../../repositories/seller_customer_repository.dart';
import '../../../api_service/seller_customer_service.dart';
import '../chat_support_page_/chat_support_page_ui.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
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

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        context.read<SellerCustomerBloc>().add(SearchCustomers(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final horizontalPadding = isDesktop
        ? size.width * 0.15
        : (isTablet ? size.width * 0.08 : 16.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Management',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Real-time Buyer Insights & History',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFE11D48)),
            tooltip: 'Customer Messages',
            onPressed: () => _navigateToChat(context),
          ),
          const SizedBox(width: 8),
        ],
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
                child: BlocConsumer<SellerCustomerBloc, SellerCustomerState>(
                  listenWhen: (prev, curr) =>
                      curr is SellerCustomerLoaded &&
                      (prev is! SellerCustomerLoaded ||
                          prev.selectedCustomer != curr.selectedCustomer),
                  listener: (context, state) {
                    if (state is SellerCustomerLoaded && state.selectedCustomer != null) {
                      _showCustomerProfile(context, state.selectedCustomer!);
                    }
                  },
                  buildWhen: (previous, current) =>
                      previous.runtimeType != current.runtimeType || previous != current,
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
        // Real-time Overview Statistics Cards
        _buildStatsSection(context, state.stats),
        const SizedBox(height: 24),

        // Search and Sort Control Bar
        _buildSearchAndSortBar(context, state),
        const SizedBox(height: 20),

        // Section Title & Customer Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.filteredCustomers.length} ${state.filteredCustomers.length == 1 ? 'Customer' : 'Customers'}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Customer List
        _buildCustomerList(context, state),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, CustomerStats stats) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final isTablet = width > 600 && width <= 900;

    final repeatRate = stats.totalCustomers > 0
        ? ((stats.repeatCustomers / stats.totalCustomers) * 100).toStringAsFixed(0)
        : '0';

    final totalCard = Semantics(
      label: 'Total Customers Card',
      value: stats.totalCustomers.toString(),
      child: _StatsCard(
        title: 'Total Customers',
        value: stats.totalCustomers.toString(),
        subtitle: 'Unique buyers at your store',
        icon: Icons.people_alt_rounded,
        iconColor: const Color(0xFF3B82F6),
        bgColor: const Color(0xFFEFF6FF),
      ),
    );

    final repeatCard = Semantics(
      label: 'Repeat Customers Card',
      value: stats.repeatCustomers.toString(),
      child: _StatsCard(
        title: 'Repeat Customers',
        value: stats.repeatCustomers.toString(),
        subtitle: '$repeatRate% buyer retention rate',
        icon: Icons.loop_rounded,
        iconColor: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
      ),
    );

    final revenueCard = Semantics(
      label: 'Total Customer Revenue Card',
      value: '₹${stats.totalRevenue.toStringAsFixed(0)}',
      child: _StatsCard(
        title: 'Total Revenue',
        value: '₹${stats.totalRevenue.toStringAsFixed(0)}',
        subtitle: 'Lifetime customer spending',
        icon: Icons.currency_rupee_rounded,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
      ),
    );

    final avgCard = Semantics(
      label: 'Average Order Value Card',
      value: '₹${stats.averageOrderValue.toStringAsFixed(0)}',
      child: _StatsCard(
        title: 'Avg Order Value',
        value: '₹${stats.averageOrderValue.toStringAsFixed(0)}',
        subtitle: 'Per order customer average',
        icon: Icons.analytics_rounded,
        iconColor: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: totalCard),
          const SizedBox(width: 14),
          Expanded(child: repeatCard),
          const SizedBox(width: 14),
          Expanded(child: revenueCard),
          const SizedBox(width: 14),
          Expanded(child: avgCard),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: totalCard),
              const SizedBox(width: 14),
              Expanded(child: repeatCard),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: revenueCard),
              const SizedBox(width: 14),
              Expanded(child: avgCard),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: totalCard),
              const SizedBox(width: 12),
              Expanded(child: repeatCard),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: revenueCard),
              const SizedBox(width: 12),
              Expanded(child: avgCard),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSearchAndSortBar(BuildContext context, SellerCustomerLoaded state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input Field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Search by buyer name or phone...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SellerCustomerBloc>().add(const SearchCustomers(''));
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sort Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'Sort by:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: 'Most Orders',
                  option: CustomerSortOption.mostOrders,
                  current: state.selectedSort,
                  icon: Icons.local_mall_outlined,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: 'Top Spending',
                  option: CustomerSortOption.highestSpending,
                  current: state.selectedSort,
                  icon: Icons.monetization_on_outlined,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: 'Recent Order',
                  option: CustomerSortOption.recentOrder,
                  current: state.selectedSort,
                  icon: Icons.history_rounded,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: 'Name (A-Z)',
                  option: CustomerSortOption.nameAsc,
                  current: state.selectedSort,
                  icon: Icons.sort_by_alpha_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required CustomerSortOption option,
    required CustomerSortOption current,
    required IconData icon,
  }) {
    final isSelected = option == current;
    return InkWell(
      onTap: () {
        context.read<SellerCustomerBloc>().add(SortCustomers(option));
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList(BuildContext context, SellerCustomerLoaded state) {
    if (state.filteredCustomers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No customers matching "${state.searchQuery}"'
                  : 'No customers found yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'Try searching by a different name or phone number.'
                  : 'Customers will automatically appear here as soon as orders are placed at your store.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
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
          itemCount: state.filteredCustomers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final customer = state.filteredCustomers[index];
            return _CustomerListItem(
              customer: customer,
              index: index,
              onTap: () {
                _showCustomerProfile(context, customer);
              },
              onChatTap: () {
                _navigateToChat(context);
              },
            );
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
              child: SkeletonBox(height: 90, borderRadius: 16),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SkeletonBox(height: 90, borderRadius: 16),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SkeletonBox(height: 50, borderRadius: 16),
        const SizedBox(height: 24),
        ...List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SkeletonBox(height: 84, borderRadius: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      key: const ValueKey('error_customer_content'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
          ),
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<SellerCustomerBloc>().add(
              const LoadCustomerData(),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerProfile(BuildContext context, CustomerItem customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _CustomerProfileBottomSheet(
        customer: customer,
        onChatTap: () {
          Navigator.of(bottomSheetContext).pop();
          _navigateToChat(context);
        },
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatSupportPage(sellerId: sellerId),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatsCard({
    required this.title,
    required this.value,
    this.subtitle = '',
    this.icon = Icons.insights,
    this.iconColor = const Color(0xFF3B82F6),
    this.bgColor = const Color(0xFFF4F6FB),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerListItem extends StatefulWidget {
  final CustomerItem customer;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onChatTap;

  const _CustomerListItem({
    required this.customer,
    required this.index,
    required this.onTap,
    required this.onChatTap,
  });

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
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _delayTimer = Timer(Duration(milliseconds: 30 * widget.index), () {
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
    final isLoyal = widget.customer.orderCount > 1;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Semantics(
          label: 'Customer Row for ${widget.customer.name}',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    _buildAvatar(),
                    const SizedBox(width: 14),

                    // Customer info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.customer.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isLoyal
                                      ? const Color(0xFFECFDF5)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isLoyal ? 'Loyal' : 'New',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isLoyal
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Masked Phone & Total Spending
                          Row(
                            children: [
                              if (widget.customer.phone.isNotEmpty) ...[
                                const Icon(Icons.phone_locked_outlined,
                                    size: 13, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  widget.customer.phone,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                '₹${widget.customer.totalSpent.toStringAsFixed(0)} spent',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Order Count badge & Quick Chat button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.customer.orderCount} ${widget.customer.orderCount == 1 ? 'Order' : 'Orders'}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: widget.onChatTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_outline,
                                    size: 14, color: Color(0xFFE11D48)),
                                const SizedBox(width: 4),
                                Text(
                                  'Chat',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: widget.customer.avatarUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: widget.customer.avatarUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFFF1F5F9),
                width: 44,
                height: 44,
                child: const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
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
    );
  }

  Widget _buildInitialsAvatar() {
    final String initial = widget.customer.name.trim().isNotEmpty
        ? widget.customer.name.trim().substring(0, 1).toUpperCase()
        : '?';
    return Container(
      color: const Color(0xFFE2E8F0),
      width: 44,
      height: 44,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

class _CustomerProfileBottomSheet extends StatelessWidget {
  final CustomerItem customer;
  final VoidCallback onChatTap;

  const _CustomerProfileBottomSheet({
    required this.customer,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildLargeAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              customer.phone.isNotEmpty
                                  ? customer.phone
                                  : 'Privacy Masked Profile',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Quick Stats Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat('Total Orders', customer.orderCount.toString()),
                    Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                    _buildMiniStat('Total Spent', '₹${customer.totalSpent.toStringAsFixed(0)}'),
                    Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                    _buildMiniStat(
                      'Avg Order',
                      customer.orderCount > 0
                          ? '₹${(customer.totalSpent / customer.orderCount).toStringAsFixed(0)}'
                          : '₹0',
                    ),
                  ],
                ),
              ),
            ),

            // Direct Chat Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onChatTap,
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: Text(
                    'Message ${customer.name}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // Tabs Header
            TabBar(
              labelColor: const Color(0xFFE11D48),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFFE11D48),
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle:
                  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: 'Order History'),
                Tab(text: 'Favourite Items'),
                Tab(text: 'Reviews'),
              ],
            ),

            // Tab Views Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrderHistoryTab(),
                  _buildFavouriteItemsTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLargeAvatar() {
    final initial = customer.name.trim().isNotEmpty
        ? customer.name.trim().substring(0, 1).toUpperCase()
        : '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: customer.avatarUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: customer.avatarUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFFE2E8F0),
                width: 56,
                height: 56,
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              color: const Color(0xFFE2E8F0),
              width: 56,
              height: 56,
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildOrderHistoryTab() {
    if (customer.orderHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'No prior orders recorded',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: customer.orderHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = customer.orderHistory[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderId.length > 8 ? order.orderId.substring(0, 8) : order.orderId}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '₹${order.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.timestamp.day}/${order.timestamp.month}/${order.timestamp.year} • ${_formatTime(order.timestamp)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              if (order.itemNames.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                Text(
                  order.itemNames.join(', '),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF475569),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavouriteItemsTab() {
    if (customer.favouriteProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'No favourite items recorded yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: customer.favouriteProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final fav = customer.favouriteProducts[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.restaurant_rounded, color: Color(0xFFE11D48), size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fav.productName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ordered ${fav.orderCount} ${fav.orderCount == 1 ? 'time' : 'times'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (fav.price > 0)
                Text(
                  '₹${fav.price.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    if (customer.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rate_review_outlined, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'No reviews left by this customer yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: customer.reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = customer.reviews[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (starIdx) => Icon(
                        starIdx < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 18,
                      ),
                    ),
                  ),
                  Text(
                    '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              if (review.productName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Item: ${review.productName}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
              if (review.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  review.content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }
}
