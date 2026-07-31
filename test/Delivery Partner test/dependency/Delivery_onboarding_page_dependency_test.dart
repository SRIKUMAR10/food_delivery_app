import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_service.dart';

void main() {
  group('DeliveryOnboardingPage Dependency Tests', () {
    test(
      'instantiates BLoC with repository and service dependencies without crashing',
      () {
        final repository = DeliveryOnboardingRepository();
        final service = DeliveryOnboardingService();
        final bloc = DeliveryOnboardingPageBloc(
          repository: repository,
          service: service,
        );

        expect(bloc.repository, equals(repository));
        expect(bloc.service, equals(service));
        bloc.close();
      },
    );
  });
}
