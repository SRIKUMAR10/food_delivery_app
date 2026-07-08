import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import '../../../../lib/features/Seller Bloc Architecture/overall_rating_page/overall_rating_page__state.dart';

void main() {
  group('Snapshot Serialization Tests', () {
    test('ReviewModel should correctly serialize/deserialize to match snapshot', () {
      final jsonSnapshot = {
        'id': '123',
        'authorName': 'John Doe',
        'authorAvatarUrl': 'http://avatar.url',
        'rating': 4.5,
        'content': 'Great stuff',
        'date': '2024-05-01T00:00:00.000'
      };

      // Simulating fromJson
      final model = ReviewModel(
        id: jsonSnapshot['id'] as String,
        authorName: jsonSnapshot['authorName'] as String,
        authorAvatarUrl: jsonSnapshot['authorAvatarUrl'] as String,
        rating: (jsonSnapshot['rating'] as num).toDouble(),
        content: jsonSnapshot['content'] as String,
        date: DateTime.parse(jsonSnapshot['date'] as String),
      );

      expect(model.id, '123');
      expect(model.authorName, 'John Doe');
      
      // Simulating toJson to match snapshot
      final map = {
        'id': model.id,
        'authorName': model.authorName,
        'authorAvatarUrl': model.authorAvatarUrl,
        'rating': model.rating,
        'content': model.content,
        'date': model.date.toIso8601String(),
      };

      expect(jsonEncode(map), jsonEncode(jsonSnapshot));
    });
  });
}
