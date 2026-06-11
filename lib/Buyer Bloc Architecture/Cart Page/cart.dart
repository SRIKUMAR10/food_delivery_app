import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Mock data moved to state for interactivity
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Double Cheese Burger',
      'quantity': 2,
      'price': 15.50,
      'isSelected': true,
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': '2',
      'name': 'Margherita Pizza',
      'quantity': 1,
      'isSelected': false,
      'price': 12.00,
      'image':
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': '3',
      'name': 'Crispy Chicken Wings',
      'quantity': 3,
      'isSelected': true,
      'price': 10.25,
      'image':
          'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?q=80&w=400&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'My Cart',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildCartItem(context, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, int index) {
    final item = _cartItems[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Selection Button (Checkbox style) - Now on the Left
          GestureDetector(
            onTap: () {
              setState(() {
                item['isSelected'] = !item['isSelected'];
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item['isSelected']
                    ? const Color(0xFFE52121)
                    : Colors.transparent,
                border: Border.all(
                  color: item['isSelected']
                      ? const Color(0xFFE52121)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: item['isSelected'] ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Image Preview with Click Functionality
          GestureDetector(
            onTap: () => _showImagePreview(context, item['image'], item['id']),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: item['id'],
                child: Image.network(
                  item['image'],
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 85,
                    height: 85,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Item Name
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // Total Price for this item
                  '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE52121), // App Primary Color
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action Column: Delete Button at top, Quantity at bottom
          SizedBox(
            height: 85, // Consistent with image height for balance
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Delete Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _cartItems.removeWhere(
                        (element) => element['id'] == item['id'],
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
                // Quantity Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQtyBtn(Icons.remove, () {
                      if (item['quantity'] > 1) {
                        setState(() => item['quantity']--);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${item['quantity']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _buildQtyBtn(Icons.add, () {
                      setState(() => item['quantity']++);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  void _showImagePreview(
    BuildContext context,
    String imageUrl,
    String heroTag,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 25,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
