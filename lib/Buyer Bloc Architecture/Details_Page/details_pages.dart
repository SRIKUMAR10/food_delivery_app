import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Class பெயரிடல் மரபுப்படி (PascalCase) மாற்றி அமைக்கப்பட்டுள்ளது
class DetailsPages extends StatefulWidget {
  final String foodName;
  final double foodPrice;
  final String foodImage;

  const DetailsPages({
    super.key,
    required this.foodName,
    required this.foodPrice,
    required this.foodImage,
  });

  @override
  State<DetailsPages> createState() => _DetailsPagesState();
}

class _DetailsPagesState extends State<DetailsPages> {
  int _quantity = 1;
  late double _unitPrice;
  late String _pizzaName;
  late String _pizzaImageUrl;

  @override
  void initState() {
    super.initState();
    _unitPrice = widget.foodPrice;
    _pizzaName = widget.foodName;
    _pizzaImageUrl = widget.foodImage;
  }

  final String _pizzaDescription =
      "We've established that most cheeses will melt when baked atop pizza. "
      "But which will not only melt but stretch into those gooey, messy strands "
      "that can make pizza eating such a delightfully challenging endeavor?";

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _handleOrder() {
    debugPrint(
      "Ordering $_quantity $_pizzaName for \$${_quantity * _unitPrice}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF9F9,
      ), // Background color matching the image
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop & Tablet Web Layout
              return _buildWideLayout(constraints.maxWidth);
            } else {
              // Mobile Layout
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // MOBILE LAYOUT
  // -------------------------------------------------------------
  Widget _buildMobileLayout() {
    double totalPrice = _quantity * _unitPrice;

    return Column(
      children: [
        // Top App Bar Area (Back Button Only)
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Row(children: [_buildBackButton()]),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pizza Image Center Alignment
                Center(
                  child: Image.network(
                    _pizzaImageUrl,
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_pizza,
                        size: 200,
                        color: Colors.amber,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Pizza Name
                Text(
                  _pizzaName,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Price Tag
                Text(
                  "\$${_unitPrice.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  _pizzaDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFF444444),
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 28),

                // Quantity Selector Label
                Text(
                  "Quantity",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Quantity Counter Buttons
                _buildQuantitySelector(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Bottom Action Bar
        _buildBottomActionBar(totalPrice),
      ],
    );
  }

  // -------------------------------------------------------------
  // DESKTOP / TABLET WEB LAYOUT
  // -------------------------------------------------------------
  Widget _buildWideLayout(double width) {
    double totalPrice = _quantity * _unitPrice;
    double paddingValue = width > 1200 ? 80.0 : 40.0;

    return Row(
      children: [
        // Left Side: Image
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFFFFF1F1),
            child: Stack(
              children: [
                Positioned(top: 24, left: 24, child: _buildBackButton()),
                Center(
                  child: Image.network(
                    _pizzaImageUrl,
                    width: width * 0.35,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_pizza,
                      size: 300,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Side: Details & Actions
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _pizzaName,
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "\$${_unitPrice.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _pizzaDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF444444),
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Quantity",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuantitySelector(),
                const Spacer(),
                _buildBottomActionBar(totalPrice, isDesktop: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // REUSABLE UI COMPONENTS
  // -------------------------------------------------------------

  // Back Button
  Widget _buildBackButton() {
    return InkWell(
      onTap: () {
        Navigator.maybePop(context);
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFFE52121),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
      ),
    );
  }

  // Quantity Selector Components (படத்தில் உள்ளவாறு: + 1 -)
  Widget _buildQuantitySelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCounterButton(icon: Icons.add, onTap: _incrementQuantity),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "$_quantity",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        _buildCounterButton(icon: Icons.remove, onTap: _decrementQuantity),
      ],
    );
  }

  // இங்கிருந்த 'Republic?' பிழை சரிசெய்யப்பட்டு 'VoidCallback?' என மாற்றப்பட்டுள்ளது
  Widget _buildCounterButton({required IconData icon, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE52121),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // Bottom Sticky Bar (Total Price Button & Order Now Button)
  Widget _buildBottomActionBar(double totalPrice, {bool isDesktop = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : 24.0,
        vertical: 20.0,
      ),
      color: isDesktop ? Colors.transparent : const Color(0xFFFFF9F9),
      child: Row(
        children: [
          // Total Price Display Box
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: const Color(0xFFE52121),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "\$${totalPrice.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Order Now Button
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _handleOrder,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "ORDER NOW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
