import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_State.dart';

void main() {
  group('WalletState', () {
    test('initial state has correct default values', () {
      final state = WalletState();
      expect(state.isLoading, false);
      expect(state.pendingAmount, null);
      expect(state.successMessage, null);
      expect(state.errorMessage, null);
    });

    test('copyWith returns a new object with updated values', () {
      final state = WalletState();
      final updatedState = state.copyWith(
        isLoading: true,
        pendingAmount: () => 100.0,
        successMessage: () => 'Success',
        errorMessage: () => 'Error',
      );

      expect(updatedState.isLoading, true);
      expect(updatedState.pendingAmount, 100.0);
      expect(updatedState.successMessage, 'Success');
      expect(updatedState.errorMessage, 'Error');
    });

    test('copyWith properly handles null functions to set properties to null', () {
      final state = WalletState(
        isLoading: true,
        pendingAmount: 100.0,
        successMessage: 'Success',
        errorMessage: 'Error',
      );

      final updatedState = state.copyWith(
        isLoading: false,
        pendingAmount: () => null,
        successMessage: () => null,
        errorMessage: () => null,
      );

      expect(updatedState.isLoading, false);
      expect(updatedState.pendingAmount, null);
      expect(updatedState.successMessage, null);
      expect(updatedState.errorMessage, null);
    });

    test('copyWith retains old values if arguments are omitted', () {
      final state = WalletState(
        isLoading: true,
        pendingAmount: 100.0,
        successMessage: 'Success',
        errorMessage: 'Error',
      );

      final updatedState = state.copyWith();

      expect(updatedState.isLoading, true);
      expect(updatedState.pendingAmount, 100.0);
      expect(updatedState.successMessage, 'Success');
      expect(updatedState.errorMessage, 'Error');
    });
  });
}
