import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/PaymentMethodsPage/PaymentMethods_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/PaymentMethodsPage/PaymentMethods_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/PaymentMethodsPage/PaymentMethods_State.dart';

class MockPaymentMethodsRepository extends Mock implements PaymentMethodsRepository {}

void main() {
  group('PaymentMethodsBloc Unit Tests', () {
    late MockPaymentMethodsRepository mockRepository;
    late PaymentMethodsBloc bloc;

    final mockCards = [
      PaymentMethodModel(
        id: 'pm_1',
        type: 'Visa',
        maskedNumber: '**** 4242',
        lastFourDigits: '4242',
        cardholderName: 'John Doe',
        expiryDate: '12/28',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setUp(() {
      mockRepository = MockPaymentMethodsRepository();
      when(() => mockRepository.streamPaymentMethods())
          .thenAnswer((_) => Stream.value(mockCards));
      bloc = PaymentMethodsBloc(mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.status, PaymentMethodsStatus.initial);
      expect(bloc.state.methods, isEmpty);
    });

    test('LoadPaymentMethods streams payment methods and emits loaded state', () async {
      bloc.add(LoadPaymentMethods());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PaymentMethodsState>().having((s) => s.status, 'status', PaymentMethodsStatus.loading),
          isA<PaymentMethodsState>()
              .having((s) => s.status, 'status', PaymentMethodsStatus.loaded)
              .having((s) => s.methods.first.lastFourDigits, 'lastFourDigits', '4242'),
        ]),
      );

      verify(() => mockRepository.streamPaymentMethods()).called(1);
    });

    test('AddPaymentMethod calls repository and emits success message', () async {
      when(() => mockRepository.addPaymentMethod(
            type: any(named: 'type'),
            maskedNumber: any(named: 'maskedNumber'),
            lastFourDigits: any(named: 'lastFourDigits'),
            expiryDate: any(named: 'expiryDate'),
            cardholderName: any(named: 'cardholderName'),
            upiId: any(named: 'upiId'),
            billingAddress: any(named: 'billingAddress'),
            isDefault: any(named: 'isDefault'),
          )).thenAnswer((_) async {});

      bloc.add(AddPaymentMethod(
        type: 'Visa',
        cardNumber: '4242 4242 4242 4242',
        expiryDate: '12/28',
        cardholderName: 'John Doe',
        isDefault: true,
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PaymentMethodsState>().having((s) => s.isSaving, 'isSaving', true),
          isA<PaymentMethodsState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.successMessage, 'successMessage', 'Payment method added'),
        ]),
      );

      verify(() => mockRepository.addPaymentMethod(
            type: 'Visa',
            maskedNumber: '**** 4242',
            lastFourDigits: '4242',
            expiryDate: '12/28',
            cardholderName: 'John Doe',
            upiId: null,
            billingAddress: null,
            isDefault: true,
          )).called(1);
    });

    test('DeletePaymentMethod calls repository and emits success message', () async {
      when(() => mockRepository.deletePaymentMethod('pm_1'))
          .thenAnswer((_) async {});

      bloc.add(DeletePaymentMethod('pm_1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PaymentMethodsState>().having((s) => s.isSaving, 'isSaving', true),
          isA<PaymentMethodsState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.successMessage, 'successMessage', 'Payment method deleted'),
        ]),
      );

      verify(() => mockRepository.deletePaymentMethod('pm_1')).called(1);
    });
  });
}
