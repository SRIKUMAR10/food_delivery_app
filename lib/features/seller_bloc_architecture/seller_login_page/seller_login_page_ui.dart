import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';
import '../seller_forgot_password/seller_forgot_password_ui.dart';
import 'seller_login_page_bloc.dart';
import 'seller_login_page_event.dart';
import 'seller_login_page_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point widget (provides BLoC)
// ─────────────────────────────────────────────────────────────────────────────
class SellerLoginPageUI extends StatelessWidget {
  const SellerLoginPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SellerLoginPageBloc(authRepository: SellerRepository()),
      child: const _SellerLoginPageView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main view — router between all 9 screens + BlocListener for navigation
// ─────────────────────────────────────────────────────────────────────────────
class _SellerLoginPageView extends StatelessWidget {
  const _SellerLoginPageView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerLoginPageBloc, SellerLoginPageState>(
      listenWhen: (prev, curr) =>
          curr.status == SellerLoginStatus.success ||
          curr.status == SellerLoginStatus.failure,
      listener: (context, state) {
        if (state.step == SellerLoginStep.loginSuccess &&
            state.status == SellerLoginStatus.success) {
          switch (state.onboardingStage) {
            case SellerOnboardingStage.kyc:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Please complete your KYC verification.',
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
              Navigator.pushReplacementNamed(context, '/sellerVerificationForm');
              break;

            case SellerOnboardingStage.storeDetails:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Please complete Step 2: Store Details.',
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
              Navigator.pushReplacementNamed(
                context,
                '/sellerStoreDetails',
                arguments: {'isOnboardingFlow': true},
              );
              break;

            case SellerOnboardingStage.businessHours:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Please set your Business Operating Hours.',
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
              Navigator.pushReplacementNamed(
                context,
                '/businessHours',
                arguments: {'isOnboardingFlow': true},
              );
              break;

            case SellerOnboardingStage.profileLive:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Please configure Profile Branding & Live Switch.',
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
              Navigator.pushReplacementNamed(
                context,
                '/sellerProfile',
                arguments: {'isOnboardingFlow': true},
              );
              break;

            case SellerOnboardingStage.menuCatalogue:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Please configure your Menu Categories.',
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
              Navigator.pushReplacementNamed(
                context,
                '/menuCategories',
                arguments: {'isOnboardingFlow': true},
              );
              break;

            case SellerOnboardingStage.bankDetails:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Please link your Bank Account for Payouts.',
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
              Navigator.pushReplacementNamed(
                context,
                '/sellerPayment',
                arguments: {'isOnboardingFlow': true},
              );
              break;

            case SellerOnboardingStage.logisticsAlerts:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Please configure Delivery Logistics & Audio Alerts.',
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
              Navigator.pushReplacementNamed(
                context,
                '/sellerLogisticsAlerts',
                arguments: {'isOnboardingFlow': true},
              );
              break;

            case SellerOnboardingStage.checklistLaunch:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Review checklist and Launch your store.',
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
              Navigator.pushReplacementNamed(
                context,
                '/sellerStoreLaunch',
                arguments: {'isOnboardingFlow': true},
              );
              break;

            case SellerOnboardingStage.completed:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful! Welcome to Seller Dashboard.',
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
              Navigator.pushReplacementNamed(context, '/sellerDashboard');
              break;
          }
        }
        if (state.status == SellerLoginStatus.failure &&
            state.errorMessage != null) {
          _showErrorSnackBar(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: SellerAuthColors.background,
        body: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
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

  Widget _buildScreen(BuildContext context, SellerLoginPageState state) {
    switch (state.step) {
      case SellerLoginStep.loginForm:
        return const _LoginFormScreen(key: ValueKey('login_form'));
      case SellerLoginStep.enterEmailPhone:
        return const _EnterEmailPhoneScreen(key: ValueKey('enter_email_phone'));
      case SellerLoginStep.enterPassword:
        return const _EnterPasswordScreen(key: ValueKey('enter_password'));
      case SellerLoginStep.otpVerification:
        return BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              previous != current,
          builder: (context, state) => SellerOtpVerificationScreen(
            key: const ValueKey('otp_verify'),
            title: 'Email Verification',
            subtitleValue: state.emailOrPhone,
            verifyLabel: 'Verify',
            isLoading: state.status == SellerLoginStatus.loading,
            countdown: state.otpCountdown,
            resendAvailable: state.isOtpResendAvailable,
            alwaysShowCountdownSlot: true,
            showStepFooter: true,
            stepFooterText: '4. Email OTP Verification',
            onBack: () =>
                context.read<SellerLoginPageBloc>().add(
                  const SellerLoginBackPressed(),
                ),
            onDigitChanged: (index, digit) => context
                .read<SellerLoginPageBloc>()
                .add(
                  SellerLoginOtpDigitChanged(
                    index: index,
                    digit: digit,
                  ),
                ),
            onResend: () => context.read<SellerLoginPageBloc>().add(
              const SellerLoginOtpResendRequested(),
            ),
            onVerify: () => context.read<SellerLoginPageBloc>().add(
              const SellerLoginOtpVerifySubmitted(),
            ),
          ),
        );
      case SellerLoginStep.loginSuccess:
        return const _LoginSuccessScreen(key: ValueKey('login_success'));
      case SellerLoginStep.forgotPassword:
        return const _ForgotPasswordScreen(key: ValueKey('forgot_password'));
      case SellerLoginStep.forgotPasswordSuccess:
        return const _ForgotPasswordSuccessScreen(
          key: ValueKey('forgot_success'),
        );
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rounded text field matching the UI.
// ─────────────────────────────────────────────────────────────────────────────
class _LoginTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final String? errorText;
  final TextInputAction textInputAction;
  final String? initialValue;

  const _LoginTextField({
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
  State<_LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<_LoginTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _LoginTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          style: GoogleFonts.inter(fontSize: 14, color: SellerAuthColors.textDark),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: SellerAuthColors.textLight,
            ),
            prefixIcon: Icon(widget.prefixIcon, color: SellerAuthColors.textLight, size: 20),
            suffixIcon: widget.suffixWidget,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: SellerAuthColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: SellerAuthColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: SellerAuthColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SellerAuthColors.error, width: 1.5),
            ),
            errorText: widget.errorText,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 1 – Login Form (Welcome Back!)
// ─────────────────────────────────────────────────────────────────────────────
class _LoginFormScreen extends StatefulWidget {
  const _LoginFormScreen({super.key});

  @override
  State<_LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<_LoginFormScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType || previous != current,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              return _buildDesktopLayout(context, state);
            }
            return _buildMobileLayout(context, state);
          },
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    SellerLoginPageState state,
  ) {
    return SellerResponsiveContainer(
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // Language selector
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.language,
                        size: 18,
                        color: SellerAuthColors.textMid,
                      ),
                      label: Text(
                        'English ▾',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: SellerAuthColors.textMid,
                        ),
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Shop illustration
                  SellerScreenIllustration(
                    heroTag: 'seller_login_illustration',
                    child: Image.asset(
                      'assets/images/Seller_login.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.storefront_rounded,
                        size: 52,
                        color: SellerAuthColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: SellerAuthColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Login to continue',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: SellerAuthColors.textLight,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Phone Number field
                  _LoginTextField(
                    initialValue: state.emailOrPhone,
                    hintText: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    onChanged: (v) => context
                        .read<SellerLoginPageBloc>()
                        .add(SellerLoginFieldChanged(v)),
                    keyboardType: TextInputType.phone,
                    errorText: state.emailPhoneError,
                  ),

                  const SizedBox(height: 14),

                  // Password field
                  _LoginTextField(
                    initialValue: state.password,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: state.isPasswordObscured,
                    onChanged: (v) => context
                        .read<SellerLoginPageBloc>()
                        .add(SellerLoginPasswordChanged(v)),
                    textInputAction: TextInputAction.done,
                    errorText: state.passwordError,
                    suffixWidget: IconButton(
                      icon: Icon(
                        state.isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: SellerAuthColors.textLight,
                        size: 20,
                      ),
                      onPressed: () => context
                          .read<SellerLoginPageBloc>()
                          .add(SellerLoginPasswordVisibilityToggled()),
                    ),
                  ),

                  // Forgot Password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context
                          .read<SellerLoginPageBloc>()
                          .add(const SellerLoginForgotPasswordNavigated()),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          color: SellerAuthColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Login button
                  SellerPrimaryButton(
                    label: 'Login',
                    isLoading: state.status == SellerLoginStatus.loading,
                    onPressed: () => context
                        .read<SellerLoginPageBloc>()
                        .add(const SellerLoginSubmitted()),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: SellerAuthColors.divider),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: GoogleFonts.inter(
                            color: SellerAuthColors.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: SellerAuthColors.divider),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Social buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        label: 'Google',
                        asset: 'assets/images/google.png',
                        fallbackIcon: Icons.g_mobiledata,
                        onTap: () => context
                            .read<SellerLoginPageBloc>()
                            .add(const SellerLoginGoogleSignInPressed()),
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        label: 'Apple',
                        asset: 'assets/images/apple_logo.png',
                        fallbackIcon: Icons.apple,
                        onTap: () => context
                            .read<SellerLoginPageBloc>()
                            .add(const SellerLoginAppleSignInPressed()),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Sign up prompt
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: SellerAuthColors.textMid,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/sellerSignUp'),
                        child: Text(
                          'Sign up',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: SellerAuthColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    SellerLoginPageState state,
  ) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Row(
        children: [
          // Left showcase pane (42% width)
          Expanded(
            flex: 5,
            child: _SellerDesktopLeftHero(),
          ),

          // Right auth form pane (58% width)
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Top Language Picker
                  Padding(
                    padding: const EdgeInsets.only(top: 24, right: 36),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.language,
                          size: 18,
                          color: SellerAuthColors.textMid,
                        ),
                        label: Text(
                          'English ▾',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: SellerAuthColors.textMid,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Centered Form
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Storefront circular badge
                              Center(
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/Seller_login.png',
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.storefront_rounded,
                                        size: 42,
                                        color: SellerAuthColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'Welcome Back!',
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: SellerAuthColors.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  'Login to continue',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: SellerAuthColors.textLight,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Phone Number field
                              _LoginTextField(
                                initialValue: state.emailOrPhone,
                                hintText: 'Phone Number',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                onChanged: (v) => context
                                    .read<SellerLoginPageBloc>()
                                    .add(SellerLoginFieldChanged(v)),
                                errorText: state.emailPhoneError,
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              _LoginTextField(
                                initialValue: state.password,
                                hintText: 'Password',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: state.isPasswordObscured,
                                onChanged: (v) => context
                                    .read<SellerLoginPageBloc>()
                                    .add(SellerLoginPasswordChanged(v)),
                                textInputAction: TextInputAction.done,
                                errorText: state.passwordError,
                                suffixWidget: IconButton(
                                  icon: Icon(
                                    state.isPasswordObscured
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: SellerAuthColors.textLight,
                                    size: 20,
                                  ),
                                  onPressed: () => context
                                      .read<SellerLoginPageBloc>()
                                      .add(
                                        SellerLoginPasswordVisibilityToggled(),
                                      ),
                                ),
                              ),

                              // Forgot Password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context
                                      .read<SellerLoginPageBloc>()
                                      .add(
                                        const SellerLoginForgotPasswordNavigated(),
                                      ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.inter(
                                      color: SellerAuthColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Primary Login button
                              SellerPrimaryButton(
                                label: 'Login',
                                isLoading:
                                    state.status == SellerLoginStatus.loading,
                                onPressed: () => context
                                    .read<SellerLoginPageBloc>()
                                    .add(const SellerLoginSubmitted()),
                              ),
                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(
                                      color: SellerAuthColors.divider,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'or continue with',
                                      style: GoogleFonts.inter(
                                        color: SellerAuthColors.textLight,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: SellerAuthColors.divider,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Social buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SocialButton(
                                    label: 'Google',
                                    asset: 'assets/images/google.png',
                                    fallbackIcon: Icons.g_mobiledata,
                                    onTap: () => context
                                        .read<SellerLoginPageBloc>()
                                        .add(
                                          const SellerLoginGoogleSignInPressed(),
                                        ),
                                  ),
                                  const SizedBox(width: 16),
                                  _SocialButton(
                                    label: 'Apple',
                                    asset: 'assets/images/apple_logo.png',
                                    fallbackIcon: Icons.apple,
                                    onTap: () => context
                                        .read<SellerLoginPageBloc>()
                                        .add(
                                          const SellerLoginAppleSignInPressed(),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // Sign up prompt
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: SellerAuthColors.textMid,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/sellerSignUp',
                                    ),
                                    child: Text(
                                      'Sign up',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: SellerAuthColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop Left Showcase Panel
// ─────────────────────────────────────────────────────────────────────────────
class _SellerDesktopLeftHero extends StatelessWidget {
  const _SellerDesktopLeftHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4FAF5),
        border: Border(
          right: BorderSide(color: Color(0xFFEAEAEA), width: 1),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7FCF8),
            Color(0xFFEFF7F1),
            Color(0xFFE5F3E7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle dot matrix pattern in top-left
          Positioned(
            left: 0,
            top: 0,
            width: 220,
            height: 220,
            child: const CustomPaint(
              painter: _DotPatternPainter(),
            ),
          ),

          // Main content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 48,
                        top: 48,
                        right: 48,
                        bottom: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Small Store Icon Badge
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE0ECE1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/images/Seller_login.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                size: 22,
                                color: SellerAuthColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Header
                          Text(
                            'Welcome Back!',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: SellerAuthColors.textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'Good to see you again! Continue your journey and grow your business.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: SellerAuthColors.textMid,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // 3 Feature highlights
                          const _DesktopFeatureRow(
                            icon: Icons.shield_outlined,
                            title: 'Secure & Reliable',
                            description:
                                'Your data is protected with enterprise-grade security.',
                          ),
                          const SizedBox(height: 24),
                          const _DesktopFeatureRow(
                            icon: Icons.bar_chart_rounded,
                            title: 'Manage with Ease',
                            description:
                                'Track orders, manage inventory and grow your business.',
                          ),
                          const SizedBox(height: 24),
                          const _DesktopFeatureRow(
                            icon: Icons.headset_mic_outlined,
                            title: '24/7 Support',
                            description:
                                "We're here to help you anytime, anywhere.",
                          ),
                          const Spacer(),

                          // Storefront Illustration at bottom
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 240,
                                maxWidth: 300,
                              ),
                              child: Image.asset(
                                'assets/images/Seller_login2.png',
                                height: 220,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.storefront_rounded,
                                  size: 100,
                                  color: SellerAuthColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop Feature Item Row
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopFeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _DesktopFeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFDFF1E2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: SellerAuthColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: SellerAuthColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: SellerAuthColors.textMid,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtle Dot Pattern Painter
// ─────────────────────────────────────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    const double spacing = 16.0;
    const double radius = 1.8;
    for (double x = 12; x < size.width; x += spacing) {
      for (double y = 12; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Social button
// ─────────────────────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final String asset;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.asset,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: SellerAuthColors.inputBorder),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Center(
          child: Image.asset(
            asset,
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) =>
                Icon(fallbackIcon, size: 28, color: SellerAuthColors.textMid),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 2 – Enter Phone Number
// ─────────────────────────────────────────────────────────────────────────────
class _EnterEmailPhoneScreen extends StatelessWidget {
  const _EnterEmailPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SellerResponsiveContainer(
      child: SafeArea(
        child: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  SellerBackButton(
                    onTap: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginBackPressed(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: SellerScreenIllustration(
                      heroTag: 'email_phone_illustration',
                      child: const Icon(
                        Icons.phone_android_rounded,
                        size: 52,
                        color: SellerAuthColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'Enter Phone Number',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: SellerAuthColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Enter your phone number to continue',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: SellerAuthColors.textLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _LoginTextField(
                    initialValue: state.emailOrPhone,
                    hintText: '+91 98765 43210',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => context.read<SellerLoginPageBloc>().add(
                      SellerLoginFieldChanged(v),
                    ),
                    errorText: state.emailPhoneError,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  SellerPrimaryButton(
                    label: 'Continue',
                    isLoading: state.status == SellerLoginStatus.loading,
                    onPressed: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginEmailPhoneContinued(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '2. Enter Phone Number',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: SellerAuthColors.textLight,
                      ),
                    ),
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
// Screen 3 – Enter Password
// ─────────────────────────────────────────────────────────────────────────────
class _EnterPasswordScreen extends StatelessWidget {
  const _EnterPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SellerResponsiveContainer(
      child: SafeArea(
        child: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  SellerBackButton(
                    onTap: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginBackPressed(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: SellerScreenIllustration(
                      heroTag: 'password_illustration',
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 52,
                        color: SellerAuthColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'Enter Password',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: SellerAuthColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Enter your password',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: SellerAuthColors.textLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _LoginTextField(
                    initialValue: state.password,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: state.isPasswordObscured,
                    onChanged: (v) => context.read<SellerLoginPageBloc>().add(
                      SellerLoginPasswordChanged(v),
                    ),
                    textInputAction: TextInputAction.done,
                    errorText: state.passwordError,
                    suffixWidget: IconButton(
                      icon: Icon(
                        state.isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: SellerAuthColors.textLight,
                        size: 20,
                      ),
                      onPressed: () => context.read<SellerLoginPageBloc>().add(
                        SellerLoginPasswordVisibilityToggled(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.read<SellerLoginPageBloc>().add(
                        const SellerLoginForgotPasswordNavigated(),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          color: SellerAuthColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SellerPrimaryButton(
                    label: 'Login',
                    isLoading: state.status == SellerLoginStatus.loading,
                    onPressed: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginPasswordStepSubmitted(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '3. Enter Password',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: SellerAuthColors.textLight,
                      ),
                    ),
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
// Screen 5 – Login Successful
// ─────────────────────────────────────────────────────────────────────────────
class _LoginSuccessScreen extends StatefulWidget {
  const _LoginSuccessScreen({super.key});

  @override
  State<_LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<_LoginSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
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
        child: Padding(
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
                    gradient: RadialGradient(
                      colors: [SellerAuthColors.primaryLight, SellerAuthColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SellerAuthColors.primary.withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Login Successful',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: SellerAuthColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back!',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: SellerAuthColors.textLight,
                ),
              ),
              const SizedBox(height: 48),
              BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
                builder: (context, state) {
                  final isKyc = state.isKycCompleted;
                  return SellerPrimaryButton(
                    label: isKyc ? 'Go to Dashboard' : 'Complete KYC Verification',
                    onPressed: () {
                      context.read<SellerLoginPageBloc>().add(
                        const SellerLoginGoToDashboardPressed(),
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        isKyc ? '/sellerDashboard' : '/sellerVerificationForm',
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '5. Login Success',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: SellerAuthColors.textLight,
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

// ─────────────────────────────────────────────────────────────────────────────
// Screen 6 – Forgot Password (Phone OTP + Password Reset)
// ─────────────────────────────────────────────────────────────────────────────
class _ForgotPasswordScreen extends StatelessWidget {
  const _ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SellerForgotPasswordPageUI();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 7 – Forgot Password Success (Link Sent)
// ─────────────────────────────────────────────────────────────────────────────
class _ForgotPasswordSuccessScreen extends StatefulWidget {
  const _ForgotPasswordSuccessScreen({super.key});

  @override
  State<_ForgotPasswordSuccessScreen> createState() =>
      _ForgotPasswordSuccessScreenState();
}

class _ForgotPasswordSuccessScreenState
    extends State<_ForgotPasswordSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SellerResponsiveContainer(
      child: SafeArea(
        child: Padding(
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
                    gradient: RadialGradient(
                      colors: [SellerAuthColors.primaryLight, SellerAuthColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SellerAuthColors.primary.withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Link Sent',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: SellerAuthColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent a password reset\nlink to your email.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: SellerAuthColors.textLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SellerPrimaryButton(
                label: 'Back to Login',
                onPressed: () {
                  context.read<SellerLoginPageBloc>().add(
                    const SellerLoginBackToLoginPressed(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '7. Forgot Password Success',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: SellerAuthColors.textLight,
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
