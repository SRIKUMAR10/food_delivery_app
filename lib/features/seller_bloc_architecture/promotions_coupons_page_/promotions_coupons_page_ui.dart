import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'promotions_coupons_page_bloc.dart';
import 'promotions_coupons_page_event.dart';
import 'promotions_coupons_page_state.dart';
import 'promotions_coupons_page_repository.dart';
import 'promotions_coupons_page_service.dart';
import 'promotions_coupons_page_model.dart';

class PromotionsCouponsPage extends StatelessWidget {
  final String sellerId;
  const PromotionsCouponsPage({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PromotionsCouponsBloc(
        repository: PromotionsCouponsRepository(service: PromotionsCouponsService()),
      )..add(LoadCouponsEvent(sellerId)),
      child: const PromotionsCouponsView(),
    );
  }
}

class PromotionsCouponsView extends StatefulWidget {
  const PromotionsCouponsView({Key? key}) : super(key: key);

  @override
  State<PromotionsCouponsView> createState() => _PromotionsCouponsViewState();
}

class _PromotionsCouponsViewState extends State<PromotionsCouponsView> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedScope = 'All';
  String _selectedType = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    context.read<PromotionsCouponsBloc>().add(FilterCouponsEvent(
          searchQuery: _searchController.text,
          statusFilter: _selectedStatus,
          scopeFilter: _selectedScope,
          typeFilter: _selectedType,
        ));
  }

  void _showCreateEditCouponDialog(BuildContext context, {CouponModel? existingCoupon}) {
    final bloc = context.read<PromotionsCouponsBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _CouponFormDialog(existingCoupon: existingCoupon),
      ),
    );
  }

  void _showTestCouponModal(BuildContext context, {CouponModel? initialCoupon}) {
    final bloc = context.read<PromotionsCouponsBloc>();
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _TestCouponValidationModal(initialCoupon: initialCoupon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Coupons & Offers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_outlined, color: Color(0xFF3B82F6)),
            tooltip: 'Test Server-Side Coupon Validation',
            onPressed: () => _showTestCouponModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEditCouponDialog(context),
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Create Offer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocListener<PromotionsCouponsBloc, PromotionsCouponsState>(
          listener: (context, state) {
            if (state is PromotionsCouponsLoaded) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.read<PromotionsCouponsBloc>().add(const ClearMessagesEvent());
              } else if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.read<PromotionsCouponsBloc>().add(const ClearMessagesEvent());
              }
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    slivers: [
                      // 1. Header Banner & Metrics
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Seller Promotions Hub',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Manage restaurant-wide, category & product offers in real-time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (constraints.maxWidth > 500)
                                    ElevatedButton.icon(
                                      onPressed: () => _showCreateEditCouponDialog(context),
                                      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                                      label: const Text('Create Coupon'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1D4ED8),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Metric Cards
                              BlocBuilder<PromotionsCouponsBloc, PromotionsCouponsState>(
                                builder: (context, state) {
                                  int totalOffers = 0;
                                  int activeOffers = 0;
                                  int totalUsed = 0;
                                  int expiredOffers = 0;

                                  if (state is PromotionsCouponsLoaded) {
                                    totalOffers = state.coupons.length;
                                    activeOffers = state.activeCouponsCount;
                                    totalUsed = state.totalRedemptions;
                                    expiredOffers = state.expiredCouponsCount;
                                  }

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _MetricCard(
                                          title: 'Active Offers',
                                          value: '$activeOffers',
                                          icon: Icons.local_offer_rounded,
                                          color: const Color(0xFF10B981),
                                          bgColor: const Color(0xFFECFDF5),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _MetricCard(
                                          title: 'Total Offers',
                                          value: '$totalOffers',
                                          icon: Icons.confirmation_number_rounded,
                                          color: const Color(0xFF3B82F6),
                                          bgColor: const Color(0xFFEFF6FF),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _MetricCard(
                                          title: 'Total Used',
                                          value: '$totalUsed',
                                          icon: Icons.redeem_rounded,
                                          color: const Color(0xFF8B5CF6),
                                          bgColor: const Color(0xFFF5F3FF),
                                        ),
                                      ),
                                      if (constraints.maxWidth > 550) ...[
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _MetricCard(
                                            title: 'Expired',
                                            value: '$expiredOffers',
                                            icon: Icons.timer_off_rounded,
                                            color: const Color(0xFFF59E0B),
                                            bgColor: const Color(0xFFFEF3C7),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. Search & Filter Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => _onFilterChanged(),
                                  decoration: InputDecoration(
                                    hintText: 'Search by coupon code or description...',
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, size: 18),
                                            onPressed: () {
                                              _searchController.clear();
                                              _onFilterChanged();
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Filter Chips Row
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Status: ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    ...['All', 'Active', 'Inactive', 'Expired'].map((st) {
                                      final isSelected = _selectedStatus == st;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: ChoiceChip(
                                          label: Text(st),
                                          selected: isSelected,
                                          onSelected: (val) {
                                            setState(() => _selectedStatus = st);
                                            _onFilterChanged();
                                          },
                                          labelStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : const Color(0xFF475569),
                                          ),
                                          selectedColor: const Color(0xFF1D4ED8),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            side: BorderSide(
                                              color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Scope: ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    ...[
                                      {'label': 'All', 'value': 'All'},
                                      {'label': 'Restaurant', 'value': 'restaurant'},
                                      {'label': 'Product', 'value': 'product'},
                                      {'label': 'Category', 'value': 'category'},
                                    ].map((sc) {
                                      final isSelected = _selectedScope == sc['value'];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: ChoiceChip(
                                          label: Text(sc['label']!),
                                          selected: isSelected,
                                          onSelected: (val) {
                                            setState(() => _selectedScope = sc['value']!);
                                            _onFilterChanged();
                                          },
                                          labelStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : const Color(0xFF475569),
                                          ),
                                          selectedColor: const Color(0xFF6D28D9),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            side: BorderSide(
                                              color: isSelected ? const Color(0xFF6D28D9) : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. Coupons List / Grid
                      BlocBuilder<PromotionsCouponsBloc, PromotionsCouponsState>(
                        builder: (context, state) {
                          if (state is PromotionsCouponsLoading || state is PromotionsCouponsInitial) {
                            return const SliverFillRemaining(
                              child: Center(
                                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                              ),
                            );
                          } else if (state is PromotionsCouponsError) {
                            return SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                                    const SizedBox(height: 12),
                                    Text(
                                      state.message,
                                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is PromotionsCouponsLoaded) {
                            final coupons = state.filteredCoupons;

                            if (coupons.isEmpty) {
                              return SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEFF6FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.local_offer_outlined,
                                              color: Color(0xFF1D4ED8),
                                              size: 48,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No Promotions Found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Create offers to attract more customers and boost orders!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton.icon(
                                            onPressed: () => _showCreateEditCouponDialog(context),
                                            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                                            label: const Text('Create First Coupon'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1D4ED8),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (isDesktop || isTablet) {
                              return SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                sliver: SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isDesktop ? 2 : 2,
                                    childAspectRatio: 1.55,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final coupon = coupons[index];
                                      final isProcessing = state.processingCouponIds.contains(coupon.id);
                                      return _CouponCard(
                                        coupon: coupon,
                                        isProcessing: isProcessing,
                                        onEdit: () => _showCreateEditCouponDialog(context, existingCoupon: coupon),
                                        onTest: () => _showTestCouponModal(context, initialCoupon: coupon),
                                      );
                                    },
                                    childCount: coupons.length,
                                  ),
                                ),
                              );
                            }

                            return SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final coupon = coupons[index];
                                    final isProcessing = state.processingCouponIds.contains(coupon.id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _CouponCard(
                                        coupon: coupon,
                                        isProcessing: isProcessing,
                                        onEdit: () => _showCreateEditCouponDialog(context, existingCoupon: coupon),
                                        onTest: () => _showTestCouponModal(context, initialCoupon: coupon),
                                      ),
                                    );
                                  },
                                  childCount: coupons.length,
                                ),
                              ),
                            );
                          }
                          return const SliverToBoxAdapter(child: SizedBox.shrink());
                        },
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final bool isProcessing;
  final VoidCallback onEdit;
  final VoidCallback onTest;

  const _CouponCard({
    required this.coupon,
    required this.isProcessing,
    required this.onEdit,
    required this.onTest,
  });

  Color _getScopeColor(String scope) {
    switch (scope.toLowerCase()) {
      case 'product':
        return const Color(0xFF3B82F6);
      case 'category':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _getScopeLabel(String scope) {
    switch (scope.toLowerCase()) {
      case 'product':
        return 'Product Specific (${coupon.applicableProductIds.length})';
      case 'category':
        return 'Category Specific (${coupon.applicableCategoryIds.length})';
      default:
        return 'Restaurant Wide';
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountStr = coupon.isPercentage
        ? '${coupon.discountAmount.toStringAsFixed(0)}% OFF'
        : '₹${coupon.discountAmount.toStringAsFixed(0)} FLAT OFF';

    final isExpired = coupon.isExpired;
    final isUpcoming = coupon.isUpcoming;
    final isUsageMaxed = coupon.isUsageLimitReached;
    final isActive = coupon.isActive && !isExpired && !isUsageMaxed;

    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Ribbon & Status
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isActive ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Scope Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScopeColor(coupon.offerScope).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getScopeColor(coupon.offerScope).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          coupon.offerScope == 'product'
                              ? Icons.fastfood_outlined
                              : (coupon.offerScope == 'category' ? Icons.category_outlined : Icons.restaurant_rounded),
                          size: 14,
                          color: _getScopeColor(coupon.offerScope),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getScopeLabel(coupon.offerScope),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getScopeColor(coupon.offerScope),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active Switch & Spinner
                  Row(
                    children: [
                      if (isProcessing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                        )
                      else
                        Switch(
                          value: coupon.isActive && !isExpired,
                          activeThumbColor: const Color(0xFF10B981),
                          onChanged: isExpired
                              ? null
                              : (val) {
                                  context
                                      .read<PromotionsCouponsBloc>()
                                      .add(ToggleCouponStatusEvent(coupon.id, val));
                                },
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Code Pill & Discount Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coupon Code Badge
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: coupon.code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied code "${coupon.code}" to clipboard!'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  coupon.code,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1D4ED8),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF3B82F6)),
                              ],
                            ),
                          ),
                        ),

                        // Discount Tag
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              discountStr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (coupon.isPercentage && coupon.maximumDiscountAmount > 0)
                              Text(
                                'Max ₹${coupon.maximumDiscountAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Description
                    if (coupon.description.isNotEmpty)
                      Text(
                        coupon.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    // Usage Limits & Min Order Info
                    Row(
                      children: [
                        if (coupon.minimumOrderValue > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Min: ₹${coupon.minimumOrderValue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        if (coupon.perCustomerLimit > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${coupon.perCustomerLimit}/user',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        if (coupon.usageLimit > 0)
                          Expanded(
                            child: Text(
                              '${coupon.usedCount}/${coupon.usageLimit} redeemed',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          )
                        else
                          Text(
                            '${coupon.usedCount} redeemed',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),

                    // Usage progress bar if limit is set
                    if (coupon.usageLimit > 0) ...[
                      const SizedBox(height: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (coupon.usedCount / coupon.usageLimit).clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            coupon.isUsageLimitReached ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Footer (Dates & Action Buttons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expiry date chip
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isExpired
                            ? const Color(0xFFEF4444)
                            : (isUpcoming ? const Color(0xFFF59E0B) : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isExpired
                            ? 'Expired'
                            : (isUpcoming
                                ? 'Starts: ${dateFormat.format(coupon.startDate)}'
                                : 'Expires: ${dateFormat.format(coupon.expiryDate)}'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isExpired
                              ? const Color(0xFFEF4444)
                              : (isUpcoming ? const Color(0xFFF59E0B) : const Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),

                  // Actions
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.verified_outlined, size: 18, color: Color(0xFF3B82F6)),
                        tooltip: 'Test Server-Side Validation',
                        onPressed: onTest,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                        tooltip: 'Edit Coupon',
                        onPressed: onEdit,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                        tooltip: 'Delete Coupon',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Coupon?'),
                              content: Text('Are you sure you want to delete coupon "${coupon.code}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<PromotionsCouponsBloc>().add(DeleteCouponEvent(coupon.id));
                                    Navigator.pop(ctx);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class _CouponFormDialog extends StatefulWidget {
  final CouponModel? existingCoupon;

  const _CouponFormDialog({Key? key, this.existingCoupon}) : super(key: key);

  @override
  State<_CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<_CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _maxDiscountCtrl;
  late final TextEditingController _minOrderCtrl;
  late final TextEditingController _usageLimitCtrl;
  late final TextEditingController _perCustomerLimitCtrl;

  late bool _isPercentage;
  late bool _isActive;
  late String _offerScope; // 'restaurant', 'product', 'category'
  late DateTime _startDate;
  late DateTime _expiryDate;
  late List<String> _selectedProductIds;
  late List<String> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCoupon;
    _codeCtrl = TextEditingController(text: c?.code ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _amountCtrl = TextEditingController(text: c != null ? c.discountAmount.toStringAsFixed(0) : '20');
    _maxDiscountCtrl = TextEditingController(text: c != null && c.maximumDiscountAmount > 0 ? c.maximumDiscountAmount.toStringAsFixed(0) : '');
    _minOrderCtrl = TextEditingController(text: c != null && c.minimumOrderValue > 0 ? c.minimumOrderValue.toStringAsFixed(0) : '100');
    _usageLimitCtrl = TextEditingController(text: c != null && c.usageLimit > 0 ? c.usageLimit.toString() : '');
    _perCustomerLimitCtrl = TextEditingController(text: c != null && c.perCustomerLimit > 0 ? c.perCustomerLimit.toString() : '1');

    _isPercentage = c?.isPercentage ?? true;
    _isActive = c?.isActive ?? true;
    _offerScope = c?.offerScope ?? 'restaurant';
    _startDate = c?.startDate ?? DateTime.now();
    _expiryDate = c?.expiryDate ?? DateTime.now().add(const Duration(days: 30));
    _selectedProductIds = List<String>.from(c?.applicableProductIds ?? []);
    _selectedCategoryIds = List<String>.from(c?.applicableCategoryIds ?? []);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _minOrderCtrl.dispose();
    _usageLimitCtrl.dispose();
    _perCustomerLimitCtrl.dispose();
    super.dispose();
  }

  void _generateRandomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    final prefix = _isPercentage ? 'SAVE' : 'FLAT';
    final numPart = _amountCtrl.text.isNotEmpty ? _amountCtrl.text : '20';
    final suffix = String.fromCharCodes(Iterable.generate(3, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    setState(() {
      _codeCtrl.text = '$prefix$numPart$suffix';
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_expiryDate.isBefore(_startDate)) {
          _expiryDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate.isAfter(_startDate) ? _expiryDate : _startDate.add(const Duration(days: 1)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCoupon != null;
    final state = context.watch<PromotionsCouponsBloc>().state;
    final sellerProducts = state is PromotionsCouponsLoaded ? state.sellerProducts : <Map<String, dynamic>>[];
    final sellerCategories = state is PromotionsCouponsLoaded ? state.sellerCategories : <String>[];
    final isSaving = state is PromotionsCouponsLoaded ? state.isSaving : false;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Coupon' : 'Create New Coupon',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coupon Code with Random Button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _codeCtrl,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]')),
                                  LengthLimitingTextInputFormatter(16),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Coupon Code *',
                                  hintText: 'e.g. WELCOME50',
                                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter coupon code';
                                  if (val.trim().length < 3) return 'Code must be at least 3 chars';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: _generateRandomCode,
                                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                label: const Text('Random'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descCtrl,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'e.g. Get 20% off up to ₹100 on orders above ₹199',
                            prefixIcon: const Icon(Icons.notes_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Offer Scope Selection
                        const Text(
                          'Offer Scope',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'restaurant',
                              label: Text('Restaurant', style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.restaurant_rounded, size: 16),
                            ),
                            ButtonSegment(
                              value: 'product',
                              label: Text('Product', style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.fastfood_outlined, size: 16),
                            ),
                            ButtonSegment(
                              value: 'category',
                              label: Text('Category', style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.category_outlined, size: 16),
                            ),
                          ],
                          selected: {_offerScope},
                          onSelectionChanged: (set) => setState(() => _offerScope = set.first),
                        ),
                        const SizedBox(height: 12),

                        // Scope Details Pickers
                        if (_offerScope == 'product') ...[
                          const Text(
                            'Select Applicable Products:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 6),
                          if (sellerProducts.isEmpty)
                            const Text(
                              'No products found in menu.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: sellerProducts.map((prod) {
                                final pId = prod['id'] as String;
                                final pName = prod['name'] as String;
                                final isSelected = _selectedProductIds.contains(pId);
                                return FilterChip(
                                  label: Text(pName),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        _selectedProductIds.add(pId);
                                      } else {
                                        _selectedProductIds.remove(pId);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 16),
                        ] else if (_offerScope == 'category') ...[
                          const Text(
                            'Select Applicable Categories:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: sellerCategories.map((cat) {
                              final isSelected = _selectedCategoryIds.contains(cat);
                              return FilterChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      _selectedCategoryIds.add(cat);
                                    } else {
                                      _selectedCategoryIds.remove(cat);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Discount Type & Amount
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<bool>(
                                value: _isPercentage,
                                decoration: InputDecoration(
                                  labelText: 'Discount Type',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: true, child: Text('% Percentage')),
                                  DropdownMenuItem(value: false, child: Text('₹ Flat Amount')),
                                ],
                                onChanged: (val) => setState(() => _isPercentage = val ?? true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _amountCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: _isPercentage ? 'Discount Percentage (%) *' : 'Discount Amount (₹) *',
                                  prefixIcon: Icon(_isPercentage ? Icons.percent_rounded : Icons.currency_rupee_rounded),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (val) {
                                  final numVal = double.tryParse(val ?? '');
                                  if (numVal == null || numVal <= 0) return 'Enter valid discount';
                                  if (_isPercentage && numVal > 100) return 'Cannot exceed 100%';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Max Discount (for %) & Minimum Order Value
                        Row(
                          children: [
                            if (_isPercentage) ...[
                              Expanded(
                                child: TextFormField(
                                  controller: _maxDiscountCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Max Discount (₹)',
                                    hintText: 'e.g. 100 (0=No cap)',
                                    prefixIcon: const Icon(Icons.arrow_upward_rounded),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: TextFormField(
                                controller: _minOrderCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Min Order Value (₹)',
                                  hintText: 'e.g. 199',
                                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Date Range
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickStartDate,
                                borderRadius: BorderRadius.circular(12),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Start Date',
                                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _pickExpiryDate,
                                borderRadius: BorderRadius.circular(12),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'End / Expiry Date',
                                    prefixIcon: const Icon(Icons.event_busy_outlined),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Usage Limits
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _usageLimitCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Global Limit',
                                  hintText: '0 = Unlimited',
                                  prefixIcon: const Icon(Icons.groups_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _perCustomerLimitCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Per Customer Limit',
                                  hintText: 'e.g. 1 (0=Unlimited)',
                                  prefixIcon: const Icon(Icons.person_outline_rounded),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Active Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Active Status',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          subtitle: Text(
                            _isActive ? 'Coupon is live for customer redemption' : 'Coupon is paused / inactive',
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: _isActive,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final coupon = CouponModel(
                                  id: widget.existingCoupon?.id ?? '',
                                  sellerId: widget.existingCoupon?.sellerId ?? '',
                                  code: _codeCtrl.text.trim().toUpperCase(),
                                  description: _descCtrl.text.trim(),
                                  discountAmount: double.tryParse(_amountCtrl.text) ?? 0.0,
                                  isPercentage: _isPercentage,
                                  maximumDiscountAmount: double.tryParse(_maxDiscountCtrl.text) ?? 0.0,
                                  minimumOrderValue: double.tryParse(_minOrderCtrl.text) ?? 0.0,
                                  startDate: _startDate,
                                  expiryDate: _expiryDate,
                                  usageLimit: int.tryParse(_usageLimitCtrl.text) ?? 0,
                                  usedCount: widget.existingCoupon?.usedCount ?? 0,
                                  perCustomerLimit: int.tryParse(_perCustomerLimitCtrl.text) ?? 0,
                                  isActive: _isActive,
                                  offerScope: _offerScope,
                                  applicableProductIds: _selectedProductIds,
                                  applicableCategoryIds: _selectedCategoryIds,
                                  customerUsage: widget.existingCoupon?.customerUsage ?? const {},
                                );

                                if (isEditing) {
                                  context.read<PromotionsCouponsBloc>().add(UpdateCouponEvent(coupon));
                                } else {
                                  context.read<PromotionsCouponsBloc>().add(AddCouponEvent(coupon));
                                }
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isEditing ? 'Update Coupon' : 'Save Coupon'),
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

class _TestCouponValidationModal extends StatefulWidget {
  final CouponModel? initialCoupon;

  const _TestCouponValidationModal({Key? key, this.initialCoupon}) : super(key: key);

  @override
  State<_TestCouponValidationModal> createState() => _TestCouponValidationModalState();
}

class _TestCouponValidationModalState extends State<_TestCouponValidationModal> {
  late final TextEditingController _codeCtrl;
  final _amountCtrl = TextEditingController(text: '300');
  final _customerIdCtrl = TextEditingController(text: 'test_user_01');

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.initialCoupon?.code ?? '');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _amountCtrl.dispose();
    _customerIdCtrl.dispose();
    super.dispose();
  }

  void _runValidation() {
    final code = _codeCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (code.isEmpty) return;

    context.read<PromotionsCouponsBloc>().add(
          ValidateCouponServerSideEvent(
            couponCode: code,
            orderTotal: amount,
            customerId: _customerIdCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PromotionsCouponsBloc>().state;
    final isValidating = state is PromotionsCouponsLoaded ? state.isValidating : false;
    final validationResult = state is PromotionsCouponsLoaded ? state.validationResult : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.verified_rounded, color: Color(0xFF3B82F6), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Server-Side Validation Test',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      context.read<PromotionsCouponsBloc>().add(const ClearCouponValidationEvent());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Test coupon eligibility and discount calculation directly against the Cloud Functions backend in real-time.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const Divider(height: 24),

              TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Coupon Code',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Test Order Amount (₹)',
                        prefixIcon: const Icon(Icons.currency_rupee_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _customerIdCtrl,
                      decoration: InputDecoration(
                        labelText: 'Customer ID',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isValidating ? null : _runValidation,
                  icon: isValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: const Text(
                    'Run Server Validation',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              if (validationResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: validationResult.isValid ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: validationResult.isValid ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            validationResult.isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: validationResult.isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            validationResult.isValid ? 'VALID COUPON' : 'INVALID COUPON',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: validationResult.isValid ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        validationResult.message,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: validationResult.isValid ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                      if (validationResult.isValid) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount Applied:',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                            ),
                            Text(
                              '- ₹${validationResult.discountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Final Payable Total:',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                            ),
                            Text(
                              '₹${validationResult.finalTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

