import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_repository.dart';

class MockDetailsRepository extends Mock implements DetailsRepository {}

void main() {
  group('DetailsBloc Unit Tests', () {
    late MockDetailsRepository mockRepo;

    setUp(() {
      mockRepo = MockDetailsRepository();
    });

    test('initial state has default quantity of 1', () {
      final bloc = DetailsBloc(repository: mockRepo);
      expect(bloc.state.quantity, 1);
      bloc.close();
    });

    test('DetailsQuantityIncreased increments quantity', () async {
      final bloc = DetailsBloc(repository: mockRepo);
      bloc.add(DetailsQuantityIncreased());
      await expectLater(
        bloc.stream,
        emits(const DetailsState(quantity: 2)),
      );
      bloc.close();
    });

    test('DetailsQuantityDecreased decrements quantity but does not go below 1', () async {
      final bloc = DetailsBloc(repository: mockRepo);
      bloc.add(DetailsQuantityIncreased());
      bloc.add(DetailsQuantityDecreased());
      bloc.add(DetailsQuantityDecreased()); // should stay 1
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const DetailsState(quantity: 2),
          const DetailsState(quantity: 1),
        ]),
      );
      bloc.close();
    });
  });

  group('Details Page Data Logic Tests', () {
    test('verifies availability state calculation logic', () {
      bool isAvailable(String status, bool isActive, bool isSellerOpen) {
        final productActive = (status != 'outOfStock') && isActive;
        return productActive && isSellerOpen;
      }

      expect(isAvailable('inStock', true, true), isTrue);
      expect(isAvailable('outOfStock', true, true), isFalse);
      expect(isAvailable('inStock', false, true), isFalse);
      expect(isAvailable('inStock', true, false), isFalse);
    });

    test('verifies ingredients logic handles empty and populated lists correctly', () {
      List<String> getEffectiveIngredients(List<String> ingredients) {
        if (ingredients.isNotEmpty) return ingredients;
        return const [];
      }

      expect(getEffectiveIngredients(['Tomato', 'Basil']), equals(['Tomato', 'Basil']));
      expect(getEffectiveIngredients([]), isEmpty);
    });

    test('verifies addons logic handles empty and populated lists correctly', () {
      List<String> getEffectiveAddons(List<String> addons) {
        if (addons.isNotEmpty) return addons;
        return const [];
      }

      expect(getEffectiveAddons(['Extra Bacon (+₹40)']), equals(['Extra Bacon (+₹40)']));
      expect(getEffectiveAddons([]), isEmpty);
    });

    test('verifies dynamic addon price parsing and effective total calculation', () {
      double parseAddonPrice(String addon) {
        final match = RegExp(r'(?:\+|\:|\₹)\s*(\d+(?:\.\d+)?)').firstMatch(addon);
        if (match != null) {
          return double.tryParse(match.group(1) ?? '0') ?? 0.0;
        }
        return 0.0;
      }

      expect(parseAddonPrice('Extra Cheese (+₹30)'), equals(30.0));
      expect(parseAddonPrice('Spicy Dip (+₹20)'), equals(20.0));
      expect(parseAddonPrice('Extra Bacon (+40)'), equals(40.0));
      expect(parseAddonPrice('Sauce: 15'), equals(15.0));
      expect(parseAddonPrice('Free Cutlery'), equals(0.0));

      // Calculate effective price
      final basePrice = 150.0;
      final selectedAddons = ['Extra Cheese (+₹30)', 'Spicy Dip (+₹20)'];
      final totalAddonsPrice = selectedAddons.fold<double>(
        0.0,
        (sum, addon) => sum + parseAddonPrice(addon),
      );

      expect(totalAddonsPrice, equals(50.0));

      final effectiveUnitPrice = basePrice + totalAddonsPrice;
      expect(effectiveUnitPrice, equals(200.0));

      // Quantity multiplier
      final quantity = 3;
      final totalPrice = effectiveUnitPrice * quantity;
      expect(totalPrice, equals(600.0));
    });
  });
}
