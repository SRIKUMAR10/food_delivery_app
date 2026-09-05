import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_product_page__bloc.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';
import '../product_list_page_/product_preview_page.dart';
import '../seller_ui_tokens.dart';
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

class _CustomizationOptionRow {
  final String id;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController discountController;
  final TextEditingController gstController;
  final TextEditingController hsnController;
  String taxType;
  bool trackInventory;

  _CustomizationOptionRow({
    String? id,
    String name = '',
    String price = '',
    String discount = '0',
    String gst = '5',
    String hsn = '996338',
    String taxType = 'intraState',
    this.trackInventory = false,
  })  : id = id ?? 'opt_${DateTime.now().microsecondsSinceEpoch}',
        nameController = TextEditingController(text: name),
        priceController = TextEditingController(text: price),
        discountController = TextEditingController(text: discount == '0' ? '' : discount),
        gstController = TextEditingController(text: gst),
        hsnController = TextEditingController(text: hsn),
        taxType = taxType;

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    discountController.dispose();
    gstController.dispose();
    hsnController.dispose();
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
  final _hsnCodeController = TextEditingController(text: '996331');
  final _subcategoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _descController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _portionSizeController = TextEditingController();
  final _addonsController = TextEditingController();
  final _newAddonNameController = TextEditingController();
  final _newAddonPriceController = TextEditingController();
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
    _hsnCodeController.addListener(() {
      _updateField('hsnCode', _hsnCodeController.text);
      context.read<AddProductPageBloc>().add(
        HsnCodeChangedEvent(_hsnCodeController.text.trim()),
      );
    });
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


