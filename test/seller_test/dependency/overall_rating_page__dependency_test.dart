import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // Mock implementations or real ones
  getIt.registerLazySingleton<OverallRatingService>(() => _FakeService());
  getIt.registerLazySingleton<OverallRatingRepository>(
    () => OverallRatingRepositoryImpl(getIt()),
  );
  getIt.registerFactory<OverallRatingBloc>(
    () => OverallRatingBloc(repository: getIt()),
  );
}

class _FakeService implements OverallRatingService {
  @override
  Future<Map<String, dynamic>> fetchRatingsAndReviews() async => {};
}

void main() {
  setUp(() {
    getIt.reset();
    setupDependencyInjection();
  });

  group('Dependency Injection Tests', () {
    test('should resolve OverallRatingBloc with its dependencies', () {
      final bloc = getIt<OverallRatingBloc>();
      expect(bloc, isNotNull);
      expect(bloc.repository, isA<OverallRatingRepositoryImpl>());
    });

    test('should resolve OverallRatingRepository as Singleton', () {
      final repo1 = getIt<OverallRatingRepository>();
      final repo2 = getIt<OverallRatingRepository>();
      expect(identical(repo1, repo2), isTrue);
    });
  });
}
