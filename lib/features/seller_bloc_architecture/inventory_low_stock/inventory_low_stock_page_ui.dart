import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'inventory_low_stock_page_bloc.dart';
import 'inventory_low_stock_page_event.dart';
import 'inventory_low_stock_page_state.dart';
import '../add_product_page_/low_stock_alert_page__ui.dart';
import 'product_details_page_ui.dart';
import 'add_product_page_ui.dart';

class InventoryLowStockPage extends StatelessWidget {
  const InventoryLowStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InventoryLowStockPageBloc()..add(LoadInventoryData()),
      child: const _InventoryLowStockView(),
    );
  }
}

class _InventoryLowStockView extends StatefulWidget {
  const _InventoryLowStockView();

  @override
  State<_InventoryLowStockView> createState() => _InventoryLowStockViewState();
}

class _InventoryLowStockViewState extends State<_InventoryLowStockView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final horizontalPadding = isDesktop ? size.width * 0.15 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium light background
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF4F46E5),
          onRefresh: () async {
            context.read<InventoryLowStockPageBloc>().add(
              RefreshInventoryData(),
            );
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
                    BlocBuilder<
                      InventoryLowStockPageBloc,
                      InventoryLowStockPageState
                    >(
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
      floatingActionButton: _buildExtendedFab(context),
      bottomNavigationBar: _buildPremiumNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      centerTitle: false,
      leading: _isSearchActive
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () {
                setState(() {
                  _isSearchActive = false;
                  _searchController.clear();
                });
                context.read<InventoryLowStockPageBloc>().add(
                  const SearchInventory(''),
                );
              },
            )
          : IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF1E293B),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  context.read<InventoryLowStockPageBloc>().add(
                    SearchInventory(value),
                  );
                },
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<InventoryLowStockPageBloc>().add(
                              const SearchInventory(''),
                            );
                            setState(() {});
                          },
                        )
                      : null,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                key: const ValueKey('title'),
                children: [
                  Text(
                    'Inventory',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Inventory Management',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        if (!_isSearchActive)
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E293B)),
            onPressed: () {
              setState(() {
                _isSearchActive = true;
              });
            },
          ),
        BlocBuilder<InventoryLowStockPageBloc, InventoryLowStockPageState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.tune, color: Color(0xFF1E293B)),
              onPressed: () {
                if (state is InventoryLoaded) {
                  _showFilterBottomSheet(context, state);
                }
              },
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    InventoryLowStockPageState state,
    bool isWideScreen,
  ) {
    if (state is InventoryLoading) {
      return _buildPremiumSkeletonLoader(isWideScreen);
    } else if (state is InventoryError) {
      return _buildPremiumErrorState(context, state.message);
    } else if (state is InventoryLoaded) {
      if (state.items.isEmpty) {
        return _buildEmptyState(context, state);
      }
      return _buildContent(context, state, isWideScreen);
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent(
    BuildContext context,
    InventoryLoaded state,
    bool isWideScreen,
  ) {
    return Column(
      key: const ValueKey('loaded_state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPremiumSummaryCards(state.summary, isWideScreen),
        const SizedBox(height: 24),
        Text(
          'Products',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = state.items[index];
            return _PremiumInventoryItemCard(item: item, animationIndex: index);
          },
        ),
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }

  Widget _buildPremiumSummaryCards(
    InventorySummary summary,
    bool isWideScreen,
  ) {
    final double spacing = isWideScreen ? 24.0 : 12.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _PremiumSummaryCard(
            title: 'Total Items',
            count: summary.totalItems.toString(),
            icon: Icons.inventory_2_rounded,
            gradientColors: const [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
            iconColor: const Color(0xFF4F46E5),
            progress: 1.0,
            delay: 0,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _PremiumSummaryCard(
            title: 'Low Stock',
            count: summary.lowStock.toString(),
            icon: Icons.warning_rounded,
            gradientColors: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
            iconColor: const Color(0xFFF59E0B),
            progress: summary.totalItems == 0
                ? 0
                : (summary.lowStock / summary.totalItems),
            delay: 100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LowStockAlertPage()),
              );
            },
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _PremiumSummaryCard(
            title: 'Out of Stock',
            count: summary.outOfStock.toString(),
            icon: Icons.error_rounded,
            gradientColors: const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
            iconColor: const Color(0xFFEF4444),
            progress: summary.totalItems == 0
                ? 0
                : (summary.outOfStock / summary.totalItems),
            delay: 200,
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context, InventoryLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<InventoryLowStockPageBloc>(),
          child:
              BlocBuilder<
                InventoryLowStockPageBloc,
                InventoryLowStockPageState
              >(
                builder: (ctx, currentState) {
                  if (currentState is! InventoryLoaded)
                    return const SizedBox.shrink();

                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filters',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ctx.read<InventoryLowStockPageBloc>().add(
                                    const UpdateFilters(
                                      status: 'All',
                                      categories: [],
                                      sortOption: 'Default',
                                    ),
                                  );
                                  Navigator.pop(bottomSheetContext);
                                },
                                child: Text(
                                  'Reset',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF4F46E5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Status - Single Select
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Status',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children:
                                [
                                  'All',
                                  'In Stock',
                                  'Low Stock',
                                  'Out of Stock',
                                ].map((status) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(status),
                                      selected:
                                          currentState.activeStatus == status,
                                      onSelected: (selected) {
                                        ctx
                                            .read<InventoryLowStockPageBloc>()
                                            .add(UpdateFilters(status: status));
                                      },
                                      labelStyle: GoogleFonts.plusJakartaSans(
                                        color:
                                            currentState.activeStatus == status
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                        fontWeight:
                                            currentState.activeStatus == status
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                      backgroundColor: Colors.white,
                                      selectedColor: const Color(0xFF1E293B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color:
                                              currentState.activeStatus ==
                                                  status
                                              ? Colors.transparent
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      showCheckmark: false,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Categories - Multi Select
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Categories',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: ['Dairy', 'Vegetables', 'Meat', 'General']
                                .map((category) {
                                  final isSelected = currentState
                                      .activeCategories
                                      .contains(category);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(category),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        final currentCats = List<String>.from(
                                          currentState.activeCategories,
                                        );
                                        if (selected) {
                                          currentCats.add(category);
                                        } else {
                                          currentCats.remove(category);
                                        }
                                        ctx
                                            .read<InventoryLowStockPageBloc>()
                                            .add(
                                              UpdateFilters(
                                                categories: currentCats,
                                              ),
                                            );
                                      },
                                      labelStyle: GoogleFonts.plusJakartaSans(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                      backgroundColor: Colors.white,
                                      selectedColor: const Color(0xFF4F46E5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.transparent
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      showCheckmark: false,
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sorting - Single Select
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Sort By',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children:
                                [
                                  'Default',
                                  'A-Z',
                                  'Z-A',
                                  'Quantity (Low to High)',
                                  'Quantity (High to Low)',
                                ].map((sortOption) {
                                  final isSelected =
                                      currentState.activeSort == sortOption;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(sortOption),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        ctx
                                            .read<InventoryLowStockPageBloc>()
                                            .add(
                                              UpdateFilters(
                                                sortOption: sortOption,
                                              ),
                                            );
                                      },
                                      labelStyle: GoogleFonts.plusJakartaSans(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                      backgroundColor: Colors.white,
                                      selectedColor: const Color(0xFF1E293B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.transparent
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      showCheckmark: false,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(bottomSheetContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E293B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Show Results',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        );
      },
    );
  }

  Widget _buildPremiumSkeletonLoader(bool isWideScreen) {
    return Column(
      key: const ValueKey('loading_state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 120,
                margin: EdgeInsets.only(
                  right: index < 2 ? (isWideScreen ? 24 : 12) : 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: _buildShimmer(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        ...List.generate(
          5,
          (index) => Container(
            height: 90,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: _buildShimmer(),
          ),
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

  Widget _buildPremiumErrorState(BuildContext context, String message) {
    return Center(
      key: const ValueKey('error_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<InventoryLowStockPageBloc>().add(
                LoadInventoryData(),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'Try Again',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, InventoryLoaded state) {
    final isSearchEmpty =
        state.searchQuery.isNotEmpty ||
        state.activeStatus != 'All' ||
        state.activeCategories.isNotEmpty;

    return Center(
      key: const ValueKey('empty_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isSearchEmpty
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearchEmpty
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                size: 80,
                color: isSearchEmpty
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchEmpty ? 'No Results Found' : 'No Products Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchEmpty
                  ? 'We couldn\'t find any products matching "${state.searchQuery}".\nTry adjusting your search or filters.'
                  : 'Your inventory is currently empty.\nAdd your first product to get started.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (!isSearchEmpty)
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'Add Product',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            if (isSearchEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  context.read<InventoryLowStockPageBloc>().add(
                    const SearchInventory(''),
                  );
                  context.read<InventoryLowStockPageBloc>().add(
                    const UpdateFilters(
                      status: 'All',
                      categories: [],
                      sortOption: 'Default',
                    ),
                  );
                  setState(() {
                    _isSearchActive = false;
                  });
                },
                icon: const Icon(Icons.clear_all_rounded, size: 20),
                label: Text(
                  'Clear Filters',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtendedFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<InventoryLowStockPageBloc>(),
              child: const AddProductPage(),
            ),
          ),
        );
      },
      backgroundColor: const Color(0xFF4F46E5), // Primary
      elevation: 4,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Add Product',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPremiumNavigationBar() {
    return NavigationBar(
      backgroundColor: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      indicatorColor: const Color(0xFFEEF2FF),
      selectedIndex: 2,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 70,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined, color: Color(0xFF64748B)),
          selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF4F46E5)),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined, color: Color(0xFF64748B)),
          selectedIcon: Icon(
            Icons.receipt_long_rounded,
            color: Color(0xFF4F46E5),
          ),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined, color: Color(0xFF64748B)),
          selectedIcon: Icon(
            Icons.inventory_2_rounded,
            color: Color(0xFF4F46E5),
          ),
          label: 'Products',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_rounded, color: Color(0xFF64748B)),
          label: 'More',
        ),
      ],
    );
  }
}

class _PremiumSummaryCard extends StatefulWidget {
  final String title;
  final String count;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;
  final double progress;
  final int delay;
  final VoidCallback? onTap;

  const _PremiumSummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
    required this.progress,
    required this.delay,
    this.onTap,
  });

  @override
  State<_PremiumSummaryCard> createState() => _PremiumSummaryCardState();
}

class _PremiumSummaryCardState extends State<_PremiumSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: widget.delay), () {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradientColors,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: widget.iconColor.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.count,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.iconColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumInventoryItemCard extends StatefulWidget {
  final InventoryItem item;
  final int animationIndex;

  const _PremiumInventoryItemCard({
    required this.item,
    required this.animationIndex,
  });

  @override
  State<_PremiumInventoryItemCard> createState() =>
      _PremiumInventoryItemCardState();
}

class _PremiumInventoryItemCardState extends State<_PremiumInventoryItemCard>
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 50 * widget.animationIndex), () {
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
    // Generate mock category based on name
    final category = _getCategory(widget.item.name);
    final stockStatus = _getStockStatus();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2), // Small margin for shadow
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<InventoryLowStockPageBloc>(),
                      child: ProductDetailsPage(item: widget.item),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              highlightColor: const Color(0xFFF8FAFC),
              splashColor: const Color(0xFFEEF2FF),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Modern Circular Icon
                    Hero(
                      tag: 'product_icon_${widget.item.name}',
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getIconBackgroundColor(
                            widget.item.name,
                          ).withValues(alpha: 0.1),
                          border: Border.all(
                            color: _getIconBackgroundColor(
                              widget.item.name,
                            ).withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.item.name.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _getIconBackgroundColor(widget.item.name),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${widget.item.quantity} ${widget.item.unit}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _PremiumBadge(status: stockStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Mini stock progress indicator
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _getStockProgress(),
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStatusColor(stockStatus),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1),
                      size: 24,
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

  String _getStockStatus() {
    if (widget.item.quantity == 0) return 'Out of Stock';
    if (widget.item.isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  double _getStockProgress() {
    if (widget.item.quantity == 0) return 0.05;
    if (widget.item.isLowStock) return 0.3;
    return 0.8;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Out of Stock':
        return const Color(0xFFEF4444);
      case 'Low Stock':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
  }

  String _getCategory(String name) {
    if (['cheese', 'milk', 'butter'].contains(name.toLowerCase()))
      return 'Dairy';
    if (['tomato', 'capsicum', 'onion'].contains(name.toLowerCase()))
      return 'Vegetables';
    if (['chicken', 'beef', 'mutton'].contains(name.toLowerCase()))
      return 'Meat';
    return 'General';
  }

  Color _getIconBackgroundColor(String name) {
    final category = _getCategory(name);
    switch (category) {
      case 'Dairy':
        return const Color(0xFF3B82F6);
      case 'Vegetables':
        return const Color(0xFF10B981);
      case 'Meat':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}

class _PremiumBadge extends StatelessWidget {
  final String status;

  const _PremiumBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Out of Stock':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'Low Stock':
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFD97706);
        break;
      case 'In Stock':
      default:
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF16A34A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
