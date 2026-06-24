import 'package:flutter_test/flutter_test.dart';
import '../Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPageBloc', () {
    late DetailsPageBloc bloc;
    late DetailsPageRepository repository;
    late DetailsPageService service;

    setUp(() {
      service = DetailsPageService();
      repository = DetailsPageRepository(service: service);
      bloc = DetailsPageBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is DetailsInitial', () {
      expect(bloc.state, isA<DetailsInitial>());
    });

    test('emits [DetailsLoading, DetailsLoaded] when LoadDetailsEvent is added', () async {
      final expectedResponse = {'id': '1', 'name': 'Delicious Burger', 'price': 10.99};
      
      bloc.add(LoadDetailsEvent('1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<DetailsLoading>(),
          isA<DetailsLoaded>().having((state) => state.data, 'data', equals(expectedResponse)),
        ]),
      );
    });

    test('emits [DetailsLoading, DetailsError] when LoadDetailsEvent fails', () async {
      bloc.add(LoadDetailsEvent('error'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<DetailsLoading>(),
          isA<DetailsError>().having((state) => state.message, 'message', contains('Failed to fetch details')),
        ]),
      );
    });
  });
}
