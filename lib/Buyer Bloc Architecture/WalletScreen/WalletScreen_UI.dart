import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../API Service/RazorpayApiService.dart';
import '../FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';
import 'WalletScreen_Bloc.dart';
import 'WalletScreen_Event.dart';
import 'WalletScreen_State.dart';

// ─────────────────────────────────────────────
//  WALLET SCREEN UI (DI layer)
// ─────────────────────────────────────────────

/// Acts as the dependency injection layer providing the [WalletBloc]
class WalletScreen_UI extends StatelessWidget {
  const WalletScreen_UI({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => RazorpayApiService(
        apiSecret: 'rzp_test_secret_here',
      ),
      child: BlocProvider(
        create: (context) => WalletBloc(WalletDatabase()),
        child: const _WalletAuthGate(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AUTH GATE — Login check
// ─────────────────────────────────────────────

/// Listen to Firebase Auth state.
/// If not logged in, returns [FoodGoLoginScreen];
/// If logged in, shows [WalletView].
class _WalletAuthGate extends StatelessWidget {
  const _WalletAuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Connection waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFE52121))),
          );
        }

        final user = snapshot.data;

        // Not logged in → Login page
        if (user == null) {
          return const FoodGoLoginScreenUI();
        }

        // Logged in → Wallet UI
        return const WalletView();
      },
    );
  }
}

