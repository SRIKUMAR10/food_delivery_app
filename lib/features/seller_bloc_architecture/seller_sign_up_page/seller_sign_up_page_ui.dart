import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_event.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';

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
        backgroundColor: SellerAuthColors.background,
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
        return BlocBuilder<SellerSignUpPageBloc, SellerSignUpPageState>(
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              previous != current,
          builder: (context, state) => SellerOtpVerificationScreen(
            key: const ValueKey('otp_verify'),
            title: 'OTP Verification',
            subtitleValue: state.phone,
            verifyLabel: 'Verify OTP',
            verifyButtonKey: const Key('verifyOtpButton'),
            isLoading: state.status == SellerSignUpStatus.loading,
            countdown: state.otpCountdown,
            resendAvailable: state.otpCountdown <= 0,
            otpError: state.otpError,
            onBack: () =>
                context.read<SellerSignUpPageBloc>().add(
                  const SellerSignUpBackPressed(),
                ),
            onDigitChanged: (index, digit) =>
                context.read<SellerSignUpPageBloc>().add(
                  SellerSignUpOtpDigitChanged(
                    index: index,
                    digit: digit,
                  ),
                ),
            onResend: () => context.read<SellerSignUpPageBloc>().add(
              const SellerSignUpOtpResendRequested(),
            ),
            onVerify: () => context.read<SellerSignUpPageBloc>().add(
              const SellerSignUpOtpVerifySubmitted(),
            ),
          ),
        );
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
          backgroundColor: SellerAuthColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 2 – Personal Details
// ─────────────────────────────────────────────────────────────────────────────
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
          style: GoogleFonts.inter(fontSize: 14, color: SellerAuthColors.textDark),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: SellerAuthColors.textLight),
            prefixIcon: Icon(prefixIcon, color: SellerAuthColors.textLight, size: 20),
            suffixIcon: suffixWidget,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SellerAuthColors.inputBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SellerAuthColors.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SellerAuthColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SellerAuthColors.error, width: 1.5),
            ),
            errorText: errorText,
          ),
        ),
      ],
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
    return SellerResponsiveContainer(
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
                  SellerBackButton(
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SellerScreenIllustration(
                      heroTag: 'personal_details_ill',
                      child: const Icon(Icons.person_rounded, size: 52, color: SellerAuthColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Personal Details',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: SellerAuthColors.textDark),
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
                  SellerPrimaryButton(
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
    return SellerResponsiveContainer(
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
                  SellerBackButton(
                    onTap: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpBackPressed()),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SellerScreenIllustration(
                      heroTag: 'contact_details_ill',
                      child: const Icon(Icons.contact_mail_rounded, size: 52, color: SellerAuthColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Contact & Security',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: SellerAuthColors.textDark),
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
                        color: SellerAuthColors.textLight,
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
                        color: SellerAuthColors.textLight,
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
                        activeColor: SellerAuthColors.primary,
                      ),
                      Expanded(
                        child: Text(
                          'I accept the terms and conditions',
                          style: GoogleFonts.inter(fontSize: 13, color: SellerAuthColors.textDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SellerPrimaryButton(
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
// Screen 5 – Email Verification
// ─────────────────────────────────────────────────────────────────────────────
class _EmailVerificationScreen extends StatelessWidget {
  const _EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SellerResponsiveContainer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SellerScreenIllustration(
                heroTag: 'email_verif_ill',
                child: const Icon(Icons.mark_email_unread_rounded, size: 52, color: SellerAuthColors.primary),
              ),
              const SizedBox(height: 32),
              Text(
                'Verification Email Sent!',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: SellerAuthColors.textDark),
              ),
              const SizedBox(height: 10),
              Text(
                'Please check your email and verify to continue.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: SellerAuthColors.textLight),
              ),
              const SizedBox(height: 48),
              SellerPrimaryButton(
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
    return SellerResponsiveContainer(
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
                        gradient: const RadialGradient(colors: [SellerAuthColors.primaryLight, SellerAuthColors.primary]),
                        boxShadow: [
                          BoxShadow(
                            color: SellerAuthColors.primary.withValues(alpha: 0.35),
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
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: SellerAuthColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Account created successfully.',
                    style: GoogleFonts.inter(fontSize: 15, color: SellerAuthColors.textLight),
                  ),
                  const SizedBox(height: 48),
                  SellerPrimaryButton(
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
