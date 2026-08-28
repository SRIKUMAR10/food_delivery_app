import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_delivery_app/repositories/seller_repository.dart';
import '../../../core/widgets/hoverable_widgets.dart';
import 'seller_forgot_password_bloc.dart';
import 'seller_forgot_password_event.dart';
import 'seller_forgot_password_state.dart';

class SellerForgotPasswordPageUI extends StatelessWidget {
  const SellerForgotPasswordPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerForgotPasswordBloc(
        authRepository: SellerRepository(),
      ),
      child: const _SellerForgotPasswordView(),
    );
  }
}

class _SellerForgotPasswordView extends StatefulWidget {
  const _SellerForgotPasswordView();

  @override
  State<_SellerForgotPasswordView> createState() =>
      _SellerForgotPasswordViewState();
}

class _SellerForgotPasswordViewState extends State<_SellerForgotPasswordView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.microtask(() => _animationController.forward());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocListener<SellerForgotPasswordBloc, SellerForgotPasswordState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();

            if (state.status == SellerForgotPasswordStatus.success) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Password reset successfully! Please log in.'),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            } else if (state.status == SellerForgotPasswordStatus.otpSent) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('OTP sent successfully to your mobile number.'),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if ((state.status == SellerForgotPasswordStatus.failure ||
                    state.status == SellerForgotPasswordStatus.otpSendFailure) &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset Password',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Verify mobile number & create new password',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: const Color(0xFF111827),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFEE2E2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock_reset_rounded,
                                      size: 44,
                                      color: Color(0xFFE52929),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Reset Your Password',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your registered mobile number to get an OTP and set your new password.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: const Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Mobile Number Label & Input
                                Text(
                                  'Mobile Number',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                BlocBuilder<SellerForgotPasswordBloc,
                                    SellerForgotPasswordState>(
                                  buildWhen: (prev, curr) =>
                                      prev.phoneNumber != curr.phoneNumber ||
                                      prev.phoneError != curr.phoneError ||
                                      prev.status != curr.status ||
                                      prev.verificationId != curr.verificationId,
                                  builder: (context, state) {
                                    final bloc = context.read<SellerForgotPasswordBloc>();
                                    final isSendingOtp =
                                        state.status == SellerForgotPasswordStatus.otpSending;
                                    final isSubmitting =
                                        state.status == SellerForgotPasswordStatus.submitting;

                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            onChanged: (value) => bloc.add(
                                              SellerForgotPasswordPhoneChanged(value),
                                            ),
                                            keyboardType: TextInputType.phone,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              color: const Color(0xFF0F172A),
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Enter 10-digit mobile number',
                                              hintStyle: GoogleFonts.plusJakartaSans(
                                                color: const Color(0xFF94A3B8),
                                              ),
                                              prefixIcon: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(width: 12),
                                                  const Icon(
                                                    Icons.phone_outlined,
                                                    color: Color(0xFF94A3B8),
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '+91',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: const Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width: 1,
                                                    margin: const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                    color: const Color(0xFFCBD5E1),
                                                  ),
                                                ],
                                              ),
                                              errorText: state.phoneError,
                                              filled: true,
                                              fillColor: const Color(0xFFF8FAFC),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(16),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFE52929),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          height: 54,
                                          child: ElevatedButton(
                                            onPressed: (isSendingOtp || isSubmitting)
                                                ? null
                                                : () {
                                                    FocusScope.of(context).unfocus();
                                                    bloc.add(
                                                      const SellerForgotPasswordSendOtpRequested(),
                                                    );
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFE52929),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                            ),
                                            child: isSendingOtp
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    state.verificationId != null
                                                        ? 'Resend'
                                                        : 'Get OTP',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                // OTP Code Label & Input
                                Text(
                                  'OTP Code',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                BlocBuilder<SellerForgotPasswordBloc,
                                    SellerForgotPasswordState>(
                                  buildWhen: (prev, curr) =>
                                      prev.otp != curr.otp ||
                                      prev.otpError != curr.otpError,
                                  builder: (context, state) {
                                    return TextFormField(
                                      onChanged: (value) => context
                                          .read<SellerForgotPasswordBloc>()
                                          .add(SellerForgotPasswordOtpChanged(value)),
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        letterSpacing: 2.0,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: 'Enter 6-digit OTP',
                                        hintStyle: GoogleFonts.plusJakartaSans(
                                          letterSpacing: 0,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.pin_outlined,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        errorText: state.otpError,
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE52929),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Create Password Label & Input
                                Text(
                                  'Create Password',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                BlocBuilder<SellerForgotPasswordBloc,
                                    SellerForgotPasswordState>(
                                  buildWhen: (prev, curr) =>
                                      prev.password != curr.password ||
                                      prev.isPasswordVisible !=
                                          curr.isPasswordVisible ||
                                      prev.passwordError != curr.passwordError,
                                  builder: (context, state) {
                                    final bloc = context.read<SellerForgotPasswordBloc>();
                                    return TextFormField(
                                      onChanged: (value) => bloc.add(
                                        SellerForgotPasswordPasswordChanged(value),
                                      ),
                                      obscureText: !state.isPasswordVisible,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter new password (min 6 characters)',
                                        hintStyle: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF94A3B8),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            state.isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                          onPressed: () => bloc.add(
                                            const SellerForgotPasswordTogglePasswordVisibility(),
                                          ),
                                        ),
                                        errorText: state.passwordError,
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE52929),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Confirm Password Label & Input
                                Text(
                                  'Confirm Password',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                BlocBuilder<SellerForgotPasswordBloc,
                                    SellerForgotPasswordState>(
                                  buildWhen: (prev, curr) =>
                                      prev.confirmPassword != curr.confirmPassword ||
                                      prev.isConfirmPasswordVisible !=
                                          curr.isConfirmPasswordVisible ||
                                      prev.confirmPasswordError !=
                                          curr.confirmPasswordError,
                                  builder: (context, state) {
                                    final bloc = context.read<SellerForgotPasswordBloc>();
                                    return TextFormField(
                                      onChanged: (value) => bloc.add(
                                        SellerForgotPasswordConfirmPasswordChanged(value),
                                      ),
                                      obscureText: !state.isConfirmPasswordVisible,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Confirm your new password',
                                        hintStyle: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF94A3B8),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            state.isConfirmPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                          onPressed: () => bloc.add(
                                            const SellerForgotPasswordToggleConfirmPasswordVisibility(),
                                          ),
                                        ),
                                        errorText: state.confirmPasswordError,
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE52929),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 32),

                                // Reset Password Submit Button
                                BlocBuilder<SellerForgotPasswordBloc,
                                    SellerForgotPasswordState>(
                                  buildWhen: (prev, curr) =>
                                      prev.status != curr.status,
                                  builder: (context, state) {
                                    final isLoading = state.status ==
                                        SellerForgotPasswordStatus.submitting;
                                    return HoverableButton(
                                      height: 56,
                                      color: const Color(0xFFE52929),
                                      shadowColor: const Color(0xFFE52929)
                                          .withValues(alpha: 0.3),
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              FocusScope.of(context).unfocus();
                                              context
                                                  .read<SellerForgotPasswordBloc>()
                                                  .add(const SellerForgotPasswordSubmitted());
                                            },
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Reset Password',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


