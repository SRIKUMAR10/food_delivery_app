import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../add_product_page_/add_product_page__ui.dart' as food_app;
import 'product_list_page__bloc.dart';
import 'product_list_page__event.dart';
import 'product_list_page__state.dart';
import 'product_model.dart';
import 'product_repository.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductListBloc(repository: ProductRepositoryImpl())
            ..add(LoadProductsEvent()),
      child: const ProductListView(),
    );
  }
}

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView>
    with SingleTickerProviderStateMixin {
  Product? _selectedProduct;

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
        backgroundColor: const Color(0xFFF8FAFC), // App background color
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildDesktopLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),
        ),
        floatingActionButton: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 800) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 100.0), // Padding to avoid overlapping mobile bottom nav
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const food_app.AddProductPage(),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFFFF3B30),
                  elevation: 4,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ── Mobile Layout ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProductListBloc>().add(LoadProductsEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Products',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildKPISection(isDesktop: false),
            const SizedBox(height: 24),
            _buildFilterSection(isDesktop: false),
            const SizedBox(height: 20),
            _buildProductList(isDesktop: false),
            const SizedBox(height: 100), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  // ── Desktop Layout (Master-Detail) ─────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        // Base Layer (Full Width Product List)
        RefreshIndicator(
          onRefresh: () async {
            context.read<ProductListBloc>().add(LoadProductsEvent());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    children: [
                      const Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const food_app.AddProductPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Add Product',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildKPISection(isDesktop: true),
                const SizedBox(height: 24),
                _buildFilterSection(isDesktop: true),
                const SizedBox(height: 20),
                _buildProductList(isDesktop: true),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        
        // Dimmed Background to close panel on outside tap
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _selectedProduct == null,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProduct = null;
                });
              },
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: _selectedProduct != null ? 1.0 : 0.0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
        
        // Sliding Panel Layer (Detail View)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          right: _selectedProduct == null ? -750 : 0,
          width: 700, // Increased width for better content display
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(-5, 0),
                ),
              ],
            ),
            child: _selectedProduct == null
                ? const SizedBox.shrink()
                : _buildProductDetailView(_selectedProduct!),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailView(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery
          Stack(
            children: [
              Hero(
                tag: 'product_image_${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : 'https://via.placeholder.com/150',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 350,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 350,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.fastfood, color: Colors.grey, size: 64),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () {
                      if (MediaQuery.of(context).size.width <= 800) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          _selectedProduct = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: index == 0 ? const Color(0xFFFF3B30) : Colors.transparent, width: 2),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(product.imageUrls.isNotEmpty ? product.imageUrls.first : 'https://via.placeholder.com/150'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildVegBadge(product.foodType),
                        const SizedBox(width: 12),
                        Icon(Icons.star_rounded, color: const Color(0xFFF59E0B), size: 20),
                        const SizedBox(width: 4),
                        Text('${product.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 6),
                        Text('(${product.reviewCount} reviews)', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${product.price.toInt()}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailStatusBadge(product.status),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDetailActionButton(Icons.edit_outlined, 'Edit', true),
              _buildDetailActionButton(Icons.open_in_new_outlined, 'Preview', true),
              _buildDetailActionButton(Icons.copy_outlined, 'Duplicate', false),
              _buildDetailActionButton(Icons.share_outlined, 'Share', false),
              _buildDetailActionButton(Icons.archive_outlined, 'Archive', false, isDestructive: true),
              _buildDetailActionButton(Icons.delete_outline, 'Delete', false, isDestructive: true),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 32),

          // Analytics Cards
          const Text(
            'Product Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMiniAnalyticsCard('Revenue', '₹${_formatCompactNumber(product.price * product.salesCount)}', '+12%', true)),
              const SizedBox(width: 16),
              Expanded(child: _buildMiniAnalyticsCard('Orders', '${product.salesCount}', '+5%', true)),
              const SizedBox(width: 16),
              Expanded(child: _buildMiniAnalyticsCard('Rating', '${product.rating}', '${product.reviewCount} reviews', true)),
              const SizedBox(width: 16),
              Expanded(child: _buildMiniAnalyticsCard('Category', product.category.isNotEmpty ? product.category : 'N/A', '', true)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'A delicious offering crafted with the finest ingredients to satisfy your cravings. Enjoy the perfect blend of flavors and textures in every bite. This is a great addition to your menu that customers will love. Prepared fresh daily using authentic recipes.',
            style: TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.6),
          ),
          
          const SizedBox(height: 32),
          // Additional Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfoRow('Category', product.category.isNotEmpty ? product.category : 'N/A')),
                    const SizedBox(width: 24),
                    Expanded(child: _buildInfoRow('Food Type', product.foodType.isNotEmpty ? product.foodType : 'N/A')),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Color(0xFFF3F4F6), height: 1),
                ),
                Row(
                  children: [
                    Expanded(child: _buildInfoRow('Spicy Level', product.spicyLevel.isNotEmpty ? product.spicyLevel : 'N/A')),
                    const SizedBox(width: 24),
                    Expanded(child: _buildInfoRow('Sales', '${product.salesCount} sold')),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Color(0xFFF3F4F6), height: 1),
                ),
                Row(
                  children: [
                    Expanded(child: _buildInfoRow('Price', '₹${product.price.toInt()}')),
                    const SizedBox(width: 24),
                    Expanded(child: _buildInfoRow('Status', product.isActive ? 'Active' : 'Inactive')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 48), // Padding for scroll
        ],
      ),
    );
  }

  Widget _buildDetailActionButton(IconData icon, String label, bool isPrimary, {bool isDestructive = false}) {
    final bgColor = isPrimary ? const Color(0xFF111827) : (isDestructive ? const Color(0xFFFEF2F2) : Colors.white);
    final fgColor = isPrimary ? Colors.white : (isDestructive ? const Color(0xFFDC2626) : const Color(0xFF374151));
    final borderColor = isPrimary ? Colors.transparent : (isDestructive ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB));

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          boxShadow: isPrimary
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniAnalyticsCard(String title, String value, String trend, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
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
          Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          if (trend.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              trend,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFF111827), fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildVegBadge(String foodType) {
    if (foodType.isEmpty) return const SizedBox.shrink();
    bool isVeg = foodType.toLowerCase() == 'veg' || foodType.toLowerCase() == 'vegetarian';
    Color color = isVeg ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVeg ? Icons.circle : Icons.change_history,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isVeg ? 'VEG' : 'NON-VEG',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          )
        ],
      )
    );
  }

  Widget _buildDetailStatusBadge(ProductStatus status) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    String text;

    switch (status) {
      case ProductStatus.inStock:
        textColor = const Color(0xFF4CAF50);
        bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.05);
        borderColor = const Color(0xFF4CAF50).withValues(alpha: 0.2);
        text = 'In Stock';
        break;
      case ProductStatus.lowStock:
        textColor = const Color(0xFFE50914);
        bgColor = const Color(0xFFE50914).withValues(alpha: 0.05);
        borderColor = const Color(0xFFE50914).withValues(alpha: 0.2);
        text = 'Low Stock';
        break;
      case ProductStatus.outOfStock:
        textColor = Colors.grey.shade700;
        bgColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade300;
        text = 'Out of Stock';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Helper: Format numbers ────────────────────────────────────────────────

  static String _formatCompactNumber(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  // ── KPI Section ────────────────────────────────────────────────────────────

  Widget _buildKPISection({bool isDesktop = false}) {
    return BlocBuilder<ProductListBloc, ProductListPageState>(
      builder: (context, state) {
        if (state is! ProductListLoaded) return const SizedBox.shrink();

        final allCount = state.allCount;
        final activePercent = allCount > 0 ? ((state.activeCount / allCount) * 100).toStringAsFixed(0) : '0';
        final inactivePercent = allCount > 0 ? ((state.inactiveCount / allCount) * 100).toStringAsFixed(0) : '0';

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 20.0),
          child: Row(
            children: [
              _buildKPICard('Total Products', '${state.allCount}', Icons.inventory_2_outlined, const Color(0xFF3B82F6), trendText: 'Total inventory', trendColor: const Color(0xFF10B981)),
              const SizedBox(width: 12),
              _buildKPICard('Active', '${state.activeCount}', Icons.check_circle_outline, const Color(0xFF10B981), trendText: '$activePercent% of total', trendColor: const Color(0xFF10B981)),
              const SizedBox(width: 12),
              _buildKPICard('Inactive', '${state.inactiveCount}', Icons.cancel_outlined, const Color(0xFFEF4444), trendText: '$inactivePercent% of total', trendColor: const Color(0xFFEF4444)),
              const SizedBox(width: 12),
              _buildKPICard('Low Stock', '${state.lowStockCount}', Icons.warning_amber_rounded, const Color(0xFFF59E0B), trendText: 'Needs attention', trendColor: const Color(0xFFEF4444)),
              const SizedBox(width: 12),
              _buildKPICard('Revenue', '₹${_formatCompactNumber(state.totalRevenue)}', Icons.currency_rupee, const Color(0xFF8B5CF6), trendText: 'All time', trendColor: const Color(0xFF10B981)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, {String? trendText, Color? trendColor}) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          if (trendText != null) ...[
            const SizedBox(height: 8),
            Text(
              trendText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: trendColor ?? const Color(0xFF10B981),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Filter Section ─────────────────────────────────────────────────────────

  Widget _buildFilterSection({bool isDesktop = false}) {
    return BlocBuilder<ProductListBloc, ProductListPageState>(
      builder: (context, state) {
        if (state is! ProductListLoaded) return const SizedBox.shrink();
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        onChanged: (value) => context.read<ProductListBloc>().add(SearchProductsEvent(value)),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildFiltersButton(context, state, isDesktop),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterPill('All Products', '${state.allCount}', null, null, state.activeFilter == 'All Products', () => context.read<ProductListBloc>().add(const FilterProductsEvent('All Products'))),
                  _buildFilterPill('Active', '${state.activeCount}', Icons.check_circle_outline_rounded, const Color(0xFF10B981), state.activeFilter == 'Active', () => context.read<ProductListBloc>().add(const FilterProductsEvent('Active'))),
                  _buildFilterPill('Inactive', '${state.inactiveCount}', Icons.pause_circle_outline_rounded, const Color(0xFF6B7280), state.activeFilter == 'Inactive', () => context.read<ProductListBloc>().add(const FilterProductsEvent('Inactive'))),
                  _buildFilterPill('Low Stock', '${state.lowStockCount}', Icons.warning_amber_rounded, const Color(0xFFF59E0B), state.activeFilter == 'Low Stock', () => context.read<ProductListBloc>().add(const FilterProductsEvent('Low Stock'))),
                  _buildFilterPill('Veg', '${state.vegCount}', Icons.eco_outlined, const Color(0xFF10B981), state.activeFilter == 'Veg', () => context.read<ProductListBloc>().add(const FilterProductsEvent('Veg'))),
                  _buildFilterPill('Non-Veg', '${state.nonVegCount}', Icons.set_meal_outlined, const Color(0xFFEF4444), state.activeFilter == 'Non-Veg', () => context.read<ProductListBloc>().add(const FilterProductsEvent('Non-Veg'))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersButton(BuildContext context, ProductListLoaded state, bool isDesktop) {
    final bool hasAdvancedFilters = state.ratingFilter != null || 
        state.categoryFilter != null || 
        state.priceRangeMin != null || 
        state.priceRangeMax != null || 
        state.sortBy != 'Recently Added';

    return GestureDetector(
      onTap: () {
        if (isDesktop) {
          _showDesktopFilterSheet(context, state);
        } else {
          _showMobileFilterSheet(context, state);
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hasAdvancedFilters ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasAdvancedFilters ? const Color(0xFF111827) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.tune_rounded, color: hasAdvancedFilters ? Colors.white : Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'Filters',
              style: TextStyle(
                color: hasAdvancedFilters ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasAdvancedFilters) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('●', style: TextStyle(color: Colors.white, fontSize: 8)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Mobile Filter Bottom Sheet ─────────────────────────────────────────────

  void _showMobileFilterSheet(BuildContext parentContext, ProductListLoaded state) {
    showGeneralDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierLabel: 'Close filters',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(parentContext).size.height * 0.9),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 40,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: _FilterSheetContent(
                    state: state,
                    allProducts: parentContext.read<ProductListBloc>().repository,
                    isDesktop: false,
                    onApply: (sortBy, ratingFilter, categoryFilter, priceMin, priceMax) {
                      parentContext.read<ProductListBloc>().add(ApplyAdvancedFiltersEvent(
                        sortBy: sortBy,
                        ratingFilter: ratingFilter,
                        categoryFilter: categoryFilter,
                        priceRangeMin: priceMin,
                        priceRangeMax: priceMax,
                      ));
                      Navigator.pop(dialogContext);
                    },
                    onReset: () {
                      parentContext.read<ProductListBloc>().add(const ApplyAdvancedFiltersEvent(sortBy: 'Recently Added'));
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Desktop Filter Side Sheet ──────────────────────────────────────────────

  void _showDesktopFilterSheet(BuildContext parentContext, ProductListLoaded state) {
    showGeneralDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierLabel: 'Close filters',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: Container(
                  width: 420,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: _FilterSheetContent(
                    state: state,
                    allProducts: parentContext.read<ProductListBloc>().repository,
                    isDesktop: true,
                    onApply: (sortBy, ratingFilter, categoryFilter, priceMin, priceMax) {
                      parentContext.read<ProductListBloc>().add(ApplyAdvancedFiltersEvent(
                        sortBy: sortBy,
                        ratingFilter: ratingFilter,
                        categoryFilter: categoryFilter,
                        priceRangeMin: priceMin,
                        priceRangeMax: priceMax,
                      ));
                      Navigator.pop(dialogContext);
                    },
                    onReset: () {
                      parentContext.read<ProductListBloc>().add(const ApplyAdvancedFiltersEvent(sortBy: 'Recently Added'));
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Filter Pill ────────────────────────────────────────────────────────────

  Widget _buildFilterPill(String label, String count, IconData? icon, Color? iconColor, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF111827).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon, 
                size: 18, 
                color: isSelected ? Colors.white : (iconColor ?? const Color(0xFF4B5563)),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Product List ───────────────────────────────────────────────────────────

  Widget _buildProductList({required bool isDesktop}) {
    return BlocBuilder<ProductListBloc, ProductListPageState>(
      builder: (context, state) {
        if (state is ProductListLoading || state is ProductListInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 20.0),
            child: _buildSkeletonLoader(),
          );
        } else if (state is ProductListError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ProductListLoaded) {
          if (state.products.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 20.0, vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Text('Try adjusting your filters or search query', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            );
          }

          return isDesktop
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return _ProductCard(
                      product: product,
                      index: index,
                      isSelected: _selectedProduct?.id == product.id,
                      onTap: () {
                        setState(() {
                          _selectedProduct = product;
                        });
                      },
                    );
                  },
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  itemCount: state.products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return _ProductCard(
                      product: product,
                      index: index,
                      isSelected: false,
                      onTap: () {
                        setState(() {
                          _selectedProduct = product;
                        });
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 400),
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Product Details', style: TextStyle(color: Colors.black87)),
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    iconTheme: const IconThemeData(color: Colors.black87),
                                  ),
                                  backgroundColor: Colors.white,
                                  body: SafeArea(
                                    child: _buildProductDetailView(product),
                                  ),
                                ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
                              return SlideTransition(position: animation.drive(tween), child: child);
                            },
                          ),
                        );
                      },
                    );
                  },
                );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const _ShimmerBox(
                width: 80,
                height: 80,
                margin: EdgeInsets.all(12),
                borderRadius: 12,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ShimmerBox(height: 14, width: 120, borderRadius: 4),
                    SizedBox(height: 8),
                    _ShimmerBox(height: 14, width: 80, borderRadius: 4),
                    SizedBox(height: 8),
                    _ShimmerBox(height: 14, width: 60, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Filter Sheet Content (used by both Bottom Sheet and Side Sheet)
// ══════════════════════════════════════════════════════════════════════════════

class _FilterSheetContent extends StatefulWidget {
  final ProductListLoaded state;
  final ProductRepository allProducts;
  final bool isDesktop;
  final Function(String sortBy, double? ratingFilter, String? categoryFilter, double? priceMin, double? priceMax) onApply;
  final VoidCallback onReset;

  const _FilterSheetContent({
    required this.state,
    required this.allProducts,
    this.isDesktop = false,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> with SingleTickerProviderStateMixin {
  late String _sortBy;
  late double? _ratingFilter;
  late String? _categoryFilter;
  late RangeValues _priceRange;
  late double _minPrice;
  late double _maxPrice;
  late List<String> _categories;
  
  // New visual filters (UI only for now, can be wired to bloc later)
  final Set<String> _availability = {'In Stock'};
  final Set<String> _productType = {'Veg'};
  final Set<String> _discount = {'On Offer'};

  @override
  void initState() {
    super.initState();
    _sortBy = widget.state.sortBy;
    _ratingFilter = widget.state.ratingFilter;
    _categoryFilter = widget.state.categoryFilter;

    final allProducts = widget.state.products;
    final categorySet = <String>{};
    double minP = double.infinity;
    double maxP = 0;

    for (var p in allProducts) {
      if (p.category.isNotEmpty) categorySet.add(p.category);
      if (p.price < minP) minP = p.price;
      if (p.price > maxP) maxP = p.price;
    }

    _categories = categorySet.toList()..sort();
    if (_categories.isEmpty) {
      _categories = ['Pizza', 'Burger', 'Dessert', 'Drinks']; // Fallback for UI demo
    }
    
    _minPrice = minP.isFinite ? minP : 0;
    _maxPrice = maxP > 0 ? maxP : 5000;
    if (_minPrice == _maxPrice) _maxPrice = _minPrice + 100;

    _priceRange = RangeValues(
      widget.state.priceRangeMin ?? _minPrice,
      widget.state.priceRangeMax ?? _maxPrice,
    );
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_sortBy != 'Recently Added') count++;
    if (_ratingFilter != null) count++;
    if (_categoryFilter != null) count++;
    if (_priceRange.start > _minPrice || _priceRange.end < _maxPrice) count++;
    if (_availability.isNotEmpty) count++;
    if (_productType.isNotEmpty) count++;
    if (_discount.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _activeFiltersCount;
    
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      if (activeCount > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$activeCount Selected',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your product results',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 24, color: Color(0xFF111827)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Scrollable Content ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // Category Card
                _buildFilterCard(
                  title: 'Category',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: [
                      _buildChip('All', _categoryFilter == null, () => setState(() => _categoryFilter = null)),
                      ..._categories.map((c) => _buildChip(c, _categoryFilter == c, () => setState(() => _categoryFilter = c))),
                    ],
                  ),
                ),
                
                // Availability Card
                _buildFilterCard(
                  title: 'Availability',
                  child: Column(
                    children: [
                      _buildCheckboxTile('In Stock', _availability.contains('In Stock'), (val) {
                        setState(() { val == true ? _availability.add('In Stock') : _availability.remove('In Stock'); });
                      }),
                      _buildCheckboxTile('Low Stock', _availability.contains('Low Stock'), (val) {
                        setState(() { val == true ? _availability.add('Low Stock') : _availability.remove('Low Stock'); });
                      }),
                      _buildCheckboxTile('Out of Stock', _availability.contains('Out of Stock'), (val) {
                        setState(() { val == true ? _availability.add('Out of Stock') : _availability.remove('Out of Stock'); });
                      }),
                    ],
                  ),
                ),

                // Product Type Card
                _buildFilterCard(
                  title: 'Product Type',
                  child: Column(
                    children: [
                      _buildCheckboxTile('Veg', _productType.contains('Veg'), (val) {
                        setState(() { val == true ? _productType.add('Veg') : _productType.remove('Veg'); });
                      }),
                      _buildCheckboxTile('Non Veg', _productType.contains('Non Veg'), (val) {
                        setState(() { val == true ? _productType.add('Non Veg') : _productType.remove('Non Veg'); });
                      }),
                    ],
                  ),
                ),

                // Price Range Card
                _buildFilterCard(
                  title: 'Price Range',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceInput('Min Price', '₹${_priceRange.start.toInt()}'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPriceInput('Max Price', '₹${_priceRange.end.toInt()}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF111827),
                          inactiveTrackColor: const Color(0xFFE5E7EB),
                          thumbColor: Colors.white,
                          overlayColor: const Color(0xFF111827).withValues(alpha: 0.1),
                          trackHeight: 4,
                          rangeThumbShape: _CustomRangeSliderThumbShape(),
                        ),
                        child: RangeSlider(
                          values: _priceRange,
                          min: _minPrice,
                          max: _maxPrice,
                          onChanged: (values) => setState(() => _priceRange = values),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating Card
                _buildFilterCard(
                  title: 'Rating',
                  child: Column(
                    children: [
                      _buildRatingTile(4.0, '⭐⭐⭐⭐☆ & Above'),
                      _buildRatingTile(3.0, '⭐⭐⭐☆☆ & Above'),
                      _buildRatingTile(2.0, '⭐⭐☆☆☆ & Above'),
                    ],
                  ),
                ),

                // Sort By Card
                _buildFilterCard(
                  title: 'Sort By',
                  child: Column(
                    children: [
                      _buildRadioTile('Recently Added', 'Recently Added'),
                      _buildRadioTile('Best Selling', 'Best Selling'),
                      _buildRadioTile('Price Low → High', 'Price: Low to High'),
                      _buildRadioTile('Price High → Low', 'Price: High to Low'),
                      _buildRadioTile('Highest Rated', 'Highest Rated'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16), // Bottom padding for scroll
              ],
            ),
          ),
        ),

        // ── Sticky Bottom Bar ──
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _sortBy = 'Recently Added';
                      _ratingFilter = null;
                      _categoryFilter = null;
                      _priceRange = RangeValues(_minPrice, _maxPrice);
                      _availability.clear();
                      _productType.clear();
                      _discount.clear();
                    });
                    widget.onReset();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF111827),
                    side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final priceMin = _priceRange.start == _minPrice ? null : _priceRange.start;
                    final priceMax = _priceRange.end == _maxPrice ? null : _priceRange.end;
                    widget.onApply(_sortBy, _ratingFilter, _categoryFilter, priceMin, priceMax);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Apply (${widget.state.products.length} Products)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: content,
    );
  }

  // ── UI Helpers ──

  Widget _buildFilterCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isSelected ? const Color(0xFF111827) : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: isSelected 
            ? [BoxShadow(color: const Color(0xFF111827).withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))] 
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: FontWeight.w600, // Keeps shape consistent
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool isSelected, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => onChanged(!isSelected),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? const Color(0xFF111827) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRadioTile(String title, String value) {
    final isSelected = _sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => setState(() => _sortBy = value),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF111827) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected 
                  ? Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF111827))) 
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingTile(double value, String label) {
    final isSelected = _ratingFilter == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => setState(() => _ratingFilter = value),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF111827) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected 
                  ? Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF111827))) 
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInput(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
        ),
      ],
    );
  }
}

class _CustomRangeSliderThumbShape extends RangeSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;
    
    // Outer circle
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..color = const Color(0xFF111827)
        ..style = PaintingStyle.fill,
    );
    
    // Inner white circle
    canvas.drawCircle(
      center,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Product Card — Redesigned
// ══════════════════════════════════════════════════════════════════════════════

class _ProductCard extends StatefulWidget {
  final Product product;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.index,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _startAnimation = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50 + (widget.index * 50)), () {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isSelected = widget.isSelected;

    final shadow = isSelected
        ? [
            BoxShadow(
              color: const Color(0xFFE50914).withValues(alpha: 0.15),
              spreadRadius: 4,
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
              spreadRadius: _isHovered ? 4 : 2,
              blurRadius: _isHovered ? 20 : 15,
              offset: const Offset(0, 5),
            ),
          ];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _startAnimation ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        offset: _startAnimation ? Offset.zero : const Offset(0, 0.1),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              height: 144,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()..scale((_isHovered && !isSelected) ? 1.02 : 1.0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE50914).withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  width: 1,
                ),
                boxShadow: shadow,
              ),
              child: Opacity(
                opacity: product.isActive ? 1.0 : 0.5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left gradient strip for selected state
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isSelected ? 6 : 0,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF3B30), Color(0xFFE52929)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            Hero(
                              tag: 'product_image_${product.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : 'https://via.placeholder.com/150',
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 110,
                                    height: 110,
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFE50914)),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 110,
                                    height: 110,
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.fastfood,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Row 1: Name + Veg badge
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF111827),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildVegBadge(product.foodType),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Row 2: Category badge + Rating + Stock
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                      if (product.category.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product.category,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            color: product.isActive ? const Color(0xFFF59E0B) : Colors.grey.shade400,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            product.rating.toStringAsFixed(1),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '(${product.reviewCount})',
                                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      _buildStatusBadge(product.status, product.isActive),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Row 3: Price + Sold + Actions
                                  Row(
                                    children: [
                                      Text(
                                        '₹${product.price.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            children: [
                                              Text('${product.salesCount} Sold',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF6B7280))),
                                              const SizedBox(width: 12),
                                              // Action buttons
                                              _buildCardAction(Icons.edit_outlined, 'Edit', () {}),
                                              const SizedBox(width: 4),
                                              _buildCardAction(Icons.delete_outline, 'Delete', () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext dialogContext) {
                                                    return AlertDialog(
                                                      title: const Text('Delete Product'),
                                                      content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                      actions: [
                                                        TextButton(
                                                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                                          onPressed: () {
                                                            Navigator.of(dialogContext).pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                          onPressed: () {
                                                            Navigator.of(dialogContext).pop();
                                                            context.read<ProductListBloc>().add(DeleteProductEvent(product.id));
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }, isDestructive: true),
                                              const SizedBox(width: 4),
                                              _buildCardAction(Icons.share_outlined, 'Share', () {}),
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                height: 24,
                                                child: Transform.scale(
                                                  scale: 0.8,
                                                  child: Switch(
                                                    value: product.isActive,
                                                    onChanged: (val) {
                                                      context.read<ProductListBloc>().add(
                                                        ToggleProductStatusEvent(product.id, val),
                                                      );
                                                    },
                                                    activeThumbColor: Colors.white,
                                                    activeTrackColor: const Color(0xFF10B981),
                                                    inactiveThumbColor: Colors.white,
                                                    inactiveTrackColor: Colors.grey.shade300,
                                                  ),
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
                          ],
                        ),
                      ),
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

  Widget _buildCardAction(IconData icon, String tooltip, VoidCallback onTap, {bool isDestructive = false}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDestructive ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB)),
          ),
          child: Icon(icon, size: 15, color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ProductStatus status, bool isActive) {
    if (!isActive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFF6B7280), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text(
            'Inactive',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      );
    }

    Color color;
    String text;

    switch (status) {
      case ProductStatus.inStock:
        color = const Color(0xFF10B981);
        text = 'In Stock';
        break;
      case ProductStatus.lowStock:
        color = const Color(0xFFF59E0B);
        text = 'Low Stock';
        break;
      case ProductStatus.outOfStock:
        color = const Color(0xFFEF4444);
        text = 'Out of Stock';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildVegBadge(String foodType) {
    if (foodType.isEmpty) return const SizedBox.shrink();
    bool isVeg = foodType.toLowerCase() == 'veg' || foodType.toLowerCase() == 'vegetarian';
    Color color = isVeg ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVeg ? Icons.circle : Icons.change_history,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isVeg ? 'VEG' : 'NON-VEG',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          )
        ],
      )
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shimmer Loading Animation
// ══════════════════════════════════════════════════════════════════════════════

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const _ShimmerBox({
    this.width = double.infinity,
    required this.height,
    this.margin,
    this.borderRadius = 0,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                ],
                stops: const [0.0, 0.5, 1.0],
                transform: GradientRotation(_animation.value),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
          );
        },
      ),
    );
  }
}
