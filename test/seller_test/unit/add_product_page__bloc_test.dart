import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__state.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  final testImage = XFile('path/to/image1.png');
  group('AddProductPageBloc', () {
    late AddProductPageBloc bloc;

    setUp(() {
      bloc = AddProductPageBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.status, AddProductStatus.initial);
      expect(bloc.state.images.isEmpty, true);
      expect(bloc.state.isActive, true);
    });

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits new image when AddImageEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(AddImageEvent(testImage)),
      expect: () => [
        AddProductPageState(images: [testImage]),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits category when CategoryChangedEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const CategoryChangedEvent('Pizza')),
      expect: () => [const AddProductPageState(category: 'Pizza')],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits validation error if SubmitProductEvent is missing fields',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const SubmitProductEvent(name: '', price: 0, description: ''),
      ),
      expect: () => [
        const AddProductPageState(status: AddProductStatus.loading),
        const AddProductPageState(
          status: AddProductStatus.error,
          errorMessage:
              'Please fill all required fields and upload at least 1 image.',
        ),
      ],
    );
  });
}
