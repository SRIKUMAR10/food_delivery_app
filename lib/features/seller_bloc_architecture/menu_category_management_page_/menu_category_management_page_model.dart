class MenuCategoryModel {
  final String id;
  final String name;
  final String? iconUrl;
  final bool isSelected;
  final int sortOrder;

  MenuCategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.isSelected,
    required this.sortOrder,
  });

  MenuCategoryModel copyWith({
    String? id,
    String? name,
    String? iconUrl,
    bool? isSelected,
    int? sortOrder,
  }) {
    return MenuCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      isSelected: isSelected ?? this.isSelected,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
