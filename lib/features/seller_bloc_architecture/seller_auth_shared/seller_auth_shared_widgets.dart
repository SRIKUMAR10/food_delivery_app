import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/widgets/primary_button.dart';
export 'seller_wizard_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared design tokens (Material 3 green theme — used by both auth flows)
// ─────────────────────────────────────────────────────────────────────────────
class SellerAuthColors {
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF4CAF50);
  static const primarySurface = Color(0xFFE8F5E9);
  static const background = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1B1B1B);
  static const textMid = Color(0xFF555555);
  static const textLight = Color(0xFF888888);
  static const inputBorder = Color(0xFFDDDDDD);
  static const error = Color(0xFFD32F2F);
  static const divider = Color(0xFFEEEEEE);
}

// ─────────────────────────────────────────────────────────────────────────────
// Responsive wrapper
// ─────────────────────────────────────────────────────────────────────────────
class SellerResponsiveContainer extends StatelessWidget {
  final Widget child;
  const SellerResponsiveContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width > 600 ? 480.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Green gradient primary button (core PrimaryButton with auth styling)
// ─────────────────────────────────────────────────────────────────────────────
class SellerPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SellerPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: label,
      isLoading: isLoading,
      onPressed: onPressed,
      height: 52,
      borderRadius: 12,
      elevation: 2,
      shadowColor: SellerAuthColors.primary.withValues(alpha: 0.4),
      backgroundColor: SellerAuthColors.primary,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Illustration container with hero animation
// ─────────────────────────────────────────────────────────────────────────────
class SellerScreenIllustration extends StatelessWidget {
  final Widget child;
  final String heroTag;

  const SellerScreenIllustration({
    super.key,
    required this.child,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SellerAuthColors.primarySurface,
          boxShadow: [
            BoxShadow(
              color: SellerAuthColors.primary.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared back button
// ─────────────────────────────────────────────────────────────────────────────
class SellerBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const SellerBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: SellerAuthColors.textDark,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP Box Row (shared 6-digit OTP input used by login & sign-up flows)
// ─────────────────────────────────────────────────────────────────────────────
class SellerOtpBoxRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String digit) onDigitChanged;

  const SellerOtpBoxRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onDigitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 46,
          height: 52,
          child: TextField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SellerAuthColors.textDark,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: SellerAuthColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: SellerAuthColors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (v) {
              onDigitChanged(i, v);
              if (v.isNotEmpty && i < 5) {
                focusNodes[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                focusNodes[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP Verification Screen (shared component used by login & sign-up flows)
// ─────────────────────────────────────────────────────────────────────────────
class SellerOtpVerificationScreen extends StatefulWidget {
  final String title;
  final String subtitleValue;
  final String verifyLabel;
  final Key? verifyButtonKey;
  final bool isLoading;
  final int countdown;
  final bool resendAvailable;
  final bool alwaysShowCountdownSlot;
  final String? otpError;
  final bool showStepFooter;
  final String stepFooterText;
  final VoidCallback onBack;
  final void Function(int index, String digit) onDigitChanged;
  final VoidCallback onResend;
  final VoidCallback onVerify;

  const SellerOtpVerificationScreen({
    super.key,
    required this.title,
    required this.subtitleValue,
    required this.verifyLabel,
    this.verifyButtonKey,
    required this.isLoading,
    required this.countdown,
    required this.resendAvailable,
    this.alwaysShowCountdownSlot = false,
    this.otpError,
    this.showStepFooter = false,
    this.stepFooterText = '',
    required this.onBack,
    required this.onDigitChanged,
    required this.onResend,
    required this.onVerify,
  });

  @override
  State<SellerOtpVerificationScreen> createState() =>
      _SellerOtpVerificationScreenState();
}

class _SellerOtpVerificationScreenState
    extends State<SellerOtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countdownText = widget.resendAvailable
        ? ''
        : 'Resend OTP in 00:${widget.countdown.toString().padLeft(2, '0')}';

    return SellerResponsiveContainer(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topLeft,
                child: SellerBackButton(onTap: widget.onBack),
              ),
              const SizedBox(height: 32),
              SellerScreenIllustration(
                heroTag: 'otp_illustration',
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const Icon(
                      Icons.mark_email_read_rounded,
                      size: 52,
                      color: SellerAuthColors.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: SellerAuthColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: SellerAuthColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: "We've sent a 6-digit OTP to\n",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: SellerAuthColors.textLight,
                  ),
                  children: [
                    TextSpan(
                      text: widget.subtitleValue,
                      style: GoogleFonts.inter(
                        color: SellerAuthColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '\nEnter the OTP below to verify',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: SellerAuthColors.textLight,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SellerOtpBoxRow(
                controllers: _controllers,
                focusNodes: _focusNodes,
                onDigitChanged: widget.onDigitChanged,
              ),
              if (widget.otpError != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.otpError!,
                  style: GoogleFonts.inter(
                    color: SellerAuthColors.error,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (widget.alwaysShowCountdownSlot)
                Text(
                  countdownText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: SellerAuthColors.textLight,
                  ),
                ),
              if (!widget.alwaysShowCountdownSlot && !widget.resendAvailable)
                Text(
                  'Resend OTP in 00:${widget.countdown.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: SellerAuthColors.textLight,
                  ),
                ),
              if (widget.resendAvailable)
                TextButton(
                  onPressed: widget.onResend,
                  child: Text(
                    'Resend OTP',
                    style: GoogleFonts.inter(
                      color: SellerAuthColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SellerPrimaryButton(
                key: widget.verifyButtonKey,
                label: widget.verifyLabel,
                isLoading: widget.isLoading,
                onPressed: widget.onVerify,
              ),
              if (widget.showStepFooter) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    widget.stepFooterText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: SellerAuthColors.textLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}