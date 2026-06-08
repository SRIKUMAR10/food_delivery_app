import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../FoodGoLoginScreen/FoodGoLoginScreen.dart'; // Login Screen-ஐ இறக்குமதி செய்யவும்

class FoodCategory {
  final String id;
  final String name;
  final String emoji;
  final bool isSelected;
  final int size;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.emoji,
    this.isSelected = false,
    required this.size,
  });
}

class FoodItem {
  final String name;
  final String price;
  final String image;

  const FoodItem({
    required this.name,
    required this.price,
    required this.image,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<FoodCategory> categories = const [
    FoodCategory(
      id: '1',
      name: 'Pizza',
      emoji: '🍕',
      isSelected: true,
      size: 35,
    ),
    FoodCategory(id: '2', name: 'Burger', emoji: '🍔', size: 35),
    FoodCategory(id: '3', name: 'Chicken', emoji: '🍗', size: 35),
    FoodCategory(id: '4', name: 'Sushi', emoji: '🍣', size: 35),
    FoodCategory(id: '5', name: 'Dessert', emoji: '🍰', size: 35),
  ];

  final List<FoodItem> foodItems = const [
    FoodItem(
      name: 'Cheese Pizza',
      price: '\$50',
      image:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=400&auto=format&fit=crop',
    ),
    FoodItem(
      name: 'Margherita pizza',
      price: '\$80',
      image:
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=400&auto=format&fit=crop',
    ),
    FoodItem(
      name: 'Margherita pizza',
      price: '\$80',
      image:
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=400&auto=format&fit=crop',
    ),
    FoodItem(
      name: 'Margherita pizza',
      price: '\$80',
      image:
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=400&auto=format&fit=crop',
    ),
  ];

  late String selectedCategoryId;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = categories
        .firstWhere((cat) => cat.isSelected, orElse: () => categories.first)
        .id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;

            int crossAxisCount = 2;
            double horizontalPadding = 16.0;
            bool isMobile = true;

            if (maxWidth >= 1024) {
              crossAxisCount = 4;
              horizontalPadding = 48.0;
              isMobile = false;
            } else if (maxWidth >= 600) {
              crossAxisCount = 3;
              horizontalPadding = 32.0;
              isMobile = false;
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 20.0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(isMobile, maxWidth),
                        if (isMobile) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Order your favourite food!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xDE000000),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                        ],
                        if (!isMobile) ...[
                          const SizedBox(height: 32),
                          Center(
                            child: Text(
                              'Order your favourite food!',
                              style: TextStyle(
                                fontSize: maxWidth >= 1024 ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C1C1C),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildCategoryRow(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.76,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => FoodCard(item: foodItems[index]),
                      childCount: foodItems.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile, double maxWidth) {
    if (isMobile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Original colors are retained by not providing a color/colorFilter
          SvgPicture.asset(
            'assets/images/FoodGo.svg',
            height: 50,
            fit: BoxFit.contain,
            semanticsLabel: 'FoodGo Logo',
          ),
          _buildProfileAvatar(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Using original SVG colors and ensuring crisp scaling
        SvgPicture.asset(
          'assets/images/FoodGo.svg',
          height: 70,
          width: 200,
          fit: BoxFit.contain,
          semanticsLabel: 'FoodGo Logo',
        ),
        Row(
          children: [
            SizedBox(width: maxWidth * 0.4, child: _buildSearchBar()),
            const SizedBox(width: 16),
            _buildProfileAvatar(),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEEF4),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search food item...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEF2A39),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 22),
        ),
      ],
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.id == selectedCategoryId;

          return GestureDetector(
            onTap: () => setState(() => selectedCategoryId = cat.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEF2A39)
                    : const Color(0xFFEFEEF4),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF2A39).withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF3A3A3A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FoodCard extends StatefulWidget {
  final FoodItem item;
  const FoodCard({super.key, required this.item});

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Login பக்கத்திற்குச் செல்லவும், FoodItem விவரங்களை அனுப்பவும்.
          // வெற்றிகரமான Login-க்குப் பிறகு, பயனர் DetailsPages-க்கு திருப்பி விடப்படுவார்.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodGoLoginScreen(
                foodItemToAccess: widget.item, // Food item-ஐ அனுப்பவும்
              ),
            ),
          );
        },
        child: AnimatedScale(
          scale: isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isHovered ? 0.06 : 0.02),
                  blurRadius: isHovered ? 10 : 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              widget.item.image,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.local_pizza,
                                    size: 50,
                                    color: Colors.orange,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.price,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 48,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF2A39),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
