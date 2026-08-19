import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';

void main() {
  group('DeliveryNavigationBarPage Dependency Injection Tests', () {
    test(
      'instantiates BLoC with concrete repository and service instances',
      () {
        final repo = DeliveryNavigationBarRepository();
        final service = DeliveryNavigationBarService();
        final bloc = DeliveryNavigationBarPageBloc(
          repository: repo,
          service: service,
        );

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
        final repo = DeliveryNavigationBarRepository(prefs: prefs);

        expect(repo, isNotNull);
        expect(await repo.getSavedSelectedIndex(), -1);
      },
    );

    test('resolves feature dependencies via GetIt service locator', () {
      final di = GetIt.instance;
      if (di.isRegistered<DeliveryNavigationBarRepositoryBase>()) {
        di.unregister<DeliveryNavigationBarRepositoryBase>();
      }
      if (di.isRegistered<DeliveryNavigationBarServiceBase>()) {
        di.unregister<DeliveryNavigationBarServiceBase>();
      }
      if (di.isRegistered<DeliveryNavigationBarPageBloc>()) {
        di.unregister<DeliveryNavigationBarPageBloc>();
      }

      di.registerLazySingleton<DeliveryNavigationBarRepositoryBase>(
        () => DeliveryNavigationBarRepository(),
      );
      di.registerLazySingleton<DeliveryNavigationBarServiceBase>(
        () => DeliveryNavigationBarService(),
      );
      di.registerFactory<DeliveryNavigationBarPageBloc>(
        () => DeliveryNavigationBarPageBloc(
          repository: di<DeliveryNavigationBarRepositoryBase>(),
          service: di<DeliveryNavigationBarServiceBase>(),
        ),
      );

      final resolvedRepository = di<DeliveryNavigationBarRepositoryBase>();
      final resolvedService = di<DeliveryNavigationBarServiceBase>();
      final bloc = di<DeliveryNavigationBarPageBloc>();

      expect(resolvedRepository, isA<DeliveryNavigationBarRepository>());
      expect(resolvedService, isA<DeliveryNavigationBarService>());
      expect(bloc.repository, same(resolvedRepository));
      expect(bloc.service, same(resolvedService));

      bloc.close();
    });
  });
}
