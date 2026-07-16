import 'dart:io';

void main() async {
  final filesToFixFirebase = [
    'test/seller_test/unit/business_hours_page_service_test.dart',
    'test/seller_test/unit/chat_support_page_service_test.dart',
    'test/seller_test/unit/disputes_refunds_page_service_test.dart',
    'test/seller_test/unit/menu_category_management_page_service_test.dart',
    'test/seller_test/unit/seller_store_details_page__bloc_test.dart',
    'test/seller_test/unit/add_product_page__bloc_test.dart',
    'test/seller_test/unit/seller_analytics_page__repository_test.dart',
  ];

  for (var path in filesToFixFirebase) {
    var file = File(path);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    if (!content.contains('setupFirebaseAuthMocks')) {
      content = "import 'package:firebase_core/firebase_core.dart';\n"
                "import '../../../../mock_firebase.dart';\n" + content;
      
      if (content.contains('setUpAll(() {')) {
        content = content.replaceAll('setUpAll(() {', 'setUpAll(() async {\n    setupFirebaseAuthMocks();\n    await Firebase.initializeApp();');
      } else {
        content = content.replaceFirst('void main() {', 'void main() {\n  setUpAll(() async {\n    setupFirebaseAuthMocks();\n    await Firebase.initializeApp();\n  });\n');
      }
      await file.writeAsString(content);
      print('Fixed Firebase in \$path');
    }
  }

  // Fix promotions_coupons arguments
  final promoFiles = [
    'test/seller_test/unit/promotions_coupons_page_repository_test.dart',
    'test/seller_test/unit/promotions_coupons_page_service_test.dart',
  ];
  for (var path in promoFiles) {
    var file = File(path);
    if (file.existsSync()) {
      var content = await file.readAsString();
      content = content.replaceAll('addCoupon(dummyCoupon)', "addCoupon('test_seller_id', dummyCoupon)");
      content = content.replaceAll('addCoupon(any())', "addCoupon(any(), any())");
      content = content.replaceAll('addCoupon(newCoupon)', "addCoupon('test_seller_id', newCoupon)");
      await file.writeAsString(content);
      print('Fixed promo args in \$path');
    }
  }

  // Fix sellerId in events
  final eventFiles = [
    'test/seller_test/unit/inventory_low_stock_page_bloc_test.dart',
    'test/seller_test/unit/seller_analytics_page__bloc_test.dart',
  ];
  for (var path in eventFiles) {
    var file = File(path);
    if (file.existsSync()) {
      var content = await file.readAsString();
      content = content.replaceAll('LoadInventoryStream()', "LoadInventoryStream(sellerId: 'test_seller_id')");
      content = content.replaceAll('LoadSellerAnalytics()', "LoadSellerAnalytics(sellerId: 'test_seller_id')");
      await file.writeAsString(content);
      print('Fixed events in \$path');
    }
  }

  // Fix registerFallbackValue
  final fallbackFiles = {
    'test/seller_test/unit/overall_rating_page__service_test.dart': "import 'package:mocktail/mocktail.dart';\nclass FakeUri extends Fake implements Uri {}\n",
    'test/seller_test/unit/product_list_page__repository_test.dart': "import 'package:mocktail/mocktail.dart';\nimport 'package:food_delivery_app/core/models/product_model.dart';\nclass FakeProduct extends Fake implements Product {}\n",
  };
  
  for (var path in fallbackFiles.keys) {
    var file = File(path);
    if (file.existsSync()) {
      var content = await file.readAsString();
      if (!content.contains('registerFallbackValue')) {
        content = fallbackFiles[path]! + content;
        var fakeClass = path.contains('overall') ? 'FakeUri()' : 'FakeProduct()';
        
        if (content.contains('setUpAll(() {')) {
          content = content.replaceAll('setUpAll(() {', "setUpAll(() {\n    registerFallbackValue(\$fakeClass);");
        } else {
          content = content.replaceFirst('void main() {', "void main() {\n  setUpAll(() {\n    registerFallbackValue(\$fakeClass);\n  });\n");
        }
        await file.writeAsString(content);
        print('Fixed fallbacks in \$path');
      }
    }
  }

  print('All done.');
}
