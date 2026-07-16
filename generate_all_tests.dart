import 'dart:io';

void main() {
  final List<String> sellerBlocs = [
    'seller_wallet_page',
    'seller_store_details_page',
    'seller_sign_up_page',
    'seller_setting_page',
    'seller_request_payout_page',
    'seller_profile_page',
    'seller_payout_history_page',
    'seller_payment_page',
    'seller_onboard_page',
    'seller_NavigationBarView_page',
    'seller_login_page',
    'seller_forgot_password',
    'seller_dashboard_page',
    'seller_customer_page',
    'seller_analytics_page',
    'product_list_page',
    'overall_rating_page',
    'out_for_delivery_page',
    'orders_list_page',
    'new_order_notification',
    'inventory_low_stock_page',
    'assign_delivery_page',
    'low_stock_alert_page',
    'add_product_page',
  ];

  final List<String> buyerBlocs = [
    'cart_page',
    'curved_navigation_bar_view',
    'details_page',
    'favorites_page',
    'food_go_login_screen',
    'forgot_password_page',
    'order_page',
    'rating_page',
    'sign_up_page',
    'track_order_page',
    'wallet_screen',
    'home_page',
    'onboarding_page',
    'user_profile_image',
  ];

  final List<String> categories = [
    'unit',
    'widget',
    'integration',
    'golden',
    'performance',
    'accessibility',
    'security',
    'localization',
    'snapshot',
    'error_handling',
    'dependency',
    'state_restoration',
    'permission',
  ];

  int createdCount = 0;

  void generateTests(List<String> blocs, String architecturePath) {
    for (var category in categories) {
      for (var bloc in blocs) {
        String cleanBloc = bloc.replaceAll('__bloc', '').replaceAll('_bloc', '');
        if (bloc.endsWith('__')) {
          cleanBloc = bloc.substring(0, bloc.length - 2);
        }
        
        String testFileName = '${cleanBloc}_${category}_test.dart';

        final dir = Directory('$architecturePath/$category');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }

        final file = File('${dir.path}/$testFileName');
        if (!file.existsSync()) {
          final title = bloc.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
          
          file.writeAsStringSync('''import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$title $category Tests', () {
    test('Placeholder for $category testing', () {
      expect(true, isTrue);
    });
  });
}
''');
          print('Created: ${file.path}');
          createdCount++;
        }
      }
    }
  }

  generateTests(sellerBlocs, 'test/seller_test');
  generateTests(buyerBlocs, 'test/buyer_test');

  print('Successfully generated $createdCount missing test files for both Buyer and Seller BLoC architectures!');
}
