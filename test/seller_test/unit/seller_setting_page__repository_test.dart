import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__state.dart';

// Since SellerSettingRepository is currently an abstract class, 
// we will test a dummy concrete implementation of it to ensure it behaves as expected.
class DummySettingRepository implements SellerSettingRepository {
  SellerSettingState _state = const SellerSettingState();

  @override
  Future<SellerSettingState> loadSettings() async {
    return _state;
  }

  @override
  Future<void> saveSettings(SellerSettingState state) async {
    _state = state;
  }
}

void main() {
  group('SellerSettingRepository', () {
    late DummySettingRepository repository;

    setUp(() {
      repository = DummySettingRepository();
    });

    test('loadSettings returns initial state', () async {
      final state = await repository.loadSettings();
      expect(state, const SellerSettingState());
    });

    test('saveSettings updates the state', () async {
      const newState = SellerSettingState(pushNotifications: false, appTheme: 'Dark');
      await repository.saveSettings(newState);
      final loadedState = await repository.loadSettings();
      expect(loadedState, newState);
    });
  });
}
