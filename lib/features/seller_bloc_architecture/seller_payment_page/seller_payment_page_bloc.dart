import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'seller_payment_page_event.dart';
import 'seller_payment_page_state.dart';

class SellerPaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<PaymentData> loadPaymentData() async {
    final sellerId = _auth.currentUser?.uid;
    BankAccountDetails bankDetails;

    if (sellerId != null) {
      final docRef = _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('payment')
          .doc('details');
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        bankDetails = BankAccountDetails(
          accountHolderName: data['accountHolderName'] ?? '',
          accountNumber: data['accountNumber'] ?? '',
          bankName: data['bankName'] ?? '',
          branchName: data['branch'] ?? '',
          ifscCode: data['ifscCode'] ?? '',
          accountType: data['accountType'] ?? 'Current Account',
          upiId: data['upiId'] ?? '',
          swiftCode: data['swiftCode'] ?? '',
          panNumber: data['panNumber'] ?? '',
          verificationStatus: data['isVerified'] == true ? 'Verified' : 'Pending',
        );
      } else {
        // Fallback for new sellers without payment details yet
        bankDetails = const BankAccountDetails(
          accountHolderName: 'FoodGo Restaurant Ltd',
          accountNumber: 'XXXX XXXX XXXX 4589',
          bankName: 'HDFC Bank',
          branchName: 'T Nagar, Chennai',
          ifscCode: 'HDFC0001234',
          accountType: 'Current Account',
          upiId: 'foodgo.restaurant@okhdfc',
          swiftCode: 'HDFCINBBAXX',
          panNumber: 'ABCDE1234F',
          verificationStatus: 'Verified',
        );
      }
    } else {
      throw Exception('User not logged in');
    }

    return PaymentData(
      walletBalance: 12680.00,
      revenue: 4560.00,
      refunds: 1230.00,
      transactions: const [
        Transaction(
          orderId: 'Order #1025',
          amount: 780.00,
          status: 'Paid',
          isRefund: false,
          date: 'Today, 10:45 AM',
        ),
        Transaction(
          orderId: 'Order #1024',
          amount: 660.00,
          status: 'Paid',
          isRefund: false,
          date: 'Today, 09:30 AM',
        ),
        Transaction(
          orderId: 'Order #1023',
          amount: 450.00,
          status: 'Refund',
          isRefund: true,
          date: 'Yesterday, 04:15 PM',
        ),
      ],
      bankDetails: bankDetails,
    );
  }
}

class SellerPaymentPageBloc
    extends Bloc<SellerPaymentPageEvent, SellerPaymentPageState> {
  final SellerPaymentRepository repository;

  SellerPaymentPageBloc({required this.repository}) : super(SellerPaymentPageInitial()) {
    on<LoadPaymentData>(_onLoadPaymentData);
    on<RefreshPaymentData>(_onRefreshPaymentData);
  }

  Future<void> _onLoadPaymentData(
    LoadPaymentData event,
    Emitter<SellerPaymentPageState> emit,
  ) async {
    emit(SellerPaymentPageLoading());
    try {
      final mockData = await repository.loadPaymentData();

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
