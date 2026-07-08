import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_state.dart';

void main() {
  group('SellerDashboardPageBloc', () {
    late SellerDashboardPageBloc bloc;

    setUp(() {
      bloc = SellerDashboardPageBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is SellerDashboardInitial', () {
      expect(bloc.state, isA<SellerDashboardInitial>());
    });

    blocTest<SellerDashboardPageBloc, SellerDashboardPageState>(
      'emits [SellerDashboardLoading, SellerDashboardLoaded] when LoadDashboardData is added',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadDashboardData()),
      wait: const Duration(seconds: 2), // Wait for mock delay
      expect: () => [
        isA<SellerDashboardLoading>(),
        isA<SellerDashboardLoaded>(),
      ],
    );

    blocTest<SellerDashboardPageBloc, SellerDashboardPageState>(
      'emits [SellerDashboardLoaded] when RefreshDashboardData is added',
      build: () => bloc,
      act: (bloc) => bloc.add(RefreshDashboardData()),
      wait: const Duration(seconds: 1), // Wait for mock delay
      expect: () => [isA<SellerDashboardLoaded>()],
    );
  });
}
