import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductData {
  final String name;
  final int count;
  final String imageUrl;

  ProductData({required this.name, required this.count, required this.imageUrl});
}

class SellerAnalyticsData {
  final double totalRevenue;
  final double percentageChange;
  final List<double> weeklyChartData; // Mon-Sun
  final List<ProductData> topProducts;

  SellerAnalyticsData({
    required this.totalRevenue,
    required this.percentageChange,
    required this.weeklyChartData,
    required this.topProducts,
  });
}

class SellerAnalyticsRepository {
  Future<SellerAnalyticsData> fetchAnalyticsData(String timeRange) async {
    // In a real app, you would make an API call here.
    // Example using dotenv:
    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.example.com';
    final apiKey = dotenv.env['API_KEY'] ?? 'mock_key';
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock response based on the image
    return SellerAnalyticsData(
      totalRevenue: 45600.0,
      percentageChange: 12.5,
      weeklyChartData: [70, 95, 80, 115, 75, 140, 80, 95], // Mon-Sun dummy heights representing the chart in the image
      topProducts: [
        ProductData(
          name: 'Red Pizza',
          count: 120,
          imageUrl: 'https://via.placeholder.com/150', // Mock image
        ),
        ProductData(
          name: 'Chicken Pizza',
          count: 98,
          imageUrl: 'https://via.placeholder.com/150',
        ),
        ProductData(
          name: 'Italian Continental',
          count: 75,
          imageUrl: 'https://via.placeholder.com/150',
        ),
      ],
    );
  }
}
