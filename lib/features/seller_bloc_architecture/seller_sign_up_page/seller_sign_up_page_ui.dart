import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/widgets/primary_button.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens (Material 3 green theme — pixel-perfect from UI image)
// ─────────────────────────────────────────────────────────────────────────────
class _AppColors {
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF4CAF50);
  static const primarySurface = Color(0xFFE8F5E9);
  static const background = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1B1B1B);
  static const textLight = Color(0xFF888888);
  static const inputBorder = Color(0xFFDDDDDD);
  static const error = Color(0xFFD32F2F);
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point widget (provides BLoC)
// ─────────────────────────────────────────────────────────────────────────────
class SellerSignUpPageUI extends StatelessWidget {
  final SellerSignUpPageBloc? bloc;
  const SellerSignUpPageUI({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<SellerSignUpPageBloc>.value(
        value: bloc!,
        child: const _SellerSignUpPageView(),
      );
    }
    return BlocProvider(
      create: (context) => SellerSignUpPageBloc(),
      child: const _SellerSignUpPageView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main view — router between screens
// ─────────────────────────────────────────────────────────────────────────────
class _SellerSignUpPageView extends StatelessWidget {
  const _SellerSignUpPageView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerSignUpPageBloc, SellerSignUpPageState>(
      listenWhen: (prev, curr) =>
          curr.status == SellerSignUpStatus.success ||
          curr.status == SellerSignUpStatus.failure || 
          curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          _showErrorSnackBar(context, state.errorMessage!);
          context.read<SellerSignUpPageBloc>().add(const SellerSignUpErrorDismissed());
        }
      },
      child: Scaffold(
        backgroundColor: _AppColors.background,
        body: BlocBuilder<SellerSignUpPageBloc, SellerSignUpPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                    ),
                    child: child,
                  ),
                );
              },
              child: _buildScreen(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, SellerSignUpPageState state) {
    switch (state.step) {
      case SellerSignUpStep.personalDetails:
        return const _PersonalDetailsScreen(key: ValueKey('personal_details'));
      case SellerSignUpStep.contactPassword:
        return const _ContactPasswordScreen(key: ValueKey('contact_password'));
      case SellerSignUpStep.otpVerification:
        return const _OtpVerificationScreen(key: ValueKey('otp_verify'));
      case SellerSignUpStep.emailVerification:
        return const _EmailVerificationScreen(key: ValueKey('email_verify'));
      case SellerSignUpStep.signUpSuccess:
        return const _SignUpSuccessScreen(key: ValueKey('signup_success'));
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: _AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Responsive wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _ResponsiveContainer extends StatelessWidget {
  final Widget child;
  const _ResponsiveContainer({required this.child});

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
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
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
      shadowColor: _AppColors.primary.withValues(alpha: 0.4),
      backgroundColor: _AppColors.primary,
    );
  }
}

