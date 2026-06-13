import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String sellerId;
  final String? image;

  const FavoriteItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.sellerId,
    this.image,
  });

  factory FavoriteItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteItem(
      id: doc.id,
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? 'No description',
      sellerId: data['sellerId'] ?? '',
      image: data['image'] ?? data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'sellerId': sellerId,
      'image': image,
      'imageUrl': image,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
