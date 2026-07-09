import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_product_page__bloc.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';

// --- Theme Constants ---
const Color _bgColor = Color(0xFFF5F7FB);
const Color _surfaceColor = Colors.white;
const Color _primaryColor = Color(0xFFE50914);
const Color _accentColor = Color(0xFFFF5A5F);
const Color _successColor = Color(0xFF2ECA7F);
const Color _textPrimary = Color(0xFF1C1C1C);
const Color _textSecondary = Color(0xFF6B7280);
const Color _borderColor = Color(0xFFE5E7EB);

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

  final List<String> _categories = [
    'Pizza',
    'Burger',
    'Beverages',
    'Dessert',
    'Main Course',
    'Starters',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: _textPrimary),
        titleSpacing: 0,
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Preview action
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'Preview',
              style: TextStyle(
                color: _textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _borderColor, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isDesktop) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _buildFormContent(isDesktop: true),
                ),
              );
            } else {
              return _buildFormContent(isDesktop: false);
            }
          },
        ),
      ),
      // Sticky bottom bar on mobile
      bottomNavigationBar: !isDesktop
          ? _buildBottomBar(context)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<AddProductPageBloc, AddProductPageState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
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
          child: _buildSaveButtonWidget(context, state),
        );
      },
    );
  }

  Widget _buildFormContent({required bool isDesktop}) {
    return BlocConsumer<AddProductPageBloc, AddProductPageState>(
      listener: (context, state) {
        if (state.status == AddProductStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Product added successfully!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: _successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.0 : 20.0,
            vertical: 24.0,
          ),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Images'),
                _buildImageUpload(context, state),
                const SizedBox(height: 32),

                _buildSectionLabel('Product Information'),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Product Name',
                        hint: 'e.g. Margherita Pizza',
                        icon: Icons.inventory_2_outlined,
                        helperText: 'Keep it short and descriptive',
                      ),
                      const SizedBox(height: 24),
                      _buildCategoryDropdown(context, state),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionLabel('Pricing'),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Price',
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
                          label: 'Discounted Price',
                          hint: '0.00',
                          icon: Icons.percent_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          helperText: 'Optional',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionLabel('Details'),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: _cardDecoration(),
                  child: _buildTextField(
                    controller: _descController,
                    label: 'Description',
                    hint:
                        'Describe the ingredients, taste, and portion size...',
                    icon: Icons.description_outlined,
                    maxLines: 5,
                    helperText: 'Maximum 500 characters',
                    maxLength: 500,
                  ),
                ),
                const SizedBox(height: 32),

                _buildAvailabilityCard(context, state),

                if (isDesktop) ...[
                  const SizedBox(height: 48),
                  _buildSaveButtonWidget(context, state),
                  const SizedBox(height: 48),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _surfaceColor,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: _borderColor, width: 0.5),
    );
  }

  Widget _buildImageUpload(BuildContext context, AddProductPageState state) {
    return GestureDetector(
      onTap: () {
        // Mocking image selection
        context.read<AddProductPageBloc>().add(
          const AddImageEvent('dummy_image_path.jpg'),
        );
      },
      child: CustomPaint(
        painter: DashedRectPainter(
          color: const Color(0xFFC7CBD1),
          strokeWidth: 2,
          gap: 6,
          radius: 24,
        ),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: _surfaceColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _borderColor),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: _textSecondary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Product Images',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap to upload or drag & drop',
                style: TextStyle(fontSize: 14, color: _textSecondary),
              ),
              const SizedBox(height: 4),
              const Text(
                'PNG, JPG • Maximum 5 images',
                style: TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (state.images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: _successColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.images.length} image(s) selected',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _successColor,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 16,
        color: _textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 70 : 0),
          child: Icon(icon, color: _textSecondary, size: 22),
        ),
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.5)),
        helperStyle: const TextStyle(color: _textSecondary, fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: _bgColor.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryColor),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    AddProductPageState state,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: state.category,
      icon: const Icon(Icons.keyboard_arrow_down, color: _textSecondary),
      style: const TextStyle(
        fontSize: 16,
        color: _textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        prefixIcon: const Icon(
          Icons.restaurant_menu,
          color: _textSecondary,
          size: 22,
        ),
        filled: true,
        fillColor: _bgColor.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      items: _categories.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<AddProductPageBloc>().add(CategoryChangedEvent(value));
        }
      },
    );
  }

  Widget _buildAvailabilityCard(
    BuildContext context,
    AddProductPageState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Availability',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Visible to customers on the app',
                style: TextStyle(fontSize: 13, color: _textSecondary),
              ),
            ],
          ),
          Switch(
            value: state.isActive,
            onChanged: (value) {
              context.read<AddProductPageBloc>().add(StatusChangedEvent(value));
            },
            activeThumbColor: Colors.white,
            activeTrackColor: _successColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: _borderColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButtonWidget(
    BuildContext context,
    AddProductPageState state,
  ) {
    final isLoading = state.status == AddProductStatus.loading;

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_accentColor, _primaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                final price = double.tryParse(_priceController.text) ?? 0.0;
                context.read<AddProductPageBloc>().add(
                  SubmitProductEvent(
                    name: _nameController.text,
                    price: price,
                    description: _descController.text,
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Save Product',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
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
    for (PathMetric pathMetric in path.computeMetrics()) {
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
