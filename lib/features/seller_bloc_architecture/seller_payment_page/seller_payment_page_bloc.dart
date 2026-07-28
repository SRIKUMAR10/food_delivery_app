import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'seller_payment_page_event.dart';
import 'seller_payment_page_state.dart';

class SellerPaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerPaymentRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<PaymentData> loadPaymentData() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    BankAccountDetails bankDetails;
    double walletBalance = 0.0;
    double revenue = 0.0;
    double refunds = 0.0;

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
      bankDetails = const BankAccountDetails(
        accountHolderName: '',
        accountNumber: '',
        bankName: '',
        branchName: '',
        ifscCode: '',
        accountType: 'Current Account',
      );
    }

    final sellerDoc = await _firestore.collection('sellers').doc(sellerId).get();
    if (sellerDoc.exists) {
      final sellerData = sellerDoc.data()!;
      walletBalance = (sellerData['walletBalance'] as num?)?.toDouble() ?? 0.0;
    }

    final ordersSnapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    final List<Transaction> transactions = [];
    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final status = data['status'] as String? ?? '';
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

      if (status == 'Delivered' || status == 'Completed') {
        revenue += amount;
      } else if (status == 'Refunded' || status == 'Rejected') {
        refunds += amount;
      }

      String dateStr = '';
      if (timestamp != null) {
        final now = DateTime.now();
        final diff = now.difference(timestamp);
        if (diff.inHours < 24) {
          dateStr = 'Today, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
        } else if (diff.inDays < 2) {
          dateStr = 'Yesterday, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
        } else {
          dateStr = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
        }
      }

      transactions.add(Transaction(
        orderId: 'Order #${doc.id.length > 5 ? doc.id.substring(0, 5) : doc.id}',
        amount: amount,
        status: (status == 'Refunded' || status == 'Rejected') ? 'Refund' : 'Paid',
        isRefund: status == 'Refunded' || status == 'Rejected',
        date: dateStr,
      ));
    }

    transactions.sort((a, b) => b.date.compareTo(a.date));

    return PaymentData(
      walletBalance: walletBalance,
      revenue: revenue,
      refunds: refunds,
      transactions: transactions.take(20).toList(),
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
      final data = await repository.loadPaymentData();
      emit(SellerPaymentPageLoaded(data));
    } catch (e) {
      emit(SellerPaymentPageError('Failed to load payment data.'));
    }
  }

  Future<void> _onRefreshPaymentData(
    RefreshPaymentData event,
    Emitter<SellerPaymentPageState> emit,
  ) async {
    add(LoadPaymentData());
  }
}
