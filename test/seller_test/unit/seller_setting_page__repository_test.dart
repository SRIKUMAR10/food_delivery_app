import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__state.dart';

class DummySettingRepository implements SellerSettingRepository {
  SellerSettingState _state = const SellerSettingState();
  bool isDeactivated = false;
  bool isDeleted = false;
  bool isLoggedOut = false;

  @override
  Future<SellerSettingState> loadSettings() async {
    return _state;
  }

  @override
  Stream<SellerSettingState> watchSettings() {
    return Stream.value(_state);
  }

  @override
  Future<void> saveSettings(SellerSettingState state) async {
    _state = state;
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword, {bool signOutOtherDevices = false}) async {
    if (currentPassword != 'CorrectPassword123') {
      throw Exception('Incorrect current password');
    }
  }

  @override
  Future<void> deactivateAccount(String reason, int durationDays) async {
    isDeactivated = true;
    _state = _state.copyWith(isDeactivated: true, deactivationReason: reason, isOpen: false, isAcceptingOrders: false);
  }

  @override
  Future<void> reactivateAccount() async {
    isDeactivated = false;
    _state = _state.copyWith(isDeactivated: false, isOpen: true, isAcceptingOrders: true);
  }

  @override
  Future<void> deleteAccount(String password) async {
    isDeleted = true;
  }

  @override
  Future<void> logout() async {
    isLoggedOut = true;
  }
}

void main() {
  group('SellerSettingRepository Tests', () {
    late DummySettingRepository repository;

    setUp(() {
      repository = DummySettingRepository();
    });

    test('loadSettings returns initial state', () async {
      final state = await repository.loadSettings();
      expect(state, const SellerSettingState());
    });

    test('watchSettings emits initial state', () async {
      final streamState = await repository.watchSettings().first;
      expect(streamState, const SellerSettingState());
    });

    test('saveSettings updates the state', () async {
      const newState = SellerSettingState(
        restaurantName: 'Grand Curry',
        pushNotifications: false,
        appTheme: 'Dark',
      );
      await repository.saveSettings(newState);
      final loadedState = await repository.loadSettings();
      expect(loadedState, newState);
    });

    test('changePassword succeeds on valid password', () async {
      expect(
        () async => await repository.changePassword('CorrectPassword123', 'NewPass456'),
        returnsNormally,
      );
    });

    test('changePassword throws on invalid password', () async {
      expect(
        () async => await repository.changePassword('WrongPassword', 'NewPass456'),
        throwsException,
      );
    });

    test('deactivateAccount updates state to deactivated', () async {
      await repository.deactivateAccount('Holiday break', 7);
      expect(repository.isDeactivated, isTrue);
      final loaded = await repository.loadSettings();
      expect(loaded.isDeactivated, isTrue);
      expect(loaded.isOpen, isFalse);
    });

    test('reactivateAccount restores active status', () async {
      await repository.deactivateAccount('Holiday', 7);
      await repository.reactivateAccount();
      expect(repository.isDeactivated, isFalse);
      final loaded = await repository.loadSettings();
      expect(loaded.isDeactivated, isFalse);
      expect(loaded.isOpen, isTrue);
    });

    test('deleteAccount and logout succeed', () async {
      await repository.deleteAccount('Password123');
      expect(repository.isDeleted, isTrue);

      await repository.logout();
      expect(repository.isLoggedOut, isTrue);
    });
  });
}
