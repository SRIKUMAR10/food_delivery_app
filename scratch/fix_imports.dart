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
    content = content.replaceAll("import '../../../../mock_firebase.dart';", "import '../../mock_firebase.dart';");
    await file.writeAsString(content);
    print('Fixed import in \$path');
  }
}
