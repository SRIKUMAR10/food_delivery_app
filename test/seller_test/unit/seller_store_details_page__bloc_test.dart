import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__state.dart';

void main() {
  group('SellerStoreDetailsBloc', () {
    late SellerStoreDetailsBloc bloc;

    setUp(() {
      bloc = SellerStoreDetailsBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is SellerStoreDetailsInitial', () {
      expect(bloc.state, equals(SellerStoreDetailsInitial()));
    });

    blocTest<SellerStoreDetailsBloc, SellerStoreDetailsPageState>(
      'emits [Loading, Loaded] when LoadStoreDetailsEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadStoreDetailsEvent()),
      wait: const Duration(seconds: 2),
      expect: () => [
        isA<SellerStoreDetailsLoading>(),
        isA<SellerStoreDetailsLoaded>(),
      ],
    );
  });
}
