import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/routes/app_router.dart';
import 'package:food_delivery_app/core/utils/navigation_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRouter Unit Tests', () {
    test('generateRoute returns valid MaterialPageRoute for buyer routes', () {
      final buyerHomeRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.buyerHome),
      );
      expect(buyerHomeRoute, isNotNull);
      expect(buyerHomeRoute, isA<MaterialPageRoute>());

      final buyerLoginRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.buyerLogin),
      );
      expect(buyerLoginRoute, isNotNull);
    });

    test('generateRoute parses trackOrder route arguments correctly', () {
      final trackRoute = AppRouter.generateRoute(
        const RouteSettings(
          name: AppRouter.trackOrder,
          arguments: {'orderId': 'ORD-98765'},
        ),
      );
      expect(trackRoute, isNotNull);
      expect(trackRoute, isA<MaterialPageRoute>());
    });

    test('generateRoute parses deep linking query parameters for web', () {
      final deepLinkRoute = AppRouter.generateRoute(
        const RouteSettings(
          name: '/trackOrder?orderId=ORD-WEB-12345',
        ),
      );
      expect(deepLinkRoute, isNotNull);
      expect(deepLinkRoute, isA<MaterialPageRoute>());
    });

    test('generateRoute returns valid routes for Seller and Delivery Partner', () {
      final sellerDash = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.sellerDashboard),
      );
      expect(sellerDash, isNotNull);

      final deliveryNav = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.deliveryNavigationBar),
      );
      expect(deliveryNav, isNotNull);

      final deliveryDetails = AppRouter.generateRoute(
        const RouteSettings(
          name: AppRouter.deliveryOrderDetails,
          arguments: {'orderId': 'DEL-101'},
        ),
      );
      expect(deliveryDetails, isNotNull);
    });

    test('unknownRoute produces a fallback 404 page', () {
      final unknown = AppRouter.unknownRoute(
        const RouteSettings(name: '/non_existent_page_123'),
      );
      expect(unknown, isNotNull);
      expect(unknown, isA<MaterialPageRoute>());
    });
  });

  group('NavigationHelper Unit Tests', () {
    test('canNavigate enforces debounce window', () {
      expect(NavigationHelper.canNavigate(), isTrue);
      // Immediately subsequent call within 500ms should return false
      expect(NavigationHelper.canNavigate(), isFalse);
    });
  });
}