  void _autoGenerateSku(BuildContext context, String? category) {
    final cat = (category ?? 'PRD').toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final shortCat = cat.length >= 3 ? cat.substring(0, 3) : cat.padRight(3, 'X');
    final randomSuffix = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    final oldSku = _skuController.text.trim();
    final newSku = 'SKU-$shortCat-$randomSuffix';
    _skuController.text = newSku;
    _updateField('sku', _skuController.text);

    final bloc = context.read<AddProductPageBloc>();
    bloc.add(SkuChangedEvent(newSku));

    // Smart Variant SKU Synchronization:
    // If existing variants have the old SKU prefix or empty SKU, cascade the update to the new SKU prefix!
    final currentVariants = bloc.state.variants;
    if (currentVariants.isNotEmpty) {
      final updatedVariants = currentVariants.map((v) {
        if (v.sku.isEmpty || (oldSku.isNotEmpty && v.sku.startsWith('$oldSku-'))) {
          String varSuffix = '';
          if (oldSku.isNotEmpty && v.sku.startsWith('$oldSku-')) {
            varSuffix = v.sku.substring('$oldSku-'.length);
          } else {
            final cleanVar = v.name.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
            varSuffix = cleanVar.length > 6 ? cleanVar.substring(0, 6) : (cleanVar.isNotEmpty ? cleanVar : 'VAR');
          }
          return v.copyWith(sku: '$newSku-$varSuffix');
        }
        return v;
      }).toList();

      bloc.add(VariantsUpdatedEvent(updatedVariants));
    }
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
    _hsnCodeController.dispose();
    _subcategoryController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descController.dispose();
    _prepTimeController.dispose();
    _caloriesController.dispose();
    _portionSizeController.dispose();
    _addonsController.dispose();
    _newAddonNameController.dispose();
    _newAddonPriceController.dispose();
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
              _hsnCodeController.text = p.hsnCode.isNotEmpty ? p.hsnCode : '996331';
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
              _updateField('sku', p.sku);
              _updateField('hsnCode', _hsnCodeController.text);
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
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: SellerUiTokens.dialogShadow,
                            border: Border.all(color: SellerUiTokens.borderSubtle),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.network(
                                'https://assets9.lottiefiles.com/packages/lf20_lk80fpsm.json',
                                width: 140,
                                height: 140,
                                repeat: false,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDCFCE7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: _successColor,
                                        size: 48,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Product Published!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your product is now live in the store.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: _textSecondary,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Close dialog
                                          Navigator.pop(context); // Go back
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Text(
                                          'View Products',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
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
                                          backgroundColor: _primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Text(
                                          'Add Another',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
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
          _buildProductInfoCard(context, state),
          const SizedBox(height: 32),

          _buildSectionHeader(
            'Unified Inventory & Pricing',
            'Single item price or multi-size portion variants with live GST calculation',
          ),
          _buildUnifiedInventoryEngine(context, state),
          const SizedBox(height: 32),

          _buildSectionHeader(
            'Customization & Add-on Groups',
            'Create optional or mandatory extras like toppings, sauces, and dips with pricing and tax',
          ),
          _buildUnifiedAddonGroupsSection(context, state),
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
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard(BuildContext context, AddProductPageState state) {
    return _buildCard(
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
                    onPressed: () => _autoGenerateSku(context, state.category),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _hsnCodeController,
                  label: 'HSN / SAC Code',
                  hint: 'e.g. 996331',
                  icon: Icons.receipt_long_outlined,
                  keyboardType: TextInputType.number,
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
          const SizedBox(height: 24),
          _buildTextField(
            controller: _descController,
            label: 'Description',
            hint: 'Describe the ingredients, taste, and portion size...',
            icon: Icons.description_outlined,
            maxLines: 4,
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
            controller: _ingredientsController,
            label: 'Ingredients',
            hint: 'e.g. Bun, Chicken Patty, Cheese, Lettuce',
            icon: Icons.eco_outlined,
            helperText: 'Optional (comma-separated)',
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedInventoryEngine(
    BuildContext context,
    AddProductPageState state,
  ) {
    final basePrice = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final discountedPrice = basePrice - (basePrice * (discount / 100));
    final isInter = state.taxType == 'interState';
    final cgstRate = state.cgstPercentage;
    final sgstRate = state.sgstPercentage;
    final igstRate = state.igstPercentage;
    final cgstVal = isInter ? 0.0 : ((discountedPrice * (cgstRate / 100)) * 100).roundToDouble() / 100.0;
    final sgstVal = isInter ? 0.0 : ((discountedPrice * (sgstRate / 100)) * 100).roundToDouble() / 100.0;
    final igstVal = isInter ? ((discountedPrice * (igstRate / 100)) * 100).roundToDouble() / 100.0 : 0.0;
    final totalTax = isInter ? igstVal : (cgstVal + sgstVal);
    final finalPrice = discountedPrice + totalTax;
    final roundedFinalPrice = finalPrice.roundToDouble();
    final roundOff = roundedFinalPrice - finalPrice;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Switch: Single Item vs Multiple Sizes / Variants
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read<AddProductPageBloc>().add(
                        const ToggleProductTypeEvent(false),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !state.hasVariants ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !state.hasVariants
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            !state.hasVariants
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 18,
                            color: !state.hasVariants ? _primaryColor : _textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Single Item (Standard)',
                            style: TextStyle(
                              fontWeight: !state.hasVariants ? FontWeight.bold : FontWeight.w500,
                              color: !state.hasVariants ? _textPrimary : _textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read<AddProductPageBloc>().add(
                        const ToggleProductTypeEvent(true),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: state.hasVariants ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: state.hasVariants
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.hasVariants
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 18,
                            color: state.hasVariants ? _primaryColor : _textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Multiple Sizes / Variants',
                            style: TextStyle(
                              fontWeight: state.hasVariants ? FontWeight.bold : FontWeight.w500,
                              color: state.hasVariants ? _textPrimary : _textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // IF SINGLE ITEM MODE
          if (!state.hasVariants) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Base Price (₹)',
                    hint: '0.00',
                    icon: Icons.currency_rupee_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _discountController,
                    label: 'Discount (%)',
                    hint: '0',
                    icon: Icons.percent_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // GST Slab & Tax Category Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<double>(
                    value: [0.0, 5.0, 12.0, 18.0, 28.0].contains(state.gstPercentage) ? state.gstPercentage : 5.0,
                    decoration: InputDecoration(
                      labelText: 'GST Slab',
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary),
                      prefixIcon: const Icon(Icons.percent_rounded, color: _primaryColor, size: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(value: 0.0, child: Text('0% (Exempt)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      DropdownMenuItem(value: 5.0, child: Text('5% (Food & Essentials)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      DropdownMenuItem(value: 12.0, child: Text('12% (Beverages & Snacks)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      DropdownMenuItem(value: 18.0, child: Text('18% (Standard Services)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      DropdownMenuItem(value: 28.0, child: Text('28% (Luxury / Aerated)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        context.read<AddProductPageBloc>().add(GstRateChangedEvent(val));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: state.taxType == 'interState' ? 'interState' : 'intraState',
                    decoration: InputDecoration(
                      labelText: 'Tax Category',
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary),
                      prefixIcon: const Icon(Icons.account_balance_outlined, color: _primaryColor, size: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(
                        value: 'intraState',
                        child: Text('Intra-State (CGST + SGST)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      DropdownMenuItem(
                        value: 'interState',
                        child: Text('Inter-State (IGST)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        context.read<AddProductPageBloc>().add(TaxTypeChangedEvent(val));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: state.hasUnlimitedStock,
                  activeColor: _primaryColor,
                  onChanged: (val) {
                    if (val != null) {
                      context.read<AddProductPageBloc>().add(
                        FieldChangedEvent('hasUnlimitedStock', val),
                      );
                    }
                  },
                ),
                const Text(
                  'Unlimited Stock (Always Available)',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Live Price Breakdown Card for Single Item
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 18, color: _primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isInter
                              ? 'Live Price & Statutory Tax (IGST: ${igstRate.toStringAsFixed(0)}% Inter-State • HSN: ${_hsnCodeController.text.trim().isNotEmpty ? _hsnCodeController.text.trim() : "996331"})'
                              : 'Live Price & Statutory Tax (CGST: ${cgstRate.toStringAsFixed(1)}% + SGST: ${sgstRate.toStringAsFixed(1)}% Intra-State • HSN: ${_hsnCodeController.text.trim().isNotEmpty ? _hsnCodeController.text.trim() : "996331"})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildPriceStat('Base Price', '₹${basePrice.toStringAsFixed(2)}', _textPrimary),
                        Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 40, color: _borderColor),
                        _buildPriceStat('Discount', '₹${(basePrice - discountedPrice).toStringAsFixed(2)}', _warningColor),
                        Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 40, color: _borderColor),
                        _buildPriceStat('Taxable Price', '₹${discountedPrice.toStringAsFixed(2)}', _textPrimary),
                        Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 40, color: _borderColor),
                        if (!isInter) ...[
                          _buildPriceStat('CGST (${cgstRate.toStringAsFixed(1)}%)', '₹${cgstVal.toStringAsFixed(2)}', _textSecondary),
                          Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 40, color: _borderColor),
                          _buildPriceStat('SGST (${sgstRate.toStringAsFixed(1)}%)', '₹${sgstVal.toStringAsFixed(2)}', _textSecondary),
                        ] else ...[
                          _buildPriceStat('IGST (${igstRate.toStringAsFixed(0)}%)', '₹${igstVal.toStringAsFixed(2)}', _textSecondary),
                        ],
                        Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 40, color: _borderColor),
                        _buildPriceStat('Round Off', '₹${roundOff.toStringAsFixed(2)}', _textSecondary),
                        Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 40, color: _borderColor),
                        _buildPriceStat('Final MRP', '₹${roundedFinalPrice.toStringAsFixed(2)}', _primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[

            // IF MULTI-VARIANT MODE
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: _primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Multi-Size Item Mode Active: Each size (Regular, Medium, Large) controls its own Base Price, GST, and Stock below.',
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Sizes / Variants Table',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Add size variants with specific pricing and inventory limits',
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => _showAddVariantDialog(context, state),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Size / Variant'),
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
              ...state.variants.asMap().entries.map((entry) {
                final index = entry.key;
                final v = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
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
                        child: const Icon(Icons.straighten, size: 18, color: _primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MRP: ₹${v.finalPrice.toStringAsFixed(2)} • Base: ₹${v.basePrice.toStringAsFixed(2)} • GST (${v.taxType == 'interState' ? 'IGST ${v.gstPercentage.toStringAsFixed(0)}%' : 'CGST+SGST ${v.gstPercentage.toStringAsFixed(0)}%'}) • HSN: ${v.hsnCode} • Stock: ${v.trackInventory ? v.stock : 'Unlimited'}${v.sku.isNotEmpty ? ' • SKU: ${v.sku}' : ''}',
                              style: const TextStyle(fontSize: 12, color: _textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: _primaryColor, size: 20),
                        tooltip: 'Edit Variant',
                        onPressed: () {
                          _showAddVariantDialog(
                            context,
                            state,
                            existingVariant: v,
                            existingIndex: index,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        tooltip: 'Delete Variant',
                        onPressed: () {
                          final updated = List<ProductVariant>.from(state.variants)
                            ..removeAt(index);
                          context.read<AddProductPageBloc>().add(
                            VariantsUpdatedEvent(updated),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Live Aggregated Summary for Multi-Variants
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPriceStat(
                      'Price Range',
                      '₹${state.computedPriceRange.$1.toStringAsFixed(0)} – ₹${state.computedPriceRange.$2.toStringAsFixed(0)}',
                      _primaryColor,
                    ),
                    Container(width: 1, height: 36, color: _borderColor),
                    _buildPriceStat(
                      'Total Available Stock',
                      '${state.effectiveTotalStock} Units',
                      _textPrimary,
                    ),
                    Container(width: 1, height: 36, color: _borderColor),
                    _buildPriceStat(
                      'Configured Sizes',
                      '${state.variants.length} Sizes',
                      _textSecondary,
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.format_list_bulleted_add, size: 36, color: _textSecondary),
                    const SizedBox(height: 8),
                    const Text(
                      'No size variants added yet.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Click "Add Size / Variant" to configure Regular, Medium, or Large portions.',
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPriceStat(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
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

  Widget _buildUnifiedAddonGroupsSection(
    BuildContext context,
    AddProductPageState state,
  ) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customization & Add-on Groups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Grouped choices like "Choice of Crust", "Extra Toppings", "Dips & Sauces"',
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
            ...state.customizationGroups.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;
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
                          icon: const Icon(Icons.edit_outlined, color: _primaryColor, size: 20),
                          tooltip: 'Edit Group',
                          onPressed: () {
                            _showAddCustomizationGroupDialog(
                              context,
                              state,
                              existingGroup: group,
                              existingIndex: index,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          tooltip: 'Delete Group',
                          onPressed: () {
                            final updated = List<ProductCustomizationGroup>.from(state.customizationGroups)
                              ..removeAt(index);
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
                        final priceLabel = opt.finalPrice > 0
                            ? '+₹${opt.finalPrice.toStringAsFixed(0)} (Base ₹${opt.basePrice.toStringAsFixed(0)}${opt.discountPercentage > 0 ? ' • ${opt.discountPercentage.toStringAsFixed(0)}% OFF' : ''} + GST ${opt.gstPercentage.toStringAsFixed(0)}%)'
                            : 'Free';
                        return Chip(
                          label: Text(
                            '${opt.name} • $priceLabel',
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

  InputDecoration _dialogInputDeco({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDense = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 13, color: _textSecondary),
      floatingLabelStyle: GoogleFonts.inter(
        fontSize: 13,
        color: _primaryColor,
        fontWeight: FontWeight.w600,
      ),
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 13,
        color: _textSecondary.withValues(alpha: 0.6),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: isDense ? 10 : 13,
      ),
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
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
    );
  }

  void _showAddVariantDialog(
    BuildContext context,
    AddProductPageState state, {
    ProductVariant? existingVariant,
    int? existingIndex,
  }) {
    final bloc = context.read<AddProductPageBloc>();
    final nameCtrl = TextEditingController(text: existingVariant?.name ?? '');
    final basePriceCtrl = TextEditingController(
      text: existingVariant != null
          ? (existingVariant.basePrice > 0
              ? (existingVariant.basePrice.truncateToDouble() == existingVariant.basePrice
                  ? existingVariant.basePrice.toInt().toString()
                  : existingVariant.basePrice.toString())
              : (existingVariant.price.truncateToDouble() == existingVariant.price
                  ? existingVariant.price.toInt().toString()
                  : existingVariant.price.toString()))
          : '',
    );
    final discountCtrl = TextEditingController(
      text: existingVariant != null ? existingVariant.discountPercentage.toStringAsFixed(0) : '0',
    );
    final gstCtrl = TextEditingController(
      text: existingVariant != null ? existingVariant.gstPercentage.toStringAsFixed(0) : state.gstPercentage.toStringAsFixed(0),
    );
    final stockCtrl = TextEditingController(
      text: existingVariant != null ? existingVariant.stock.toString() : '50',
    );
    final skuCtrl = TextEditingController(text: existingVariant?.sku ?? '');
    final hsnCtrl = TextEditingController(
      text: existingVariant?.hsnCode.isNotEmpty == true
          ? existingVariant!.hsnCode
          : (_hsnCodeController.text.trim().isNotEmpty
              ? _hsnCodeController.text.trim()
              : '996338'),
    );
    bool trackInventory = existingVariant?.trackInventory ?? true;
    String variantTaxType = existingVariant?.taxType ?? state.taxType;

    void generateVariantSku() {
      final vName = nameCtrl.text.trim();
      final cleanVar = vName.isNotEmpty
          ? vName.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '')
          : 'VAR';
      final varSuffix = cleanVar.length > 6 ? cleanVar.substring(0, 6) : cleanVar;

      String baseSku = _skuController.text.trim();
      if (baseSku.isEmpty) {
        final cat = (state.category ?? 'PRD').toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
        final shortCat = cat.length >= 3 ? cat.substring(0, 3) : cat.padRight(3, 'X');
        final randomSuffix = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
        baseSku = 'SKU-$shortCat-$randomSuffix';
      }
      skuCtrl.text = '$baseSku-$varSuffix';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (innerContext, setDialogState) {
              final double screenWidth = MediaQuery.of(dialogContext).size.width;
              final bool isDesktop = screenWidth >= 640;

              final double basePriceVal = double.tryParse(basePriceCtrl.text) ?? 0.0;
              final double discVal = double.tryParse(discountCtrl.text) ?? 0.0;
              final double gstVal = double.tryParse(gstCtrl.text) ?? 5.0;
              final double discountedVal = basePriceVal * (1 - (discVal / 100).clamp(0.0, 1.0));
              final bool isInter = variantTaxType == 'interState';
              final double cgstRate = isInter ? 0.0 : gstVal / 2.0;
              final double sgstRate = isInter ? 0.0 : gstVal / 2.0;
              final double igstRate = isInter ? gstVal : 0.0;
              final double cgstAmt = isInter ? 0.0 : ((discountedVal * (cgstRate / 100)) * 100).roundToDouble() / 100;
              final double sgstAmt = isInter ? 0.0 : ((discountedVal * (sgstRate / 100)) * 100).roundToDouble() / 100;
              final double igstAmt = isInter ? ((discountedVal * (igstRate / 100)) * 100).roundToDouble() / 100 : 0.0;
              final double totalTax = isInter ? igstAmt : (cgstAmt + sgstAmt);
              final double unroundedTotal = discountedVal + totalTax;
              final double estimatedMrp = unroundedTotal.roundToDouble();
              final double roundOffAmt = (((estimatedMrp - unroundedTotal)) * 100).roundToDouble() / 100.0;
              final String varHsn = hsnCtrl.text.trim().isNotEmpty
                  ? hsnCtrl.text.trim()
                  : (_hsnCodeController.text.trim().isNotEmpty
                      ? _hsnCodeController.text.trim()
                      : '996338');

              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 540 : 460),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: SellerUiTokens.dialogShadow,
                        border: Border.all(color: SellerUiTokens.borderSubtle),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: _primaryColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        existingVariant != null
                                            ? 'Edit Product Variant'
                                            : 'Add Product Variant',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Configure statutory tax, pricing, stock & SKU',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: _textSecondary, size: 22),
                                  tooltip: 'Close',
                                  onPressed: () => Navigator.pop(dialogContext),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),

                          // Content Scrollable
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Variant Name
                                  TextField(
                                    controller: nameCtrl,
                                    onChanged: (_) => setDialogState(() {}),
                                    decoration: _dialogInputDeco(
                                      label: 'Variant / Size Name',
                                      hint: 'e.g. Regular, Large, 500ml',
                                      prefixIcon: const Icon(Icons.title_rounded, size: 20, color: _textSecondary),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Base Price & Discount
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: basePriceCtrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (_) => setDialogState(() {}),
                                          decoration: _dialogInputDeco(
                                            label: 'Base Price (₹)',
                                            hint: '0.00',
                                            prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18, color: _textSecondary),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: discountCtrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (_) => setDialogState(() {}),
                                          decoration: _dialogInputDeco(
                                            label: 'Discount %',
                                            hint: '0',
                                            prefixIcon: const Icon(Icons.percent_rounded, size: 16, color: _textSecondary),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // GST Rate Slabs & Tax Category
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<double>(
                                          value: [0.0, 5.0, 12.0, 18.0, 28.0].contains(double.tryParse(gstCtrl.text)) ? double.tryParse(gstCtrl.text) : 5.0,
                                          isExpanded: true,
                                          decoration: _dialogInputDeco(
                                            label: 'GST Slab',
                                            prefixIcon: const Icon(Icons.percent_rounded, size: 16, color: _textSecondary),
                                            isDense: true,
                                          ),
                                          dropdownColor: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          items: const [
                                            DropdownMenuItem(value: 0.0, child: Text('0% (Exempt)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: 5.0, child: Text('5% (Food)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: 12.0, child: Text('12% (Drinks)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: 18.0, child: Text('18% (Std)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: 28.0, child: Text('28% (Lux)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setDialogState(() {
                                                gstCtrl.text = val.toStringAsFixed(0);
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: variantTaxType == 'interState' ? 'interState' : 'intraState',
                                          isExpanded: true,
                                          decoration: _dialogInputDeco(
                                            label: 'Tax Type',
                                            prefixIcon: const Icon(Icons.account_balance_outlined, size: 16, color: _textSecondary),
                                            isDense: true,
                                          ),
                                          dropdownColor: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          items: const [
                                            DropdownMenuItem(value: 'intraState', child: Text('CGST+SGST', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: 'interState', child: Text('IGST', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setDialogState(() {
                                                variantTaxType = val;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Stock Qty & Variant SKU
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: stockCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: _dialogInputDeco(
                                            label: 'Stock',
                                            hint: '50',
                                            prefixIcon: const Icon(Icons.inventory_rounded, size: 16, color: _textSecondary),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: skuCtrl,
                                          decoration: _dialogInputDeco(
                                            label: 'Variant SKU',
                                            hint: 'e.g. SKU-BUR-REG',
                                            prefixIcon: const Icon(Icons.qr_code_2_rounded, size: 16, color: _textSecondary),
                                            isDense: true,
                                            suffixIcon: IconButton(
                                              tooltip: 'Auto Generate Variant SKU',
                                              icon: const Icon(Icons.autorenew_rounded, color: _primaryColor, size: 16),
                                              onPressed: () {
                                                setDialogState(() {
                                                  generateVariantSku();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Statutory HSN Code
                                  TextField(
                                    controller: hsnCtrl,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setDialogState(() {}),
                                    decoration: _dialogInputDeco(
                                      label: 'HSN Code',
                                      hint: '996338',
                                      prefixIcon: const Icon(Icons.tag_rounded, size: 16, color: _textSecondary),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Live Price & Statutory Tax Preview Card (matching Image 1 ditto!)
                                  if (basePriceVal > 0)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 14),
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
                                            children: [
                                              const Icon(Icons.receipt_long_rounded, size: 16, color: _primaryColor),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  isInter
                                                      ? 'Live Price & Statutory Tax (IGST: ${igstRate.toStringAsFixed(0)}% Inter-State • HSN: $varHsn)'
                                                      : 'Live Price & Statutory Tax (CGST: ${cgstRate.toStringAsFixed(1)}% + SGST: ${sgstRate.toStringAsFixed(1)}% Intra-State • HSN: $varHsn)',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                    color: _textPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                _buildPriceStat('Base Price', '₹${basePriceVal.toStringAsFixed(2)}', _textPrimary),
                                                Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                                _buildPriceStat('Discount', '₹${(basePriceVal - discountedVal).toStringAsFixed(2)}', _warningColor),
                                                Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                                _buildPriceStat('Taxable Price', '₹${discountedVal.toStringAsFixed(2)}', _textPrimary),
                                                Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                                if (!isInter) ...[
                                                  _buildPriceStat('CGST (${cgstRate.toStringAsFixed(1)}%)', '₹${cgstAmt.toStringAsFixed(2)}', _textSecondary),
                                                  Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                                  _buildPriceStat('SGST (${sgstRate.toStringAsFixed(1)}%)', '₹${sgstAmt.toStringAsFixed(2)}', _textSecondary),
                                                ] else ...[
                                                  _buildPriceStat('IGST (${igstRate.toStringAsFixed(0)}%)', '₹${igstAmt.toStringAsFixed(2)}', _textSecondary),
                                                ],
                                                Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                                _buildPriceStat('Round Off', '₹${roundOffAmt.toStringAsFixed(2)}', _textSecondary),
                                                Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                                _buildPriceStat('Final MRP', '₹${estimatedMrp.toStringAsFixed(2)}', _primaryColor),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 12),

                                  // Track Inventory Card
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: trackInventory
                                                ? _primaryColor.withValues(alpha: 0.1)
                                                : const Color(0xFFE2E8F0),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            size: 20,
                                            color: trackInventory ? _primaryColor : _textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Track Inventory',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _textPrimary,
                                                ),
                                              ),
                                              Text(
                                                'Enforce stock limit for this variant',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: _textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: trackInventory,
                                          activeThumbColor: Colors.white,
                                          activeTrackColor: _primaryColor,
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor: const Color(0xFFCBD5E1),
                                          onChanged: (val) => setDialogState(() => trackInventory = val),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 1, color: Color(0xFFF1F5F9)),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        final name = nameCtrl.text.trim();
                                        final basePrice = double.tryParse(basePriceCtrl.text) ?? 0.0;
                                        final discount = double.tryParse(discountCtrl.text) ?? 0.0;
                                        final gst = double.tryParse(gstCtrl.text) ?? 5.0;
                                        final stock = int.tryParse(stockCtrl.text) ?? 0;
                                        final sku = skuCtrl.text.trim();
                                        final hsn = hsnCtrl.text.trim().isNotEmpty ? hsnCtrl.text.trim() : '996338';

                                        if (name.isEmpty || basePrice <= 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please enter variant name and valid base price')),
                                          );
                                          return;
                                        }

                                        final newVariant = ProductVariant(
                                          id: existingVariant?.id ?? 'var_${DateTime.now().millisecondsSinceEpoch}',
                                          name: name,
                                          basePrice: basePrice,
                                          discountPercentage: discount,
                                          gstPercentage: gst,
                                          taxType: variantTaxType,
                                          hsnCode: hsn,
                                          stock: stock,
                                          sku: sku,
                                          isAvailable: true,
                                          trackInventory: trackInventory,
                                        );

                                        final updated = List<ProductVariant>.from(state.variants);
                                        if (existingIndex != null && existingIndex >= 0 && existingIndex < updated.length) {
                                          updated[existingIndex] = newVariant;
                                        } else {
                                          updated.add(newVariant);
                                        }


                                        bloc.add(VariantsUpdatedEvent(updated));
                                        Navigator.pop(dialogContext);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Variant "$name" saved successfully!'),
                                            backgroundColor: _successColor,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        existingVariant != null ? 'Update Variant' : 'Add Variant',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddCustomizationGroupDialog(
    BuildContext context,
    AddProductPageState state, {
    ProductCustomizationGroup? existingGroup,
    int? existingIndex,
  }) {
    final bloc = context.read<AddProductPageBloc>();
    final groupNameCtrl = TextEditingController(text: existingGroup?.groupName ?? '');
    bool isRequired = existingGroup?.isRequired ?? false;

    // Initialize option rows
    final List<_CustomizationOptionRow> optionRows = [];
    final String defaultHsn = _hsnCodeController.text.trim().isNotEmpty
        ? _hsnCodeController.text.trim()
        : '996338';

    if (existingGroup != null && existingGroup.options.isNotEmpty) {
      for (final opt in existingGroup.options) {
        final p = opt.basePrice > 0
            ? (opt.basePrice.truncateToDouble() == opt.basePrice
                ? opt.basePrice.toInt().toString()
                : opt.basePrice.toString())
            : (opt.price > 0
                ? (opt.price.truncateToDouble() == opt.price
                    ? opt.price.toInt().toString()
                    : opt.price.toString())
                : '');
        final disc = opt.discountPercentage.toStringAsFixed(0);
        optionRows.add(_CustomizationOptionRow(
          id: opt.id,
          name: opt.name,
          price: p,
          discount: disc != '0' ? disc : '',
          gst: opt.gstPercentage.toStringAsFixed(0),
          hsn: opt.hsnCode.isNotEmpty ? opt.hsnCode : defaultHsn,
          taxType: opt.taxType.isNotEmpty ? opt.taxType : state.taxType,
          trackInventory: opt.trackInventory,
        ));
      }
    } else {
      // Start with 1 empty row ready to type
      optionRows.add(_CustomizationOptionRow(
        hsn: defaultHsn,
        taxType: state.taxType,
      ));
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (innerContext, setDialogState) {
              final double screenWidth = MediaQuery.of(dialogContext).size.width;
              final bool isDesktop = screenWidth >= 640;

              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 680 : 540),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: SellerUiTokens.dialogShadow,
                        border: Border.all(color: SellerUiTokens.borderSubtle),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: const Icon(
                                    Icons.layers_outlined,
                                    color: _primaryColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        existingGroup != null
                                            ? 'Edit Customization Group'
                                            : 'Add Customization Group',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Configure required choices, statutory tax & add-on pricing',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: _textSecondary, size: 22),
                                  tooltip: 'Close',
                                  onPressed: () {
                                    for (final r in optionRows) {
                                      r.dispose();
                                    }
                                    Navigator.pop(dialogContext);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),

                          // Content Scrollable
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Group Name
                                  TextField(
                                    controller: groupNameCtrl,
                                    decoration: _dialogInputDeco(
                                      label: 'Group Name',
                                      hint: 'e.g. Choose Crust, Extra Toppings',
                                      prefixIcon: const Icon(Icons.category_outlined, size: 20, color: _textSecondary),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Required Selection Switch Card
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isRequired
                                                ? _primaryColor.withValues(alpha: 0.1)
                                                : const Color(0xFFE2E8F0),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.fact_check_outlined,
                                            size: 20,
                                            color: isRequired ? _primaryColor : _textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Required Selection',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _textPrimary,
                                                ),
                                              ),
                                              Text(
                                                'Customer must select an option',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: _textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: isRequired,
                                          activeThumbColor: Colors.white,
                                          activeTrackColor: _primaryColor,
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor: const Color(0xFFCBD5E1),
                                          onChanged: (val) => setDialogState(() => isRequired = val),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Options Header
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Text(
                                              'Options in this Group:',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: _textPrimary,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEF2F2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFFECACA)),
                                              ),
                                              child: Text(
                                                '${optionRows.length} option${optionRows.length > 1 ? 's' : ''}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: _primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          setDialogState(() {
                                            optionRows.add(_CustomizationOptionRow(
                                              hsn: defaultHsn,
                                              taxType: state.taxType,
                                            ));
                                          });
                                        },
                                        icon: const Icon(Icons.add, size: 16, color: _primaryColor),
                                        label: Text(
                                          'Add Option',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Base price, Discount %, Statutory GST slab & HSN code per add-on. Leave price 0 for free options.',
                                    style: GoogleFonts.inter(fontSize: 11, color: _textSecondary),
                                  ),
                                  const SizedBox(height: 12),

                                  // List of dynamic option cards with live Statutory Tax breakdown
                                  ...List.generate(optionRows.length, (idx) {
                                    final row = optionRows[idx];
                                    final double basePriceVal = double.tryParse(row.priceController.text.trim()) ?? 0.0;
                                    final double discVal = double.tryParse(row.discountController.text.trim()) ?? 0.0;
                                    final double gstVal = double.tryParse(row.gstController.text.trim()) ?? 5.0;
                                    final double discountedVal = basePriceVal * (1.0 - (discVal / 100.0).clamp(0.0, 1.0));
                                    final bool isInter = row.taxType == 'interState';
                                    final double cgstRate = isInter ? 0.0 : gstVal / 2.0;
                                    final double sgstRate = isInter ? 0.0 : gstVal / 2.0;
                                    final double igstRate = isInter ? gstVal : 0.0;
                                    final double cgstVal = isInter ? 0.0 : ((discountedVal * (cgstRate / 100.0)) * 100).roundToDouble() / 100.0;
                                    final double sgstVal = isInter ? 0.0 : ((discountedVal * (sgstRate / 100.0)) * 100).roundToDouble() / 100.0;
                                    final double igstVal = isInter ? ((discountedVal * (igstRate / 100.0)) * 100).roundToDouble() / 100.0 : 0.0;
                                    final double totalTax = isInter ? igstVal : (cgstVal + sgstVal);
                                    final double unroundedFinal = discountedVal + totalTax;
                                    final double roundedFinalPrice = unroundedFinal.roundToDouble();
                                    final double roundOff = ((roundedFinalPrice - unroundedFinal) * 100).roundToDouble() / 100.0;
                                    final String optHsn = row.hsnController.text.trim().isNotEmpty
                                        ? row.hsnController.text.trim()
                                        : defaultHsn;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12.0),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Top Row: Option Name + HSN Code + Action Buttons
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: TextField(
                                                  controller: row.nameController,
                                                  onChanged: (_) => setDialogState(() {}),
                                                  decoration: _dialogInputDeco(
                                                    label: 'Option ${idx + 1} Name',
                                                    hint: 'e.g. Extra Cheese',
                                                    isDense: true,
                                                    prefixIcon: const Icon(Icons.label_outline, size: 16, color: _textSecondary),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 3,
                                                child: TextField(
                                                  controller: row.hsnController,
                                                  onChanged: (_) => setDialogState(() {}),
                                                  decoration: _dialogInputDeco(
                                                    label: 'HSN Code',
                                                    hint: '996338',
                                                    isDense: true,
                                                    prefixIcon: const Icon(Icons.tag_rounded, size: 16, color: _textSecondary),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                                                tooltip: 'Remove option',
                                                onPressed: optionRows.length > 1
                                                    ? () {
                                                        setDialogState(() {
                                                          final removed = optionRows.removeAt(idx);
                                                          removed.dispose();
                                                        });
                                                      }
                                                    : () {
                                                        setDialogState(() {
                                                          row.nameController.clear();
                                                          row.priceController.clear();
                                                          row.discountController.clear();
                                                          row.gstController.text = '5';
                                                          row.hsnController.text = defaultHsn;
                                                          row.taxType = state.taxType;
                                                        });
                                                      },
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                icon: const Icon(Icons.add_circle, color: _primaryColor, size: 24),
                                                tooltip: 'Add option below',
                                                onPressed: () {
                                                  setDialogState(() {
                                                    optionRows.insert(
                                                      idx + 1,
                                                      _CustomizationOptionRow(
                                                        hsn: defaultHsn,
                                                        taxType: state.taxType,
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          // Second Row: Base Price + Discount + GST Slab + Tax Type
                                          Row(
                                            children: [
                                              // Base Price (₹)
                                              Expanded(
                                                flex: 2,
                                                child: TextField(
                                                  controller: row.priceController,
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  onChanged: (_) => setDialogState(() {}),
                                                  decoration: _dialogInputDeco(
                                                    label: 'Base (₹)',
                                                    hint: '0',
                                                    isDense: true,
                                                    prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 15, color: _textSecondary),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Discount %
                                              Expanded(
                                                flex: 2,
                                                child: TextField(
                                                  controller: row.discountController,
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  onChanged: (_) => setDialogState(() {}),
                                                  decoration: _dialogInputDeco(
                                                    label: 'Disc %',
                                                    hint: '0',
                                                    isDense: true,
                                                    prefixIcon: const Icon(Icons.percent_rounded, size: 14, color: _textSecondary),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // GST Slab Dropdown
                                              Expanded(
                                                flex: 3,
                                                child: DropdownButtonFormField<double>(
                                                  value: [0.0, 5.0, 12.0, 18.0, 28.0].contains(double.tryParse(row.gstController.text))
                                                      ? double.tryParse(row.gstController.text)
                                                      : 5.0,
                                                  isExpanded: true,
                                                  decoration: _dialogInputDeco(
                                                    label: 'GST Slab',
                                                    isDense: true,
                                                  ),
                                                  dropdownColor: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  items: const [
                                                    DropdownMenuItem(value: 0.0, child: Text('0% (Exempt)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                                    DropdownMenuItem(value: 5.0, child: Text('5% (Food)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                                    DropdownMenuItem(value: 12.0, child: Text('12% (Drinks)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                                    DropdownMenuItem(value: 18.0, child: Text('18% (Std)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                                    DropdownMenuItem(value: 28.0, child: Text('28% (Lux)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                                  ],
                                                  onChanged: (val) {
                                                    if (val != null) {
                                                      setDialogState(() {
                                                        row.gstController.text = val.toStringAsFixed(0);
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Tax Type Dropdown
                                              Expanded(
                                                flex: 3,
                                                child: DropdownButtonFormField<String>(
                                                  value: row.taxType == 'interState' ? 'interState' : 'intraState',
                                                  isExpanded: true,
                                                  decoration: _dialogInputDeco(
                                                    label: 'Tax Type',
                                                    isDense: true,
                                                  ),
                                                  dropdownColor: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  items: const [
                                                    DropdownMenuItem(value: 'intraState', child: Text('CGST+SGST', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                                    DropdownMenuItem(value: 'interState', child: Text('IGST', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                                  ],
                                                  onChanged: (val) {
                                                    if (val != null) {
                                                      setDialogState(() {
                                                        row.taxType = val;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Live Price & Statutory Tax Preview Card (matching Image 2 ditto!)
                                          if (basePriceVal > 0) ...[
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.receipt_long_outlined, size: 15, color: _primaryColor),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          isInter
                                                              ? 'Live Price & Statutory Tax (IGST: ${igstRate.toStringAsFixed(0)}% Inter-State • HSN: $optHsn)'
                                                              : 'Live Price & Statutory Tax (CGST: ${cgstRate.toStringAsFixed(1)}% + SGST: ${sgstRate.toStringAsFixed(1)}% Intra-State • HSN: $optHsn)',
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: _textPrimary),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        _buildPriceStat('Base Price', '₹${basePriceVal.toStringAsFixed(2)}', _textPrimary),
                                                        Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 32, color: _borderColor),
                                                        _buildPriceStat('Discount', '₹${(basePriceVal - discountedVal).toStringAsFixed(2)}', _warningColor),
                                                        Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 32, color: _borderColor),
                                                        _buildPriceStat('Taxable Price', '₹${discountedVal.toStringAsFixed(2)}', _textPrimary),
                                                        Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 32, color: _borderColor),
                                                        if (!isInter) ...[
                                                          _buildPriceStat('CGST (${cgstRate.toStringAsFixed(1)}%)', '₹${cgstVal.toStringAsFixed(2)}', _textSecondary),
                                                          Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 32, color: _borderColor),
                                                          _buildPriceStat('SGST (${sgstRate.toStringAsFixed(1)}%)', '₹${sgstVal.toStringAsFixed(2)}', _textSecondary),
                                                        ] else ...[
                                                          _buildPriceStat('IGST (${igstRate.toStringAsFixed(0)}%)', '₹${igstVal.toStringAsFixed(2)}', _textSecondary),
                                                        ],
                                                        Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 32, color: _borderColor),
                                                        _buildPriceStat('Round Off', '₹${roundOff.toStringAsFixed(2)}', _textSecondary),
                                                        Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 32, color: _borderColor),
                                                        _buildPriceStat('Final MRP', '₹${roundedFinalPrice.toStringAsFixed(2)}', _primaryColor),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 1, color: Color(0xFFF1F5F9)),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        for (final r in optionRows) {
                                          r.dispose();
                                        }
                                        Navigator.pop(dialogContext);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        final groupName = groupNameCtrl.text.trim();
                                        if (groupName.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please enter group name')),
                                          );
                                          return;
                                        }

                                        final List<ProductAddon> validOptions = [];
                                        for (int i = 0; i < optionRows.length; i++) {
                                          final row = optionRows[i];
                                          final optName = row.nameController.text.trim();
                                          if (optName.isNotEmpty) {
                                            final priceVal = double.tryParse(row.priceController.text.trim()) ?? 0.0;
                                            final discountVal = double.tryParse(row.discountController.text.trim()) ?? 0.0;
                                            final gstVal = double.tryParse(row.gstController.text.trim()) ?? 5.0;
                                            final hsnVal = row.hsnController.text.trim().isNotEmpty
                                                ? row.hsnController.text.trim()
                                                : defaultHsn;
                                            final taxTypeVal = row.taxType;

                                            validOptions.add(
                                              ProductAddon(
                                                id: row.id.isNotEmpty ? row.id : 'opt_${DateTime.now().microsecondsSinceEpoch}_$i',
                                                name: optName,
                                                basePrice: priceVal >= 0 ? priceVal : 0.0,
                                                discountPercentage: discountVal >= 0 ? discountVal : 0.0,
                                                gstPercentage: gstVal,
                                                taxType: taxTypeVal,
                                                hsnCode: hsnVal,
                                                isAvailable: true,
                                                trackInventory: row.trackInventory,
                                              ),
                                            );
                                          }
                                        }

                                        if (validOptions.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please enter at least one option name')),
                                          );
                                          return;
                                        }

                                        final newGroup = ProductCustomizationGroup(
                                          groupName: groupName,
                                          isRequired: isRequired,
                                          minSelect: isRequired ? 1 : 0,
                                          maxSelect: 5,
                                          options: validOptions,
                                        );

                                        final updated = List<ProductCustomizationGroup>.from(state.customizationGroups);
                                        if (existingIndex != null && existingIndex >= 0 && existingIndex < updated.length) {
                                          updated[existingIndex] = newGroup;
                                        } else {
                                          updated.add(newGroup);
                                        }

                                        bloc.add(CustomizationGroupsUpdatedEvent(updated));
                                        Navigator.pop(dialogContext);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Customization group "$groupName" saved successfully!'),
                                            backgroundColor: _successColor,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        existingGroup != null ? 'Update Group' : 'Add Group',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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
                                    elevation: 0,
                                    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.88),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: SellerUiTokens.dialogShadow,
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: InteractiveViewer(
                                                  minScale: 1.0,
                                                  maxScale: 4.0,
                                                  child: isExistingImage
                                                      ? CachedNetworkImage(
                                                          imageUrl: state.existingImages[imageIndex],
                                                          fit: BoxFit.contain,
                                                        )
                                                      : (kIsWeb
                                                          ? Image.network(
                                                              state.images[imageIndex].path,
                                                              fit: BoxFit.contain,
                                                            )
                                                          : Image.file(
                                                              File(state.images[imageIndex].path),
                                                              fit: BoxFit.contain,
                                                            )),
                                                ),
                                              ),
                                              Positioned(
                                                top: 12,
                                                right: 12,
                                                child: Material(
                                                  color: Colors.black.withValues(alpha: 0.6),
                                                  shape: const CircleBorder(),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                    tooltip: 'Close Preview',
                                                    onPressed: () {
                                                      Navigator.pop(dialogContext);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
    bool hasPrice = state.hasVariants
        ? state.variants.isNotEmpty
        : (double.tryParse(_priceController.text) != null &&
            double.tryParse(_priceController.text)! > 0);
    bool hasCategory = state.category?.isNotEmpty ?? false;
    bool hasHsn = _hsnCodeController.text.trim().isNotEmpty;

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
          const Divider(height: 32, color: _borderColor),
          _buildChecklistItem(
            'Tax & HSN (HSN ${_hsnCodeController.text.trim().isNotEmpty ? _hsnCodeController.text.trim() : "996331"} • ${state.gstPercentage.toStringAsFixed(0)}% ${state.taxType == 'interState' ? 'IGST' : 'CGST+SGST'})',
            hasHsn,
          ),
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
    final bool hasVar = state.hasVariants && state.variants.isNotEmpty;
    final double previewBasePrice;
    final double previewPrice;
    final double previewDiscountPrice;

    if (hasVar) {
      previewBasePrice = state.variants.map((v) => v.basePrice).reduce((a, b) => a < b ? a : b);
      previewPrice = state.variants.map((v) => v.grossBasePriceWithGst).reduce((a, b) => a < b ? a : b);
      previewDiscountPrice = state.variants.map((v) => v.effectivePrice).reduce((a, b) => a < b ? a : b);
    } else {
      previewBasePrice = double.tryParse(_priceController.text) ?? 0.0;
      final discount = double.tryParse(_discountController.text) ?? 0.0;
      final discountedPrice = previewBasePrice - (previewBasePrice * (discount / 100));
      final gstAmount = discountedPrice * (state.gstPercentage / 100);
      previewDiscountPrice = (discountedPrice + gstAmount).roundToDouble();
      previewPrice = (previewBasePrice + (previewBasePrice * (state.gstPercentage / 100))).roundToDouble();
    }

    final previewProduct = Product(
      id: state.initialProduct?.id ?? 'preview-id',
      name: _nameController.text.isEmpty ? 'Product Name' : _nameController.text,
      sku: _skuController.text,
      hsnCode: _hsnCodeController.text.trim().isNotEmpty ? _hsnCodeController.text.trim() : '996331',
      taxType: state.taxType,
      subcategory: _subcategoryController.text,
      variants: state.hasVariants ? state.variants : const [],
      hasVariants: state.hasVariants && state.variants.isNotEmpty,
      customizationGroups: state.customizationGroups,
      price: previewPrice,
      basePrice: previewBasePrice,
      gstPercentage: state.gstPercentage,
      discountPrice: previewDiscountPrice,
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

  void _handlePublishProduct(BuildContext context, AddProductPageState state) {
    if (state.status == AddProductStatus.loading) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product name')),
      );
      return;
    }

    if (state.category == null || state.category!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (state.images.isEmpty && state.existingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 1 image')),
      );
      return;
    }

    double basePrice;
    double roundedFinalPrice;
    double roundedBasePriceWithGst;
    int? availableStock;
    int? minimumAlert;
    List<ProductVariant> effectiveVariants;

    if (state.hasVariants) {
      if (state.variants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one size variant before publishing')),
        );
        return;
      }
      final invalidVariant = state.variants.any((v) => v.name.trim().isEmpty || v.basePrice <= 0);
      if (invalidVariant) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All size variants must have a name and base price greater than ₹0')),
        );
        return;
      }
      effectiveVariants = state.variants;
      basePrice = state.variants.map((v) => v.basePrice).reduce((a, b) => a < b ? a : b);
      roundedBasePriceWithGst = state.variants.map((v) => v.grossBasePriceWithGst).reduce((a, b) => a < b ? a : b);
      roundedFinalPrice = state.variants.map((v) => v.effectivePrice).reduce((a, b) => a < b ? a : b);
      availableStock = state.effectiveTotalStock;
      minimumAlert = int.tryParse(_alertController.text) ?? 10;
    } else {
      effectiveVariants = const [];
      final parsedBase = double.tryParse(_priceController.text) ?? 0.0;
      if (parsedBase <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid base price greater than ₹0')),
        );
        return;
      }
      basePrice = parsedBase;
      final discountPct = double.tryParse(_discountController.text) ?? 0.0;
      final discounted = basePrice - (basePrice * (discountPct / 100));
      final gstAmount = discounted * (state.gstPercentage / 100);
      final finalPrice = discounted + gstAmount;
      roundedFinalPrice = finalPrice.roundToDouble();
      final basePriceWithGst = basePrice + (basePrice * (state.gstPercentage / 100));
      roundedBasePriceWithGst = basePriceWithGst.roundToDouble();
      availableStock = int.tryParse(_stockController.text);
      minimumAlert = int.tryParse(_alertController.text);
    }

    context.read<AddProductPageBloc>().add(
      SubmitProductEvent(
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        hsnCode: _hsnCodeController.text.trim().isNotEmpty ? _hsnCodeController.text.trim() : '996331',
        taxType: state.taxType,
        subcategory: _subcategoryController.text.trim(),
        variants: effectiveVariants,
        customizationGroups: state.customizationGroups,
        price: roundedBasePriceWithGst,
        basePrice: basePrice,
        gstPercentage: state.gstPercentage,
        discountPrice: roundedFinalPrice,
        description: _descController.text.trim(),
        prepTime: _prepTimeController.text.trim(),
        calories: _caloriesController.text.trim(),
        portionSize: _portionSizeController.text.trim(),
        addons: _addonsController.text.trim(),
        ingredients: _ingredientsController.text.trim(),
        availableStock: availableStock,
        minimumAlert: minimumAlert,
      ),
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
                : () => _handlePublishProduct(context, state),
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
                      : () => _handlePublishProduct(context, state),
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


