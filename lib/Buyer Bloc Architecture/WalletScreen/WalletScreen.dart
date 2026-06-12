import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../API Service/RazorpayApiService.dart';

/// **Wallet Events**
abstract class WalletEvent {}

class LoadWalletData extends WalletEvent {}

class AddFundsRequested extends WalletEvent {
  final double amount;
  AddFundsRequested(this.amount);
}

class PaymentSuccessEvent extends WalletEvent {}

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
      // மெசேஜ் இல்லாமல் டேட்டாவை மட்டும் புதுப்பிக்கிறது
      emit(state.copyWith(isLoading: false));
    });
    on<AddFundsRequested>((event, emit) {
      emit(
        state.copyWith(
          isLoading: true,
          pendingAmount: event.amount,
          successMessage: null,
          errorMessage: null,
        ),
      );
    });
    on<PaymentSuccessEvent>((event, emit) async {
      final amount = state.pendingAmount;
      if (amount != null && amount > 0) {
        try {
          // Firestore-ல் Wallet பேலன்ஸ் மற்றும் Transaction-ஐ அப்டேட் செய்கிறோம்
          await database.addTransaction(amount, "Wallet Top-up", true);
          emit(
            state.copyWith(
              isLoading: false,
              pendingAmount: null,
              successMessage: "Funds added successfully!",
              errorMessage: null,
            ),
          );
        } catch (e) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: "Failed to update wallet: $e",
            ),
          );
        }
      }
    });
    on<PaymentFailedEvent>((event, emit) {
      emit(
        state.copyWith(
          isLoading: false,
          pendingAmount: null,
          errorMessage: event.message,
        ),
      );
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
      create: (context) =>
          RazorpayApiService(), // Client-side orders create செய்யாததால் secret தேவையில்லை
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
    _loadInitialData();
    // RazorpayApiService மூலம் listeners-ஐ initialize செய்கிறோம்
    context.read<RazorpayApiService>().initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
    );
  }

  void _loadInitialData() {
    context.read<WalletBloc>().add(LoadWalletData());
  }

  @override
  void dispose() {
    context.read<RazorpayApiService>().dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    HapticFeedback.heavyImpact();
    context.read<WalletBloc>().add(PaymentSuccessEvent());
    _loadInitialData(); // பேலன்ஸ்-ஐ அப்டேட் செய்ய
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    context.read<WalletBloc>().add(
      PaymentFailedEvent(response.message ?? "Payment Failed"),
    );
  }

  void _startRazorpay(double amount) {
    final bloc = context.read<WalletBloc>();
    // Service மூலம் payment-ஐத் தொடங்குகிறோம்
    context.read<RazorpayApiService>().startPayment(
      amount: amount,
      email: bloc.database.currentUserEmail ?? '',
    );
  }

  bool _isBalanceVisible = true;
  double? _selectedAmount;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WalletBloc>();
    final db = bloc.database;

    return BlocListener<WalletBloc, WalletState>(
      listenWhen: (previous, current) {
        return previous.isLoading != current.isLoading ||
            previous.successMessage != current.successMessage ||
            previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        if (state.pendingAmount != null && state.isLoading) {
          _startRazorpay(state.pendingAmount!);
        }
        // இங்கே ஏற்கனவே listenWhen ஃபில்டர் செய்திருப்பதால், தேவையற்ற பாப்-அப்கள் வராது
        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          _showTopSnackBar(context, state.successMessage!, Colors.green);
        }
        if (state.errorMessage != null) {
          _showTopSnackBar(context, state.errorMessage!, Colors.red);
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFBFBFB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: Text(
              'Wallet',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async => _loadInitialData(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildBalanceCard(db),
                      const SizedBox(height: 30),
                      Text(
                        "Quick Top-up",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildQuickAmountSelection(context),
                      const SizedBox(height: 40),
                      _buildAddMoneyButton(),
                      const SizedBox(height: 40),
                      _buildTransactionList(db),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTopSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
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

        return AspectRatio(
          aspectRatio: 1.8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE52121), Color(0xFFFF5252)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE52121).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 32,
                        ),
                        IconButton(
                          icon: Icon(
                            _isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            setState(
                              () => _isBalanceVisible = !_isBalanceVisible,
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isBalanceVisible
                                ? '₹${balance.toStringAsFixed(2)}'
                                : '••••••',
                            key: ValueKey(_isBalanceVisible),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: _isBalanceVisible ? 0 : 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAmountSelection(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final List<int> amounts = [100, 200, 500, 1000, 2000];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: amounts.length,
        itemBuilder: (context, index) {
          final amount = amounts[index].toDouble();
          final isSelected = _selectedAmount == amount;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedAmount = amount);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : Colors.grey.withOpacity(0.2),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  '₹$amount',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddMoneyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ElevatedButton(
        onPressed: () {
          if (_selectedAmount != null) {
            context.read<WalletBloc>().add(AddFundsRequested(_selectedAmount!));
          } else {
            _showAddMoneyBottomSheet();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
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

  void _showAddMoneyBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Enter Amount",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE52121),
              ),
              decoration: InputDecoration(
                hintText: "₹ 0.00",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[300]),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Min: ₹10 | Max: ₹50,000",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                double? amt = double.tryParse(_amountController.text);
                if (amt != null && amt >= 10 && amt <= 50000) {
                  Navigator.pop(context);
                  this.context.read<WalletBloc>().add(AddFundsRequested(amt));
                  _amountController.clear();
                } else {
                  HapticFeedback.vibrate();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52121),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Proceed to Pay",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
