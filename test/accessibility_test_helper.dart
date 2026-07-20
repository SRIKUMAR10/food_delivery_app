import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/repositories/i_inventory_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'mock_firebase.dart';

class MockProductRepository extends Mock implements IProductRepository {}
class MockOrderRepository extends Mock implements IOrderRepository {}
class MockCartRepository extends Mock implements ICartRepository {}
class MockInventoryRepository extends Mock implements IInventoryRepository {}
class MockSellerRepository extends Mock implements SellerRepository {}
class MockAuthService extends Mock implements IAuthService {}

Future<void> setupAccessibilityTest() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseAuthMocks();
  await Firebase.initializeApp();
}
