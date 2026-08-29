import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'add_product_page__bloc.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';
import '../product_list_page_/product_preview_page.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/repositories/i_product_repository.dart';
import '../../../../core/repositories/i_seller_repository.dart';
import '../../../../core/services/i_auth_service.dart';

// --- Theme Constants (Material 3) ---
const Color _bgColor = Color(0xFFF7F8FA);
const Color _surfaceColor = Color(0xFFFFFFFF);
const Color _primaryColor = Color(0xFFE53935);
const Color _accentColor = Color(0xFFFF6B35);
const Color _successColor = Color(0xFF16A34A); // Green
const Color _warningColor = Color(0xFFF59E0B); // Amber
const Color _textPrimary = Color(0xFF111827); // Dark gray
const Color _textSecondary = Color(0xFF6B7280); // Mid gray
const Color _borderColor = Color(0xFFE5E7EB); // Light border

class AddProductPage extends StatelessWidget {
  final String? productId;
  const AddProductPage({super.key, this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = AddProductPageBloc(
          repository: context.read<IProductRepository>(),
          authService: context.read<IAuthService>(),
          sellerRepository: context.read<ISellerRepository>(),
        )..add(FetchGstPercentageEvent());
        if (productId != null) {
          bloc.add(LoadProductEvent(productId!));
        }
        return bloc;
      },
      child: const AddProductView(),
    );
  }
}

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _descController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _portionSizeController = TextEditingController();
  final _addonsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _alertController = TextEditingController(text: '10');

  bool _isPreviewDesktop = false;
  bool _showLivePreview = true;
  bool _isUpdating = false;
  Timer? _updateTimer;
  bool _isInitialized = false;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'Fried Chicken', 'icon': '🍗', 'label': 'Fried Chicken'},
    {'id': 'Burgers', 'icon': '🍔', 'label': 'Burgers'},
    {'id': 'Pizza', 'icon': '🍕', 'label': 'Pizza'},
    {'id': 'Sides', 'icon': '🍟', 'label': 'Sides'},
    {'id': 'Beverages', 'icon': '🥤', 'label': 'Beverages'},
    {'id': 'Desserts', 'icon': '🍰', 'label': 'Desserts'},
    {'id': 'Special Combos', 'icon': '🍱', 'label': 'Special Combos'},
    {'id': 'Kids Meals', 'icon': '🧸', 'label': 'Kids Meals'},
  ];

  final Map<String, List<String>> _categorySubcategoryPresets = {
    'Fried Chicken': ['Buckets', 'Tenders & Strips', 'Popcorn Chicken', 'Wings', 'Crispy Drumsticks'],
    'Burgers': ['Crispy Chicken Burger', 'Classic Cheeseburger', 'Double Patty Tower', 'Veggie Burger', 'Smash Burger'],
    'Pizza': ['Margherita', 'Pepperoni', 'Veggie Supreme', 'BBQ Chicken', 'Cheese Burst', 'Thin Crust'],
    'Sides': ['French Fries', 'Chicken Nuggets', 'Garlic Bread', 'Onion Rings', 'Cheese Dips'],
    'Beverages': ['Cool Drinks', 'Soft Drinks', 'Thick Shakes', 'Mojitos & Crushes', 'Iced Teas'],
    'Desserts': ['Brownie Cake', 'Smoked Cake', 'Cheesecake', 'Lava Cake', 'Pastries', 'Ice Cream'],
    'Special Combos': ['Solo Box', 'Duo Feast', 'Family Mega Combo', 'Party Bucket', 'Lunch Deal'],
    'Kids Meals': ['Junior Burger Pack', 'Popcorn Chicken Kids Box', 'Mini Pizza Meal', 'Kids Box + Toy'],
  };

  final List<Map<String, dynamic>> _foodTypes = [
    {'id': 'Veg', 'color': Colors.green},
    {'id': 'Non-Veg', 'color': Colors.red},
    {'id': 'Egg', 'color': Colors.yellow.shade700},
  ];

  final List<Map<String, dynamic>> _spicyLevels = [
    {'id': 'Mild', 'icon': '🌶️'},
    {'id': 'Medium', 'icon': '🌶️🌶️'},
    {'id': 'Spicy', 'icon': '🌶️🌶️🌶️'},
    {'id': 'Extra Hot', 'icon': '🌶️🌶️🌶️🌶️'},
  ];

  @override
  void initState() {
    super.initState();
    // Add listeners to update live preview state
    _nameController.addListener(
      () => _updateField('name', _nameController.text),
    );
    _skuController.addListener(
      () => _updateField('sku', _skuController.text),
    );
    _subcategoryController.addListener(
      () => _updateField('subcategory', _subcategoryController.text),
    );
    _priceController.addListener(
      () =>
          _updateField('price', double.tryParse(_priceController.text) ?? 0.0),
    );
    _discountController.addListener(
      () => _updateField(
        'discountPercent',
        double.tryParse(_discountController.text) ?? 0.0,
      ),
    );
    _descController.addListener(
      () => _updateField('description', _descController.text),
    );
    _stockController.addListener(
      () => _updateField(
        'availableStock',
        int.tryParse(_stockController.text) ?? 0,
      ),
    );
    _alertController.addListener(
      () => _updateField(
        'minimumAlert',
        int.tryParse(_alertController.text) ?? 10,
      ),
    );
  }

  void _autoGenerateSku(String? category) {
    final cat = (category ?? 'PRD').toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final shortCat = cat.length >= 3 ? cat.substring(0, 3) : cat.padRight(3, 'X');
    final randomSuffix = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    _skuController.text = 'SKU-$shortCat-$randomSuffix';
    _updateField('sku', _skuController.text);
  }

  void _updateField(String field, dynamic value) {
    setState(() => _isUpdating = true);
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isUpdating = false);
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _nameController.dispose();
    _skuController.dispose();
    _subcategoryController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descController.dispose();
    _prepTimeController.dispose();
    _caloriesController.dispose();
    _portionSizeController.dispose();
    _addonsController.dispose();
    _ingredientsController.dispose();
    _stockController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocConsumer<AddProductPageBloc, AddProductPageState>(
          listener: (context, state) {
            if (state.initialProduct != null && !_isInitialized) {
              final p = state.initialProduct!;
              _nameController.text = p.name;
              _priceController.text = p.basePrice > 0 ? p.basePrice.toString() : p.price.toString();

              double pct = 0.0;
              final currentBasePrice = p.basePrice > 0 ? p.basePrice : p.price;
              if (p.discountPrice > 0 && currentBasePrice > 0) {
                // Determine discount based on pre-GST base price vs. post-GST final price.
                // The easiest way is to use the discountPercentage if we stored it,
                // but since we don't, we can reverse calculate the discount.
                final basePriceWithGst = currentBasePrice * (1 + (p.gstPercentage / 100));
                pct = 100 * (1 - (p.discountPrice / basePriceWithGst));
                if (pct < 0) pct = 0;
              }
              _discountController.text = pct > 0 ? pct.toStringAsFixed(0) : '';

              _descController.text = p.description;
              _skuController.text = p.sku;
              _subcategoryController.text = p.subcategory;
              _prepTimeController.text = p.prepTime.toString();
              _caloriesController.text = p.calories.toString();
              _portionSizeController.text = p.portionSize;
              _addonsController.text = p.addons.join(', ');
              _ingredientsController.text = p.ingredients.join(', ');
              _stockController.text = p.availableStock.toString();
              _alertController.text = p.minimumAlert.toString();
              _isInitialized = true;

              // Trigger live preview updates
              _updateField('name', p.name);
              _updateField('price', p.price);
              _updateField('discountPercent', pct);
              _updateField('description', p.description);
            }

            if (state.status == AddProductStatus.success) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: _surfaceColor,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.network(
                            'https://assets9.lottiefiles.com/packages/lf20_lk80fpsm.json',
                            width: 150,
                            height: 150,
                            repeat: false,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.check_circle,
                                  color: _successColor,
                                  size: 100,
                                ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Product Published!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your product is now live in the store.',
                            style: TextStyle(
                              fontSize: 14,
                              color: _textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(context); // Go back
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Products',
                                    style: TextStyle(color: _textPrimary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AddProductPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: _primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Add Another',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state.status == AddProductStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: _primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            if (isDesktop) {
              return _buildDesktopLayout(context, state);
            }
            return Column(
              children: [
                _buildProgressStepper(state.currentStep),
                Expanded(
                  child: ClipRect(
                    child: _buildMobileLayout(context, state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: !isDesktop ? _buildBottomActionBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth > 1024
        ? 26
        : (screenWidth > 600 ? 24 : 22);

    return AppBar(
      backgroundColor: _surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: _textPrimary),
      centerTitle: true,
      title: Text(
        'Add Product',
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: _textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        BlocBuilder<AddProductPageBloc, AddProductPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            if (state.lastSavedAt == null) return const SizedBox.shrink();
            final difference = DateTime.now().difference(state.lastSavedAt!);
            final timeStr = difference.inSeconds < 60
                ? '${difference.inSeconds} seconds ago'
                : '${difference.inMinutes} minutes ago';
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Saved $timeStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: _borderColor, height: 1.0),
      ),
    );
  }

  Widget _buildProgressStepper(int currentStep) {
    final steps = ['Images', 'Details', 'Pricing', 'Review'];
    return Container(
      color: _surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          return Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [_primaryColor, _accentColor],
                            )
                          : null,
                      color: isCompleted
                          ? _successColor
                          : (isActive ? null : _surfaceColor),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? _successColor
                            : (isActive ? Colors.transparent : _borderColor),
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: _primaryColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : _textSecondary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: isCompleted || isActive
                          ? _textPrimary
                          : _textSecondary,
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1)
                Container(
                  width: 50,
                  height: 3,
                  margin: const EdgeInsets.only(
                    bottom: 24,
                    left: 12,
                    right: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted ? _successColor : _borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AddProductPageState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Form (65%)
        Expanded(
          flex: 65,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressStepper(state.currentStep),
                _buildFormSections(context, state),
              ],
            ),
          ),
        ),
        // Right Column: Preview & Status (35%)
        Container(width: 1, color: _borderColor),
        Expanded(
          flex: 35,
          child: Container(
            color: _bgColor,
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _buildPreviewHeader(),
                  ),
                  const SizedBox(height: 16),
                  if (_showLivePreview) ...[
                    if (!_isPreviewDesktop)
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _buildPreviewWidget(state),
                          ),
                          SizedBox(
                            width: 320,
                            child: _buildActionCard(context, state),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _buildPreviewWidget(state),
                          ),
                          const SizedBox(height: 24),
                          _buildActionCard(context, state),
                        ],
                      ),
                  ] else ...[
                    _buildActionCard(context, state),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, AddProductPageState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildFormSections(context, state),
    );
  }

  Widget _buildFormSections(BuildContext context, AddProductPageState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Images', 'Upload up to 5 product images'),
          _buildImageUpload(context, state),
          const SizedBox(height: 32),

          _buildSectionHeader(
            'Product Information',
            'Basic details about your food item',
          ),
          _buildCard(
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'e.g. Burger Deluxe',
                  icon: Icons.inventory_2_outlined,
                  maxLength: 60,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        controller: _skuController,
                        label: 'SKU / Product ID',
                        hint: 'e.g. SKU-BUR-1001',
                        icon: Icons.qr_code_outlined,
                        suffixWidget: IconButton(
                          tooltip: 'Auto Generate SKU',
                          icon: const Icon(Icons.autorenew, color: _primaryColor),
                          onPressed: () => _autoGenerateSku(state.category),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        controller: _subcategoryController,
                        label: 'Subcategory',
                        hint: 'e.g. Gourmet Burgers',
                        icon: Icons.category_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildCategorySelector(context, state),
                const SizedBox(height: 24),
                _buildFoodTypeSelector(context, state),
                const SizedBox(height: 24),
                _buildSpicyLevelSelector(context, state),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader(
            'Pricing',
            'Set price, discounts, and calculate profit',
          ),
          _buildPricingSection(context, state),
          const SizedBox(height: 32),

          _buildSectionHeader(
            'Inventory & Logistics',
            'Manage stock and preparation time',
          ),
          _buildInventorySection(context, state),
          const SizedBox(height: 32),

          _buildSectionHeader('Details', 'Add descriptions and customizations'),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTextField(
                  controller: _descController,
                  label: 'Description',
                  hint: 'Describe the ingredients, taste, and portion size...',
                  icon: Icons.description_outlined,
                  maxLines: 5,
                  maxLength: 500,
                  helperText: 'Markdown supported',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _prepTimeController,
                        label: 'Prep Time',
                        hint: 'e.g. 15 mins',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _caloriesController,
                        label: 'Calories',
                        hint: 'e.g. 350 kcal',
                        icon: Icons.local_fire_department_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _portionSizeController,
                        label: 'Portion Size',
                        hint: 'e.g. Serves 2',
                        icon: Icons.restaurant_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _addonsController,
                  label: 'Add-ons / Customizations',
                  hint: 'e.g. Extra Cheese (+₹30), Extra Mayo (+₹15), Fries (+₹40)',
                  icon: Icons.add_circle_outline,
                  helperText: 'Optional (e.g. Name (+₹Price) or Name:Price)',
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _ingredientsController,
                  label: 'Ingredients',
                  hint: 'e.g. Bun, Chicken Patty, Cheese, Lettuce',
                  icon: Icons.eco_outlined,
                  helperText: 'Optional (comma-separated)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader(
            'Variants & Customizations',
            'Add size variants and add-on groups with pricing',
          ),
          _buildVariantsAndCustomizationSection(context, state),
          const SizedBox(height: 32),

          _buildSectionHeader(
            'Status & Visibility',
            'Control where this product appears',
          ),
          _buildStatusToggles(context, state),
          const SizedBox(height: 32),

          _buildSectionHeader(
            'Premium Features',
            'AI tools to optimize your listing',
          ),
          _buildPremiumFeaturesPlaceholder(),
          const SizedBox(height: 32),

          _buildSectionHeader('Review', 'Check before publishing'),
          _buildReviewChecklist(state),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildVariantsAndCustomizationSection(
    BuildContext context,
    AddProductPageState state,
  ) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Variants
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Variants / Sizes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Different sizes or portions (e.g., Small, Medium, Large)',
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showAddVariantDialog(context, state),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Variant'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          if (state.variants.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...state.variants.map((v) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.straighten, size: 16, color: _primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Price: ₹${v.price.toStringAsFixed(0)} • Stock: ${v.stock} ${v.sku.isNotEmpty ? '• SKU: ${v.sku}' : ''}',
                            style: const TextStyle(fontSize: 12, color: _textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () {
                        final updated = List<ProductVariant>.from(state.variants)
                          ..removeWhere((item) => item.id == v.id);
                        context.read<AddProductPageBloc>().add(
                          VariantsUpdatedEvent(updated),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: const Center(
                child: Text(
                  'No variants added yet. Click "Add Variant" if this item has multiple sizes.',
                  style: TextStyle(fontSize: 13, color: _textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(color: _borderColor),
          const SizedBox(height: 24),

          // Header: Customization Groups
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customization / Add-on Groups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Grouped choices (e.g., Choice of Crust, Extra Cheese)',
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showAddCustomizationGroupDialog(context, state),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Group'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          if (state.customizationGroups.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...state.customizationGroups.map((group) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          group.groupName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: group.isRequired
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            group.isRequired ? 'Required' : 'Optional',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: group.isRequired ? Colors.red : Colors.blue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () {
                            final updated = List<ProductCustomizationGroup>.from(state.customizationGroups)
                              ..removeWhere((g) => g.groupName == group.groupName);
                            context.read<AddProductPageBloc>().add(
                              CustomizationGroupsUpdatedEvent(updated),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: group.options.map((opt) {
                        return Chip(
                          label: Text(
                            '${opt.name} (+₹${opt.price.toStringAsFixed(0)})',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _borderColor),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: const Center(
                child: Text(
                  'No add-on groups added yet. Click "Add Group" to add required or optional extras.',
                  style: TextStyle(fontSize: 13, color: _textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddVariantDialog(BuildContext context, AddProductPageState state) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '50');
    final skuCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Product Variant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Variant / Size Name',
                    hintText: 'e.g. Regular, Large, 500ml',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Price (₹)',
                    hintText: '0.00',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stock Quantity',
                    hintText: '50',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skuCtrl,
                  decoration: InputDecoration(
                    labelText: 'Variant SKU (Optional)',
                    hintText: 'e.g. SKU-BUR-REG',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text) ?? 0.0;
                final stock = int.tryParse(stockCtrl.text) ?? 0;
                final sku = skuCtrl.text.trim();

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter variant name and valid price')),
                  );
                  return;
                }

                final newVariant = ProductVariant(
                  id: 'var_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  price: price,
                  stock: stock,
                  sku: sku,
                  isAvailable: true,
                );

                final updated = List<ProductVariant>.from(state.variants)..add(newVariant);
                context.read<AddProductPageBloc>().add(VariantsUpdatedEvent(updated));
                Navigator.pop(dialogContext);
              },
              child: const Text('Add Variant', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomizationGroupDialog(
    BuildContext context,
    AddProductPageState state,
  ) {
    final groupNameCtrl = TextEditingController();
    bool isRequired = false;
    final List<ProductAddon> options = [];
    final optNameCtrl = TextEditingController();
    final optPriceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Add Customization Group'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: groupNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        hintText: 'e.g. Choose Crust, Extra Toppings',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Required Selection'),
                      subtitle: const Text('Customer must select an option'),
                      value: isRequired,
                      onChanged: (val) {
                        setDialogState(() => isRequired = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Options in this Group:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    if (options.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        children: options.map((opt) {
                          return Chip(
                            label: Text('${opt.name} (+₹${opt.price.toStringAsFixed(0)})'),
                            onDeleted: () {
                              setDialogState(() {
                                options.removeWhere((o) => o.name == opt.name);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: optNameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Option Name',
                              hintText: 'e.g. Cheese Burst',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: optPriceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Price (₹)',
                              hintText: '40',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: _primaryColor),
                          onPressed: () {
                            final name = optNameCtrl.text.trim();
                            final price = double.tryParse(optPriceCtrl.text) ?? 0.0;
                            if (name.isNotEmpty) {
                              setDialogState(() {
                                options.add(
                                  ProductAddon(
                                    id: 'opt_${DateTime.now().millisecondsSinceEpoch}_${options.length}',
                                    name: name,
                                    price: price,
                                    isAvailable: true,
                                  ),
                                );
                                optNameCtrl.clear();
                                optPriceCtrl.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final groupName = groupNameCtrl.text.trim();
                    if (groupName.isEmpty || options.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter group name and at least one option')),
                      );
                      return;
                    }

                    final newGroup = ProductCustomizationGroup(
                      groupName: groupName,
                      isRequired: isRequired,
                      minSelect: isRequired ? 1 : 0,
                      maxSelect: 5,
                      options: options,
                    );

                    final updated = List<ProductCustomizationGroup>.from(state.customizationGroups)..add(newGroup);
                    context.read<AddProductPageBloc>().add(CustomizationGroupsUpdatedEvent(updated));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save Group', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImageUpload(BuildContext context, AddProductPageState state) {
    return _buildCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final List<XFile> images = await picker.pickMultiImage();
              if (images.isNotEmpty) {
                for (var image in images) {
                  if (mounted)
                    context.read<AddProductPageBloc>().add(
                      AddImageEvent(image),
                    );
                }
              }
            },
            child: CustomPaint(
              painter: DashedRectPainter(
                color: const Color(0xFFC7CBD1),
                strokeWidth: 2,
                gap: 8,
                radius: 16,
              ),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: _primaryColor,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Drag Images Here',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PNG • JPG • WEBP\nMaximum 5 Images',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: _borderColor),
                        borderRadius: BorderRadius.circular(8),
                        color: _surfaceColor,
                      ),
                      child: const Text(
                        'Browse Files',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.images.isNotEmpty || state.existingImages.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text(
              'Uploaded',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        state.existingImages.length +
                        state.images.length +
                        ((state.images.length + state.existingImages.length) < 5
                            ? 1
                            : 0),
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final totalImages =
                          state.existingImages.length + state.images.length;
                      if (index == totalImages) {
                        return GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final List<XFile> images = await picker
                                .pickMultiImage();
                            if (images.isNotEmpty) {
                              for (var image in images) {
                                if (mounted)
                                  context.read<AddProductPageBloc>().add(
                                    AddImageEvent(image),
                                  );
                              }
                            }
                          },
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _borderColor,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFFF9FAFB),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: _textSecondary,
                                size: 32,
                              ),
                            ),
                          ),
                        );
                      }

                      final isExistingImage =
                          index < state.existingImages.length;
                      final imageIndex = isExistingImage
                          ? index
                          : index - state.existingImages.length;
                      final isMain = index == 0;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        InteractiveViewer(
                                          minScale: 1.0,
                                          maxScale: 4.0,
                                          child: isExistingImage
                                              ? CachedNetworkImage(
                                                  imageUrl: state
                                                      .existingImages[imageIndex],
                                                  fit: BoxFit.contain,
                                                )
                                              : (kIsWeb
                                                    ? Image.network(
                                                        state
                                                            .images[imageIndex]
                                                            .path,
                                                      )
                                                    : Image.file(
                                                        File(
                                                          state
                                                              .images[imageIndex]
                                                              .path,
                                                        ),
                                                      )),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isMain ? _primaryColor : _borderColor,
                                  width: isMain ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: isExistingImage
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            state.existingImages[imageIndex],
                                        fit: BoxFit.cover,
                                      )
                                    : (kIsWeb
                                          ? Image.network(
                                              state.images[imageIndex].path,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(
                                                state.images[imageIndex].path,
                                              ),
                                              fit: BoxFit.cover,
                                            )),
                              ),
                            ),
                          ),
                          if (isMain)
                            Positioned(
                              top: -8,
                              left: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Main',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: GestureDetector(
                              onTap: () {
                                if (isExistingImage) {
                                  context.read<AddProductPageBloc>().add(
                                    RemoveExistingImageEvent(imageIndex),
                                  );
                                } else {
                                  context.read<AddProductPageBloc>().add(
                                    RemoveImageEvent(imageIndex),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: _primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.info_outline, size: 14, color: _textSecondary),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Drag to reorder. The first image will be used as the main thumbnail.',
                        style: TextStyle(fontSize: 13, color: _textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    AddProductPageState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 15,
            color: _textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _categories.map((cat) {
            final isSelected = state.category == cat['id'];
            return GestureDetector(
              onTap: () => context.read<AddProductPageBloc>().add(
                CategoryChangedEvent(cat['id']),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                width: 100,
                height: 100,
                transform: isSelected
                    ? (Matrix4.identity()..scale(1.05))
                    : Matrix4.identity(),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [_primaryColor, _accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : _surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : _borderColor,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cat['icon'], style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      cat['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (state.category != null && _categorySubcategoryPresets.containsKey(state.category)) ...[
          const SizedBox(height: 16),
          Text(
            'Suggested Subcategories for ${state.category}:',
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categorySubcategoryPresets[state.category]!.map((subcat) {
              final isSubSelected = _subcategoryController.text.trim().toLowerCase() == subcat.toLowerCase();
              return ActionChip(
                label: Text(subcat),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSubSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSubSelected ? _primaryColor : _textPrimary,
                ),
                backgroundColor: isSubSelected ? _primaryColor.withValues(alpha: 0.12) : _surfaceColor,
                side: BorderSide(
                  color: isSubSelected ? _primaryColor : _borderColor,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  _subcategoryController.text = subcat;
                  _updateField('subcategory', subcat);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFoodTypeSelector(
    BuildContext context,
    AddProductPageState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Type',
          style: TextStyle(
            fontSize: 14,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _foodTypes.map((type) {
            final isSelected = state.foodType == type['id'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: type['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(type['id']),
                ],
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val)
                  context.read<AddProductPageBloc>().add(
                    FoodTypeChangedEvent(type['id']),
                  );
              },
              selectedColor: (type['color'] as Color).withValues(alpha: 0.1),
              backgroundColor: _surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? type['color'] : _borderColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpicyLevelSelector(
    BuildContext context,
    AddProductPageState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spicy Level',
          style: TextStyle(
            fontSize: 14,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _spicyLevels.map((level) {
            final isSelected = state.spicyLevel == level['id'];
            return ChoiceChip(
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(level['icon'], style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(level['id'], style: const TextStyle(fontSize: 11)),
                ],
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val)
                  context.read<AddProductPageBloc>().add(
                    SpicyLevelChangedEvent(level['id']),
                  );
              },
              selectedColor: _primaryColor.withValues(alpha: 0.1),
              backgroundColor: _surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? _primaryColor : _borderColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPricingSection(BuildContext context, AddProductPageState state) {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final discountedPrice = price - (price * (discount / 100));
    final gstAmount = discountedPrice * (state.gstPercentage / 100);
    final finalPrice = discountedPrice + gstAmount;
    final roundedFinalPrice = finalPrice.roundToDouble();
    final roundOff = roundedFinalPrice - finalPrice;

    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _priceController,
                  label: 'Base Price',
                  hint: '0.00',
                  icon: Icons.currency_rupee_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _discountController,
                  label: 'Discount (%)',
                  hint: '0',
                  icon: Icons.percent_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceStat(
                  'Base Price',
                  '₹${price.toStringAsFixed(2)}',
                  _textPrimary,
                ),
                Container(width: 1, height: 40, color: _borderColor),
                _buildPriceStat(
                  'Discount',
                  '₹${(price - discountedPrice).toStringAsFixed(2)}',
                  _warningColor,
                ),
                if (state.gstPercentage > 0) ...[
                  Container(width: 1, height: 40, color: _borderColor),
                  _buildPriceStat(
                    'GST (${state.gstPercentage.toStringAsFixed(0)}%)',
                    '₹${gstAmount.toStringAsFixed(2)}',
                    _textSecondary,
                  ),
                ],
                Container(width: 1, height: 40, color: _borderColor),
                _buildPriceStat(
                  'Round Off',
                  '₹${roundOff.toStringAsFixed(2)}',
                  _textSecondary,
                ),
                Container(width: 1, height: 40, color: _borderColor),
                _buildPriceStat(
                  'Final Price',
                  '₹${roundedFinalPrice.toStringAsFixed(2)}',
                  _primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySection(
    BuildContext context,
    AddProductPageState state,
  ) {
    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stockController,
                  label: 'Available Stock',
                  hint: '0',
                  icon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  enabled: !state.hasUnlimitedStock,
                  onTap: () {
                    if (_stockController.text == '0') {
                      _stockController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _alertController,
                  label: 'Minimum Alert',
                  hint: '10',
                  icon: Icons.notification_important_outlined,
                  keyboardType: TextInputType.number,
                  enabled: !state.hasUnlimitedStock,
                  onTap: () {
                    if (_alertController.text == '10' || _alertController.text == '0') {
                      _alertController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: state.hasUnlimitedStock,
                activeColor: _primaryColor,
                onChanged: (val) {
                  if (val != null)
                    context.read<AddProductPageBloc>().add(
                      FieldChangedEvent('hasUnlimitedStock', val),
                    );
                },
              ),
              Expanded(
                child: const Text(
                  'Unlimited Stock (Always Available)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggles(BuildContext context, AddProductPageState state) {
    return _buildCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildToggleRow(
            'Available',
            'Customers can view and purchase this item',
            state.isActive,
            (val) =>
                context.read<AddProductPageBloc>().add(StatusChangedEvent(val)),
          ),
          const Divider(height: 1, color: _borderColor),
          _buildToggleRow(
            'Featured',
            'Highlight on the top of the menu',
            state.isFeatured,
            (val) => context.read<AddProductPageBloc>().add(
              FieldChangedEvent('isFeatured', val),
            ),
          ),
          const Divider(height: 1, color: _borderColor),
          _buildToggleRow(
            'Best Seller',
            'Add a best seller badge to this item',
            state.isBestSeller,
            (val) => context.read<AddProductPageBloc>().add(
              FieldChangedEvent('isBestSeller', val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: _textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _successColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeaturesPlaceholder() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildPremiumFeatureCard(
          'AI Description',
          Icons.auto_awesome,
          'Generate with AI',
        ),
        _buildPremiumFeatureCard('Smart Tags', Icons.tag, 'Auto-generate tags'),
        _buildPremiumFeatureCard(
          'Image Enhancer',
          Icons.image,
          'Auto crop & compress',
        ),
      ],
    );
  }

  Widget _buildPremiumFeatureCard(
    String title,
    IconData icon,
    String subtitle,
  ) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryColor, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewChecklist(AddProductPageState state) {
    bool hasImages = state.images.isNotEmpty || state.existingImages.isNotEmpty;
    bool hasName = _nameController.text.isNotEmpty;
    bool hasPrice =
        double.tryParse(_priceController.text) != null &&
        double.tryParse(_priceController.text)! > 0;
    bool hasCategory = state.category?.isNotEmpty ?? false;

    return _buildCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildChecklistItem('Images Uploaded', hasImages),
          const Divider(height: 32, color: _borderColor),
          _buildChecklistItem('Product Details', hasName),
          const Divider(height: 32, color: _borderColor),
          _buildChecklistItem('Price Setup', hasPrice),
          const Divider(height: 32, color: _borderColor),
          _buildChecklistItem('Category Selected', hasCategory),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool isComplete) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isComplete ? _successColor : _surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isComplete ? _successColor : _borderColor,
              width: 2,
            ),
          ),
          child: isComplete
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isComplete ? _textPrimary : _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
    int? maxLength,
    bool enabled = true,
    VoidCallback? onTap,
    Widget? suffixWidget,
  }) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        fontSize: 15,
        color: enabled ? _textPrimary : _textSecondary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: suffixWidget ??
            (controller.text.isNotEmpty && enabled
                ? const Icon(Icons.check_circle, color: _successColor, size: 20)
                : null),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? (maxLines * 20.0) : 0,
          ),
          child: Icon(icon, color: _primaryColor, size: 20),
        ),
        labelStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: _textSecondary.withValues(alpha: 0.5),
          fontWeight: FontWeight.normal,
        ),
        helperStyle: const TextStyle(color: _textSecondary, fontSize: 12),
        filled: true,
        fillColor: enabled ? _surfaceColor : _bgColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor),
        ),
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _showLivePreview = !_showLivePreview;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  _showLivePreview ? Icons.visibility : Icons.visibility_off,
                  color: _textSecondary,
                  size: 20,
                ),
              ),
            ),
            Text(
              'Live App Preview',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isUpdating
                  ? Row(
                      key: const ValueKey('updating'),
                      children: [
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _warningColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Updating...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _warningColor,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      key: const ValueKey('live'),
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _successColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _successColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
        if (_showLivePreview)
          Container(
            width: 200,
            height: 40,
            decoration: BoxDecoration(
              color: _borderColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  alignment: _isPreviewDesktop
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    heightFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildSegment(
                        'Mobile',
                        Icons.phone_android,
                        !_isPreviewDesktop,
                        () => setState(() => _isPreviewDesktop = false),
                      ),
                    ),
                    Expanded(
                      child: _buildSegment(
                        'Desktop',
                        Icons.desktop_windows,
                        _isPreviewDesktop,
                        () => setState(() => _isPreviewDesktop = true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSegment(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? _primaryColor : _textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? _primaryColor : _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewWidget(AddProductPageState state) {
    // Construct a temporary Product object from form controllers and BLoC state
    // This object is used to power the live preview.
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final discountedPrice = price - (price * (discount / 100));
    final gstAmount = discountedPrice * (state.gstPercentage / 100);
    final finalPrice = discountedPrice + gstAmount;
    final roundedFinalPrice = finalPrice.roundToDouble();
    final basePriceWithGst = price + (price * (state.gstPercentage / 100));
    final roundedBasePriceWithGst = basePriceWithGst.roundToDouble();

    final previewProduct = Product(
      id: state.initialProduct?.id ?? 'preview-id',
      name: _nameController.text,
      sku: _skuController.text,
      subcategory: _subcategoryController.text,
      variants: state.variants,
      customizationGroups: state.customizationGroups,
      price: roundedBasePriceWithGst,
      discountPrice: roundedFinalPrice,
      description: _descController.text,
      imageUrls: [
        ...state.existingImages,
        ...state.images.map((e) => e.path).toList()
      ],
      category: state.category ?? '',
      foodType: state.foodType ?? '',
      spicyLevel: state.spicyLevel ?? '',
      isBestSeller: state.isBestSeller,
      isFeatured: state.isFeatured,
      isActive: state.isActive,
      status: ProductStatus.inStock, // Preview assumes in stock
      rating: 0.0,
      reviewCount: 0,
      prepTime: int.tryParse(_prepTimeController.text) ?? 15,
      calories: int.tryParse(_caloriesController.text) ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return ProductPreviewWidget(
      product: previewProduct,
      initialIsDesktop: _isPreviewDesktop,
      // Pass local images for preview
      localImages: state.images.map((e) => File(e.path)).toList(),
      showHeader: false, // Prevent duplicated preview header
    );
  }

  Widget _buildActionCard(BuildContext context, AddProductPageState state) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: _borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save as Draft',
              style: TextStyle(color: _textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: state.status == AddProductStatus.loading
                ? null
                : () {
                    final basePrice = double.tryParse(_priceController.text) ?? 0.0;
                    final discountPct = double.tryParse(_discountController.text) ?? 0.0;
                    final discounted = basePrice - (basePrice * (discountPct / 100));
                    final gstAmount = discounted * (state.gstPercentage / 100);
                    final finalPrice = discounted + gstAmount;
                    final roundedFinalPrice = finalPrice.roundToDouble();
                    final basePriceWithGst = basePrice + (basePrice * (state.gstPercentage / 100));
                    final roundedBasePriceWithGst = basePriceWithGst.roundToDouble();

                    context.read<AddProductPageBloc>().add(
                      SubmitProductEvent(
                        name: _nameController.text,
                        sku: _skuController.text,
                        subcategory: _subcategoryController.text,
                        variants: state.variants,
                        customizationGroups: state.customizationGroups,
                        price: roundedBasePriceWithGst,
                        basePrice: basePrice,
                        gstPercentage: state.gstPercentage,
                        discountPrice: roundedFinalPrice,
                        description: _descController.text,
                        prepTime: _prepTimeController.text,
                        calories: _caloriesController.text,
                        portionSize: _portionSizeController.text,
                        addons: _addonsController.text,
                        ingredients: _ingredientsController.text,
                        availableStock: int.tryParse(_stockController.text),
                        minimumAlert: int.tryParse(_alertController.text),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.status == AddProductStatus.loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Publish Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return BlocBuilder<AddProductPageBloc, AddProductPageState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: _surfaceColor,
            border: const Border(top: BorderSide(color: _borderColor)),
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
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Draft',
                    style: TextStyle(color: _textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: state.status == AddProductStatus.loading
                      ? null
                      : () {
                          final basePrice = double.tryParse(_priceController.text) ?? 0.0;
                          final discountPct = double.tryParse(_discountController.text) ?? 0.0;
                          final discounted = basePrice - (basePrice * (discountPct / 100));
                          final gstAmount = discounted * (state.gstPercentage / 100);
                          final finalPrice = discounted + gstAmount;
                          final roundedFinalPrice = finalPrice.roundToDouble();
                          final basePriceWithGst = basePrice + (basePrice * (state.gstPercentage / 100));
                          final roundedBasePriceWithGst = basePriceWithGst.roundToDouble();

                          context.read<AddProductPageBloc>().add(
                            SubmitProductEvent(
                              name: _nameController.text,
                              sku: _skuController.text,
                              subcategory: _subcategoryController.text,
                              variants: state.variants,
                              customizationGroups: state.customizationGroups,
                              price: roundedBasePriceWithGst,
                              basePrice: basePrice,
                              gstPercentage: state.gstPercentage,
                              discountPrice: roundedFinalPrice,
                              description: _descController.text,
                              prepTime: _prepTimeController.text,
                              calories: _caloriesController.text,
                              portionSize: _portionSizeController.text,
                              addons: _addonsController.text,
                              ingredients: _ingredientsController.text,
                              availableStock: int.tryParse(_stockController.text),
                              minimumAlert: int.tryParse(_alertController.text),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.status == AddProductStatus.loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Publish',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom Painter for dashed border
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
    );

    Path dashPath = Path();
    double distance = 0.0;
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2.0;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}


