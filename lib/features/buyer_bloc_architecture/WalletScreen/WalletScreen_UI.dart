import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/widgets/responsive_layout.dart';
import 'package:food_delivery_app/core/widgets/transaction_history.dart';
import 'WalletScreen_Bloc.dart';
import 'WalletScreen_Event.dart';
import 'WalletScreen_State.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
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
            WalletBloc(WalletDatabase(authService: ctx.read<IAuthService>()), ctx.read<RazorpayApiService>()),
        child: const _WalletAuthGate(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AUTH GATE — Login check
// ─────────────────────────────────────────────

/// Listen to auth state via [IAuthService].
class _WalletAuthGate extends StatelessWidget {
  const _WalletAuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: context.read<IAuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: BuyerAppColors.primaryDeep),
            ),
          );
        }

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
          if (mounted) {
            setState(() => _selectedAmount = null);
          }
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
          if (mounted) {
            setState(() => _selectedAmount = null);
          }
          final isCancelled = response.code == Razorpay.PAYMENT_CANCELLED ||
              (response.message?.toLowerCase().contains('cancelled') ?? false);
          context.read<WalletBloc>().add(
            PaymentFailedEvent(
              response.message ?? "Payment Failed",
              userCancelled: isCancelled,
            ),
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
                color: Colors.red.withValues(alpha: 0.10),
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
                  backgroundColor: BuyerAppColors.primaryDeep,
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

        // Reset selected amount when payment completes or cancels
        if (state.paymentStatus == PaymentStatus.initial ||
            state.paymentStatus == PaymentStatus.failed ||
            state.paymentStatus == PaymentStatus.success) {
          setState(() => _selectedAmount = null);
        }

        // ── Start Razorpay Checkout ─────────────────────────────────────────
        if (state.paymentStatus == PaymentStatus.orderCreated) {
          context.read<RazorpayApiService>().startPayment(
            amount: state.pendingAmount ?? 0,
            email:
                context.read<WalletBloc>().database.authService.currentUserEmail ??
                'user@example.com',
            orderId: state.orderId,
            name: 'FoodGo Wallet',
            description: 'Wallet Top-up',
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
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => _loadInitialData(),
              child: BlocBuilder<WalletBloc, WalletState>(
                buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
                  return Stack(
                    children: [
                      // ── Main content ──────────────────────────────────────
                      if (ResponsiveHelper.isWide(context))
                        _buildWideLayout(context, state, db, size)
                      else
                        _buildMobileLayout(context, state, db, size),
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
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
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
                  color: BuyerAppColors.primaryDeep,
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
          const SizedBox(height: 32),
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
                const SizedBox(height: 32),
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
                  color: Colors.black.withValues(alpha: 0.02),
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
    return StreamBuilder<double?>(
      stream: db.getWalletBalanceStream(),
      builder: (context, snapshot) {
        double balance = snapshot.data ?? 0.0;

        return AspectRatio(
          aspectRatio: 1.8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BuyerAppColors.primaryDeep, Color(0xFFFF5252)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: BuyerAppColors.primaryDeep.withValues(alpha: 0.4),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: -15,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
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
                                ? '₹${balance.toStringAsFixed(0)}'
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
    const primaryColor = BuyerAppColors.primaryDeep;
    const List<int> amounts = [100, 200, 500];

    return Row(
      children: amounts.map((amt) {
        final amount = amt.toDouble();
        final isSelected = _selectedAmount == amount;
        final isProcessing = state.isCreatingOrder && state.pendingAmount == amount;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: state.isCreatingOrder
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_selectedAmount == amount) {
                          _selectedAmount = null;
                        } else {
                          _selectedAmount = amount;
                        }
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF0F0) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : Colors.grey.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
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
                                    ? primaryColor
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isSelected ? 'Selected' : 'Tap to Add',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? primaryColor
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

  // ── Add Money Button ─────────────────────────────────────────────────────

  Widget _buildAddMoneyButton(BuildContext context, WalletState state) {
    final hasSelection = _selectedAmount != null && _selectedAmount! > 0;
    final isProcessing = state.isCreatingOrder;

    return ElevatedButton(
      onPressed: isProcessing
          ? null
          : () {
              if (hasSelection) {
                HapticFeedback.mediumImpact();
                context.read<WalletBloc>().add(
                  InitiatePaymentRequested(_selectedAmount!),
                );
              } else {
                _showAddMoneyBottomSheet(context);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: BuyerAppColors.primaryDeep,
        disabledBackgroundColor: BuyerAppColors.primaryDeep.withValues(alpha: 0.6),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 2,
      ),
      child: isProcessing
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasSelection ? Icons.payment_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasSelection
                      ? 'Add ₹${_selectedAmount!.toInt()}'
                      : 'Add Money',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  // ── Add Money Bottom Sheet (custom amount) ───────────────────────────────

  void _showAddMoneyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _AddMoneyBottomSheetContent(
        onProceed: (amt) {
          setState(() => _selectedAmount = null);
          context.read<WalletBloc>().add(InitiatePaymentRequested(amt));
        },
      ),
    );
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
          color: isSelected ? BuyerAppColors.primaryDeep : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? BuyerAppColors.primaryDeep : Colors.grey.shade300,
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
                color: BuyerAppColors.primaryDeep.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Live',
                style: TextStyle(
                  fontSize: 11,
                  color: BuyerAppColors.primaryDeep,
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
        StreamBuilder<List<Map<String, dynamic>>>(
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

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyTransactions();
            }

            final allDocs = snapshot.data!;

            final docs = allDocs.where((data) {
              final double rawAmount = (data['amount'] as num?)?.toDouble() ?? 0.0;
              final bool isCredit = data['isCredit'] ?? (rawAmount >= 0 && data['type'] != 'order_payment');
              if (_selectedFilter == 'Credits') return isCredit;
              if (_selectedFilter == 'Debits') return !isCredit;
              return true;
            }).toList();

            double totalDebits = 0;
            double totalCredits = 0;
            for (var data in docs) {
              final double rawAmount = (data['amount'] as num?)?.toDouble() ?? 0.0;
              final bool isCredit = data['isCredit'] ?? (rawAmount >= 0 && data['type'] != 'order_payment');
              if (!isCredit) {
                totalDebits += rawAmount.abs();
              } else {
                totalCredits += rawAmount.abs();
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
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.2),
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
                            '+₹${totalCredits.toStringAsFixed(0)}',
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
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.2),
                        ),
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
                            '₹${totalDebits.toStringAsFixed(0)}',
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
                      final data = docs[index];
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
    return const TransactionEmptyState(
      title: 'No transactions yet',
      subtitle: 'Top-up your wallet to get started!',
    );
  }

  Widget _buildTransactionItem(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    return TransactionItemCard(
      data: data,
      onTap: () => showTransactionDetailSheet(context, data),
    );
  }
}

// ─────────────────────────────────────────────
// ADD MONEY BOTTOM SHEET CONTENT
// ─────────────────────────────────────────────

class _AddMoneyBottomSheetContent extends StatefulWidget {
  final ValueChanged<double> onProceed;

  const _AddMoneyBottomSheetContent({required this.onProceed});

  @override
  State<_AddMoneyBottomSheetContent> createState() =>
      _AddMoneyBottomSheetContentState();
}

class _AddMoneyBottomSheetContentState
    extends State<_AddMoneyBottomSheetContent> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
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
                  controller: _amountCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: BuyerAppColors.primaryDeep,
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
                  final double? amt = double.tryParse(_amountCtrl.text.trim());
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
                  Navigator.pop(context);
                  widget.onProceed(amt);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BuyerAppColors.primaryDeep,
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
    );
  }
}