class _SignUpTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final String? errorText;
  final TextInputAction textInputAction;
  final String? initialValue;

  const _SignUpTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: initialValue,
          obscureText: obscureText,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: GoogleFonts.inter(fontSize: 14, color: _AppColors.textDark),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: _AppColors.textLight),
            prefixIcon: Icon(prefixIcon, color: _AppColors.textLight, size: 20),
            suffixIcon: suffixWidget,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _AppColors.inputBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _AppColors.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _AppColors.error, width: 1.5),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class _ScreenIllustration extends StatelessWidget {
  final Widget child;
  final String heroTag;

  const _ScreenIllustration({required this.child, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _AppColors.primarySurface,
          boxShadow: [
            BoxShadow(
              color: _AppColors.primary.withValues(alpha: 0.12),
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

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

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
          color: _AppColors.textDark,
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Screen 2 – Personal Details
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalDetailsScreen extends StatelessWidget {
  const _PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
      child: SafeArea(
        child: BlocBuilder<SellerSignUpPageBloc, SellerSignUpPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _BackButton(
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _ScreenIllustration(
                      heroTag: 'personal_details_ill',
                      child: const Icon(Icons.person_rounded, size: 52, color: _AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Personal Details',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: _AppColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SignUpTextField(
                    key: const Key('nameField'),
                    initialValue: state.name,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    onChanged: (v) => context.read<SellerSignUpPageBloc>().add(SellerSignUpNameChanged(v)),
                    errorText: state.nameError,
                  ),
                  const SizedBox(height: 16),
                  _SignUpTextField(
                    key: const Key('shopNameField'),
                    initialValue: state.shopName,
                    hintText: 'Shop Name',
                    prefixIcon: Icons.storefront_outlined,
                    onChanged: (v) => context.read<SellerSignUpPageBloc>().add(SellerSignUpShopNameChanged(v)),
                    errorText: state.shopNameError,
                  ),
                  const SizedBox(height: 16),
                  _SignUpTextField(
                    key: const Key('businessDetailsField'),
                    initialValue: state.businessDetails,
                    hintText: 'Business Details',
                    prefixIcon: Icons.business_center_outlined,
                    onChanged: (v) => context.read<SellerSignUpPageBloc>().add(SellerSignUpBusinessDetailsChanged(v)),
                    errorText: state.businessDetailsError,
                  ),
                  const SizedBox(height: 32),
                  _PrimaryButton(
                    label: 'Next',
                    onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpPersonalDetailsSubmitted()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 3 – Contact & Password
// ─────────────────────────────────────────────────────────────────────────────
class _ContactPasswordScreen extends StatelessWidget {
  const _ContactPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
      child: SafeArea(
        child: BlocBuilder<SellerSignUpPageBloc, SellerSignUpPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _BackButton(
                    onTap: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpBackPressed()),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _ScreenIllustration(
                      heroTag: 'contact_details_ill',
                      child: const Icon(Icons.contact_mail_rounded, size: 52, color: _AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Contact & Security',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: _AppColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SignUpTextField(
                    key: const Key('phoneField'),
                    initialValue: state.phone,
                    hintText: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => context.read<SellerSignUpPageBloc>().add(SellerSignUpPhoneChanged(v)),
                    errorText: state.phoneError,
                  ),
                  const SizedBox(height: 16),
                  _SignUpTextField(
                    key: const Key('emailField'),
                    initialValue: state.email,
                    hintText: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => context.read<SellerSignUpPageBloc>().add(SellerSignUpEmailChanged(v)),
                    errorText: state.emailError,
                  ),
                  const SizedBox(height: 16),
                  _SignUpTextField(
                    key: const Key('passwordField'),
                    initialValue: state.password,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: state.isPasswordObscured,
                    onChanged: (v) => context.read<SellerSignUpPageBloc>().add(SellerSignUpPasswordChanged(v)),
                    errorText: state.passwordError,
                    suffixWidget: IconButton(
                      icon: Icon(
                        state.isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: _AppColors.textLight,
                        size: 20,
                      ),
                      onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpPasswordVisibilityToggled()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SignUpTextField(
                    key: const Key('confirmPasswordField'),
                    initialValue: state.confirmPassword,
                    hintText: 'Confirm Password',
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: state.isConfirmPasswordObscured,
                    onChanged: (v) => context.read<SellerSignUpPageBloc>().add(SellerSignUpConfirmPasswordChanged(v)),
                    errorText: state.confirmPasswordError,
                    textInputAction: TextInputAction.done,
                    suffixWidget: IconButton(
                      icon: Icon(
                        state.isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: _AppColors.textLight,
                        size: 20,
                      ),
                      onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpConfirmPasswordVisibilityToggled()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: state.termsAccepted,
                        onChanged: (v) => context.read<SellerSignUpPageBloc>().add(const SellerSignUpTermsToggled()),
                        activeColor: _AppColors.primary,
                      ),
                      Expanded(
                        child: Text(
                          'I accept the terms and conditions',
                          style: GoogleFonts.inter(fontSize: 13, color: _AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: 'Create Account / Send OTP',
                    isLoading: state.status == SellerSignUpStatus.loading,
                    onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpContactSubmitted()),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 4 – OTP Verification
// ─────────────────────────────────────────────────────────────────────────────
class _OtpVerificationScreen extends StatefulWidget {
  const _OtpVerificationScreen({super.key});

  @override
  State<_OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<_OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
      child: SafeArea(
        child: BlocBuilder<SellerSignUpPageBloc, SellerSignUpPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.topLeft,
                    child: _BackButton(
                      onTap: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpBackPressed()),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ScreenIllustration(
                    heroTag: 'otp_illustration',
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const Icon(Icons.mark_email_read_rounded, size: 52, color: _AppColors.primary),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: _AppColors.primaryLight, shape: BoxShape.circle),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'OTP Verification',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: _AppColors.textDark),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: "We've sent a 6-digit OTP to\n",
                      style: GoogleFonts.inter(fontSize: 14, color: _AppColors.textLight),
                      children: [
                        TextSpan(
                          text: state.phone,
                          style: GoogleFonts.inter(color: _AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: '\nEnter the OTP below to verify',
                          style: GoogleFonts.inter(fontSize: 14, color: _AppColors.textLight),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _OtpBoxRow(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    onDigitChanged: (index, digit) =>
                        context.read<SellerSignUpPageBloc>().add(SellerSignUpOtpDigitChanged(index: index, digit: digit)),
                  ),
                  if (state.otpError != null) ...[
                    const SizedBox(height: 8),
                    Text(state.otpError!, style: GoogleFonts.inter(color: _AppColors.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  if (state.otpCountdown > 0)
                    Text(
                      'Resend OTP in 00:${state.otpCountdown.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(fontSize: 13, color: _AppColors.textLight),
                    )
                  else
                    TextButton(
                      onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpOtpResendRequested()),
                      child: Text(
                        'Resend OTP',
                        style: GoogleFonts.inter(color: _AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    key: const Key('verifyOtpButton'),
                    label: 'Verify OTP',
                    isLoading: state.status == SellerSignUpStatus.loading,
                    onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpOtpVerifySubmitted()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OtpBoxRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String digit) onDigitChanged;

  const _OtpBoxRow({
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
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: _AppColors.textDark),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _AppColors.primary, width: 2),
              ),
            ),
            onChanged: (v) {
              onDigitChanged(i, v);
              if (v.isNotEmpty && i < 5) focusNodes[i + 1].requestFocus();
              else if (v.isEmpty && i > 0) focusNodes[i - 1].requestFocus();
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 5 – Email Verification
// ─────────────────────────────────────────────────────────────────────────────
class _EmailVerificationScreen extends StatelessWidget {
  const _EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ScreenIllustration(
                heroTag: 'email_verif_ill',
                child: const Icon(Icons.mark_email_unread_rounded, size: 52, color: _AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text(
                'Verification Email Sent!',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: _AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Text(
                'Please check your email and verify to continue.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: _AppColors.textLight),
              ),
              const SizedBox(height: 48),
              _PrimaryButton(
                label: 'I have verified',
                onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpEmailVerifyCheckPressed()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 6 – Success
// ─────────────────────────────────────────────────────────────────────────────
class _SignUpSuccessScreen extends StatefulWidget {
  const _SignUpSuccessScreen({super.key});

  @override
  State<_SignUpSuccessScreen> createState() => _SignUpSuccessScreenState();
}

class _SignUpSuccessScreenState extends State<_SignUpSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _checkAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _checkAnim, curve: Curves.elasticOut);
    _checkAnim.forward();
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
      child: SafeArea(
        child: BlocBuilder<SellerSignUpPageBloc, SellerSignUpPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(colors: [_AppColors.primaryLight, _AppColors.primary]),
                        boxShadow: [
                          BoxShadow(
                            color: _AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_circle_rounded, size: 72, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome, ${state.name}!',
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: _AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Account created successfully.',
                    style: GoogleFonts.inter(fontSize: 15, color: _AppColors.textLight),
                  ),
                  const SizedBox(height: 48),
                  _PrimaryButton(
                    key: const Key('goToDashboardButton'),
                    label: 'Go to Dashboard',
                    onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpGoToDashboardPressed()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
