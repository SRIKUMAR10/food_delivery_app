import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'add_product_page__bloc.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';

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

  bool _isPreviewDesktop = false;
  bool _showLivePreview = true;
  bool _isUpdating = false;
  Timer? _updateTimer;

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
    _nameController.addListener(
      () => _updateField('name', _nameController.text),
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

  void _updateField(String field, dynamic value) {
    context.read<AddProductPageBloc>().add(FieldChangedEvent(field, value));
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
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocConsumer<AddProductPageBloc, AddProductPageState>(
          listener: (context, state) {
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
                                    // Normally you'd reset the form/bloc here
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth > 1024 ? 26 : (screenWidth > 600 ? 24 : 22);

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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
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
            padding: const EdgeInsets.all(40),
            child: _buildFormSections(context, state),
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
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _buildPreviewAnimation(context, state),
                          ),
                          SizedBox(
                            width: 300,
                            child: _buildActionCard(context, state),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _buildPreviewAnimation(context, state),
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
          if (state.images.isNotEmpty) ...[
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
                        state.images.length + (state.images.length < 5 ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      if (index == state.images.length) {
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
                                          child: kIsWeb
                                              ? Image.network(
                                                  state.images[index].path,
                                                )
                                              : Image.file(
                                                  File(
                                                    state.images[index].path,
                                                  ),
                                                ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: GestureDetector(
                                            onTap: () =>
                                                Navigator.pop(dialogContext),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: isMain
                                    ? Border.all(color: _primaryColor, width: 2)
                                    : Border.all(color: _borderColor),
                                image: DecorationImage(
                                  image: kIsWeb
                                      ? NetworkImage(state.images[index].path)
                                      : FileImage(
                                              File(state.images[index].path),
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
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
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Main Image ⭐',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: GestureDetector(
                              onTap: () {
                                context.read<AddProductPageBloc>().add(
                                  RemoveImageEvent(index),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
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
                  children: [
                    Icon(Icons.info_outline, size: 14, color: _textSecondary),
                    SizedBox(width: 8),
                    Text(
                      'Drag to reorder. The first image will be used as the main thumbnail.',
                      style: TextStyle(fontSize: 13, color: _textSecondary),
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
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = state.category == cat['id'];
              return GestureDetector(
                onTap: () => context.read<AddProductPageBloc>().add(
                  CategoryChangedEvent(cat['id']),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  width: 100,
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
            },
          ),
        ),
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
    final gst = discountedPrice * 0.18; // 18% GST example
    final finalPrice = discountedPrice + gst;

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
                  'Discount Price',
                  '₹${discountedPrice.toStringAsFixed(2)}',
                  _textPrimary,
                ),
                Container(width: 1, height: 40, color: _borderColor),
                _buildPriceStat(
                  'GST (18%)',
                  '₹${gst.toStringAsFixed(2)}',
                  _warningColor,
                ),
                Container(width: 1, height: 40, color: _borderColor),
                _buildPriceStat(
                  'Final Price',
                  '₹${finalPrice.toStringAsFixed(2)}',
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
                  if (val != null)
                    context.read<AddProductPageBloc>().add(
                      FieldChangedEvent('hasUnlimitedStock', val),
                    );
                },
              ),
              const Text(
                'Unlimited Stock (Always Available)',
                style: TextStyle(fontWeight: FontWeight.w500),
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
    bool hasImages = state.images.isNotEmpty;
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
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: controller.text.isNotEmpty && enabled
            ? const Icon(Icons.check_circle, color: _successColor, size: 20)
            : null,
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
            const SizedBox(width: 4),
            const Text(
              'Live App Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
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

  Widget _buildPreviewAnimation(
    BuildContext context,
    AddProductPageState state,
  ) {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final finalPrice = price - (price * (discount / 100));

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: _isPreviewDesktop ? 1 : 0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutBack,
      builder: (context, double val, child) {
        bool isDesktop = val >= 0.5;
        double angle = isDesktop ? (val - 1) * 3.14159 : val * 3.14159;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isDesktop
              ? _buildDesktopPreviewCard(
                  context,
                  state,
                  finalPrice,
                  price,
                  discount,
                )
              : _buildMobilePreviewCard(
                  context,
                  state,
                  finalPrice,
                  price,
                  discount,
                ),
        );
      },
    );
  }

  Widget _buildPreviewImage(AddProductPageState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: state.images.isNotEmpty
          ? SizedBox(
              key: const ValueKey('image'),
              width: double.infinity,
              height: double.infinity,
              child: kIsWeb
                  ? Image.network(state.images.first.path, fit: BoxFit.cover)
                  : Image.file(
                      File(state.images.first.path),
                      fit: BoxFit.cover,
                    ),
            )
          : ShimmerLoading(
              key: const ValueKey('shimmer'),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildMobilePreviewCard(
    BuildContext context,
    AddProductPageState state,
    double finalPrice,
    double price,
    double discount,
  ) {
    return Container(
      width: 320,
      height: 660,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(44),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '9:41',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.signal_cellular_4_bar, size: 14),
                          SizedBox(width: 6),
                          Icon(Icons.wifi, size: 14),
                          SizedBox(width: 6),
                          Icon(Icons.battery_full, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.arrow_back_ios, size: 20),
                      Icon(Icons.favorite_border, size: 24),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: _buildPreviewImage(state),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.isBestSeller)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: _warningColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Bestseller',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text
                                : 'Product Name',
                            key: ValueKey(_nameController.text),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            key: ValueKey(finalPrice),
                            children: [
                              Text(
                                '₹${finalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                              if (discount > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '₹${price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Text(
                            _descController.text.isNotEmpty
                                ? _descController.text
                                : 'Product description will appear here...',
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textSecondary,
                              height: 1.5,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Add to Cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: _borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 100,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopPreviewCard(
    BuildContext context,
    AddProductPageState state,
    double finalPrice,
    double price,
    double discount,
  ) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: 720,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Container(
              height: 32,
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5F56),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFBD2E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27C93F),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildPreviewImage(state),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.isBestSeller)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: _warningColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Bestseller',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: FittedBox(
                              key: ValueKey(_nameController.text),
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text
                                    : 'Product Name',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Row(
                              key: ValueKey(finalPrice),
                              children: [
                                Text(
                                  '₹${finalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                                if (discount > 0) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    '₹${price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: _textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _descController.text.isNotEmpty
                                ? _descController.text
                                : 'Product description will appear here...',
                            style: const TextStyle(
                              fontSize: 16,
                              color: _textSecondary,
                              height: 1.6,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(color: _borderColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.favorite_border,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                : () {
                    context.read<AddProductPageBloc>().add(
                      SubmitProductEvent(
                        name: _nameController.text,
                        price: double.tryParse(_priceController.text) ?? 0.0,
                        discountPrice:
                            double.tryParse(_discountController.text) ?? 0.0,
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
                          context.read<AddProductPageBloc>().add(
                            SubmitProductEvent(
                              name: _nameController.text,
                              price:
                                  double.tryParse(_priceController.text) ?? 0.0,
                              discountPrice:
                                  double.tryParse(_discountController.text) ??
                                  0.0,
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

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1500),
        )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFFE5E7EB),
                Color(0xFFF9FAFB),
                Color(0xFFE5E7EB),
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: const FractionalOffset(-1.0, -0.5),
              end: const FractionalOffset(2.0, 0.5),
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 3 - 1.5),
      0.0,
      0.0,
    );
  }
}
