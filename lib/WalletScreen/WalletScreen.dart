import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_web/razorpay_web.dart';
import '../API Service/RazorpayApiService.dart';

/// **Wallet Events**
abstract class WalletEvent {}

class LoadWalletData extends WalletEvent {}

class AddFundsRequested extends WalletEvent {
  final double amount;
  AddFundsRequested(this.amount);
}

class PaymentFailedEvent extends WalletEvent {
  final String message;
  PaymentFailedEvent(this.message);
}

/// **Wallet State**
class WalletState {
  final bool isLoading;
  final double? pendingAmount;
  final String? successMessage;
  final String? errorMessage;

  WalletState({
    this.isLoading = false,
    this.pendingAmount,
    this.successMessage,
    this.errorMessage,
  });

  WalletState copyWith({
    bool? isLoading,
    double? pendingAmount,
    String? successMessage,
    String? errorMessage,
  }) {
    return WalletState(
      isLoading: isLoading ?? false,
      pendingAmount: pendingAmount,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

/// **Wallet BLoC**
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletDatabase database;
  WalletBloc(this.database) : super(WalletState()) {
    on<LoadWalletData>((event, emit) {
      emit(state.copyWith(successMessage: "Wallet Updated Successfully"));
    });
    on<AddFundsRequested>((event, emit) {
      emit(state.copyWith(isLoading: true, pendingAmount: event.amount));
    });
    on<PaymentFailedEvent>((event, emit) {
      emit(state.copyWith(errorMessage: event.message));
    });
  }
}

/// **Wallet Database Helper**
class WalletDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserEmail => _auth.currentUser?.email;
  String? get _uid => _auth.currentUser?.uid;

  Stream<DocumentSnapshot> getWalletStream() {
    return _firestore.collection('users').doc(_uid).snapshots();
  }

  Stream<QuerySnapshot> getTransactionsStream() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addTransaction(
    double amount,
    String title,
    bool isCredit,
  ) async {
    if (_uid == null) return;

    final userRef = _firestore.collection('users').doc(_uid);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      double currentBalance =
          (snapshot.data() as Map<String, dynamic>)['wallet']?.toDouble() ??
          0.0;

      transaction.update(userRef, {
        'wallet': isCredit ? currentBalance + amount : currentBalance - amount,
      });

      transaction.set(userRef.collection('transactions').doc(), {
        'amount': amount,
        'title': title,
        'isCredit': isCredit,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}

/// **WalletScreen**
/// Acts as the dependency injection layer providing the [WalletBloc]
/// down to the widget tree before rendering the view.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => RazorpayApiService(
        apiSecret:
            'rzp_test_secret_here', // பாதுகாப்பு காரணங்களுக்காக இதை கவனமாக கையாளவும்
      ),
      child: BlocProvider(
        create: (context) => WalletBloc(WalletDatabase()),
        child: const WalletView(),
      ),
    );
  }
}

/// **WalletView**
/// The visual presentation layer handling user interactions, Razorpay SDK lifecycle,
/// and rendering reactive UI elements based on state changes.
class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // RazorpayApiService மூலம் listeners-ஐ initialize செய்கிறோம்
    context.read<RazorpayApiService>().initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
    );
  }

  @override
  void dispose() {
    context.read<RazorpayApiService>().dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    context.read<WalletBloc>().add(LoadWalletData());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    context.read<WalletBloc>().add(
      PaymentFailedEvent(response.message ?? "Payment Failed"),
    );
  }

  void _startRazorpay(double amount) {
    final db = WalletDatabase();
    // Service மூலம் payment-ஐத் தொடங்குகிறோம்
    context.read<RazorpayApiService>().startPayment(
      amount: amount,
      email: db.currentUserEmail ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final db = WalletDatabase();

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state.pendingAmount != null && state.isLoading) {
          _startRazorpay(state.pendingAmount!);
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      'Wallet',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildBalanceCard(db),

                    const SizedBox(height: 30),

                    _buildQuickAmountSelection(context),

                    const SizedBox(height: 30),

                    _buildAddMoneyButton(),

                    const SizedBox(height: 30),

                    _buildTransactionList(db),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletDatabase db) {
    return StreamBuilder<DocumentSnapshot>(
      stream: db.getWalletStream(),
      builder: (context, snapshot) {
        double balance = 0.0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          balance = (data['wallet'] as num?)?.toDouble() ?? 0.0;
        }

        return Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFFE52121), // App Primary Color
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE52121).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 50,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Your Balance',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAmountSelection(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final List<int> amounts = [100, 200, 300];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: amounts.map((amount) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<WalletBloc>().add(
                  AddFundsRequested(amount.toDouble()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: primaryColor.withOpacity(0.7),
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                '+ ₹$amount',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddMoneyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => _showAddMoneyDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          minimumSize: const Size(double.infinity, 55),
          shape: const StadiumBorder(),
        ),
        child: Text(
          'Add Money',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹ ', hintText: '0.00'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {
              double? amt = double.tryParse(_amountController.text);

              if (amt != null && amt > 0) {
                Navigator.pop(context);

                this.context.read<WalletBloc>().add(AddFundsRequested(amt));

                _amountController.clear();
              }
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(WalletDatabase db) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 20),

          StreamBuilder<QuerySnapshot>(
            stream: db.getTransactionsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("No transactions yet"));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _buildTransactionItem(data);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> data) {
    final bool isCredit = data['isCredit'] ?? true;
    final Timestamp? ts = data['timestamp'];

    final String dateStr = ts != null
        ? "${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}"
        : "";

    final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCredit
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
              isCredit ? Icons.add : Icons.remove,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'Transaction',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
