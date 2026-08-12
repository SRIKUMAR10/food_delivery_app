import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'buyer_forgot_password_page_bloc.dart';
import 'buyer_forgot_password_page_event.dart';
import 'buyer_forgot_password_page_state.dart';

class BuyerForgotPasswordPageUI extends StatefulWidget {
  const BuyerForgotPasswordPageUI({super.key});

  @override
  State<BuyerForgotPasswordPageUI> createState() =>
      _BuyerForgotPasswordPageUIState();
}

class _BuyerForgotPasswordPageUIState extends State<BuyerForgotPasswordPageUI> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuyerForgotPasswordBloc(),
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
            'Forgot Password',
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
              child: BlocConsumer<BuyerForgotPasswordBloc, BuyerForgotPasswordState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.errorMessage != current.errorMessage,
                listener: (context, state) {
                  if (state.status == BuyerForgotPasswordStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset successfully! Please log in.'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    if (Navigator.canPop(context)) Navigator.of(context).pop();
                  } else if (state.status == BuyerForgotPasswordStatus.otpSent) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('OTP sent successfully to your phone number.'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if ((state.status == BuyerForgotPasswordStatus.failure ||
                          state.status == BuyerForgotPasswordStatus.otpSendFailure) &&
                      state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final bloc = context.read<BuyerForgotPasswordBloc>();

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
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your registered Phone Number, verify OTP, and set your new password.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Phone Number',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (v) => bloc.add(BuyerForgotPasswordPhoneChanged(v)),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Enter phone number',
                                  prefixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 12),
                                      const Icon(Icons.phone_outlined, color: Colors.grey, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '+91',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 1,
                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                        color: Colors.grey.shade300,
                                      ),
                                    ],
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFEEF0F5),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  errorText: state.phoneError,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE52121), width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (state.status == BuyerForgotPasswordStatus.otpSending ||
                                        state.status == BuyerForgotPasswordStatus.submitting)
                                    ? null
                                    : () => bloc.add(const BuyerForgotPasswordSendOtpRequested()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE52121),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: state.status == BuyerForgotPasswordStatus.otpSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        state.verificationId != null ? 'Resend' : 'Get OTP',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'OTP Code',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (v) => bloc.add(BuyerForgotPasswordOtpChanged(v)),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit OTP',
                            prefixIcon: const Icon(Icons.pin_outlined, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFEEF0F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            errorText: state.otpError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE52121), width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create Password',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (v) => bloc.add(BuyerForgotPasswordPasswordChanged(v)),
                          obscureText: !state.isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Enter new password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () =>
                                  bloc.add(const BuyerForgotPasswordTogglePasswordVisibility()),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEEF0F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            errorText: state.passwordError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE52121), width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Confirm Password',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (v) => bloc.add(BuyerForgotPasswordConfirmPasswordChanged(v)),
                          obscureText: !state.isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Confirm new password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () =>
                                  bloc.add(const BuyerForgotPasswordToggleConfirmPasswordVisibility()),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEEF0F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            errorText: state.confirmPasswordError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE52121), width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.status == BuyerForgotPasswordStatus.submitting
                                ? null
                                : () => bloc.add(const BuyerForgotPasswordSubmitted()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE52121),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: state.status == BuyerForgotPasswordStatus.submitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
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

