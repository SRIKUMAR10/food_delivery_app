import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_delivery_app/repositories/seller_repository.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';
import '../seller_login_page/seller_login_page_bloc.dart';
import '../seller_login_page/seller_login_page_event.dart';
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
      begin: const Offset(0, 0.1),
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

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      try {
        context.read<SellerLoginPageBloc>().add(const SellerLoginBackPressed());
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SellerAuthColors.background,
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
                SnackBar(
                  content: Text(
                    'Password reset successfully! Please log in.',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  ),
                  backgroundColor: SellerAuthColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
              _handleBack(context);
            } else if (state.status == SellerForgotPasswordStatus.otpSent) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'OTP sent successfully to your mobile number.',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  ),
                  backgroundColor: SellerAuthColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            } else if ((state.status == SellerForgotPasswordStatus.failure ||
                    state.status == SellerForgotPasswordStatus.otpSendFailure) &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  ),
                  backgroundColor: SellerAuthColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: SellerAuthColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Verify mobile number & create new password',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: SellerAuthColors.textMid,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          onPressed: () => _handleBack(context),
                          color: SellerAuthColors.textDark,
                          tooltip: 'Back',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
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
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: SellerAuthColors.divider,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
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
                                      color: SellerAuthColors.primarySurface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock_reset_rounded,
                                      size: 40,
                                      color: SellerAuthColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Reset Your Password',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: SellerAuthColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your registered mobile number to get an OTP and set your new password.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: SellerAuthColors.textMid,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Mobile Number Label & Input
                                Text(
                                  'Mobile Number',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: SellerAuthColors.textDark,
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
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(10),
                                            ],
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: SellerAuthColors.textDark,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Enter 10-digit mobile number',
                                              hintStyle: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: SellerAuthColors.textLight,
                                              ),
                                              prefixIcon: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(width: 14),
                                                  const Icon(
                                                    Icons.phone_outlined,
                                                    color: SellerAuthColors.textLight,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '+91',
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                      color: SellerAuthColors.textDark,
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 18,
                                                    width: 1,
                                                    margin: const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                    color: SellerAuthColors.divider,
                                                  ),
                                                ],
                                              ),
                                              errorText: state.phoneError,
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: SellerAuthColors.inputBorder,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: SellerAuthColors.inputBorder,
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: SellerAuthColors.primary,
                                                  width: 1.5,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: SellerAuthColors.error,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          height: 48,
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
                                              backgroundColor: SellerAuthColors.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                            ),
                                            child: isSendingOtp
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    state.verificationId != null
                                                        ? 'Resend'
                                                        : 'Get OTP',
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600,
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
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: SellerAuthColors.textDark,
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
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        letterSpacing: 2.0,
                                        fontWeight: FontWeight.w600,
                                        color: SellerAuthColors.textDark,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: 'Enter 6-digit OTP',
                                        hintStyle: GoogleFonts.inter(
                                          letterSpacing: 0,
                                          fontSize: 14,
                                          color: SellerAuthColors.textLight,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.pin_outlined,
                                          color: SellerAuthColors.textLight,
                                          size: 20,
                                        ),
                                        errorText: state.otpError,
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.inputBorder,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.inputBorder,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.primary,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.error,
                                            width: 1.5,
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
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: SellerAuthColors.textDark,
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
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: SellerAuthColors.textDark,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter new password (min 6 characters)',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: SellerAuthColors.textLight,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: SellerAuthColors.textLight,
                                          size: 20,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            state.isPasswordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: SellerAuthColors.textLight,
                                            size: 20,
                                          ),
                                          onPressed: () => bloc.add(
                                            const SellerForgotPasswordTogglePasswordVisibility(),
                                          ),
                                        ),
                                        errorText: state.passwordError,
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.inputBorder,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.inputBorder,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.primary,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.error,
                                            width: 1.5,
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
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: SellerAuthColors.textDark,
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
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: SellerAuthColors.textDark,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Confirm your new password',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: SellerAuthColors.textLight,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: SellerAuthColors.textLight,
                                          size: 20,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            state.isConfirmPasswordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: SellerAuthColors.textLight,
                                            size: 20,
                                          ),
                                          onPressed: () => bloc.add(
                                            const SellerForgotPasswordToggleConfirmPasswordVisibility(),
                                          ),
                                        ),
                                        errorText: state.confirmPasswordError,
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.inputBorder,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.inputBorder,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.primary,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: SellerAuthColors.error,
                                            width: 1.5,
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
                                    return SellerPrimaryButton(
                                      label: 'Reset Password',
                                      isLoading: isLoading,
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              FocusScope.of(context).unfocus();
                                              context
                                                  .read<SellerForgotPasswordBloc>()
                                                  .add(const SellerForgotPasswordSubmitted());
                                            },
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



