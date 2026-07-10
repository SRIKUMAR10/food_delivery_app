import 'package:flutter/material.dart';
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
  int _currentIndex = 2; // "Products" selected by default based on image
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
        backgroundColor: const Color(0xFFFBF5F5), // App background color
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
      ),
    );
  }

  // ── Mobile Layout ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Column(
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
        const SizedBox(height: 24),
        _buildFilterSection(),
        const SizedBox(height: 20),
        Expanded(child: _buildProductList(isDesktop: false)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildAddProductButton(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Desktop Layout (Master-Detail) ─────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Master View (List of Products)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildFilterSection(isDesktop: true),
              const SizedBox(height: 20),
              Expanded(child: _buildProductList(isDesktop: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: _buildAddProductButton(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Detail View
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.white,
            child: _selectedProduct == null
                ? const Center(
                    child: Text(
                      'Select a product to view details',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  )
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 350,
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE50914)),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 350,
                color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, color: Colors.grey, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
              ),
              Text(
                '₹${product.price.toInt()}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE50914),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusBadge(product.status),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 24),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'A delicious offering crafted with the finest ingredients to satisfy your cravings. Enjoy the perfect blend of flavors and textures in every bite. This is a great addition to your menu that customers will love.',
            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ProductStatus status) {
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

  Widget _buildFilterSection({bool isDesktop = false}) {
    return BlocBuilder<ProductListBloc, ProductListPageState>(
      builder: (context, state) {
        if (state is ProductListLoaded) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 20.0),
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'All',
                  state.allCount,
                  state.activeFilter == 'All',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Active',
                  state.activeCount,
                  state.activeFilter == 'Active',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Inactive',
                  state.inactiveCount,
                  state.activeFilter == 'Inactive',
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    int count,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<ProductListBloc>().add(FilterProductsEvent(label));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE50914) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

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
            return const Center(child: Text('No products found.'));
          }

          // Auto-select first product on desktop if none selected
          if (isDesktop &&
              _selectedProduct == null &&
              state.products.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedProduct = state.products.first;
                });
              }
            });
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProductListBloc>().add(LoadProductsEvent());
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.0 : 20.0,
              ),
              itemCount: state.products.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = state.products[index];
                return _ProductCard(
                  product: product,
                  isSelected: isDesktop && _selectedProduct?.id == product.id,
                  onTap: () {
                    setState(() {
                      _selectedProduct = product;
                    });
                    if (!isDesktop) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  Scaffold(
                                    appBar: AppBar(
                                      title: const Text(
                                        'Product Details',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      iconTheme: const IconThemeData(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    body: SafeArea(
                                      child: _buildProductDetailView(product),
                                    ),
                                  ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                var tween = Tween(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).chain(CurveTween(curve: Curves.easeInOut));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
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

  Widget _buildAddProductButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const food_app.AddProductPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE50914), // Red color
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text(
              'Add Product',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFFE50914), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914)),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildVegBadge(product.foodType),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(product.status),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${product.price.toInt()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF10B981),
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
    );
  }

  Widget _buildStatusBadge(ProductStatus status) {
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
