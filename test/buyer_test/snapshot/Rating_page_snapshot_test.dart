import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';

void main() {
  group('Rating Page Snapshot Tests', () {
    test('Initial state snapshot is correct', () {
      const state = RatingInitial(rating: 5.0);
      expect(state.rating, 5.0);
    });

    test('Loading state snapshot is correct', () {
      const state = RatingLoading(rating: 4.0);
      expect(state.rating, 4.0);
    });
  });
}
