import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import '../FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';
import 'WalletScreen_Bloc.dart';
import 'WalletScreen_Event.dart';
import 'WalletScreen_State.dart';

// ─────────────────────────────────────────────
//  WALLET SCREEN UI (DI layer)
// ─────────────────────────────────────────────

/// Acts as the dependency injection layer providing the [WalletBloc].
class WalletScreen_UI extends StatelessWidget {
  const WalletScreen_UI({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => RazorpayApiService(),
      child: BlocProvider(
        create: (ctx) =>
            WalletBloc(WalletDatabase(), ctx.read<RazorpayApiService>()),
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
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE52121)),
            ),
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
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    // Initialize Razorpay listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RazorpayApiService>().initialize(
        onSuccess: (response) {
          final state = context.read<WalletBloc>().state;
          context.read<WalletBloc>().add(
            PaymentSuccessEvent(
              amount: state.pendingAmount ?? 0,
              paymentId: response.paymentId ?? '',
              orderId: response.orderId ?? state.orderId ?? '',
            ),
          );
        },
        onFailure: (response) {
          context.read<WalletBloc>().add(
            PaymentFailedEvent(response.message ?? "Payment Failed"),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    // Note: We cannot safely use context.read in dispose easily,
    // but Razorpay instance will be garbage collected or we can ignore it.
    // Ideally we clear listeners.
    super.dispose();
  }

  void _loadInitialData() {
    context.read<WalletBloc>().add(LoadWalletData());
  }

  // ── UI Helpers ───────────────────────────────────────────────────────────

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (color == Colors.green.shade600)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text('✅', style: TextStyle(fontSize: 16)),
              ),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorBottomSheet(
    BuildContext context,
    String error,
    bool canRetry,
    double? amount,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Retry button (shown only when canRetry is true and amount is known)
            if (canRetry && amount != null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  context.read<WalletBloc>().add(PaymentRetryRequested(amount));
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  'Retry Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE52121),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(sheetCtx);
                // Silently reset BLoC state.
                context.read<WalletBloc>().add(
                  PaymentFailedEvent('', userCancelled: true),
                );
                setState(() => _selectedAmount = null);
              },
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final db = context.read<WalletBloc>().database;

    return BlocListener<WalletBloc, WalletState>(
      listenWhen: (previous, current) =>
          previous.paymentStatus != current.paymentStatus ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (!mounted) return;

        // ── Start Razorpay Checkout ─────────────────────────────────────────
        if (state.paymentStatus == PaymentStatus.orderCreated) {
          context.read<RazorpayApiService>().startPayment(
            amount: state.pendingAmount ?? 0,
            email:
                context.read<WalletBloc>().database.currentUserEmail ??
                'user@example.com',
            orderId: state.orderId,
          );
        }

        // ── Show error bottom sheet ─────────────────────────────────────────
        if (state.paymentStatus == PaymentStatus.failed &&
            state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          _showErrorBottomSheet(
            context,
            state.errorMessage!,
            state.canRetry,
            state.pendingAmount,
          );
        }

        // ── Show success snackbar ───────────────────────────────────────────
        if (state.paymentStatus == PaymentStatus.success &&
            state.successMessage != null &&
            state.successMessage!.isNotEmpty) {
          setState(() => _selectedAmount = null);
          _showSnackBar(context, state.successMessage!, Colors.green.shade600);
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
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => _loadInitialData(),
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      // ── Main content ──────────────────────────────────────
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return _buildWideLayout(context, state, db, size);
                          } else {
                            return _buildMobileLayout(context, state, db, size);
                          }
                        },
                      ),
                      // ── Loading overlay (link fetch in progress) ──────────
                      if (state.paymentStatus == PaymentStatus.creatingOrder)
                        _buildLoadingOverlay(),
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

  // ── Loading Overlay ──────────────────────────────────────────────────────

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: Color(0xFFE52121),
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Preparing Payment…',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Fetching secure payment link',
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Layouts ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return const Row(
      children: [
        Text(
          'Wallet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WalletState state,
    WalletDatabase db,
    Size size,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildBalanceCard(db, size),
          const SizedBox(height: 30),
          Text(
            'Quick Top-up',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select amount and confirm to start payment',
            style: TextStyle(fontSize: 12, color: Colors.black45),
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

  Widget _buildWideLayout(
    BuildContext context,
    WalletState state,
    WalletDatabase db,
    Size size,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Balance and Top-up Options
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildBalanceCard(db, size),
                const SizedBox(height: 30),
                Text(
                  'Quick Top-up',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select amount and confirm to start payment',
                  style: TextStyle(fontSize: 12, color: Colors.black45),
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
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: _buildTransactionList(db),
            ),
          ),
        ),
      ],
    );
  }

