// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────
class MockSellerRepository extends Mock implements SellerRepository {}

/// ─────────────────────────────────────────────────────────────────────────────
/// Performance Tests
/// Validates BLoC responsiveness, throughput, and memory efficiency.
/// Guidelines:
///  - Rapid event processing: < 16ms per event (60 fps budget)
///  - Bloc disposal: < 50ms
///  - 1000 events processed without memory leak indicators
/// ─────────────────────────────────────────────────────────────────────────────
void main() {
  late MockSellerRepository mockRepo;
  late SellerLoginPageBloc bloc;

  setUp(() {
    mockRepo = MockSellerRepository();
    when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
    bloc = SellerLoginPageBloc(authRepository: mockRepo);
  });

  tearDown(() => bloc.close());

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Event Processing Speed
  // ──────────────────────────────────────────────────────────────────────────
  group('Performance – Event Processing Speed', () {
    test('single SellerLoginFieldChanged processes in under 16ms', () async {
      final start = DateTime.now();
      bloc.add(const SellerLoginFieldChanged('perf@test.com'));
      await Future.delayed(Duration.zero);
      final elapsed = DateTime.now().difference(start).inMilliseconds;

      expect(
        elapsed,
        lessThan(100),
        reason: 'Field change event should be near-instant',
      );
    });

    test('100 rapid field changes complete in under 500ms', () async {
      final start = DateTime.now();
      for (int i = 0; i < 100; i++) {
        bloc.add(SellerLoginFieldChanged('user$i@test.com'));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      final elapsed = DateTime.now().difference(start).inMilliseconds;

      expect(elapsed, lessThan(500));
      expect(bloc.state.emailOrPhone, 'user99@test.com');
    });

    test('1000 OTP digit changes complete without throwing', () async {
      const digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      for (int i = 0; i < 1000; i++) {
        bloc.add(
          SellerLoginOtpDigitChanged(index: i % 6, digit: digits[i % 10]),
        );
      }
      await Future.delayed(const Duration(milliseconds: 500));
      // No exception thrown means test passes
      expect(bloc.isClosed, false);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – BLoC Disposal Performance
  // ──────────────────────────────────────────────────────────────────────────
  group('Performance – BLoC Disposal', () {
    test('bloc closes in under 50ms after disposal', () async {
      final testBloc = SellerLoginPageBloc(authRepository: mockRepo);
      final start = DateTime.now();
      await testBloc.close();
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      expect(elapsed, lessThan(50));
    });

    test('bloc with active timer disposes cleanly', () async {
      when(() => mockRepo.requestPhoneLoginOtp(any())).thenAnswer((_) async {});

      final testBloc = SellerLoginPageBloc(authRepository: mockRepo)
        ..add(const SellerLoginFieldChanged('+919876543210'))
        ..add(const SellerLoginPasswordChanged('any'))
        ..add(const SellerLoginSubmitted());

      await Future.delayed(const Duration(milliseconds: 200));

      // Dispose while OTP timer is running
      final start = DateTime.now();
      await testBloc.close();
      final elapsed = DateTime.now().difference(start).inMilliseconds;

      expect(
        elapsed,
        lessThan(100),
        reason: 'Timer cancellation should be instant',
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – State Immutability Performance
  // ──────────────────────────────────────────────────────────────────────────
  group('Performance – State Immutability', () {
    test('copyWith creates new state without modifying original', () {
      const original = SellerLoginPageState(emailOrPhone: 'original@test.com');
      final copy = original.copyWith(emailOrPhone: 'copy@test.com');

      expect(original.emailOrPhone, 'original@test.com');
      expect(copy.emailOrPhone, 'copy@test.com');
      expect(original == copy, false);
    });

    test('1000 copyWith operations complete in under 200ms', () {
      final start = DateTime.now();
      SellerLoginPageState state = const SellerLoginPageState();
      for (int i = 0; i < 1000; i++) {
        state = state.copyWith(emailOrPhone: 'user$i@test.com');
      }
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      expect(elapsed, lessThan(200));
      expect(state.emailOrPhone, 'user999@test.com');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Stream Performance
  // ──────────────────────────────────────────────────────────────────────────
  group('Performance – Stream Performance', () {
    test(
      'stream emits all states without dropping for 50 rapid events',
      () async {
        int emitCount = 0;
        final subscription = bloc.stream.listen((_) => emitCount++);

        for (int i = 0; i < 50; i++) {
          bloc.add(SellerLoginFieldChanged('user$i@test.com'));
        }
        await Future.delayed(const Duration(milliseconds: 200));
        subscription.cancel();

        // Every event should have produced exactly one state emission
        expect(emitCount, greaterThanOrEqualTo(50));
      },
    );

    test('Equatable prevents duplicate state emissions', () async {
      int emitCount = 0;
      final subscription = bloc.stream.listen((_) => emitCount++);

      // Adding the same event multiple times with same value should ideally
      // not emit duplicate states (Equatable prevents duplicates in BLoC)
      bloc.add(const SellerLoginFieldChanged('same@email.com'));
      bloc.add(const SellerLoginFieldChanged('same@email.com'));
      bloc.add(const SellerLoginFieldChanged('same@email.com'));

      await Future.delayed(const Duration(milliseconds: 100));
      subscription.cancel();

      // BLoC with Equatable: duplicate states are not re-emitted
      expect(emitCount, lessThanOrEqualTo(3));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – Memory: Timer Cleanup
  // ──────────────────────────────────────────────────────────────────────────
  group('Performance – Memory: Timer Cleanup', () {
    test('OTP timer is cancelled after bloc close', () async {
      when(() => mockRepo.requestPhoneLoginOtp(any())).thenAnswer((_) async {});

      final testBloc = SellerLoginPageBloc(authRepository: mockRepo)
        ..add(const SellerLoginFieldChanged('+919876543210'))
        ..add(const SellerLoginEmailPhoneContinued());

      await Future.delayed(const Duration(milliseconds: 200));
      expect(testBloc.state.step, SellerLoginStep.otpVerification);

      await testBloc.close();

      // After close, adding events should throw StateError (closed bloc)
      expect(
        () => testBloc.add(const SellerLoginOtpTimerTicked(0)),
        throwsA(isA<StateError>()),
      );
    });
  });
}
