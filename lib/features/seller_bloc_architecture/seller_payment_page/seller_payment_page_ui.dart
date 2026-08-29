import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'seller_payment_page_bloc.dart';
import 'seller_payment_page_event.dart';
import 'seller_payment_page_state.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../repositories/seller_repository.dart';
import '../seller_app_bar_page/seller_app_bar_page_ui.dart';
import '../seller_auth_shared/onboarding_back_handler.dart';
import '../seller_auth_shared/seller_wizard_container.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';
import '../seller_ui_tokens.dart';

typedef SellerPaymentPageUI = SellerPaymentPage;

class SellerPaymentPage extends StatelessWidget {
  final bool isOnboardingFlow;
  const SellerPaymentPage({super.key, this.isOnboardingFlow = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerPaymentPageBloc(
        repository: SellerPaymentRepository(),
      )..add(const LoadPaymentData()),
      child: _SellerPaymentView(isOnboardingFlow: isOnboardingFlow),
    );
  }
}

class _SellerPaymentView extends StatefulWidget {
  final bool isOnboardingFlow;
  const _SellerPaymentView({this.isOnboardingFlow = false});

  @override
  State<_SellerPaymentView> createState() => _SellerPaymentViewState();
}

class _SellerPaymentViewState extends State<_SellerPaymentView> {
  bool _isAccountNumberMasked = true;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _formatCompactCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final horizontalPadding = SellerUiTokens.responsivePadding(size.width);

