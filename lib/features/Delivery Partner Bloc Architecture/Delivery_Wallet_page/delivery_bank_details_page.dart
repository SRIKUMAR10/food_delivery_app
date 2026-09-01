import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/bank_ifsc_service.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../../../core/widgets/delivery_withdraw_dialog.dart';
import '../Delivery_onboarding_verification_page/delivery_bank_ifsc_search_dialog.dart';
import 'Delivery_Wallet_page_bloc.dart';
import 'Delivery_Wallet_page_event.dart';
import 'Delivery_Wallet_page_repository.dart';
import 'Delivery_Wallet_page_service.dart';
import 'Delivery_Wallet_page_state.dart';

class DeliveryBankDetailsStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'pageTitle': 'Bank Details & Payouts',
      'tagline':
          'Manage your registered bank account, IFSC verification, instant UPI ID, and bank settlement history.',
      'primaryBank': 'Primary Payout Bank',
      'bankName': 'Bank Name',
      'accountHolder': 'Account Holder Name',
      'accountNumber': 'Account Number',
      'maskedAccountNumber': 'Masked Account',
      'ifscCode': 'IFSC Code',
      'branchName': 'Branch Name',
      'accountType': 'Account Type',
      'savingsAccount': 'Savings / Current Account',
      'verified': 'Verified',
      'verificationPending': 'Under Review',
      'notLinked': 'Not Linked',
      'upiPayout': 'Instant UPI Payout ID',
      'upiId': 'UPI ID',
      'copiedToClipboard': 'Copied to clipboard',
      'withdrawableBalance': 'Withdrawable Payout Balance',
      'availableForPayout': 'Available for instant bank transfer',
      'instantPayout': 'Instant Payout',
      'totalSettled': 'Total Settled to Bank',
      'totalTransferred': 'Lifetime Payout Transfers',
      'updateBank': 'Update Bank Account',
      'editDetails': 'Edit Details',
      'bankSecurityTitle': '256-bit Bank Grade Security',
      'bankSecuritySub':
          'Your bank details are encrypted and securely verified in compliance with RBI payout standards.',
      'payoutSchedule': 'Payout & Settlement Rules',
      'rule1': 'Daily auto-settlement processes at 07:00 AM IST.',
      'rule2': 'Instant on-demand payouts available 24/7 (min ₹100).',
      'rule3': 'Zero processing fee for all verified bank transfers.',
      'rule4': 'Settlement reference (UTR) is updated within 15 minutes.',
      'settlementHistory': 'Bank Payout & Settlement History',
      'searchSettlements': 'Search payouts by UTR / Reference...',
      'allPayouts': 'All Payouts',
      'settled': 'Settled',
      'processing': 'Processing',
      'scheduled': 'Scheduled',
      'noSettlementsFound': 'No bank payout records found',
      'showing': 'Showing {start}-{end} of {total}',
      'previous': 'Previous',
      'next': 'Next',
      'utrRef': 'UTR / Ref No',
      'transferDate': 'Transfer Date',
      'destination': 'Destination',
      'status': 'Status',
      'amount': 'Amount',
      'updateBankTitle': 'Update Bank Account Details',
      'updateBankSub':
          'Enter your registered bank account and IFSC. Instant verification will validate your branch.',
      'confirmAccountNumber': 'Confirm Account Number',
      'searchIfsc': 'Search IFSC / Branch',
      'saveBankDetails': 'Save Bank Details',
      'saving': 'Saving bank details...',
      'cancel': 'Cancel',
      'bankDetailsUpdated': 'Bank details updated successfully!',
      'accountMismatch': 'Account numbers do not match.',
      'enterValidIfsc': 'Please enter a valid 11-digit IFSC code.',
      'enterHolderName': 'Please enter the account holder name.',
      'enterAccountNumber': 'Please enter a valid account number.',
      'retry': 'Retry',
      'errorMessage': 'Failed to load bank details. Please try again.',
      'noBankLinkedPrompt':
          'No bank account linked yet. Tap "Update Bank Account" to link your payout account.',
    },
    'ta': {
      'pageTitle': 'வங்கி விவரங்கள் & தீர்வு அமைப்புகள்',
      'tagline':
          'உங்கள் பதிவுசெய்யப்பட்ட வங்கிக் கணக்கு, IFSC சரிபார்ப்பு, UPI ஐடி மற்றும் வங்கி பரிமாற்ற வரலாற்றை நிர்வகிக்கவும்.',
      'primaryBank': 'முதன்மை வங்கி கணக்கு',
      'bankName': 'வங்கி பெயர்',
      'accountHolder': 'கணக்கு வைத்திருப்பவர் பெயர்',
      'accountNumber': 'கணக்கு எண்',
      'maskedAccountNumber': 'மறைக்கப்பட்ட கணக்கு எண்',
      'ifscCode': 'IFSC குறியீடு',
      'branchName': 'கிளை பெயர்',
      'accountType': 'கணக்கு வகை',
      'savingsAccount': 'சேமிப்பு / நடப்புக் கணக்கு',
      'verified': 'சரிபார்க்கப்பட்டது',
      'verificationPending': 'மதிப்பாய்வில் உள்ளது',
      'notLinked': 'இணைக்கப்படவில்லை',
      'upiPayout': 'உடனடி UPI Payout ஐடி',
      'upiId': 'UPI ஐடி',
      'copiedToClipboard': 'கிளிப்போர்டில் நகலெடுக்கப்பட்டது',
      'withdrawableBalance': 'எடுக்கக்கூடிய Payout இருப்பு',
      'availableForPayout': 'உடனடி வங்கி பரிமாற்றத்திற்கு கிடைக்கிறது',
      'instantPayout': 'உடனடி Payout எடுக்க',
      'totalSettled': 'வங்கிக்கு மாற்றப்பட்ட மொத்த தொகை',
      'totalTransferred': 'மொத்த Payout பரிமாற்றங்கள்',
      'updateBank': 'வங்கி விவரங்களை மாற்று',
      'editDetails': 'விவரங்களை திருத்து',
      'bankSecurityTitle': 'வங்கி தரத்திலான 256-பிட் பாதுகாப்பு',
      'bankSecuritySub':
          'உங்கள் வங்கி விவரங்கள் RBI தரநிலைகளின்படி பாதுகாப்பாக குறியாக்கம் செய்யப்பட்டு சரிபார்க்கப்படுகின்றன.',
      'payoutSchedule': 'Payout & தீர்வு விதிகள்',
      'rule1': 'தினசரி தானியங்கி தீர்வு காலை 07:00 மணிக்கு நடைபெறும்.',
      'rule2': 'உடனடி Payout 24/7 கிடைக்கிறது (குறைந்தபட்சம் ₹100).',
      'rule3': 'அனைத்து வங்கி பரிமாற்றங்களுக்கும் கட்டணம் இல்லை (₹0 Fee).',
      'rule4': 'பரிமாற்ற குறிப்பு (UTR) 15 நிமிடங்களுக்குள் புதுப்பிக்கப்படும்.',
      'settlementHistory': 'வங்கி Payout மற்றும் தீர்வு வரலாறு',
      'searchSettlements': 'UTR / குறிப்பு எண்ணை வைத்து தேடுங்கள்...',
      'allPayouts': 'அனைத்து Payouts',
      'settled': 'தீர்க்கப்பட்டது',
      'processing': 'செயலாக்கத்தில்',
      'scheduled': 'திட்டமிடப்பட்டது',
      'noSettlementsFound': 'வங்கி Payout பதிவுகள் எதுவும் கிடைக்கவில்லை',
      'showing': '{start}-{end} / {total} காட்டுகிறது',
      'previous': 'முந்தையது',
      'next': 'அடுத்தது',
      'utrRef': 'UTR / குறிப்பு எண்',
      'transferDate': 'பரிமாற்ற தேதி',
      'destination': 'இலக்கு',
      'status': 'நிலை',
      'amount': 'தொகை',
      'updateBankTitle': 'வங்கி விவரங்களைப் புதுப்பிக்கவும்',
      'updateBankSub':
          'உங்கள் பதிவுசெய்யப்பட்ட வங்கிக் கணக்கு மற்றும் IFSC குறியீட்டை உள்ளிடவும்.',
      'confirmAccountNumber': 'கணக்கு எண்ணை உறுதிப்படுத்தவும்',
      'searchIfsc': 'IFSC / கிளையைத் தேடு',
      'saveBankDetails': 'வங்கி விவரங்களை சேமி',
      'saving': 'வங்கி விவரங்கள் சேமிக்கப்படுகிறது...',
      'cancel': 'ரத்து செய்',
      'bankDetailsUpdated': 'வங்கி விவரங்கள் வெற்றிகரமாக புதுப்பிக்கப்பட்டன!',
      'accountMismatch': 'கணக்கு எண்கள் பொருந்தவில்லை.',
      'enterValidIfsc': 'சரியான 11 இலக்க IFSC குறியீட்டை உள்ளிடவும்.',
      'enterHolderName': 'கணக்கு வைத்திருப்பவர் பெயரை உள்ளிடவும்.',
      'enterAccountNumber': 'சரியான கணக்கு எண்ணை உள்ளிடவும்.',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'errorMessage': 'வங்கி விவரங்களை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'noBankLinkedPrompt':
          'இதுவரை வங்கிக் கணக்கு இணைக்கப்படவில்லை. உங்கள் Payout கணக்கை இணைக்க "வங்கி விவரங்களை மாற்று" என்பதைத் தட்டவும்.',
    },
  };

  static String of(String key, String localeCode) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key] ?? key;
  }
}

