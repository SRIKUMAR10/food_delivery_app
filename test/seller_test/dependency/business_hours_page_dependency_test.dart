import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_service.dart';

void main() {
  group('BusinessHoursPage Dependency Test', () {
    test('Dependency injection resolution for Repository and Service', () {
      final service = BusinessHoursService();
      final repository = BusinessHoursRepository(service: service);
      final bloc = BusinessHoursBloc(repository: repository);

      expect(repository.service, equals(service));
      expect(bloc.repository, equals(repository));
      bloc.close();
    });
  });
}

