import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'seller_payment_page_event.dart';
import 'seller_payment_page_state.dart';

class SellerPaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerPaymentRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentSellerId => _auth.currentUser?.uid;

  /// Real-time stream providing continuous reactive synchronization across all platforms
  Stream<PaymentData> streamPaymentData({String? sellerId}) {
    final uid = sellerId ?? currentSellerId;
    if (uid == null || uid.isEmpty) {
      return Stream.value(_emptyPaymentData());
    }

    final sellerDocStream = _firestore.collection('sellers').doc(uid).snapshots();
    final paymentDocStream = _firestore
        .collection('sellers')
        .doc(uid)
        .collection('payment')
        .doc('details')
        .snapshots();
    final ordersStream = _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: uid)
        .snapshots();
    final payoutsStream = _firestore
        .collection('payouts')
        .where('sellerId', isEqualTo: uid)
        .snapshots();

    return Rx.combineLatest4<
        DocumentSnapshot<Map<String, dynamic>>,
        DocumentSnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>,
        PaymentData>(
      sellerDocStream,
      paymentDocStream,
      ordersStream,
      payoutsStream,
      (sellerSnap, paymentSnap, ordersSnap, payoutsSnap) {
        return _calculatePaymentData(
          sellerSnap: sellerSnap,
          paymentSnap: paymentSnap,
          ordersDocs: ordersSnap.docs,
          payoutsDocs: payoutsSnap.docs,
        );
      },
    ).handleError((error) {
      return _emptyPaymentData();
    });
  }

  PaymentData _calculatePaymentData({
    required DocumentSnapshot<Map<String, dynamic>> sellerSnap,
    required DocumentSnapshot<Map<String, dynamic>> paymentSnap,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> ordersDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> payoutsDocs,
  }) {
    final sellerData = sellerSnap.data() ?? {};
    final paymentData = paymentSnap.data() ?? {};

    // 1. Available Wallet Balance
    final double walletBalance =
        (sellerData['walletBalance'] as num?)?.toDouble() ?? 0.0;

    // 2. Bank & UPI Details
    final bankDetails = BankAccountDetails(
      accountHolderName: paymentData['accountHolderName'] ??
          sellerData['accountHolderName'] ??
          '',
      accountNumber: paymentData['accountNumber'] ??
          sellerData['bankAccountNumber'] ??
          '',
      bankName: paymentData['bankName'] ?? sellerData['bankName'] ?? '',
      branchName: paymentData['branch'] ??
          paymentData['branchName'] ??
          sellerData['bankBranch'] ??
          '',
      ifscCode: paymentData['ifscCode'] ?? sellerData['ifscCode'] ?? '',
      accountType: paymentData['accountType'] ?? 'Current Account',
      upiId: paymentData['upiId'] ?? sellerData['upiId'] ?? '',
      swiftCode: paymentData['swiftCode'] ?? '',
      panNumber: paymentData['panNumber'] ?? sellerData['panNumber'] ?? '',
      verificationStatus: (paymentData['isVerified'] == true ||
              sellerData['isVerified'] == true)
          ? 'Verified'
          : 'Pending',
      isVerified: paymentData['isVerified'] == true ||
          sellerData['isVerified'] == true,
    );

    // 3. Time boundaries for today, week, month
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfThisWeek =
        startOfToday.subtract(Duration(days: now.weekday - 1));
    final startOfThisMonth = DateTime(now.year, now.month, 1);

    double totalRevenue = 0.0;
    double todayRevenue = 0.0;
    double weeklyRevenue = 0.0;
    double monthlyRevenue = 0.0;
    double orderRevenue = 0.0;
    double deliveryCharges = 0.0;
    double platformCommission = 0.0;
    double taxes = 0.0;
    double discounts = 0.0;
    double refunds = 0.0;

    final List<EarningsBreakdown> transactions = [];

    for (var doc in ordersDocs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final subtotal = (data['subtotal'] as num?)?.toDouble() ??
          (amount > 40 ? amount - 40 : amount);
      final deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      final platformFee = (data['platformFee'] as num?)?.toDouble() ??
          (amount * 0.05); // Standard 5% platform commission
      final taxAmount = (data['taxAmount'] as num?)?.toDouble() ??
          (amount * 0.05); // 5% GST
      final discountAmount =
          (data['discountAmount'] as num?)?.toDouble() ?? 0.0;
      final status = (data['status'] as String? ?? '').trim();
      final isPaidOrDelivered = status.toLowerCase() == 'delivered' ||
          status.toLowerCase() == 'completed' ||
          status.toLowerCase() == 'paid';
      final isRefunded = status.toLowerCase() == 'refunded' ||
          status.toLowerCase() == 'rejected' ||
          status.toLowerCase() == 'cancelled';

      final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now();

      final txnId = data['razorpayPaymentId'] as String? ??
          data['transactionId'] as String? ??
          'TXN-${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length).toUpperCase()}';

      // Items description summary
      String itemsSummary = '';
      if (data['items'] is List && (data['items'] as List).isNotEmpty) {
        final firstItem = (data['items'] as List).first;
        if (firstItem is Map) {
          itemsSummary = '${firstItem['name'] ?? 'Food Item'} x${firstItem['quantity'] ?? 1}';
          if ((data['items'] as List).length > 1) {
            itemsSummary += ' + ${(data['items'] as List).length - 1} more';
          }
        }
      }

      if (isPaidOrDelivered) {
        totalRevenue += amount;
        orderRevenue += subtotal;
        deliveryCharges += deliveryFee;
        platformCommission += platformFee;
        taxes += taxAmount;
        discounts += discountAmount;

        if (timestamp.isAfter(startOfToday) ||
            timestamp.isAtSameMomentAs(startOfToday)) {
          todayRevenue += amount;
        }
        if (timestamp.isAfter(startOfThisWeek) ||
            timestamp.isAtSameMomentAs(startOfThisWeek)) {
          weeklyRevenue += amount;
        }
        if (timestamp.isAfter(startOfThisMonth) ||
            timestamp.isAtSameMomentAs(startOfThisMonth)) {
          monthlyRevenue += amount;
        }
      } else if (isRefunded) {
        refunds += amount;
      }

      // Format human-friendly date string
      String dateStr = _formatRelativeDate(timestamp, now);

      final netOrderEarning = isRefunded
          ? -amount
          : (subtotal + deliveryFee - platformFee - taxAmount - discountAmount);

      transactions.add(EarningsBreakdown(
        orderId: 'Order #${doc.id.length > 6 ? doc.id.substring(0, 6).toUpperCase() : doc.id}',
        transactionId: txnId,
        amount: amount,
        itemSubtotal: subtotal,
        deliveryCharges: deliveryFee,
        platformCommission: platformFee,
        taxes: taxAmount,
        discounts: discountAmount,
        refundAmount: isRefunded ? amount : 0.0,
        netEarnings: netOrderEarning > 0 ? netOrderEarning : (isRefunded ? -amount : amount * 0.85),
        status: isRefunded ? 'Refund' : (isPaidOrDelivered ? 'Paid' : status),
        isRefund: isRefunded,
        date: dateStr,
        timestamp: timestamp,
        paymentMethod: data['paymentMethod'] as String? ?? 'Online',
        itemsSummary: itemsSummary,
      ));
    }

    // Sort transactions descending by date
    transactions.sort((a, b) {
      final aTime = a.timestamp ?? DateTime(2000);
      final bTime = b.timestamp ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });

    // 4. Process Payouts & Settlements
    double pendingSettlement = 0.0;
    double paidSettlement = 0.0;
    final List<PayoutRecord> payouts = [];

    for (var doc in payoutsDocs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final status = (data['status'] as String? ?? 'Paid').trim();
      final method = (data['method'] as String? ?? 'Bank Transfer').trim();
      final timestamp = (data['date'] as Timestamp?)?.toDate() ??
          (data['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.now();
      final utr = data['utrNumber'] as String? ??
          data['transactionId'] as String? ??
          'UTR-${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length).toUpperCase()}';

      if (status.toLowerCase() == 'pending' ||
          status.toLowerCase() == 'processing') {
        pendingSettlement += amount;
      } else if (status.toLowerCase() == 'paid' ||
          status.toLowerCase() == 'settled' ||
          status.toLowerCase() == 'completed') {
        paidSettlement += amount;
      }

      payouts.add(PayoutRecord(
        id: doc.id,
        utrNumber: utr,
        amount: amount,
        method: method,
        status: status,
        date: _formatRelativeDate(timestamp, now),
        timestamp: timestamp,
      ));
    }

    // Sort payouts descending
    payouts.sort((a, b) {
      final aTime = a.timestamp ?? DateTime(2000);
      final bTime = b.timestamp ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });

    // Net Earnings calculation
    final double netEarnings =
        (totalRevenue > 0) ? (totalRevenue - platformCommission - taxes - refunds) : 0.0;

    return PaymentData(
      walletBalance: walletBalance,
      totalRevenue: totalRevenue,
      todayRevenue: todayRevenue,
      weeklyRevenue: weeklyRevenue,
      monthlyRevenue: monthlyRevenue,
      orderRevenue: orderRevenue,
      deliveryCharges: deliveryCharges,
      platformCommission: platformCommission,
      taxes: taxes,
      discounts: discounts,
      refunds: refunds,
      netEarnings: netEarnings > 0 ? netEarnings : walletBalance,
      pendingSettlement: pendingSettlement > 0
          ? pendingSettlement
          : ((sellerData['pendingSettlement'] as num?)?.toDouble() ?? 0.0),
      paidSettlement: paidSettlement > 0
          ? paidSettlement
          : ((sellerData['paidSettlement'] as num?)?.toDouble() ?? 0.0),
      bankDetails: bankDetails,
      transactions: transactions,
      payouts: payouts,
    );
  }

  String _formatRelativeDate(DateTime timestamp, DateTime now) {
    final diff = now.difference(timestamp);
    if (diff.inHours < 24 && timestamp.day == now.day) {
      return 'Today, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 2) {
      return 'Yesterday, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    }
  }

  PaymentData _emptyPaymentData() {
    return const PaymentData(
      walletBalance: 0.0,
      totalRevenue: 0.0,
      todayRevenue: 0.0,
      weeklyRevenue: 0.0,
      monthlyRevenue: 0.0,
      orderRevenue: 0.0,
      deliveryCharges: 0.0,
      platformCommission: 0.0,
      taxes: 0.0,
      discounts: 0.0,
      refunds: 0.0,
      netEarnings: 0.0,
      pendingSettlement: 0.0,
      paidSettlement: 0.0,
      bankDetails: BankAccountDetails(
        accountHolderName: '',
        accountNumber: '',
        bankName: '',
        branchName: '',
        ifscCode: '',
        accountType: 'Current Account',
      ),
      transactions: [],
      payouts: [],
    );
  }

  /// Request instant payout withdrawal with atomic Firestore balance deduction
  Future<bool> requestPayout({
    required double amount,
    required String method,
    required String destination,
  }) async {
    final sellerId = currentSellerId;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final sellerRef = _firestore.collection('sellers').doc(sellerId);
        final sellerDoc = await transaction.get(sellerRef);

        if (!sellerDoc.exists) {
          throw Exception('Seller profile not found');
        }

        final currentBalance =
            (sellerDoc.data()!['walletBalance'] as num?)?.toDouble() ?? 0.0;

        if (currentBalance < amount) {
          throw Exception('Insufficient wallet balance');
        }

        final currentPending =
            (sellerDoc.data()!['pendingSettlement'] as num?)?.toDouble() ?? 0.0;

        // Deduct wallet balance and add to pending settlement
        transaction.update(sellerRef, {
          'walletBalance': currentBalance - amount,
          'pendingSettlement': currentPending + amount,
        });

        final utr = 'UTR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

        // 1. Create payout request document
        final requestRef = _firestore.collection('payout_requests').doc();
        transaction.set(requestRef, {
          'sellerId': sellerId,
          'amount': amount,
          'method': method,
          'destination': destination,
          'utrNumber': utr,
          'status': 'Pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 2. Create payout history entry
        final payoutRef = _firestore.collection('payouts').doc();
        transaction.set(payoutRef, {
          'sellerId': sellerId,
          'title': '$method Payout',
          'amount': amount,
          'method': method,
          'destination': destination,
          'utrNumber': utr,
          'status': 'Pending',
          'date': FieldValue.serverTimestamp(),
        });

        // 3. Create transaction log
        final txnRef = _firestore
            .collection('sellers')
            .doc(sellerId)
            .collection('transactions')
            .doc();
        transaction.set(txnRef, {
          'type': 'payout_debit',
          'amount': amount,
          'method': method,
          'utrNumber': utr,
          'balanceBefore': currentBalance,
          'balanceAfter': currentBalance - amount,
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      if (e.toString().contains('Insufficient wallet balance')) {
        rethrow;
      }
      return false;
    }
  }

  /// Update Bank and UPI Account details in real time
  Future<bool> updateBankAndUpiDetails({
    required BankAccountDetails details,
  }) async {
    final sellerId = currentSellerId;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      final batch = _firestore.batch();

      final paymentDocRef = _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('payment')
          .doc('details');
      batch.set(paymentDocRef, {
        'accountHolderName': details.accountHolderName,
        'accountNumber': details.accountNumber,
        'bankName': details.bankName,
        'branch': details.branchName,
        'branchName': details.branchName,
        'ifscCode': details.ifscCode,
        'accountType': details.accountType,
        'upiId': details.upiId,
        'swiftCode': details.swiftCode,
        'panNumber': details.panNumber,
        'isVerified': details.isVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final sellerDocRef = _firestore.collection('sellers').doc(sellerId);
      batch.update(sellerDocRef, {
        'accountHolderName': details.accountHolderName,
        'bankAccountNumber': details.accountNumber,
        'bankName': details.bankName,
        'bankBranch': details.branchName,
        'ifscCode': details.ifscCode,
        'upiId': details.upiId,
        'panNumber': details.panNumber,
      });

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// One-shot load data for offline / fallback scenarios
  Future<PaymentData> loadPaymentData({String? sellerId}) async {
    final uid = sellerId ?? currentSellerId;
    if (uid == null) {
      return _emptyPaymentData();
    }

    try {
      final sellerSnap = await _firestore.collection('sellers').doc(uid).get();
      final paymentSnap = await _firestore
          .collection('sellers')
          .doc(uid)
          .collection('payment')
          .doc('details')
          .get();
      final ordersSnap = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: uid)
          .get();
      final payoutsSnap = await _firestore
          .collection('payouts')
          .where('sellerId', isEqualTo: uid)
          .get();

      return _calculatePaymentData(
        sellerSnap: sellerSnap,
        paymentSnap: paymentSnap,
        ordersDocs: ordersSnap.docs,
        payoutsDocs: payoutsSnap.docs,
      );
    } catch (e) {
      return _emptyPaymentData();
    }
  }
}

class SellerPaymentPageBloc
    extends Bloc<SellerPaymentPageEvent, SellerPaymentPageState> {
  final SellerPaymentRepository repository;
  StreamSubscription<PaymentData>? _paymentDataSubscription;

  SellerPaymentPageBloc({required this.repository})
      : super(SellerPaymentPageInitial()) {
    on<LoadPaymentData>(_onLoadPaymentData);
    on<PaymentDataUpdated>(_onPaymentDataUpdated);
    on<ChangeTimeframeFilter>(_onChangeTimeframeFilter);
    on<SubmitPayoutRequest>(_onSubmitPayoutRequest);
    on<UpdateBankAndUpiDetails>(_onUpdateBankAndUpiDetails);
    on<RefreshPaymentData>(_onRefreshPaymentData);
  }

  Future<void> _onLoadPaymentData(
    LoadPaymentData event,
    Emitter<SellerPaymentPageState> emit,
  ) async {
    emit(SellerPaymentPageLoading());
    await _paymentDataSubscription?.cancel();

    try {
      // First emit quick fetch if available
      final initialData = await repository.loadPaymentData();
      if (!emit.isDone) {
        emit(SellerPaymentPageLoaded(initialData));
      }
    } catch (_) {}

    // Subscribe to real-time stream
    _paymentDataSubscription = repository.streamPaymentData().listen(
      (data) {
        add(PaymentDataUpdated(data));
      },
      onError: (error) {
        // Log or handle error gracefully
      },
    );
  }

  void _onPaymentDataUpdated(
    PaymentDataUpdated event,
    Emitter<SellerPaymentPageState> emit,
  ) {
    if (state is SellerPaymentPageLoaded) {
      final current = state as SellerPaymentPageLoaded;
      emit(current.copyWith(data: event.data));
    } else {
      emit(SellerPaymentPageLoaded(event.data));
    }
  }

  void _onChangeTimeframeFilter(
    ChangeTimeframeFilter event,
    Emitter<SellerPaymentPageState> emit,
  ) {
    if (state is SellerPaymentPageLoaded) {
      final current = state as SellerPaymentPageLoaded;
      emit(current.copyWith(selectedTimeframe: event.timeframe));
    }
  }

  Future<void> _onSubmitPayoutRequest(
    SubmitPayoutRequest event,
    Emitter<SellerPaymentPageState> emit,
  ) async {
    if (state is! SellerPaymentPageLoaded) return;
    final current = state as SellerPaymentPageLoaded;

    emit(current.copyWith(isPayoutSubmitting: true, errorMessage: null));

    try {
      final success = await repository.requestPayout(
        amount: event.amount,
        method: event.method,
        destination: event.destination,
      );

      if (success) {
        emit(current.copyWith(
          isPayoutSubmitting: false,
          payoutSuccessMessage: 'Payout request for ₹${event.amount.toStringAsFixed(0)} submitted successfully!',
        ));
      } else {
        emit(current.copyWith(
          isPayoutSubmitting: false,
          errorMessage: 'Failed to submit payout request. Please try again.',
        ));
      }
    } catch (e) {
      emit(current.copyWith(
        isPayoutSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> _onUpdateBankAndUpiDetails(
    UpdateBankAndUpiDetails event,
    Emitter<SellerPaymentPageState> emit,
  ) async {
    if (state is! SellerPaymentPageLoaded) return;
    final current = state as SellerPaymentPageLoaded;

    emit(current.copyWith(isUpdatingBankDetails: true, errorMessage: null));

    try {
      final success = await repository.updateBankAndUpiDetails(details: event.details);
      if (success) {
        emit(current.copyWith(
          isUpdatingBankDetails: false,
          bankUpdateSuccess: true,
        ));
      } else {
        emit(current.copyWith(
          isUpdatingBankDetails: false,
          errorMessage: 'Failed to update bank details. Please try again.',
        ));
      }
    } catch (e) {
      emit(current.copyWith(
        isUpdatingBankDetails: false,
        errorMessage: 'Error updating details: $e',
      ));
    }
  }

  Future<void> _onRefreshPaymentData(
    RefreshPaymentData event,
    Emitter<SellerPaymentPageState> emit,
  ) async {
    try {
      final data = await repository.loadPaymentData();
      if (state is SellerPaymentPageLoaded) {
        emit((state as SellerPaymentPageLoaded).copyWith(data: data));
      } else {
        emit(SellerPaymentPageLoaded(data));
      }
    } catch (e) {
      emit(SellerPaymentPageError('Failed to refresh data: $e'));
    }
  }

  @override
  Future<void> close() {
    _paymentDataSubscription?.cancel();
    return super.close();
  }
}
