import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__state.dart';

class MockSellerSettingRepository extends Mock implements SellerSettingRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SellerSettingState());
  });

  group('SellerSettingBloc', () {
    late SellerSettingBloc bloc;
    late MockSellerSettingRepository mockRepository;

    setUp(() {
      mockRepository = MockSellerSettingRepository();
      bloc = SellerSettingBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, const SellerSettingState());
    });

    blocTest<SellerSettingBloc, SellerSettingState>(
      'emits [isLoading: true, settings] when LoadSellerSettings is added and succeeds',
      build: () {
        when(() => mockRepository.loadSettings()).thenAnswer(
          (_) async => const SellerSettingState(pushNotifications: false),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LoadSellerSettings()),
      expect: () => [
        const SellerSettingState(isLoading: true),
        const SellerSettingState(isLoading: false, pushNotifications: false),
      ],
      verify: (_) {
        verify(() => mockRepository.loadSettings()).called(1);
      },
    );

    blocTest<SellerSettingBloc, SellerSettingState>(
      'emits [isLoading: true, error] when LoadSellerSettings is added and fails',
      build: () {
        when(() => mockRepository.loadSettings()).thenThrow(Exception('Failed to load'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadSellerSettings()),
      expect: () => [
        const SellerSettingState(isLoading: true),
        const SellerSettingState(isLoading: false, error: 'Exception: Failed to load'),
      ],
    );

    blocTest<SellerSettingBloc, SellerSettingState>(
      'emits updated pushNotifications when UpdatePushNotifications is added',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdatePushNotifications(false)),
      expect: () => [
        const SellerSettingState(pushNotifications: false),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSettings(const SellerSettingState(pushNotifications: false))).called(1);
      },
    );

    blocTest<SellerSettingBloc, SellerSettingState>(
      'emits updated appTheme when UpdateAppTheme is added',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateAppTheme('Dark')),
      expect: () => [
        const SellerSettingState(appTheme: 'Dark'),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSettings(const SellerSettingState(appTheme: 'Dark'))).called(1);
      },
    );
  });
}
