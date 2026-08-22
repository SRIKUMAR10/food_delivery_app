import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_NavigationBarView_page/seller_NavigationBarView_page_state.dart';

void main() {
  group('SellerNavigationBarViewPageBloc Unit Tests', () {
    late SellerNavigationBarViewPageBloc bloc;

    setUp(() {
      bloc = SellerNavigationBarViewPageBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is SellerNavigationBarViewPageInitial with tabIndex 0', () {
      expect(bloc.state, isA<SellerNavigationBarViewPageInitial>());
      expect((bloc.state as SellerNavigationBarViewPageInitial).tabIndex, 0);
      expect(bloc.state.currentTabIndex, 0);
    });

    blocTest<SellerNavigationBarViewPageBloc, SellerNavigationBarViewPageState>(
      'emits [SellerNavigationBarViewPageUpdated(1)] when TabChangedEvent(1) is added for Orders',
      build: () => SellerNavigationBarViewPageBloc(),
      act: (bloc) => bloc.add(const TabChangedEvent(1)),
      expect: () => [
        const SellerNavigationBarViewPageUpdated(1),
      ],
    );

    blocTest<SellerNavigationBarViewPageBloc, SellerNavigationBarViewPageState>(
      'emits [SellerNavigationBarViewPageUpdated(2)] when TabChangedEvent(2) is added for Products',
      build: () => SellerNavigationBarViewPageBloc(),
      act: (bloc) => bloc.add(const TabChangedEvent(2)),
      expect: () => [
        const SellerNavigationBarViewPageUpdated(2),
      ],
    );

    blocTest<SellerNavigationBarViewPageBloc, SellerNavigationBarViewPageState>(
      'emits [SellerNavigationBarViewPageUpdated(3)] when TabChangedEvent(3) is added for Wallet',
      build: () => SellerNavigationBarViewPageBloc(),
      act: (bloc) => bloc.add(const TabChangedEvent(3)),
      expect: () => [
        const SellerNavigationBarViewPageUpdated(3),
      ],
    );

    blocTest<SellerNavigationBarViewPageBloc, SellerNavigationBarViewPageState>(
      'emits [SellerNavigationBarViewPageUpdated(4)] when TabChangedEvent(4) is added for Support Chat',
      build: () => SellerNavigationBarViewPageBloc(),
      act: (bloc) => bloc.add(const TabChangedEvent(4)),
      expect: () => [
        const SellerNavigationBarViewPageUpdated(4),
      ],
    );

    blocTest<SellerNavigationBarViewPageBloc, SellerNavigationBarViewPageState>(
      'emits [SellerNavigationBarViewPageUpdated(5)] when TabChangedEvent(5) is added for Ratings & Reviews',
      build: () => SellerNavigationBarViewPageBloc(),
      act: (bloc) => bloc.add(const TabChangedEvent(5)),
      expect: () => [
        const SellerNavigationBarViewPageUpdated(5),
      ],
    );

    blocTest<SellerNavigationBarViewPageBloc, SellerNavigationBarViewPageState>(
      'emits [SellerNavigationBarViewPageUpdated(6)] when TabChangedEvent(6) is added for Customer Insights',
      build: () => SellerNavigationBarViewPageBloc(),
      act: (bloc) => bloc.add(const TabChangedEvent(6)),
      expect: () => [
        const SellerNavigationBarViewPageUpdated(6),
      ],
    );

    blocTest<SellerNavigationBarViewPageBloc, SellerNavigationBarViewPageState>(
      'emits [SellerNavigationBarViewPageUpdated(7)] when TabChangedEvent(7) is added for More',
      build: () => SellerNavigationBarViewPageBloc(),
      act: (bloc) => bloc.add(const TabChangedEvent(7)),
      expect: () => [
        const SellerNavigationBarViewPageUpdated(7),
      ],
    );
  });
}

