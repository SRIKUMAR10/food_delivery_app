import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Details_Page/details_page_Bloc.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Details_Page/details_page_Event.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Details_Page/details_page_State.dart';

void main() {
  group('DetailsBloc', () {
    late DetailsBloc detailsBloc;

    setUp(() {
      detailsBloc = DetailsBloc();
    });

    tearDown(() {
      detailsBloc.close();
    });

    test('initial state should be DetailsState with quantity 1 and isFavourite false', () {
      expect(detailsBloc.state, const DetailsState(quantity: 1, isFavourite: false));
    });

    test('DetailsQuantityIncreased should increment quantity by 1', () {
      detailsBloc.add(DetailsQuantityIncreased());
      expectLater(
        detailsBloc.stream,
        emitsInOrder([
          const DetailsState(quantity: 2, isFavourite: false),
        ]),
      );
    });

    test('DetailsQuantityDecreased should decrement quantity by 1 when quantity > 1', () async {
      // First increase to 2
      detailsBloc.add(DetailsQuantityIncreased());
      // Then decrease back to 1
      detailsBloc.add(DetailsQuantityDecreased());

      expectLater(
        detailsBloc.stream,
        emitsInOrder([
          const DetailsState(quantity: 2, isFavourite: false),
          const DetailsState(quantity: 1, isFavourite: false),
        ]),
      );
    });

    test('DetailsQuantityDecreased should not decrement quantity below 1', () {
      // Initial is 1, so decreasing should not change state
      detailsBloc.add(DetailsQuantityDecreased());
      
      // We expect no new states to be emitted since it's constrained
      // However, to be safe we can just assert the state remains 1 after a microtask.
      Future.delayed(Duration.zero, () {
        expect(detailsBloc.state.quantity, 1);
      });
    });

    test('DetailsFavouriteToggled should toggle isFavourite', () {
      detailsBloc.add(DetailsFavouriteToggled());
      
      expectLater(
        detailsBloc.stream,
        emitsInOrder([
          const DetailsState(quantity: 1, isFavourite: true),
        ]),
      );
    });
    
    test('DetailsFavouriteToggled multiple times', () {
      detailsBloc.add(DetailsFavouriteToggled());
      detailsBloc.add(DetailsFavouriteToggled());
      
      expectLater(
        detailsBloc.stream,
        emitsInOrder([
          const DetailsState(quantity: 1, isFavourite: true),
          const DetailsState(quantity: 1, isFavourite: false),
        ]),
      );
    });
  });
}
