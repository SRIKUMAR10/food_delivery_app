class MenuCategoryModel {
  final String id;
  final String name;
  final String? iconUrl;
  final String? emoji;
  final bool isSelected;
  final int sortOrder;

  MenuCategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    this.emoji,
    required this.isSelected,
    required this.sortOrder,
  });

  String get displayEmoji {
    if (emoji != null && emoji!.trim().isNotEmpty) {
      return emoji!;
    }
    return getCategoryEmoji(name);
  }

  static String getCategoryEmoji(String categoryName) {
    final lower = categoryName.toLowerCase().trim();
    if (lower.contains('chicken')) return '🍗';
    if (lower.contains('burger')) return '🍔';
    if (lower.contains('pizza')) return '🍕';
    if (lower.contains('side') || lower.contains('frie')) return '🍟';
    if (lower.contains('beverage') || lower.contains('drink')) return '🥤';
    if (lower.contains('dessert') || lower.contains('cake')) return '🍰';
    if (lower.contains('combo')) return '🍱';
    if (lower.contains('kid')) return '🧸';
    if (lower.contains('wrap')) return '🌯';
    return '🍽️';
  }

  MenuCategoryModel copyWith({
    String? id,
    String? name,
    String? iconUrl,
    String? emoji,
    bool? isSelected,
    int? sortOrder,
  }) {
    return MenuCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      emoji: emoji ?? this.emoji,
      isSelected: isSelected ?? this.isSelected,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