class DeliveryBankDetailsPage extends StatelessWidget {
  final DeliveryWalletPageRepositoryBase? repository;
  final DeliveryWalletPageServiceBase? service;
  final DeliveryWalletPageBloc? bloc;

  const DeliveryBankDetailsPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryWalletPageBloc>.value(
        value: bloc!,
        child: const DeliveryBankDetailsPageView(),
      );
    }

    return BlocProvider<DeliveryWalletPageBloc>(
      create: (context) => DeliveryWalletPageBloc(
        repository: repository ?? DeliveryWalletPageRepository(),
        service: service ?? DeliveryWalletPageService(),
      )..add(const DeliveryWalletInitEvent()),
      child: const DeliveryBankDetailsPageView(),
    );
  }
}

class DeliveryBankDetailsPageView extends StatelessWidget {
  const DeliveryBankDetailsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryWalletPageBloc, DeliveryWalletPageState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null &&
          current.errorMessage!.isNotEmpty,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == DeliveryWalletStatus.initial ||
            state.status == DeliveryWalletStatus.loading) {
          return const _BankDetailsSkeleton();
        }

        if (state.status == DeliveryWalletStatus.error) {
          return _BankDetailsErrorShell(state: state);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

            final content = _BankDetailsContent(
              state: state,
              isDesktop: isDesktop,
              isTablet: isTablet,
            );

            return SingleChildScrollView(
              key: const Key('dp_bank_details_page'),
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: content,
            );
          },
        );
      },
    );
  }
}

