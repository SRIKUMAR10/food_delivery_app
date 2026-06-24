import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this for TextInputFormatter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../Seller_LoginScreen/Seller_LoginScreen_UI.dart';
import 'app_constants.dart';
import 'seller_product_bloc.dart';
import 'seller_product_event.dart';
import 'seller_product_state.dart';

class SellerAddProductScreen extends StatefulWidget {
  const SellerAddProductScreen({super.key});

  @override
  State<SellerAddProductScreen> createState() => _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Directly monitor Firebase Auth user state
  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    // Restore data already in Bloc (Memory)
    // This helps prevent data loss after returning from login
    final state = context.read<SellerProductBloc>().state;
    _nameController.text = state.productName;
    _priceController.text = state.productPrice;
    _descriptionController.text = state.productDescription;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Common function to navigate to login page
  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SellerLoginScreenUI()),
    );
  }

  // Image picking function (image_picker for Web, file_picker for other platforms)
  Future<void> _pickImage() async {
    if (!_isLoggedIn) {
      _redirectToLogin();
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      context.read<SellerProductBloc>().add(ProductImagePicked(image));
    }
  }

  void _submitForm() {
    if (!_isLoggedIn) {
      _redirectToLogin();
      return;
    }

    if (_formKey.currentState!.validate()) {
      final state = context.read<SellerProductBloc>().state;
      if (state.productImage != null) {
        context.read<SellerProductBloc>().add(const AddProductSubmitted());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5),
      appBar: AppBar(
        title: Text(
          "Add New Product",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: const Color(0xFFFEEBC1),
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<SellerProductBloc, SellerProductState>(
        listener: (context, state) {
          if (state.status == AddProductStatus.loading) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          } else if (state.status == AddProductStatus.success) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<SellerProductBloc>().add(const AddProductReset());
            _nameController.clear();
            _priceController.clear();
            _descriptionController.clear();
          } else if (state.status == AddProductStatus.error) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${state.errorMessage ?? "Unknown error"}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  _buildLabel("Product Name"),
                  _buildTextField(
                    key: const ValueKey('productNameField'),
                    controller: _nameController,
                    hintText: "Enter product name",
                    icon: Icons.fastfood,
                    onChanged: (value) => context.read<SellerProductBloc>().add(
                      ProductNameChanged(value),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Product name cannot be empty' : null,
                  ),
                  const SizedBox(height: 20),

                  // Price
                  _buildLabel("Price"),
                  _buildTextField(
                    key: const ValueKey('productPriceField'),
                    controller: _priceController,
                    hintText: "Enter price (${AppConstants.currencySymbol})",
                    icon: AppConstants.currencyIcon,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      // Only numbers and one decimal point are allowed
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (value) => context.read<SellerProductBloc>().add(
                      ProductPriceChanged(value),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Price cannot be empty';
                      if (double.tryParse(value) == null) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildLabel("Description"),
                  _buildTextField(
                    key: const ValueKey('productDescriptionField'),
                    controller: _descriptionController,
                    hintText: "Enter product description",
                    icon: Icons.description,
                    maxLines: 3,
                    onChanged: (value) => context.read<SellerProductBloc>().add(
                      ProductDescriptionChanged(value),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Description cannot be empty' : null,
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  _buildLabel("Category"),
                  _buildCategoryDropdown(context, state.productCategory),
                  const SizedBox(height: 20),

                  // Image Upload
                  _buildLabel("Product Image"),
                  _buildImagePicker(context, state.productImage),
                  if (state.productImage == null &&
                      state.status == AddProductStatus.error &&
                      state.errorMessage != null &&
                      state.errorMessage!.contains('image'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select an image',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Add Product Button
                  _buildAddProductButton(context, state.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters, // New parameter
  }) {
    // Can type only if logged in, otherwise navigates to login page
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        readOnly: !_isLoggedIn,
        onTap: _isLoggedIn ? null : _redirectToLogin,
        maxLines: maxLines,
        inputFormatters: inputFormatters, // Use here
        style: TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54, size: 20),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, String selectedCategory) {
    final List<String> categories = [
      'Pizza',
      'Burger',
      'Pasta',
      'Drinks',
      'Dessert',
    ];
    // If clicked when not logged in, navigates to login page
    return GestureDetector(
      key: const ValueKey('productCategoryDropdown'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_isLoggedIn) _redirectToLogin();
      },
      child: AbsorbPointer(
        absorbing: !_isLoggedIn,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFECEFF6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              isExpanded: true,
              style: TextStyle(fontSize: 15, color: Colors.black87),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<SellerProductBloc>().add(
                    ProductCategoryChanged(newValue),
                  );
                }
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, XFile? imageFile) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFECEFF6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black38),
            ),
            child: imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        color: Colors.black54,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to select image",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? FutureBuilder(
                            future: imageFile.readAsBytes(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              );
                            },
                          )
                        : Image.file(
                            File(
                              imageFile.path,
                            ), // Native platforms will have path
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
          ),
        ),
        if (imageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isLoggedIn
                    ? () {
                        context.read<SellerProductBloc>().add(
                          const ProductImagePicked(null),
                        );
                      }
                    : _redirectToLogin,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: Text(
                  "Remove Image",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddProductButton(BuildContext context, AddProductStatus status) {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: const ValueKey('productSubmitButton'),
          onTap: status == AddProductStatus.loading ? null : _submitForm,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: status == AddProductStatus.loading
                  ? Colors.grey
                  : const Color(0xFFE52121),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE52121).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                status == AddProductStatus.loading
                    ? "Adding Product..."
                    : "Add Product",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