  // ── Balance Card ─────────────────────────────────────────────────────────

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
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isBalanceVisible
                                ? '₹${balance.toStringAsFixed(2)}'
                                : '••••••',
                            key: ValueKey(_isBalanceVisible),
                            style: TextStyle(
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

  // ── Quick Amount Selection (100, 200, 500) ───────────────────────────────

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
                      context.read<WalletBloc>().add(
                        InitiatePaymentRequested(amount),
                      );
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              'Tap to Add',
                              style: TextStyle(
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

  // ── Add Money Button (custom amount) ─────────────────────────────────────

  Widget _buildAddMoneyButton(BuildContext context, WalletState state) {
    return ElevatedButton.icon(
      onPressed: state.isLoading
          ? null
          : () => _showAddMoneyBottomSheet(context),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Add Money',
        style: TextStyle(
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

  // ── Add Money Bottom Sheet (custom amount) ───────────────────────────────

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
                style: TextStyle(
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                    hintStyle: TextStyle(
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
                style: TextStyle(color: Colors.black38, fontSize: 12),
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
                          style: TextStyle(color: Colors.white),
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
                  if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  setState(() => _selectedAmount = amt);
                  context.read<WalletBloc>().add(InitiatePaymentRequested(amt));
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
                  style: TextStyle(
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

  // ── Transaction List ─────────────────────────────────────────────────────

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE52121) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE52121) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(WalletDatabase db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE52121).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Live',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFFE52121),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildFilterChip('All'),
            const SizedBox(width: 8),
            _buildFilterChip('Credits'),
            const SizedBox(width: 8),
            _buildFilterChip('Debits'),
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

            final allDocs = snapshot.data!.docs;

            final docs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final bool isCredit = data['isCredit'] ?? true;
              if (_selectedFilter == 'Credits') return isCredit;
              if (_selectedFilter == 'Debits') return !isCredit;
              return true;
            }).toList();

            double totalDebits = 0;
            double totalCredits = 0;
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final bool isCredit = data['isCredit'] ?? true;
              if (!isCredit) {
                totalDebits += (data['amount'] as num?)?.toDouble() ?? 0.0;
              } else {
                totalCredits += (data['amount'] as num?)?.toDouble() ?? 0.0;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (totalCredits > 0 &&
                    (_selectedFilter == 'Credits' || _selectedFilter == 'All'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Credits',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            '+₹${totalCredits.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (totalDebits > 0 &&
                    (_selectedFilter == 'Debits' || _selectedFilter == 'All'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Debits',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                          Text(
                            '₹${totalDebits.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (docs.isEmpty)
                  _buildEmptyTransactions()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _buildTransactionItem(data, context);
                    },
                  ),
              ],
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
              style: TextStyle(
                color: Colors.black38,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Top-up your wallet to get started!',
              style: TextStyle(color: Colors.black26, fontSize: 12),
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
    final bool isCredit = data['isCredit'] ?? true;
    final String title =
        data['title'] ?? (isCredit ? 'Wallet Top-up' : 'Wallet Payment');

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
                color: isCredit
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit
                    ? Icons.add_circle_outline_rounded
                    : Icons.remove_circle_outline_rounded,
                color: isCredit ? Colors.green : Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isCredit
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
    final bool isCredit = data['isCredit'] ?? true;
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
                color: isCredit
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: isCredit ? Colors.green : Colors.red,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _detailRow(
              'Amount',
              '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
              valueColor: isCredit
                  ? Colors.green.shade600
                  : Colors.red.shade600,
            ),
            _detailRow('Currency', currency),
            _detailRow(
              'Status',
              status,
              valueColor: isCredit
                  ? Colors.green.shade600
                  : (status == 'success' ? Colors.red.shade600 : Colors.orange),
            ),
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
                style: TextStyle(
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

  Widget _detailRow(
    String label,
    String value, {
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
              style: TextStyle(
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
              style: TextStyle(
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