class _BankDetailsContent extends StatefulWidget {
  final DeliveryWalletPageState state;
  final bool isDesktop;
  final bool isTablet;

  const _BankDetailsContent({
    required this.state,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  State<_BankDetailsContent> createState() => _BankDetailsContentState();
}

class _BankDetailsContentState extends State<_BankDetailsContent> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  int _currentPage = 1;
  static const int _pageSize = 5;

  List<DeliveryWalletTransaction> _getPayoutTransactions() {
    final allTx = widget.state.transactions;
    final payoutTx = allTx.where((t) {
      final isPayout = t.type == 'withdrawal' ||
          t.type == 'settlement' ||
          t.type == 'payout';
      return isPayout;
    }).toList();

    return payoutTx.where((t) {
      if (_selectedFilter == 'settled' &&
          t.status.toLowerCase() != 'completed' &&
          t.status.toLowerCase() != 'settled') {
        return false;
      }
      if (_selectedFilter == 'processing' &&
          t.status.toLowerCase() != 'processing' &&
          t.status.toLowerCase() != 'pending') {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchId = t.id.toLowerCase().contains(query);
        final matchDesc = (t.description ?? '').toLowerCase().contains(query);
        if (!matchTitle && !matchId && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  void _showUpdateBankModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UpdateBankDetailsSheet(
        currentBank: widget.state.bankAccount,
        currentUpi: widget.state.paymentMethods
            .where((pm) => pm.type == 'UPI')
            .map((pm) => pm.maskedIdentifier)
            .firstOrNull,
        localeCode: widget.state.localeCode,
        onSuccess: () {
          context.read<DeliveryWalletPageBloc>().add(const DeliveryWalletRefreshEvent());
        },
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final available = widget.state.withdrawableAmount;
    final lang = widget.state.localeCode;

    DeliveryWithdrawDialog.show(
      context,
      walletBalance: available,
      title: DeliveryBankDetailsStrings.of('instantPayout', lang),
      subtitle: DeliveryBankDetailsStrings.of('availableForPayout', lang),
      availableBalanceText:
          DeliveryBankDetailsStrings.of('withdrawableBalance', lang),
      confirmText: DeliveryBankDetailsStrings.of('instantPayout', lang),
      onConfirm: (amount) {
        context
            .read<DeliveryWalletPageBloc>()
            .add(DeliveryWalletWithdrawRequestedEvent(amount));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final lang = state.localeCode;
    final isDesktop = widget.isDesktop;
    final isTablet = widget.isTablet;

    final filteredPayouts = _getPayoutTransactions();
    final totalPayoutCount = filteredPayouts.length;
    final totalPages = (totalPayoutCount / _pageSize).ceil().clamp(1, 9999);
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalPayoutCount);
    final pagePayouts = totalPayoutCount > 0 && startIndex < totalPayoutCount
        ? filteredPayouts.sublist(startIndex, endIndex)
        : <DeliveryWalletTransaction>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BankDetailsHeader(
          state: state,
          isDesktop: isDesktop,
          onUpdatePressed: () => _showUpdateBankModal(context),
        ),
        const SizedBox(height: 20),
        _BankSummaryGrid(
          state: state,
          isDesktop: isDesktop,
          isTablet: isTablet,
          onInstantPayout: () => _showWithdrawDialog(context),
        ),
        const SizedBox(height: 20),
        if (state.status == DeliveryWalletStatus.refreshing) ...[
          const LinearProgressIndicator(
            minHeight: 2,
            color: DeliveryAppColors.primary,
            backgroundColor: Colors.white10,
          ),
          const SizedBox(height: 16),
        ],
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _PrimaryBankCard(
                      state: state,
                      onEditPressed: () => _showUpdateBankModal(context),
                    ),
                    const SizedBox(height: 20),
                    _BankSettlementsTableCard(
                      state: state,
                      payouts: pagePayouts,
                      totalCount: totalPayoutCount,
                      currentPage: _currentPage,
                      totalPages: totalPages,
                      startIndex: totalPayoutCount > 0 ? startIndex + 1 : 0,
                      endIndex: endIndex,
                      selectedFilter: _selectedFilter,
                      searchQuery: _searchQuery,
                      onFilterChanged: (f) => setState(() {
                        _selectedFilter = f;
                        _currentPage = 1;
                      }),
                      onSearchChanged: (q) => setState(() {
                        _searchQuery = q;
                        _currentPage = 1;
                      }),
                      onPageChanged: (p) => setState(() => _currentPage = p),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _InstantUpiCard(
                      state: state,
                      onEditPressed: () => _showUpdateBankModal(context),
                    ),
                    const SizedBox(height: 20),
                    _BankSecurityCard(localeCode: lang),
                    const SizedBox(height: 20),
                    _PayoutRulesCard(localeCode: lang),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _PrimaryBankCard(
            state: state,
            onEditPressed: () => _showUpdateBankModal(context),
          ),
          const SizedBox(height: 20),
          _InstantUpiCard(
            state: state,
            onEditPressed: () => _showUpdateBankModal(context),
          ),
          const SizedBox(height: 20),
          _BankSettlementsTableCard(
            state: state,
            payouts: pagePayouts,
            totalCount: totalPayoutCount,
            currentPage: _currentPage,
            totalPages: totalPages,
            startIndex: totalPayoutCount > 0 ? startIndex + 1 : 0,
            endIndex: endIndex,
            selectedFilter: _selectedFilter,
            searchQuery: _searchQuery,
            onFilterChanged: (f) => setState(() {
              _selectedFilter = f;
              _currentPage = 1;
            }),
            onSearchChanged: (q) => setState(() {
              _searchQuery = q;
              _currentPage = 1;
            }),
            onPageChanged: (p) => setState(() => _currentPage = p),
          ),
          const SizedBox(height: 20),
          _BankSecurityCard(localeCode: lang),
          const SizedBox(height: 20),
          _PayoutRulesCard(localeCode: lang),
        ],
      ],
    );
  }
}

class _BankDetailsHeader extends StatelessWidget {
  final DeliveryWalletPageState state;
  final bool isDesktop;
  final VoidCallback onUpdatePressed;

  const _BankDetailsHeader({
    required this.state,
    required this.isDesktop,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final isVerified = state.bankAccount?.isVerified ?? false;

    return Container(
      key: const Key('dp_bank_details_header'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DeliveryAppColors.background, DeliveryAppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DeliveryAppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DeliveryAppColors.primary, Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: DeliveryAppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.black,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      DeliveryBankDetailsStrings.of('pageTitle', lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? DeliveryAppColors.primary.withValues(alpha: 0.15)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isVerified
                              ? DeliveryAppColors.primary.withValues(alpha: 0.4)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified ? Icons.verified : Icons.hourglass_top,
                            size: 12,
                            color: isVerified
                                ? DeliveryAppColors.primary
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVerified
                                ? DeliveryBankDetailsStrings.of('verified', lang)
                                : DeliveryBankDetailsStrings.of(
                                    'verificationPending',
                                    lang,
                                  ),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isVerified
                                  ? DeliveryAppColors.primary
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DeliveryBankDetailsStrings.of('tagline', lang),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 16),
            ElevatedButton.icon(
              key: const Key('dp_bank_update_btn'),
              onPressed: onUpdatePressed,
              icon: const Icon(Icons.edit, size: 16, color: Colors.black),
              label: Text(
                DeliveryBankDetailsStrings.of('updateBank', lang),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BankSummaryGrid extends StatelessWidget {
  final DeliveryWalletPageState state;
  final bool isDesktop;
  final bool isTablet;
  final VoidCallback onInstantPayout;

  const _BankSummaryGrid({
    required this.state,
    required this.isDesktop,
    required this.isTablet,
    required this.onInstantPayout,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final bank = state.bankAccount;
    final upi = state.paymentMethods
        .where((p) => p.type == 'UPI')
        .map((p) => p.maskedIdentifier)
        .firstOrNull;

    final cards = [
      _BankMetricTile(
        title: DeliveryBankDetailsStrings.of('primaryBank', lang),
        value: bank?.bankName ?? DeliveryBankDetailsStrings.of('notLinked', lang),
        subtitle: bank?.maskedAccountNumber ?? '—',
        icon: Icons.account_balance,
        accentColor: const Color(0xFF10B981),
        trailingWidget: (bank?.isVerified ?? false)
            ? const Icon(Icons.verified, color: DeliveryAppColors.primary, size: 18)
            : null,
      ),
      _BankMetricTile(
        title: DeliveryBankDetailsStrings.of('upiPayout', lang),
        value: upi ?? '—',
        subtitle: upi != null ? 'Instant Payout Active' : 'Not configured',
        icon: Icons.qr_code_2,
        accentColor: const Color(0xFF38BDF8),
        trailingWidget: upi != null
            ? IconButton(
                icon: const Icon(Icons.copy, size: 16, color: Color(0xFF94A3B8)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: upi));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        DeliveryBankDetailsStrings.of('copiedToClipboard', lang),
                      ),
                      backgroundColor: DeliveryAppColors.surface,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Copy UPI',
              )
            : null,
      ),
      _BankMetricTile(
        title: DeliveryBankDetailsStrings.of('withdrawableBalance', lang),
        value: '₹${state.withdrawableAmount.toStringAsFixed(2)}',
        subtitle: DeliveryBankDetailsStrings.of('availableForPayout', lang),
        icon: Icons.account_balance_wallet,
        accentColor: const Color(0xFFF59E0B),
        actionButtonText: DeliveryBankDetailsStrings.of('instantPayout', lang),
        onActionTap: onInstantPayout,
      ),
      _BankMetricTile(
        title: DeliveryBankDetailsStrings.of('totalSettled', lang),
        value: '₹${state.totalWithdrawn.toStringAsFixed(2)}',
        subtitle: DeliveryBankDetailsStrings.of('totalTransferred', lang),
        icon: Icons.check_circle_outline,
        accentColor: const Color(0xFF818CF8),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          cards[i],
        ],
      ],
    );
  }
}

class _BankMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget? trailingWidget;
  final String? actionButtonText;
  final VoidCallback? onActionTap;

  const _BankMetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.trailingWidget,
    this.actionButtonText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailingWidget ??
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: accentColor),
                  ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actionButtonText != null && onActionTap != null)
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: DeliveryAppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: DeliveryAppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      actionButtonText!,
                      style: const TextStyle(
                        color: DeliveryAppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
}

class _PrimaryBankCard extends StatefulWidget {
  final DeliveryWalletPageState state;
  final VoidCallback onEditPressed;

  const _PrimaryBankCard({
    required this.state,
    required this.onEditPressed,
  });

  @override
  State<_PrimaryBankCard> createState() => _PrimaryBankCardState();
}

class _PrimaryBankCardState extends State<_PrimaryBankCard> {
  @override
  Widget build(BuildContext context) {
    final lang = widget.state.localeCode;
    final account = widget.state.bankAccount;

    return Container(
      key: const Key('dp_bank_primary_card'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F231D), Color(0xFF0B1713)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: DeliveryAppColors.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: DeliveryAppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: DeliveryAppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account?.bankName ??
                                DeliveryBankDetailsStrings.of('bankName', lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            DeliveryBankDetailsStrings.of('savingsAccount', lang),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (account?.isVerified ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: DeliveryAppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: DeliveryAppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DeliveryBankDetailsStrings.of('verified', lang),
                            style: const TextStyle(
                              color: DeliveryAppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.white70),
                    tooltip: DeliveryBankDetailsStrings.of('editDetails', lang),
                    onPressed: widget.onEditPressed,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (account == null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DeliveryBankDetailsStrings.of('noBankLinkedPrompt', lang),
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Bank Card Chip & Contactless Visual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.6),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.memory,
                      size: 20,
                      color: Color(0xFFFDE68A),
                    ),
                  ),
                ),
                const Icon(Icons.contactless, color: Colors.white38, size: 24),
              ],
            ),
            const SizedBox(height: 20),
            // Account Number with copy & toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.maskedAccountNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                  tooltip: 'Copy Account',
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: account.maskedAccountNumber),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          DeliveryBankDetailsStrings.of(
                            'copiedToClipboard',
                            lang,
                          ),
                        ),
                        backgroundColor: DeliveryAppColors.surface,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grid of Holder & IFSC
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DeliveryBankDetailsStrings.of('accountHolder', lang),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.accountHolder,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DeliveryBankDetailsStrings.of('ifscCode', lang),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.ifscCode,
                          style: const TextStyle(
                            color: DeliveryAppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InstantUpiCard extends StatelessWidget {
  final DeliveryWalletPageState state;
  final VoidCallback onEditPressed;

  const _InstantUpiCard({
    required this.state,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final upi = state.paymentMethods
        .where((p) => p.type == 'UPI')
        .map((p) => p.maskedIdentifier)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        color: Color(0xFF38BDF8),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DeliveryBankDetailsStrings.of('upiPayout', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 16, color: Colors.white60),
                onPressed: onEditPressed,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (upi == null)
            Text(
              DeliveryBankDetailsStrings.of('notLinked', lang),
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alternate_email, size: 16, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      upi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: upi));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            DeliveryBankDetailsStrings.of(
                              'copiedToClipboard',
                              lang,
                            ),
                          ),
                          backgroundColor: DeliveryAppColors.surface,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BankSettlementsTableCard extends StatelessWidget {
  final DeliveryWalletPageState state;
  final List<DeliveryWalletTransaction> payouts;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final int startIndex;
  final int endIndex;
  final String selectedFilter;
  final String searchQuery;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onPageChanged;

  const _BankSettlementsTableCard({
    required this.state,
    required this.payouts,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.startIndex,
    required this.endIndex,
    required this.selectedFilter,
    required this.searchQuery,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Container(
      key: const Key('dp_bank_settlements_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DeliveryBankDetailsStrings.of('settlementHistory', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalCount transfers',
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Box & Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1219),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.search,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                      hintText: DeliveryBankDetailsStrings.of(
                        'searchSettlements',
                        lang,
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              _FilterButton(
                label: DeliveryBankDetailsStrings.of('allPayouts', lang),
                isSelected: selectedFilter == 'all',
                onTap: () => onFilterChanged('all'),
              ),
              _FilterButton(
                label: DeliveryBankDetailsStrings.of('settled', lang),
                isSelected: selectedFilter == 'settled',
                onTap: () => onFilterChanged('settled'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (payouts.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 36,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DeliveryBankDetailsStrings.of('noSettlementsFound', lang),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payouts.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.05),
                height: 16,
              ),
              itemBuilder: (context, index) {
                final item = payouts[index];
                final isSettled =
                    item.status.toLowerCase() == 'completed' ||
                    item.status.toLowerCase() == 'settled';

                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSettled
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isSettled ? Icons.arrow_outward : Icons.hourglass_empty,
                        color: isSettled
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title.isNotEmpty
                                ? item.title
                                : 'Bank Transfer Settlement',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppDateFormatter.formatDisplayDateTime(item.date),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${item.amount.abs().toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSettled
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isSettled
                                ? DeliveryBankDetailsStrings.of('settled', lang)
                                : DeliveryBankDetailsStrings.of(
                                    'processing',
                                    lang,
                                  ),
                            style: TextStyle(
                              color: isSettled
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Pagination controls
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  DeliveryBankDetailsStrings.of('showing', lang)
                      .replaceAll('{start}', '$startIndex')
                      .replaceAll('{end}', '$endIndex')
                      .replaceAll('{total}', '$totalCount'),
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 18),
                      onPressed: currentPage > 1
                          ? () => onPageChanged(currentPage - 1)
                          : null,
                      color: Colors.white70,
                    ),
                    Text(
                      '$currentPage / $totalPages',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 18),
                      onPressed: currentPage < totalPages
                          ? () => onPageChanged(currentPage + 1)
                          : null,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DeliveryAppColors.primary.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? DeliveryAppColors.primary
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? DeliveryAppColors.primary : const Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BankSecurityCard extends StatelessWidget {
  final String localeCode;

  const _BankSecurityCard({required this.localeCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryBankDetailsStrings.of('bankSecurityTitle', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DeliveryBankDetailsStrings.of('bankSecuritySub', localeCode),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutRulesCard extends StatelessWidget {
  final String localeCode;

  const _PayoutRulesCard({required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final rules = [
      DeliveryBankDetailsStrings.of('rule1', localeCode),
      DeliveryBankDetailsStrings.of('rule2', localeCode),
      DeliveryBankDetailsStrings.of('rule3', localeCode),
      DeliveryBankDetailsStrings.of('rule4', localeCode),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryBankDetailsStrings.of('payoutSchedule', localeCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final r in rules) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: DeliveryAppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpdateBankDetailsSheet extends StatefulWidget {
  final DeliveryBankAccount? currentBank;
  final String? currentUpi;
  final String localeCode;
  final VoidCallback onSuccess;

  const _UpdateBankDetailsSheet({
    this.currentBank,
    this.currentUpi,
    required this.localeCode,
    required this.onSuccess,
  });

  @override
  State<_UpdateBankDetailsSheet> createState() => _UpdateBankDetailsSheetState();
}

class _UpdateBankDetailsSheetState extends State<_UpdateBankDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _holderController;
  late final TextEditingController _accNumController;
  late final TextEditingController _confirmAccController;
  late final TextEditingController _ifscController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _upiController;

  bool _isSaving = false;
  String? _ifscBranchHint;

  @override
  void initState() {
    super.initState();
    final bank = widget.currentBank;
    _holderController = TextEditingController(text: bank?.accountHolder ?? '');
    _accNumController = TextEditingController(
      text: bank?.maskedAccountNumber.replaceAll(RegExp(r'[^\d]'), '') ?? '',
    );
    _confirmAccController = TextEditingController(
      text: bank?.maskedAccountNumber.replaceAll(RegExp(r'[^\d]'), '') ?? '',
    );
    _ifscController = TextEditingController(text: bank?.ifscCode ?? '');
    _bankNameController = TextEditingController(text: bank?.bankName ?? '');
    _upiController = TextEditingController(text: widget.currentUpi ?? '');

    if (bank?.ifscCode.isNotEmpty ?? false) {
      _lookupIfsc(bank!.ifscCode);
    }
  }

  @override
  void dispose() {
    _holderController.dispose();
    _accNumController.dispose();
    _confirmAccController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _lookupIfsc(String code) async {
    final info = await BankIfscService.instance.lookupIfsc(code);
    if (mounted && info != null) {
      setState(() {
        _bankNameController.text = info.bankName;
        _ifscBranchHint = '${info.bankName} - ${info.branch}, ${info.city}';
      });
    }
  }

  Future<void> _openIfscSearchDialog() async {
    final selected = await DeliveryBankIfscSearchDialog.show(
      context: context,
      initialQuery: _ifscController.text,
    );
    if (selected != null && mounted) {
      setState(() {
        _ifscController.text = selected.ifsc;
        _bankNameController.text = selected.bankName;
        _ifscBranchHint =
            '${selected.bankName} - ${selected.branch}, ${selected.city}';
      });
    }
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;
    if (_accNumController.text.trim() != _confirmAccController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DeliveryBankDetailsStrings.of(
              'accountMismatch',
              widget.localeCode,
            ),
          ),
          backgroundColor: DeliveryAppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final firestore = FirebaseFirestore.instance;
        final payload = {
          'bankAccountNumber': _accNumController.text.trim(),
          'ifscCode': _ifscController.text.trim().toUpperCase(),
          'bankName': _bankNameController.text.trim().isNotEmpty
              ? _bankNameController.text.trim()
              : 'Bank Account',
          'accountHolderName': _holderController.text.trim(),
          'upiId': _upiController.text.trim(),
          'isVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        final batch = firestore.batch();
        final bankRef = firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('bank_details')
            .doc('payout_account');
        batch.set(bankRef, payload, SetOptions(merge: true));

        final partnerRef = firestore.collection('delivery_partners').doc(uid);
        batch.set(partnerRef, payload, SetOptions(merge: true));

        await batch.commit();

        if (mounted) {
          widget.onSuccess();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                DeliveryBankDetailsStrings.of(
                  'bankDetailsUpdated',
                  widget.localeCode,
                ),
              ),
              backgroundColor: DeliveryAppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save bank details: $e'),
            backgroundColor: DeliveryAppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.localeCode;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: DeliveryAppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DeliveryBankDetailsStrings.of('updateBankTitle', lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                DeliveryBankDetailsStrings.of('updateBankSub', lang),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 20),
              // Holder Name
              TextFormField(
                controller: _holderController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText:
                      DeliveryBankDetailsStrings.of('accountHolder', lang),
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: DeliveryAppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? DeliveryBankDetailsStrings.of('enterHolderName', lang)
                    : null,
              ),
              const SizedBox(height: 14),
              // Account Number
              TextFormField(
                controller: _accNumController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText:
                      DeliveryBankDetailsStrings.of('accountNumber', lang),
                  prefixIcon: const Icon(Icons.credit_card),
                  filled: true,
                  fillColor: DeliveryAppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => (val == null || val.trim().length < 6)
                    ? DeliveryBankDetailsStrings.of(
                        'enterAccountNumber',
                        lang,
                      )
                    : null,
              ),
              const SizedBox(height: 14),
              // Confirm Account Number
              TextFormField(
                controller: _confirmAccController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: DeliveryBankDetailsStrings.of(
                    'confirmAccountNumber',
                    lang,
                  ),
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  filled: true,
                  fillColor: DeliveryAppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? DeliveryBankDetailsStrings.of(
                        'enterAccountNumber',
                        lang,
                      )
                    : null,
              ),
              const SizedBox(height: 14),
              // IFSC Code & Search
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ifscController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        if (val.trim().length == 11) {
                          _lookupIfsc(val.trim());
                        }
                      },
                      decoration: InputDecoration(
                        labelText:
                            DeliveryBankDetailsStrings.of('ifscCode', lang),
                        prefixIcon: const Icon(Icons.business),
                        filled: true,
                        fillColor: DeliveryAppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) => (val == null ||
                              !BankIfscService.isValidIfscFormat(val.trim()))
                          ? DeliveryBankDetailsStrings.of(
                              'enterValidIfsc',
                              lang,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openIfscSearchDialog,
                    icon: const Icon(Icons.search, size: 16),
                    label: Text(
                      DeliveryBankDetailsStrings.of('searchIfsc', lang),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DeliveryAppColors.surface,
                      foregroundColor: DeliveryAppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: DeliveryAppColors.primary),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              if (_ifscBranchHint != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _ifscBranchHint!,
                    style: const TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              // UPI ID
              TextFormField(
                controller: _upiController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: DeliveryBankDetailsStrings.of('upiId', lang),
                  prefixIcon: const Icon(Icons.alternate_email),
                  filled: true,
                  fillColor: DeliveryAppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('dp_bank_save_submit_btn'),
                  onPressed: _isSaving ? null : _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DeliveryAppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          DeliveryBankDetailsStrings.of(
                            'saveBankDetails',
                            lang,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
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

class _BankDetailsSkeleton extends StatelessWidget {
  const _BankDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DeliveryAppColors.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankDetailsErrorShell extends StatelessWidget {
  final DeliveryWalletPageState state;

  const _BankDetailsErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: DeliveryAppColors.error),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ??
                  DeliveryBankDetailsStrings.of('errorMessage', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context
                    .read<DeliveryWalletPageBloc>()
                    .add(const DeliveryWalletInitEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: Colors.black,
              ),
              child: Text(DeliveryBankDetailsStrings.of('retry', lang)),
            ),
          ],
        ),
      ),
    );
  }
}
