import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_product_page__bloc.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';

// --- Theme Constants (Material 3) ---
const Color _bgColor = Color(0xFFF8FAFC); // Light Gray
const Color _surfaceColor = Color(0xFFFFFFFF);
const Color _primaryColor = Color(0xFFE50914); // Netflix Red / FoodGo Primary
const Color _accentColor = Color(0xFFFF5A5F);
const Color _successColor = Color(0xFF16A34A); // Green
const Color _warningColor = Color(0xFFF59E0B); // Amber
const Color _textPrimary = Color(0xFF111827); // Dark gray
const Color _textSecondary = Color(0xFF6B7280); // Mid gray
const Color _borderColor = Color(0xFFE5E7EB); // Light border

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddProductPageBloc(),
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
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _descController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _portionSizeController = TextEditingController();
  final _addonsController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _alertController = TextEditingController(text: '10');

  final List<Map<String, dynamic>> _categories = [
    {'id': 'Pizza', 'icon': '🍕', 'label': 'Pizza'},
    {'id': 'Burger', 'icon': '🍔', 'label': 'Burger'},
    {'id': 'Beverages', 'icon': '🥤', 'label': 'Beverages'},
    {'id': 'Dessert', 'icon': '🍰', 'label': 'Dessert'},
    {'id': 'Main Course', 'icon': '🍛', 'label': 'Main Course'},
  ];

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
    _nameController.addListener(() => _updateField('name', _nameController.text));
    _priceController.addListener(() => _updateField('price', double.tryParse(_priceController.text) ?? 0.0));
    _discountController.addListener(() => _updateField('discountPercent', double.tryParse(_discountController.text) ?? 0.0));
    _descController.addListener(() => _updateField('description', _descController.text));
    _stockController.addListener(() => _updateField('availableStock', int.tryParse(_stockController.text) ?? 0));
    _alertController.addListener(() => _updateField('minimumAlert', int.tryParse(_alertController.text) ?? 10));
  }

  void _updateField(String field, dynamic value) {
    context.read<AddProductPageBloc>().add(FieldChangedEvent(field, value));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descController.dispose();
    _prepTimeController.dispose();
    _portionSizeController.dispose();
    _addonsController.dispose();
    _stockController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocConsumer<AddProductPageBloc, AddProductPageState>(
          listener: (context, state) {
            if (state.status == AddProductStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Product published successfully!', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  backgroundColor: _successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
              Navigator.pop(context);
            } else if (state.status == AddProductStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: _primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildProgressStepper(state.currentStep),
                Expanded(
                  child: isDesktop
                      ? _buildDesktopLayout(context, state)
                      : _buildMobileLayout(context, state),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: !isDesktop ? _buildBottomActionBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: _textPrimary),
      centerTitle: true,
      title: const Text(
        'Add Product',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        BlocBuilder<AddProductPageBloc, AddProductPageState>(
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive ? _primaryColor : _surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted || isActive ? _primaryColor : _borderColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : _textSecondary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isCompleted || isActive ? _textPrimary : _textSecondary,
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1)
                Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
                  color: isCompleted ? _primaryColor : _borderColor,
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
        // Left Column: Form
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildFormSections(context, state),
          ),
        ),
        // Right Column: Preview & Status
        Container(
          width: 1,
          color: _borderColor,
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: _bgColor,
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLivePreview(context, state),
                  const SizedBox(height: 24),
                  _buildActionCard(context, state),
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

          _buildSectionHeader('Product Information', 'Basic details about your food item'),
          _buildCard(
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'e.g. Red Pizza',
                  icon: Icons.inventory_2_outlined,
                  helperText: 'Keep it short and descriptive',
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

          _buildSectionHeader('Pricing', 'Set price, discounts, and calculate profit'),
          _buildPricingSection(context, state),
          const SizedBox(height: 32),

          _buildSectionHeader('Inventory & Logistics', 'Manage stock and preparation time'),
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
                        label: 'Preparation Time',
                        hint: 'e.g. 15 mins',
                        icon: Icons.timer_outlined,
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
                  hint: 'e.g. Extra Cheese, Extra Mayo',
                  icon: Icons.add_circle_outline,
                  helperText: 'Optional',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader('Status & Visibility', 'Control where this product appears'),
          _buildStatusToggles(context, state),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 24,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                ),
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

  Widget _buildImageUpload(BuildContext context, AddProductPageState state) {
    return _buildCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (state.images.isEmpty)
            GestureDetector(
              onTap: () {
                context.read<AddProductPageBloc>().add(const AddImageEvent('https://picsum.photos/400/400'));
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
                      const Icon(Icons.cloud_upload_outlined, color: _primaryColor, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Drop Images Here',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text('PNG • JPG • WEBP\nMaximum 5 Images', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: _textSecondary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: _borderColor),
                          borderRadius: BorderRadius.circular(8),
                          color: _surfaceColor,
                        ),
                        child: const Text('Browse Files', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.images.length + (state.images.length < 5 ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index == state.images.length) {
                        // Add Button
                        return GestureDetector(
                          onTap: () {
                            context.read<AddProductPageBloc>().add(const AddImageEvent('https://picsum.photos/400/400'));
                          },
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: _borderColor, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFF9FAFB),
                            ),
                            child: const Center(
                              child: Icon(Icons.add, color: _textSecondary),
                            ),
                          ),
                        );
                      }
                      // Image Thumbnail
                      final isMain = index == 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isMain ? _primaryColor : _borderColor, width: isMain ? 2 : 1),
                              image: DecorationImage(
                                image: NetworkImage(state.images[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (isMain)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: _primaryColor,
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: const Center(
                                  child: Text('Main Image ⭐', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: GestureDetector(
                              onTap: () {
                                context.read<AddProductPageBloc>().add(RemoveImageEvent(index));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: const Icon(Icons.close, size: 14, color: _primaryColor),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: _textSecondary),
                    SizedBox(width: 6),
                    Text('Drag to reorder. The first image will be used as the main thumbnail.', style: TextStyle(fontSize: 12, color: _textSecondary)),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, AddProductPageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 14, color: _textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = state.category == cat['id'];
              return GestureDetector(
                onTap: () => context.read<AddProductPageBloc>().add(CategoryChangedEvent(cat['id'])),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 90,
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor.withValues(alpha: 0.1) : _surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: isSelected ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat['icon'], style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? _primaryColor : _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodTypeSelector(BuildContext context, AddProductPageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Food Type', style: TextStyle(fontSize: 14, color: _textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
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
                if (val) context.read<AddProductPageBloc>().add(FoodTypeChangedEvent(type['id']));
              },
              selectedColor: (type['color'] as Color).withValues(alpha: 0.1),
              backgroundColor: _surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? type['color'] : _borderColor),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpicyLevelSelector(BuildContext context, AddProductPageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Spicy Level', style: TextStyle(fontSize: 14, color: _textSecondary, fontWeight: FontWeight.w500)),
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
                if (val) context.read<AddProductPageBloc>().add(SpicyLevelChangedEvent(level['id']));
              },
              selectedColor: _primaryColor.withValues(alpha: 0.1),
              backgroundColor: _surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? _primaryColor : _borderColor),
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
    final finalPrice = price - (price * (discount / 100));
    final margin = price > 0 ? (finalPrice / price) * 100 : 0.0;

    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _priceController,
                  label: 'Original Price',
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceStat('Final Price', '₹${finalPrice.toStringAsFixed(2)}', _primaryColor),
                Container(width: 1, height: 40, color: _borderColor),
                _buildPriceStat('Profit Margin', '${margin.toStringAsFixed(1)}%', _successColor),
                Container(width: 1, height: 40, color: _borderColor),
                _buildPriceStat('Tax', 'Included', _textSecondary),
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
        Text(label, style: const TextStyle(fontSize: 12, color: _textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildInventorySection(BuildContext context, AddProductPageState state) {
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
                  if (val != null) context.read<AddProductPageBloc>().add(FieldChangedEvent('hasUnlimitedStock', val));
                },
              ),
              const Text('Unlimited Stock (Always Available)', style: TextStyle(fontWeight: FontWeight.w500)),
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
          _buildToggleRow('Available', 'Customers can view and purchase this item', state.isActive, (val) => context.read<AddProductPageBloc>().add(StatusChangedEvent(val))),
          const Divider(height: 1, color: _borderColor),
          _buildToggleRow('Featured', 'Highlight on the top of the menu', state.isFeatured, (val) => context.read<AddProductPageBloc>().add(FieldChangedEvent('isFeatured', val))),
          const Divider(height: 1, color: _borderColor),
          _buildToggleRow('Best Seller', 'Add a best seller badge to this item', state.isBestSeller, (val) => context.read<AddProductPageBloc>().add(FieldChangedEvent('isBestSeller', val))),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: _textSecondary)),
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
  }) {
    return TextFormField(
      controller: controller,
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
        suffixIcon: controller.text.isNotEmpty && enabled
            ? const Icon(Icons.check_circle, color: _successColor, size: 20)
            : null,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 20.0) : 0),
          child: Icon(icon, color: _textSecondary, size: 20),
        ),
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.5)),
        helperStyle: const TextStyle(color: _textSecondary, fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: enabled ? _surfaceColor : _bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primaryColor, width: 2)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
      ),
    );
  }

  Widget _buildLivePreview(BuildContext context, AddProductPageState state) {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final finalPrice = price - (price * (discount / 100));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.remove_red_eye_outlined, color: _textSecondary, size: 20),
            SizedBox(width: 8),
            Text('Live App Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 320, // Mobile width
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _borderColor, width: 4),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mock App Header
              Container(
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 18),
                    Icon(Icons.favorite_border, size: 20),
                  ],
                ),
              ),
              // Product Image
              Container(
                height: 200,
                width: double.infinity,
                color: _bgColor,
                child: state.images.isNotEmpty
                    ? Image.network(state.images.first, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.fastfood, size: 64, color: _borderColor)),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.isBestSeller)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: _warningColor, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Bestseller', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    Text(
                      _nameController.text.isNotEmpty ? _nameController.text : 'Product Name',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('₹${finalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
                        if (discount > 0) ...[
                          const SizedBox(width: 8),
                          Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, color: _textSecondary, decoration: TextDecoration.lineThrough)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _descController.text.isNotEmpty ? _descController.text : 'Product description will appear here...',
                      style: const TextStyle(fontSize: 14, color: _textSecondary, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Add to Cart Button mock
              Container(
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, AddProductPageState state) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: _borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save as Draft', style: TextStyle(color: _textPrimary)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: state.status == AddProductStatus.loading
                ? null
                : () {
                    context.read<AddProductPageBloc>().add(
                          SubmitProductEvent(
                            name: _nameController.text,
                            price: double.tryParse(_priceController.text) ?? 0.0,
                            discountPrice: double.tryParse(_discountController.text) ?? 0.0,
                            description: _descController.text,
                            prepTime: _prepTimeController.text,
                            portionSize: _portionSizeController.text,
                            addons: _addonsController.text,
                          ),
                        );
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state.status == AddProductStatus.loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Publish Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return BlocBuilder<AddProductPageBloc, AddProductPageState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            border: const Border(top: BorderSide(color: _borderColor)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Draft', style: TextStyle(color: _textPrimary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: state.status == AddProductStatus.loading
                      ? null
                      : () {
                          context.read<AddProductPageBloc>().add(
                                SubmitProductEvent(
                                  name: _nameController.text,
                                  price: double.tryParse(_priceController.text) ?? 0.0,
                                  discountPrice: double.tryParse(_discountController.text) ?? 0.0,
                                  description: _descController.text,
                                  prepTime: _prepTimeController.text,
                                  portionSize: _portionSizeController.text,
                                  addons: _addonsController.text,
                                ),
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.status == AddProductStatus.loading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Publish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
