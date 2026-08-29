import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../repositories/seller_request_payout_repository.dart';
import '../../../api_service/seller_request_payout_service.dart';
import 'seller_request_payout_page__bloc.dart';
import 'seller_request_payout_page__event.dart';
import 'seller_request_payout_page__state.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../seller_app_bar_page/seller_app_bar_page_ui.dart';
import '../seller_ui_tokens.dart';

class SellerRequestPayoutPage extends StatelessWidget {
  const SellerRequestPayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerRequestPayoutBloc(
        repository: SellerRequestPayoutRepository(
          service: SellerRequestPayoutService(),
        ),
      )..add(const LoadPayoutDetails()),
      child: const SellerRequestPayoutView(),
    );
  }
}

class SellerRequestPayoutView extends StatefulWidget {
  const SellerRequestPayoutView({super.key});

  @override
  State<SellerRequestPayoutView> createState() =>
      _SellerRequestPayoutViewState();
}

class _SellerRequestPayoutViewState extends State<SellerRequestPayoutView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _upiController;
  String? _selectedBank;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '5000');
    _upiController = TextEditingController(text: 'seller@upi');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount, BuildContext context) {
    final Locale currentLocale = Localizations.localeOf(context);
    final format = NumberFormat.simpleCurrency(
      locale: currentLocale.toString(),
      name: 'INR',
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SellerUiTokens.pageBackground,
      appBar: const SellerAppBarPageUI(
        title: 'Request Payout',
        showNotification: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = SellerUiTokens.responsivePadding(
              constraints.maxWidth,
            );
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: SellerUiTokens.maxWidthForm,
                ),
                child: BlocConsumer<SellerRequestPayoutBloc,
                    SellerRequestPayoutState>(
                  listener: (context, state) {
                    if (state is SellerRequestPayoutLoaded) {
                      if (state.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Payout request submitted successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage!),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildContentForState(
                        context,
                        state,
                        horizontalPadding,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentForState(
    BuildContext context,
    SellerRequestPayoutState state,
    double horizontalPadding,
  ) {
    if (state is SellerRequestPayoutLoading) {
      return _buildSkeletonLoader(horizontalPadding);
    } else if (state is SellerRequestPayoutError) {
      return _buildErrorState(context, state.message, horizontalPadding);
    } else if (state is SellerRequestPayoutLoaded) {
      if (_selectedBank == null && state.bankAccounts.isNotEmpty) {
        _selectedBank = state.bankAccounts.first;
      }
      return _buildFormContent(context, state, horizontalPadding);
    }
    return const SizedBox.shrink();
  }

  Widget _buildFormContent(
    BuildContext context,
    SellerRequestPayoutLoaded state,
    double horizontalPadding,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Withdraw funds to your account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Available Balance Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    decoration: BoxDecoration(
                      color: SellerUiTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(SellerUiTokens.radiusCard),
                      border: Border.all(color: SellerUiTokens.borderSubtle),
                      boxShadow: SellerUiTokens.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(state.balance, context),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Enter Amount Input
                  Text(
                    'Enter Amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16, right: 12),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                          color: Color(0xFFE11D48),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final double? amt = double.tryParse(value);
                      if (amt == null) {
                        return 'Please enter a valid amount';
                      }
                      if (amt <= 0) {
                        return 'Amount must be greater than zero';
                      }
                      if (amt > state.balance) {
                        return 'Insufficient balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bank Account Selector
                  Text(
                    'Bank Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBank,
                    items: state.bankAccounts.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(
                          bank,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBank = val;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                          color: SellerUiTokens.brand,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // UPI ID Input
                  Text(
                    'UPI ID',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _upiController,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                          color: SellerUiTokens.brand,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Request Payout Button Footer
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16.0,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          final double amt = double.parse(
                            _amountController.text,
                          );
                          context.read<SellerRequestPayoutBloc>().add(
                            SubmitPayout(
                              amount: amt,
                              bankAccount: _selectedBank ?? '',
                              upiId: _upiController.text,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SellerUiTokens.brand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Request Payout',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(double horizontalPadding) {
    return Padding(
      key: const ValueKey('loading_payout_skeleton'),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const SkeletonBox(
            height: 120,
            width: double.infinity,
            borderRadius: 20,
          ),
          const SizedBox(height: 24),
          const SkeletonBox(width: 100, height: 16, borderRadius: 0),
          const SizedBox(height: 8),
          const SkeletonBox(
            height: 52,
            width: double.infinity,
            borderRadius: 0,
          ),
          const SizedBox(height: 24),
          const SkeletonBox(width: 100, height: 16, borderRadius: 0),
          const SizedBox(height: 8),
          const SkeletonBox(
            height: 52,
            width: double.infinity,
            borderRadius: 0,
          ),
          const SizedBox(height: 24),
          const SkeletonBox(width: 100, height: 16, borderRadius: 0),
          const SizedBox(height: 8),
          const SkeletonBox(
            height: 52,
            width: double.infinity,
            borderRadius: 0,
          ),
          const Spacer(),
          const SkeletonBox(
            height: 52,
            width: double.infinity,
            borderRadius: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    double horizontalPadding,
  ) {
    return Center(
      key: const ValueKey('error_payout_content'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<SellerRequestPayoutBloc>().add(
                const LoadPayoutDetails(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: SellerUiTokens.brand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
