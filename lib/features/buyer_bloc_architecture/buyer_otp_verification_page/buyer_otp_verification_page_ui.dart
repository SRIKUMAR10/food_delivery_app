import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/widgets/auth_form_widgets.dart';
import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';
import '../buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';
import 'buyer_otp_verification_page_bloc.dart';
import 'buyer_otp_verification_page_event.dart';
import 'buyer_otp_verification_page_state.dart';

class BuyerOtpVerificationPageUI extends StatefulWidget {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final String verificationId;

  const BuyerOtpVerificationPageUI({
    super.key,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    this.verificationId = '',
  });

  @override
  State<BuyerOtpVerificationPageUI> createState() => _BuyerOtpVerificationPageUIState();
}

class _BuyerOtpVerificationPageUIState extends State<BuyerOtpVerificationPageUI> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuyerOtpBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'OTP Verification',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: BlocConsumer<BuyerOtpBloc, BuyerOtpState>(
                listener: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.clearSnackBars();

                    if (state.status == BuyerOtpStatus.success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Registration & Mobile Verification Successful! Welcome to FoodGo.'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => BuyerOnboardingVerificationPage(
                            initialFullName: widget.fullName,
                            initialEmail: widget.email,
                            initialPhone: widget.mobileNumber,
                            initialIsPhoneVerified: true,
                          ),
                        ),
                        (route) => false,
                      );
                    } else if (state.status == BuyerOtpStatus.failure) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            state.errorMessage ?? 'OTP Verification failed',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  });
                },
                builder: (context, state) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verify Phone Number',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the 6-digit code sent to ${widget.mobileNumber}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        const AuthFieldLabel('Enter OTP'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                          decoration: authFieldDecoration(
                            borderRadius: 16,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 32),
                        AuthPrimaryButton(
                          label: 'Confirm OTP',
                          isLoading: state.status == BuyerOtpStatus.loading,
                          onPressed: () {
                            context.read<BuyerOtpBloc>().add(
                                  BuyerVerifyOtpSubmitted(
                                    fullName: widget.fullName,
                                    email: widget.email,
                                    mobileNumber: widget.mobileNumber,
                                    password: widget.password,
                                    otpCode: _otpController.text.trim(),
                                    verificationId: widget.verificationId,
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
