import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Delivery_Forgot_Password_page_bloc.dart';
import 'Delivery_Forgot_Password_page_event.dart';
import 'Delivery_Forgot_Password_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';

class DeliveryForgotPasswordPage extends StatelessWidget {
  const DeliveryForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryForgotPasswordBloc(),
      child: const _DeliveryForgotPasswordView(),
    );
  }
}

class _DeliveryForgotPasswordView extends StatefulWidget {
  const _DeliveryForgotPasswordView();

  @override
  State<_DeliveryForgotPasswordView> createState() =>
      _DeliveryForgotPasswordViewState();
}

class _DeliveryForgotPasswordViewState
    extends State<_DeliveryForgotPasswordView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(_fadeAnim);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeliveryAppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Delivery_Login_scooter.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: DeliveryAppColors.background),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
          BlocConsumer<DeliveryForgotPasswordBloc,
              DeliveryForgotPasswordState>(
            listener: (context, state) {
              if (state.status == DeliveryForgotPasswordStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully! Please login.'),
                    backgroundColor: DeliveryAppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              } else if (state.status == DeliveryForgotPasswordStatus.otpSent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OTP sent successfully to your phone.'),
                    backgroundColor: DeliveryAppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if ((state.status == DeliveryForgotPasswordStatus.failure ||
                      state.status == DeliveryForgotPasswordStatus.otpSendFailure) &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: AnimatedBuilder(
                        animation: _animController,
                        child: _buildCard(context, state),
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnim,
                            child: ScaleTransition(
                              scale: _scaleAnim,
                              child: child,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, DeliveryForgotPasswordState state) {
    final bloc = context.read<DeliveryForgotPasswordBloc>();

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF091413).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: DeliveryAppColors.primary.withValues(alpha: 0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: DeliveryAppColors.primary.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                color: Colors.white70, size: 24),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DeliveryAppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: DeliveryAppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: DeliveryAppColors.primary,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Reset Password',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify your phone number and reset your account password.',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Phone Number',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) =>
                      bloc.add(DeliveryForgotPasswordPhoneChanged(v)),
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF081412),
                    hintText: '98765 43210',
                    hintStyle:
                        GoogleFonts.inter(color: Colors.white30, fontSize: 14),
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.phone_outlined,
                            color: Colors.white60, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '+91',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.white24,
                        ),
                      ],
                    ),
                    errorText: state.phoneError,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: DeliveryAppColors.primary.withValues(alpha: 0.25)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: DeliveryAppColors.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (state.status == DeliveryForgotPasswordStatus.otpSending ||
                          state.status == DeliveryForgotPasswordStatus.submitting)
                      ? null
                      : () => bloc.add(const DeliveryForgotPasswordSendOtpRequested()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DeliveryAppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.status == DeliveryForgotPasswordStatus.otpSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text(
                          state.verificationId != null ? 'Resend' : 'Get OTP',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                ),
              ),
            ],
          ),
          if (state.verificationId != null) ...[
            const SizedBox(height: 16),
            Text(
              'OTP Code',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => bloc.add(DeliveryForgotPasswordOtpChanged(v)),
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF081412),
                hintText: 'Enter 6-digit OTP',
                hintStyle:
                    GoogleFonts.inter(color: Colors.white30, fontSize: 14),
                prefixIcon: const Icon(Icons.pin_outlined, color: Colors.white60),
                errorText: state.otpError,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: DeliveryAppColors.primary.withValues(alpha: 0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: DeliveryAppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'New Password',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => bloc.add(DeliveryForgotPasswordPasswordChanged(v)),
              obscureText: !state.isPasswordVisible,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF081412),
                hintText: '••••••••',
                hintStyle:
                    GoogleFonts.inter(color: Colors.white30, fontSize: 14),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white60,
                    size: 20,
                  ),
                  onPressed: () =>
                      bloc.add(const DeliveryForgotPasswordTogglePasswordVisibility()),
                ),
                errorText: state.passwordError,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: DeliveryAppColors.primary.withValues(alpha: 0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: DeliveryAppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm New Password',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => bloc.add(DeliveryForgotPasswordConfirmPasswordChanged(v)),
              obscureText: !state.isConfirmPasswordVisible,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF081412),
                hintText: '••••••••',
                hintStyle:
                    GoogleFonts.inter(color: Colors.white30, fontSize: 14),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white60,
                    size: 20,
                  ),
                  onPressed: () =>
                      bloc.add(const DeliveryForgotPasswordToggleConfirmPasswordVisibility()),
                ),
                errorText: state.confirmPasswordError,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: DeliveryAppColors.primary.withValues(alpha: 0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: DeliveryAppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state.status == DeliveryForgotPasswordStatus.submitting
                    ? null
                    : () => bloc.add(const DeliveryForgotPasswordSubmitted()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeliveryAppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shadowColor: DeliveryAppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state.status == DeliveryForgotPasswordStatus.submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        'Reset Password',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

