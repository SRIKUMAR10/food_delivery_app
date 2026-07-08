import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_payment_page_event.dart';
import 'seller_payment_page_state.dart';

class SellerPaymentPageBloc
    extends Bloc<SellerPaymentPageEvent, SellerPaymentPageState> {
  SellerPaymentPageBloc() : super(SellerPaymentPageInitial()) {
    on<LoadPaymentData>(_onLoadPaymentData);
    on<RefreshPaymentData>(_onRefreshPaymentData);
  }

  Future<void> _onLoadPaymentData(
    LoadPaymentData event,
    Emitter<SellerPaymentPageState> emit,
  ) async {
    emit(SellerPaymentPageLoading());
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock Data matching the design
      final mockData = PaymentData(
        walletBalance: 12680.00,
        revenue: 4560.00,
        refunds: 1230.00,
        transactions: [
          const Transaction(
            orderId: 'Order #1025',
            amount: 780.00,
            status: 'Paid',
            isRefund: false,
            date: 'Today, 10:45 AM',
          ),
          const Transaction(
            orderId: 'Order #1024',
            amount: 660.00,
            status: 'Paid',
            isRefund: false,
            date: 'Today, 09:30 AM',
          ),
          const Transaction(
            orderId: 'Order #1023',
            amount: 450.00,
            status: 'Refund',
            isRefund: true,
            date: 'Yesterday, 04:15 PM',
          ),
        ],
      );

      emit(SellerPaymentPageLoaded(mockData));
    } catch (e) {
      emit(const SellerPaymentPageError('Failed to load payment data.'));
    }
  }

  Future<void> _onRefreshPaymentData(
    RefreshPaymentData event,
    Emitter<SellerPaymentPageState> emit,
  ) async {
    add(LoadPaymentData());
  }
}
