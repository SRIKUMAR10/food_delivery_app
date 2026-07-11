import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_repository.dart';

void main() {
  group('SellerAnalyticsRepository', () {
    late SellerAnalyticsRepository repository;

    setUp(() async {
      repository = SellerAnalyticsRepository();
      // Load mock env for testing if needed
      dotenv.env.addAll({'BASE_URL': 'test', 'API_KEY': 'test'});
    });

    test('fetchAnalyticsData returns SellerAnalyticsData', () async {
      final data = await repository.fetchAnalyticsData('This Week');

      expect(data, isA<SellerAnalyticsData>());
      expect(data.totalRevenue, 45600.0);
      expect(data.percentageChange, 12.5);
      expect(data.weeklyChartData.length, 8); // Mock has 8 elements
      expect(data.topProducts.length, 3);
      expect(data.topProducts.first.name, 'Red Pizza');
    });
  });
}
