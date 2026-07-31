import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';

void main() {
  group('DeliveryNavigationScreenPage Dependency Injection Tests', () {
    test(
      'instantiates BLoC with concrete repository and service instances',
      () {
        final repo = DeliveryNavigationRepository();
        final service = DeliveryNavigationService();
        final bloc = DeliveryNavigationBloc(repository: repo, service: service);

        expect(bloc.repository, same(repo));
        expect(bloc.service, same(service));
        bloc.close();
      },
    );

    test(
      'concrete repository can be constructed with injected preferences',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = DeliveryNavigationRepository(prefs: prefs);

        expect(repo, isNotNull);
        expect(await repo.getAudioEnabled(), isFalse);
        expect(await repo.getLocaleCode(), 'en');
      },
    );

    test('resolves feature dependencies via GetIt service locator', () {
      final di = GetIt.instance;
      if (di.isRegistered<DeliveryNavigationRepositoryBase>()) {
        di.unregister<DeliveryNavigationRepositoryBase>();
      }
      if (di.isRegistered<DeliveryNavigationServiceBase>()) {
        di.unregister<DeliveryNavigationServiceBase>();
      }
      if (di.isRegistered<DeliveryNavigationBloc>()) {
        di.unregister<DeliveryNavigationBloc>();
      }

      di.registerLazySingleton<DeliveryNavigationRepositoryBase>(
        () => DeliveryNavigationRepository(),
      );
      di.registerLazySingleton<DeliveryNavigationServiceBase>(
        () => DeliveryNavigationService(),
      );
      di.registerFactory<DeliveryNavigationBloc>(
        () => DeliveryNavigationBloc(
          repository: di<DeliveryNavigationRepositoryBase>(),
          service: di<DeliveryNavigationServiceBase>(),
        ),
      );

      final resolvedRepository = di<DeliveryNavigationRepositoryBase>();
      final resolvedService = di<DeliveryNavigationServiceBase>();
      final bloc = di<DeliveryNavigationBloc>();

      expect(resolvedRepository, isA<DeliveryNavigationRepository>());
      expect(resolvedService, isA<DeliveryNavigationService>());
      expect(bloc.repository, same(resolvedRepository));
      expect(bloc.service, same(resolvedService));

      bloc.close();
    });
  });
}
