import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // பண மதிப்பை வடிவமைக்க

const String _kDefaultFoodImageUrl =
    "https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982";

class DetailsPage extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String description;
  final String sellerId;
  final String? image;

  const DetailsPage({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.sellerId,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    // பண மதிப்பை வடிவமைக்க
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US', // அல்லது உங்கள் தேவைக்கேற்ப மாற்றவும்
      symbol: '\$', // அல்லது உங்கள் தேவைக்கேற்ப மாற்றவும்
      decimalDigits: 2,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full-screen width Image (extends to top)
                _buildImageWithFallbacks(
                  imageUrl: image,
                  height: 400, // Increased height for a hero effect
                  width: double.infinity,
                  showNoImageTextOnMissing: true,
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C1C1C),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Product Price
                      Text(
                        currencyFormatter.format(price),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFEF2A39),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Product Description
                      Text(
                        "Description:",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3A3A3A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF3A3A3A),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Seller ID
                      Text(
                        "Seller ID: $sellerId",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Add to Cart Button
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name added to cart!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF2A39),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Add to Cart",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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

          // Transparent Overlay Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithFallbacks({
    required String? imageUrl,
    required double height,
    required double width,
    bool showNoImageTextOnMissing = false,
  }) {
    final imageUri = Uri.tryParse(imageUrl ?? '');

    if (imageUri != null && imageUri.hasAbsolutePath) {
      return Image.network(
        imageUri.toString(),
        fit: BoxFit.cover,
        width: width,
        height: height,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: height,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            _kDefaultFoodImageUrl,
            fit: BoxFit.cover,
            width: width,
            height: height,
          );
        },
      );
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Image.network(_kDefaultFoodImageUrl, fit: BoxFit.cover),
    );
  }
}