    return PopScope(
      canPop: !widget.isOnboardingFlow,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (widget.isOnboardingFlow) {
          await OnboardingBackHandler.handleBack(context, previousRoute: '/menuCategories');
        }
      },
      child: BlocConsumer<SellerPaymentPageBloc, SellerPaymentPageState>(
        listener: (context, state) {
          if (state is SellerPaymentPageLoaded) {
            if (state.payoutSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.payoutSuccessMessage!)),
                    ],
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
            if (state.bankUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Bank & UPI details updated successfully!'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.errorMessage!)),
                    ],
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (widget.isOnboardingFlow) {
            return SellerWizardContainer(
              stepIndex: 6,
              totalSteps: 8,
              stepBadge: 'Step 6 of 8 • Bank Account & Payouts',
              title: 'Bank Account & Payouts',
              subtitle: 'Verify bank account and IFSC details for automated payouts and settlement',
              onBack: () => OnboardingBackHandler.handleBack(context, previousRoute: '/menuCategories'),
              child: _buildStateContent(
                context,
                state,
                horizontalPadding,
                isDesktop,
                isTablet,
              ),
            );
          }

          return Scaffold(
            backgroundColor: SellerUiTokens.pageBackground,
            appBar: SellerAppBarPageUI(
              title: 'Payments',
              subtitle: 'Real-time revenue, settlements & earnings',
              showNotification: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _buildLiveSyncBadge(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
                  tooltip: 'Refresh Data',
                  onPressed: () {
                    context.read<SellerPaymentPageBloc>().add(const RefreshPaymentData());
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: () async {
                  context.read<SellerPaymentPageBloc>().add(const RefreshPaymentData());
                },
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: SellerUiTokens.maxWidthForm),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStateContent(
                        context,
                        state,
                        horizontalPadding,
                        isDesktop,
                        isTablet,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveSyncBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 6, height: 6),
          ),
          SizedBox(width: 5),
          Text(
            'LIVE SYNC',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF047857),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    SellerPaymentPageState state,
    double padding,
    bool isDesktop,
    bool isTablet,
  ) {
    if (state is SellerPaymentPageLoading) {
      return _buildSkeletonLoader(padding);
    } else if (state is SellerPaymentPageError) {
      return _buildErrorState(context, state.message, padding);
    } else if (state is SellerPaymentPageLoaded) {
      return _buildLoadedContent(
        context,
        state,
        padding,
        isDesktop,
        isTablet,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadedContent(
    BuildContext context,
    SellerPaymentPageLoaded state,
    double padding,
    bool isDesktop,
    bool isTablet,
  ) {
    final data = state.data;
    final timeframe = state.selectedTimeframe;

    // Filter displayed revenue based on timeframe
    double displayRevenue = data.totalRevenue;
    String revenuePeriodLabel = 'Total Revenue';
    if (timeframe == 'Today') {
      displayRevenue = data.todayRevenue;
      revenuePeriodLabel = "Today's Revenue";
    } else if (timeframe == 'Weekly') {
      displayRevenue = data.weeklyRevenue;
      revenuePeriodLabel = 'Weekly Revenue';
    } else if (timeframe == 'Monthly') {
      displayRevenue = data.monthlyRevenue;
      revenuePeriodLabel = 'Monthly Revenue';
    }

    return SingleChildScrollView(
      key: const ValueKey('loaded_state'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isOnboardingFlow) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.flag_outlined, color: Color(0xFF3B82F6), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Step 6 of 8 (Bank Account & Payouts)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E40AF)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // 1. Timeframe Filter Selector Chips
          _buildTimeframeFilter(context, state.selectedTimeframe),
          const SizedBox(height: 20),

          // 2. Hero Net Earnings & Wallet Overview Card
          _buildHeroEarningsCard(context, data, state),
          const SizedBox(height: 28),

          // 3. Section Title: Financial Breakdown (The 21 Dimensions)
          _buildSectionHeader(
            title: 'Financial Breakdown',
            subtitle: 'Itemized revenue, charges, commissions & taxes',
          ),
          const SizedBox(height: 14),

          // 4. Financial Metrics 8-Card Responsive Grid
          _buildFinancialMetricsGrid(
            data,
            displayRevenue,
            revenuePeriodLabel,
            isDesktop,
            isTablet,
          ),
          const SizedBox(height: 28),

          // 5. Section: Bank Account & UPI Details
          _buildSectionHeader(
            title: 'Bank & Payout Accounts',
            subtitle: 'Verified settlement destinations',
            actionText: 'Update Details',
            onActionTap: () => _showUpdateBankDetailsSheet(context, data.bankDetails),
          ),
          const SizedBox(height: 14),
          _buildBankAccountCard(context, data.bankDetails),
          const SizedBox(height: 28),

          // 6. Section: Payout History & Settlement Status
          _buildSectionHeader(
            title: 'Payout & Settlement History',
            subtitle: 'Track status and transaction IDs for disbursed funds',
          ),
          const SizedBox(height: 14),
          _buildPayoutHistoryList(context, data.payouts),
          const SizedBox(height: 28),

          // 7. Section: Recent Transactions & Order Earnings Breakdown
          _buildSectionHeader(
            title: 'Recent Order Earnings',
            subtitle: 'Tap any order to view detailed financial breakdown sheet',
          ),
          const SizedBox(height: 14),
          _buildTransactionsList(context, data.transactions),
          if (widget.isOnboardingFlow) ...[
            const SizedBox(height: 32),
            SellerWizardPrimaryButton(
              buttonKey: const ValueKey('complete_store_setup_launch_btn'),
              label: 'Save & Continue to Delivery & Audio Alerts',
              onPressed: () async {
                final repo = SellerRepository();
                final uid = repo.currentUser?.uid;
                if (uid != null && uid.isNotEmpty) {
                  try {
                    await repo.updateSellerData(uid, {
                      'isBankDetailsCompleted': true,
                    });
                  } catch (_) {}
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bank details saved! Moving to Step 7: Delivery & Audio Alerts.'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pushReplacementNamed(
                    context,
                    '/sellerLogisticsAlerts',
                    arguments: {
                      'isOnboardingFlow': true,
                      'sellerId': uid ?? '',
                    },
                  );
                }
              },
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTimeframeFilter(BuildContext context, String selectedTimeframe) {
    final periods = ['Today', 'Weekly', 'Monthly', 'All Time'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedTimeframe == period;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                context
                    .read<SellerPaymentPageBloc>()
                    .add(ChangeTimeframeFilter(period));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroEarningsCard(
    BuildContext context,
    PaymentData data,
    SellerPaymentPageLoaded state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF818CF8),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Available Wallet Balance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(data.walletBalance),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              // Net Earnings Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Net Earnings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCompactCurrency(data.netEarnings),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 16),

          // Settlement summary row
          Row(
            children: [
              Expanded(
                child: _buildSettlementMiniStat(
                  icon: Icons.hourglass_top_rounded,
                  iconColor: const Color(0xFFFBBF24),
                  label: 'Pending Settlement',
                  value: _formatCompactCurrency(data.pendingSettlement),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSettlementMiniStat(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF34D399),
                  label: 'Paid Settlement',
                  value: _formatCompactCurrency(data.paidSettlement),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRequestPayoutDialog(context, data),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Request Payout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(SellerUiTokens.primaryButtonHeight),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showUpdateBankDetailsSheet(context, data.bankDetails),
                  icon: const Icon(Icons.account_balance_rounded, size: 18),
                  label: const Text('Manage Bank / UPI'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    minimumSize: const Size.fromHeight(SellerUiTokens.primaryButtonHeight),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementMiniStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (actionText != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFinancialMetricsGrid(
    PaymentData data,
    double displayRevenue,
    String revenuePeriodLabel,
    bool isDesktop,
    bool isTablet,
  ) {
    final int crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    final cards = [
      _MetricCardItem(
        title: revenuePeriodLabel,
        amount: displayRevenue,
        subtitle: 'Gross sales',
        icon: Icons.trending_up_rounded,
        iconColor: const Color(0xFF3B82F6),
        bgColor: const Color(0xFFEFF6FF),
        borderColor: const Color(0xFFDBEAFE),
      ),
      _MetricCardItem(
        title: 'Order Revenue',
        amount: data.orderRevenue,
        subtitle: 'Food subtotal',
        icon: Icons.restaurant_rounded,
        iconColor: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
        borderColor: const Color(0xFFA7F3D0),
      ),
      _MetricCardItem(
        title: 'Delivery Charges',
        amount: data.deliveryCharges,
        subtitle: 'Collected fees',
        icon: Icons.delivery_dining_rounded,
        iconColor: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
        borderColor: const Color(0xFFDDD6FE),
      ),
      _MetricCardItem(
        title: 'Platform Commission',
        amount: data.platformCommission,
        subtitle: '5% service fee',
        icon: Icons.pie_chart_outline_rounded,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFDE68A),
      ),
      _MetricCardItem(
        title: 'Taxes (GST)',
        amount: data.taxes,
        subtitle: 'Govt. 5% GST',
        icon: Icons.receipt_rounded,
        iconColor: const Color(0xFF06B6D4),
        bgColor: const Color(0xFFECFEFF),
        borderColor: const Color(0xFFCFFAFE),
      ),
      _MetricCardItem(
        title: 'Discounts',
        amount: data.discounts,
        subtitle: 'Coupons applied',
        icon: Icons.local_offer_outlined,
        iconColor: const Color(0xFFEC4899),
        bgColor: const Color(0xFFFDF2F8),
        borderColor: const Color(0xFFFBCFE8),
      ),
      _MetricCardItem(
        title: 'Refunds',
        amount: data.refunds,
        subtitle: 'Cancelled/rejected',
        icon: Icons.replay_rounded,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFECACA),
      ),
      _MetricCardItem(
        title: 'Net Earnings',
        amount: data.netEarnings,
        subtitle: 'Realized profit',
        icon: Icons.verified_rounded,
        iconColor: const Color(0xFF059669),
        bgColor: const Color(0xFFD1FAE5),
        borderColor: const Color(0xFF6EE7B7),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: isDesktop ? 1.45 : (isTablet ? 1.35 : 1.25),
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final item = cards[index];
        return _buildMetricCard(item);
      },
    );
  }

  Widget _buildMetricCard(_MetricCardItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SellerUiTokens.radiusCard),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: item.borderColor),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 18),
              ),
              Text(
                item.subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatCompactCurrency(item.amount),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(BuildContext context, BankAccountDetails bank) {
    final maskedAccount = bank.accountNumber.length > 4
        ? '•••• •••• ${bank.accountNumber.substring(bank.accountNumber.length - 4)}'
        : (bank.accountNumber.isEmpty ? 'Not Provided' : bank.accountNumber);
    final displayedAccount = _isAccountNumberMasked ? maskedAccount : bank.accountNumber;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFF4F46E5),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.bankName.isNotEmpty ? bank.bankName : 'Primary Bank Account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        bank.accountType,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bank.isVerified
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: bank.isVerified
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      bank.isVerified ? Icons.verified_user : Icons.schedule,
                      size: 14,
                      color: bank.isVerified
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bank.verificationStatus,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: bank.isVerified
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),

          // Bank Account Details Rows
          _buildBankDetailItem(
            label: 'Account Holder',
            value: bank.accountHolderName.isNotEmpty
                ? bank.accountHolderName
                : 'Not Set',
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Number',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Row(
                children: [
                  Text(
                    displayedAccount,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: _isAccountNumberMasked ? 1.0 : 0.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isAccountNumberMasked = !_isAccountNumberMasked;
                      });
                    },
                    child: Icon(
                      _isAccountNumberMasked
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBankDetailItem(
            label: 'IFSC Code',
            value: bank.ifscCode.isNotEmpty ? bank.ifscCode : 'Not Set',
          ),
          if (bank.branchName.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildBankDetailItem(label: 'Branch', value: bank.branchName),
          ],
          if (bank.upiId.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildBankDetailItem(
              label: 'UPI ID',
              value: bank.upiId,
              valueColor: const Color(0xFF4F46E5),
              showCopyIcon: true,
            ),
          ],
          if (bank.panNumber.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildBankDetailItem(label: 'PAN Number', value: bank.panNumber),
          ],
        ],
      ),
    );
  }

  Widget _buildBankDetailItem({
    required String label,
    required String value,
    Color? valueColor,
    bool showCopyIcon = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF0F172A),
              ),
            ),
            if (showCopyIcon) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UPI ID copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPayoutHistoryList(
    BuildContext context,
    List<PayoutRecord> payouts,
  ) {
    if (payouts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: SellerUiTokens.cardShadow,
        ),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No payout records yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your withdrawal settlements will appear here',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: payouts.length > 5 ? 5 : payouts.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final payout = payouts[index];
          final isSettled = payout.status.toLowerCase() == 'paid' ||
              payout.status.toLowerCase() == 'settled';
          final isPending = payout.status.toLowerCase() == 'pending' ||
              payout.status.toLowerCase() == 'processing';

          Color statusBg = const Color(0xFFECFDF5);
          Color statusText = const Color(0xFF059669);
          if (isPending) {
            statusBg = const Color(0xFFFFFBEB);
            statusText = const Color(0xFFD97706);
          } else if (!isSettled) {
            statusBg = const Color(0xFFFEF2F2);
            statusText = const Color(0xFFDC2626);
          }

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSettled
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                payout.method.contains('UPI')
                    ? Icons.qr_code_2_rounded
                    : Icons.account_balance_rounded,
                color: isSettled
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
                size: 22,
              ),
            ),
            title: Text(
              payout.method,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            subtitle: Text(
              '${payout.utrNumber} • ${payout.date}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCompactCurrency(payout.amount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payout.status,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusText,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    List<EarningsBreakdown> transactions,
  ) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: SellerUiTokens.cardShadow,
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 54, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No recent orders yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time order revenues and breakdowns will appear here',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length > 15 ? 15 : transactions.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return InkWell(
            onTap: () => _showEarningsDetailsSheet(context, tx),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tx.isRefund
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tx.isRefund
                          ? Icons.replay_rounded
                          : Icons.shopping_bag_outlined,
                      color: tx.isRefund
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tx.orderId,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (tx.isRefund)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Refund',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tx.date} • ${tx.transactionId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${tx.isRefund ? '-' : '+'}${_formatCompactCurrency(tx.amount)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: tx.isRefund
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: Color(0xFF4F46E5),
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
      ),
    );
  }

  /// Interactive Earnings Details Modal displaying complete arithmetic breakdown
  void _showEarningsDetailsSheet(BuildContext context, EarningsBreakdown tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earnings Details',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.orderId} • ${tx.date}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Breakdown Container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildBreakdownRow('Item Subtotal (Gross Food)', '+${_formatCurrency(tx.itemSubtotal)}'),
                    const SizedBox(height: 10),
                    _buildBreakdownRow('Delivery Charges', '+${_formatCurrency(tx.deliveryCharges)}'),
                    const SizedBox(height: 10),
                    _buildBreakdownRow('Platform Commission (5%)', '-${_formatCurrency(tx.platformCommission)}', isDeduction: true),
                    const SizedBox(height: 10),
                    _buildBreakdownRow('Taxes & GST (5%)', '-${_formatCurrency(tx.taxes)}', isDeduction: true),
                    if (tx.discounts > 0) ...[
                      const SizedBox(height: 10),
                      _buildBreakdownRow('Discounts & Promotions', '-${_formatCurrency(tx.discounts)}', isDeduction: true),
                    ],
                    if (tx.isRefund) ...[
                      const SizedBox(height: 10),
                      _buildBreakdownRow('Refund Deducted', '-${_formatCurrency(tx.refundAmount)}', isDeduction: true),
                    ],
                    const Divider(color: Color(0xFFCBD5E1), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Credited Amount',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _formatCurrency(tx.netEarnings),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: tx.isRefund
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Transaction Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Reference ID',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                          Text(
                            tx.transactionId,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          size: 16, color: Color(0xFF3B82F6)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: tx.transactionId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction ID copied!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isDeduction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDeduction ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  /// Interactive Request Payout Dialog
  void _showRequestPayoutDialog(BuildContext context, PaymentData data) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: data.walletBalance > 1000
          ? '1000'
          : data.walletBalance.toStringAsFixed(0),
    );
    String selectedMethod = data.bankDetails.upiId.isNotEmpty ? 'UPI' : 'Bank Account';
    String destination = selectedMethod == 'UPI'
        ? data.bankDetails.upiId
        : data.bankDetails.accountNumber;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Request Instant Payout',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Available Balance: ${_formatCurrency(data.walletBalance)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Payout Method Selector
                      Text(
                        'Withdrawal Destination',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedMethod = 'Bank Account';
                                  destination = data.bankDetails.accountNumber;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: selectedMethod == 'Bank Account'
                                      ? const Color(0xFFEEF2FF)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedMethod == 'Bank Account'
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_rounded,
                                      size: 16,
                                      color: selectedMethod == 'Bank Account'
                                          ? const Color(0xFF4F46E5)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Bank Account',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: selectedMethod == 'Bank Account'
                                            ? const Color(0xFF4F46E5)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedMethod = 'UPI';
                                  destination = data.bankDetails.upiId;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: selectedMethod == 'UPI'
                                      ? const Color(0xFFEEF2FF)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedMethod == 'UPI'
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 16,
                                      color: selectedMethod == 'UPI'
                                          ? const Color(0xFF4F46E5)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'UPI VPA',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: selectedMethod == 'UPI'
                                            ? const Color(0xFF4F46E5)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Enter Amount Field
                      Text(
                        'Enter Withdrawal Amount',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF4F46E5),
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter amount';
                          }
                          final amt = double.tryParse(value);
                          if (amt == null || amt <= 0) {
                            return 'Enter a valid amount';
                          }
                          if (amt > data.walletBalance) {
                            return 'Amount exceeds wallet balance';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: SellerUiTokens.primaryButtonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final amt = double.parse(amountController.text);
                              Navigator.pop(sheetContext);
                              context.read<SellerPaymentPageBloc>().add(
                                    SubmitPayoutRequest(
                                      amount: amt,
                                      method: selectedMethod,
                                      destination: destination.isNotEmpty
                                          ? destination
                                          : 'Primary Account',
                                    ),
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Confirm & Withdraw',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Interactive Update Bank & UPI Details Bottom Sheet
  void _showUpdateBankDetailsSheet(
    BuildContext context,
    BankAccountDetails bank,
  ) {
    final formKey = GlobalKey<FormState>();
    final holderController =
        TextEditingController(text: bank.accountHolderName);
    final accountController =
        TextEditingController(text: bank.accountNumber);
    final bankNameController = TextEditingController(text: bank.bankName);
    final ifscController = TextEditingController(text: bank.ifscCode);
    final branchController = TextEditingController(text: bank.branchName);
    final upiController = TextEditingController(text: bank.upiId);
    final panController = TextEditingController(text: bank.panNumber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Manage Bank & UPI Accounts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Settlements are directly transferred to these verified credentials',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextInput(
                      controller: holderController,
                      label: 'Account Holder Name',
                      hint: 'e.g. John Doe',
                    ),
                    const SizedBox(height: 14),
                    _buildTextInput(
                      controller: bankNameController,
                      label: 'Bank Name',
                      hint: 'e.g. HDFC Bank',
                    ),
                    const SizedBox(height: 14),
                    _buildTextInput(
                      controller: accountController,
                      label: 'Account Number',
                      hint: 'e.g. 50100234567890',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _buildTextInput(
                      controller: ifscController,
                      label: 'IFSC Code',
                      hint: 'e.g. HDFC0001234',
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 14),
                    _buildTextInput(
                      controller: branchController,
                      label: 'Branch Name',
                      hint: 'e.g. T. Nagar, Chennai',
                    ),
                    const SizedBox(height: 14),
                    _buildTextInput(
                      controller: upiController,
                      label: 'UPI ID (VPA)',
                      hint: 'e.g. seller@okaxis',
                    ),
                    const SizedBox(height: 14),
                    _buildTextInput(
                      controller: panController,
                      label: 'PAN Number',
                      hint: 'e.g. ABCDE1234F',
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: SellerUiTokens.primaryButtonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final updated = bank.copyWith(
                              accountHolderName: holderController.text.trim(),
                              bankName: bankNameController.text.trim(),
                              accountNumber: accountController.text.trim(),
                              ifscCode: ifscController.text.trim(),
                              branchName: branchController.text.trim(),
                              upiId: upiController.text.trim(),
                              panNumber: panController.text.trim(),
                              isVerified: true,
                              verificationStatus: 'Verified',
                            );
                            Navigator.pop(sheetContext);
                            context.read<SellerPaymentPageBloc>().add(
                                  UpdateBankAndUpiDetails(updated),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Credentials',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4F46E5),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoader(double padding) {
    return SingleChildScrollView(
      key: const ValueKey('loading_state'),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 48, borderRadius: 14),
          const SizedBox(height: 20),
          const SkeletonBox(height: 220, borderRadius: 24),
          const SizedBox(height: 28),
          const SkeletonBox(width: 180, height: 24, borderRadius: 6),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.3,
            children: List.generate(
              4,
              (index) => const SkeletonBox(borderRadius: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    double padding,
  ) {
    return Center(
      key: const ValueKey('error_state'),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load payment data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<SellerPaymentPageBloc>()
                    .add(const LoadPaymentData());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(SellerUiTokens.primaryButtonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCardItem {
  final String title;
  final double amount;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;

  const _MetricCardItem({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
  });
}
