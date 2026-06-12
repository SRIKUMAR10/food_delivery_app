import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore-ஐ இறக்குமதி செய்யவும்
import 'package:firebase_auth/firebase_auth.dart'; // Auth நிலையைச் சரிபார்க்க
import 'package:google_fonts/google_fonts.dart'; // GoogleFonts-ஐ இறக்குமதி செய்யவும்
import 'package:intl/intl.dart'; // பண மதிப்பை வடிவமைக்க
// Login Screen-ஐ இறக்குமதி செய்யவும்
import '../FoodGoLoginScreen/FoodGoLoginScreen.dart';
import '../Details_Page/DetailsPage.dart'; // DetailsPage-ஐ இறக்குமதி செய்யவும்
import 'user_profile_image.dart'; // User Profile Drawer-ஐ இறக்குமதி செய்யவும்

const String _kDefaultFoodImageUrl =
    "https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982";

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

// FoodItem class-ஐ Firebase-இல் உள்ள product collection-க்கு ஏற்றவாறு மாற்றியமைக்கவும்
class FoodItem {
  final String id; // Firestore document ID
  final String name;
  final double price; // Changed to double
  final String description; // New field
  final String category; // New field
  final String? image; // Made nullable
  final String sellerId; // New field to link to seller

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    this.image,
    required this.sellerId,
  });

  // Firestore DocumentSnapshot-லிருந்து FoodItem உருவாக்க ஒரு factory constructor
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    debugPrint(
      "DEBUG 1 (Firestore Data): $data",
    ); // Firestore-லிருந்து வரும் முழு டேட்டா
    return FoodItem(
      id: doc.id,
      name: data['name'] ?? 'Unknown Product',
      price:
          (data['price'] as num?)?.toDouble() ??
          0.0, // num-ஐ double-ஆக மாற்றவும்
      description: data['description'] ?? 'No description available.',
      category: data['category'] ?? 'Uncategorized',
      image: (data['imageUrl'] as String?)
          ?.trim(), // Firestore-ல் 'imageUrl' என்று சேமிக்கப்படும்
      sellerId: data['sellerId'] ?? 'Unknown Seller',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<FoodCategory> categories = [
    const FoodCategory(
      id: '1',
      name: 'Pizza',
      emoji: '🍕',
      isSelected: true,
      size: 35,
    ),
    const FoodCategory(id: '2', name: 'Burger', emoji: '🍔', size: 35),
    const FoodCategory(id: '3', name: 'Pasta', emoji: '🍝', size: 35),
    const FoodCategory(id: '4', name: 'Drinks', emoji: '🥤', size: 35),
    const FoodCategory(id: '5', name: 'Dessert', emoji: '🍰', size: 35),
  ];

  // Firestore-லிருந்து products-ஐப் பெற ஒரு Stream
  Stream<List<FoodItem>> _getProductsStream(String categoryName) {
    return FirebaseFirestore.instance
        .collection('products')
        .where(
          'category',
          isEqualTo: categoryName,
        ) // Category மூலம் வடிகட்டவும்
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final item = FoodItem.fromFirestore(doc);
            debugPrint(
              "DEBUG 2 (Mapped Item Image): ${item.image}",
            ); // Model-ல் மேப் ஆன பிறகு
            return item;
          }).toList();
        });
  }

  late String selectedCategoryId;

  // தேர்ந்தெடுக்கப்பட்ட category-ன் பெயரைக் கண்டறிய
  String get _selectedCategoryName {
    return categories.firstWhere((cat) => cat.id == selectedCategoryId).name;
  }

  @override
  void initState() {
    super.initState();
    selectedCategoryId = categories
        .firstWhere((cat) => cat.isSelected, orElse: () => categories.first)
        .id;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const user_profile_image(), // Drawer-ஐ இங்கே இணைக்கவும்
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;

            int crossAxisCount = 2;
            double horizontalPadding = 16.0;
            bool isMobile = true;

            // GoogleFonts-ஐப் பயன்படுத்தவும்
            final TextStyle defaultTextStyle = GoogleFonts.poppins(
              color: const Color(0xDE000000),
            );

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
                          Text(
                            'Order your favourite food!', // GoogleFonts-ஐப் பயன்படுத்தவும்
                            style: defaultTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xDE000000),
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
                              style: GoogleFonts.poppins(
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
                StreamBuilder<List<FoodItem>>(
                  stream: _getProductsStream(_selectedCategoryName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        child: Center(child: Text('Error: ${snapshot.error}')),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No products available',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      );
                    }

                    // தேடல் வினவல் (search query) மூலம் பொருட்களை வடிகட்டவும்
                    final List<FoodItem> foodItems = snapshot.data!.where((
                      item,
                    ) {
                      return item.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (foodItems.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No products match "$_searchQuery"',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.76,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              FoodCard(item: foodItems[index], index: index),
                          childCount: foodItems.length,
                        ),
                      ),
                    );
                  },
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
          Row(
            children: [
              // _buildCartIcon() removed
              // const SizedBox(width: 12) removed
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoodGoLoginScreen(),
                        ),
                      );
                    } else {
                      // லாகின் ஆகியிருந்தால் Drawer-ஐத் திறக்கவும்
                      Scaffold.of(context).openEndDrawer();
                    }
                  },
                  child: _buildProfileAvatar(),
                ),
              ),
            ],
          ),
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
            // _buildCartIcon() removed
            // const SizedBox(width: 16) removed
            Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FoodGoLoginScreen(),
                      ),
                    );
                  } else {
                    Scaffold.of(context).openEndDrawer();
                  }
                },
                child: _buildProfileAvatar(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: user != null
              ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots()
              : null,
          builder: (context, snapshot) {
            String? imageUrl;
            if (snapshot.hasData && snapshot.data!.exists) {
              imageUrl =
                  (snapshot.data!.data() as Map<String, dynamic>?)?['imageUrl'];
            }

            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEEF4),
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null && imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl.isEmpty
                  ? const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFFEF2A39),
                      size: 24,
                    )
                  : null,
            );
          },
        ),
        const SizedBox(height: 4),
        const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
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
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
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
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.id == selectedCategoryId;

          return GestureDetector(
            onTap: () => setState(() => selectedCategoryId = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEF2A39)
                    : const Color(0xFFEFEEF4),
                borderRadius: BorderRadius.circular(isSelected ? 20 : 14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF2A39).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
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
                    style: GoogleFonts.poppins(
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
  final int index;

  const FoodCard({super.key, required this.item, this.index = 0});

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    // பண மதிப்பை வடிவமைக்க
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US', // அல்லது உங்கள் தேவைக்கேற்ப மாற்றவும்
      symbol: '\$', // அல்லது உங்கள் தேவைக்கேற்ப மாற்றவும்
      decimalDigits: 2,
    );
    debugPrint(
      "DEBUG 3 (FoodCard Image URL): ${widget.item.image}",
    ); // UI-க்கு வரும்போது

    // நுழைவு அனிமேஷன் (Fade and Slide)
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (widget.index * 50).clamp(0, 400)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        // Added missing closing parenthesis for TweenAnimationBuilder child
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              // பயனர் ஏற்கனவே லாகின் செய்திருந்தால் நேரடியாக DetailsPage-க்குச் செல்லவும்
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(
                    id: widget.item.id,
                    name: widget.item.name,
                    price: widget.item.price,
                    description: widget.item.description,
                    sellerId: widget.item.sellerId,
                    image: widget.item.image,
                  ),
                ),
              );
            } else {
              // லாகின் செய்யவில்லை என்றால் லாகின் பக்கத்திற்குச் செல்லவும்
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FoodGoLoginScreen(foodItemToAccess: widget.item),
                ),
              );
            }
          },
          child: AnimatedScale(
            scale: isHovered ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isHovered ? 0.06 : 0.02,
                    ),
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
                              child: Builder(
                                builder: (context) {
                                  // URL-ல் உள்ள தேவையற்ற ஸ்பேஸ் அல்லது நியூ-லைன்களை நீக்குதல்
                                  final imageUri = Uri.tryParse(
                                    widget.item.image ?? '',
                                  );

                                  if (imageUri != null &&
                                      imageUri.hasAbsolutePath) {
                                    return Image.network(
                                      imageUri.toString(),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                progress.expectedTotalBytes !=
                                                    null
                                                ? progress.cumulativeBytesLoaded /
                                                      progress
                                                          .expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            debugPrint(
                                              "Image Load Error: $error",
                                            );
                                            return Image.network(
                                              _kDefaultFoodImageUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder: (context, e, s) =>
                                                  Image.asset(
                                                    'assets/images/chef.png',
                                                    fit: BoxFit.contain,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                            );
                                          },
                                    );
                                  }
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey[100],
                                    child: Image.network(
                                      _kDefaultFoodImageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C1C1C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatter.format(
                            widget.item.price,
                          ), // Format price
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(255, 146, 142, 142),
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
      ),
    );
  }
}