// ─────────────────────────────────────────────
//  WALLET VIEW
// ─────────────────────────────────────────────

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  bool _isBalanceVisible = true;
  double? _selectedAmount;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    // Send paymentId to event
    context.read<WalletBloc>().add(
      PaymentSuccessEvent(response.paymentId ?? ''),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    context.read<WalletBloc>().add(
      PaymentFailedEvent(response.message ?? 'Payment Failed'),
    );
  }

  void _startRazorpay(double amount) {
    if (!mounted) return;
    final bloc = context.read<WalletBloc>();
    context.read<RazorpayApiService>().startPayment(
      amount: amount,
      email: bloc.database.currentUserEmail ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final db = context.read<WalletBloc>().database;

    return BlocListener<WalletBloc, WalletState>(
      listenWhen: (previous, current) {
        return (previous.isLoading != current.isLoading) ||
            previous.successMessage != current.successMessage ||
            previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        // Trigger Razorpay SDK
        if (state.isLoading && state.pendingAmount != null) {
          _startRazorpay(state.pendingAmount!);
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          _showSnackBar(context, state.successMessage!, Colors.green.shade600);
        }

        if (state.errorMessage != null) {
          _showSnackBar(context, state.errorMessage!, Colors.red.shade600);
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
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
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => _loadInitialData(),
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return _buildWideLayout(context, state, db, size);
                      } else {
                        return _buildMobileLayout(context, state, db, size);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Layouts ──────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, WalletState state, WalletDatabase db, Size size) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildBalanceCard(db, size),
          const SizedBox(height: 30),
          Text(
            'Quick Top-up',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select amount and confirm to start payment',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickAmountSelection(context, state),
          const SizedBox(height: 20),
          _buildAddMoneyButton(context, state),
          const SizedBox(height: 40),
          _buildTransactionList(db),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, WalletState state, WalletDatabase db, Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Balance and Top-up Options
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(db, size),
                const SizedBox(height: 30),
                Text(
                  'Quick Top-up',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select amount and confirm to start payment',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickAmountSelection(context, state),
                const SizedBox(height: 20),
                _buildAddMoneyButton(context, state),
              ],
            ),
          ),
        ),
        // Right Column: Transaction List
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.only(right: 20, bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: _buildTransactionList(db),
            ),
          ),
        ),
      ],
    );
  }

  // ── Snackbars ────────────────────────────────────────────

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Balance Card ─────────────────────────────────────────

  Widget _buildBalanceCard(WalletDatabase db, Size size) {
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
                Positioned(
                  right: 20,
                  bottom: -15,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withOpacity(0.07),
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
                            setState(() => _isBalanceVisible = !_isBalanceVisible);
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

  // ── Quick Amount Selection (100, 200, 500) ───────────────

  Widget _buildQuickAmountSelection(BuildContext context, WalletState state) {
    final primaryColor = Theme.of(context).primaryColor;
    const List<int> amounts = [100, 200, 500];

    return Row(
      children: amounts.map((amt) {
        final amount = amt.toDouble();
        final isSelected = _selectedAmount == amount;
        final isProcessing = state.isLoading && state.pendingAmount == amount;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: state.isLoading
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedAmount = amount);
                      _showConfirmDialog(context, amount);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : Colors.grey.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: isProcessing
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isSelected ? Colors.white : primaryColor,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹$amt',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Tap to Add',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Add Money Button (custom amount) ─────────────────────

  Widget _buildAddMoneyButton(BuildContext context, WalletState state) {
    return ElevatedButton.icon(
      onPressed: state.isLoading ? null : () => _showAddMoneyBottomSheet(context),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Add Money',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE52121),
        minimumSize: const Size(double.infinity, 58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 2,
      ),
    );
  }

  // ── Confirm Dialog ───────────────────────────────────────

  void _showConfirmDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE52121).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFFE52121),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Payment',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Wallet '),
                  TextSpan(
                    text: '₹${amount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const TextSpan(text: ' will be added.\nPayment will start via Razorpay.'),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedAmount = null);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WalletBloc>().add(AddFundsRequested(amount));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE52121),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: Text(
              'Pay ₹${amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Add Money Bottom Sheet (custom amount) ───────────────

  void _showAddMoneyBottomSheet(BuildContext context) {
    final TextEditingController amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
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
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enter Amount',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: amountCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE52121),
                  ),
                  decoration: InputDecoration(
                    hintText: '₹ 0',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade300,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Min: ₹10  |  Max: ₹50,000',
                style: GoogleFonts.poppins(
                  color: Colors.black38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  final double? amt = double.tryParse(amountCtrl.text.trim());
                  if (amt == null || amt < 10 || amt > 50000) {
                    HapticFeedback.vibrate();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter a valid amount between ₹10 and ₹50,000',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(sheetCtx);
                  setState(() => _selectedAmount = amt);
                  _showConfirmDialog(context, amt);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE52121),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Proceed',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() => amountCtrl.dispose());
  }

  // ── Transaction List ─────────────────────────────────────

  Widget _buildTransactionList(WalletDatabase db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE52121).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Live',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFFE52121),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: db.getTransactionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyTransactions();
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return _buildTransactionItem(data, context);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: GoogleFonts.poppins(
                color: Colors.black38,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Top-up your wallet to get started!',
              style: GoogleFonts.poppins(
                color: Colors.black26,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final String status = data['status'] ?? 'success';

    final Timestamp? ts =
        data['createdAt'] as Timestamp? ?? data['timestamp'] as Timestamp?;
    final String dateStr = ts != null ? _formatDate(ts.toDate()) : '';

    final bool isSuccess = status == 'success';

    return GestureDetector(
      onTap: () => _showTransactionDetail(context, data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.green,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Top-up',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      color: Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+₹${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSuccess ? Colors.green.shade700 : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$min $ampm';
  }

  void _showTransactionDetail(BuildContext context, Map<String, dynamic> data) {
    final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final String status = data['status'] ?? 'success';
    final String currency = data['currency'] ?? 'INR';
    final String paymentId = data['paymentId'] ?? data['title'] ?? 'N/A';
    final Timestamp? ts =
        data['createdAt'] as Timestamp? ?? data['timestamp'] as Timestamp?;
    final String dateStr = ts != null ? _formatDate(ts.toDate()) : 'N/A';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Transaction Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _detailRow('Amount', '₹${amount.toStringAsFixed(2)}',
                valueColor: Colors.green.shade600),
            _detailRow('Currency', currency),
            _detailRow('Status', status, valueColor: Colors.green.shade600),
            _detailRow('Payment ID', paymentId, isSmall: true),
            _detailRow('Date & Time', dateStr),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52121),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {
    Color? valueColor,
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
