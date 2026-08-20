import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/widgets/primary_button.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'seller_login_page_bloc.dart';
import 'seller_login_page_event.dart';
import 'seller_login_page_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens (Material 3 green theme — pixel-perfect from UI image)
// ─────────────────────────────────────────────────────────────────────────────
class _AppColors {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login successful! Welcome Seller.',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: _AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pushReplacementNamed(context, '/sellerDashboard');
        }
        if (state.status == SellerLoginStatus.failure &&
            state.errorMessage != null) {
          _showErrorSnackBar(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: _AppColors.background,
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
        return const _OtpVerificationScreen(key: ValueKey('otp_verify'));
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
          backgroundColor: _AppColors.error,
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

/// Green gradient primary button (shared PrimaryButton with login styling).
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
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

/// Rounded text field matching the UI.
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
          style: GoogleFonts.inter(fontSize: 14, color: _AppColors.textDark),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: _AppColors.textLight,
            ),
            prefixIcon: Icon(widget.prefixIcon, color: _AppColors.textLight, size: 20),
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
                color: _AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _AppColors.error, width: 1.5),
            ),
            errorText: widget.errorText,
          ),
        ),
      ],
    );
  }
}

/// Illustration container with hero animation.
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
    return _ResponsiveContainer(
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
              buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
                return SingleChildScrollView(
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
                            color: _AppColors.textMid,
                          ),
                          label: Text(
                            'English ▾',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _AppColors.textMid,
                            ),
                          ),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Shop illustration
                      _ScreenIllustration(
                        heroTag: 'seller_login_illustration',
                        child: Image.asset(
                          'assets/images/Seller_login.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.storefront_rounded,
                            size: 52,
                            color: _AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Login to continue',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _AppColors.textLight,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email / Phone field
                      _LoginTextField(
                        initialValue: state.emailOrPhone,
                        hintText: 'Email / Phone',
                        prefixIcon: Icons.email_outlined,
                        onChanged: (v) => context
                            .read<SellerLoginPageBloc>()
                            .add(SellerLoginFieldChanged(v)),
                        keyboardType: TextInputType.emailAddress,
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
                            color: _AppColors.textLight,
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
                              color: _AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Login button
                      _PrimaryButton(
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
                            child: Divider(color: _AppColors.divider),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or continue with',
                              style: GoogleFonts.inter(
                                color: _AppColors.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: _AppColors.divider),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _AppColors.textMid,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/sellerSignUp'),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: _AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
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
          border: Border.all(color: _AppColors.inputBorder),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Center(
          child: Image.asset(
            asset,
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) =>
                Icon(fallbackIcon, size: 28, color: _AppColors.textMid),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 2 – Enter Email / Phone
// ─────────────────────────────────────────────────────────────────────────────
class _EnterEmailPhoneScreen extends StatelessWidget {
  const _EnterEmailPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
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
                  _BackButton(
                    onTap: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginBackPressed(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _ScreenIllustration(
                      heroTag: 'email_phone_illustration',
                      child: const Icon(
                        Icons.phone_android_rounded,
                        size: 52,
                        color: _AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'Enter Email / Phone',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Enter your email address or\nphone number to continue',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _AppColors.textLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _LoginTextField(
                    initialValue: state.emailOrPhone,
                    hintText: 'john@gmail.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => context.read<SellerLoginPageBloc>().add(
                      SellerLoginFieldChanged(v),
                    ),
                    errorText: state.emailPhoneError,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: 'Continue',
                    isLoading: state.status == SellerLoginStatus.loading,
                    onPressed: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginEmailPhoneContinued(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '2. Enter Email / Phone',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _AppColors.textLight,
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
    return _ResponsiveContainer(
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
                  _BackButton(
                    onTap: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginBackPressed(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _ScreenIllustration(
                      heroTag: 'password_illustration',
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 52,
                        color: _AppColors.primary,
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
                        color: _AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Enter your password',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _AppColors.textLight,
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
                        color: _AppColors.textLight,
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
                          color: _AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PrimaryButton(
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
                        color: _AppColors.textLight,
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
// Screen 4 – OTP Verification
// ─────────────────────────────────────────────────────────────────────────────
class _OtpVerificationScreen extends StatefulWidget {
  const _OtpVerificationScreen({super.key});

  @override
  State<_OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<_OtpVerificationScreen> {
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
    return _ResponsiveContainer(
      child: SafeArea(
        child: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
            final email = state.emailOrPhone;
            final countdown = state.otpCountdown;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.topLeft,
                    child: _BackButton(
                      onTap: () => context.read<SellerLoginPageBloc>().add(
                        const SellerLoginBackPressed(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ScreenIllustration(
                    heroTag: 'otp_illustration',
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const Icon(
                          Icons.mark_email_read_rounded,
                          size: 52,
                          color: _AppColors.primary,
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: _AppColors.primaryLight,
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
                    'Email Verification',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: "We've sent a 6-digit OTP to\n",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _AppColors.textLight,
                      ),
                      children: [
                        TextSpan(
                          text: email,
                          style: GoogleFonts.inter(
                            color: _AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '\nEnter the OTP below to verify',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: _AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 6-digit OTP boxes
                  _OtpBoxRow(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    onDigitChanged: (index, digit) =>
                        context.read<SellerLoginPageBloc>().add(
                          SellerLoginOtpDigitChanged(
                            index: index,
                            digit: digit,
                          ),
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Countdown
                  Text(
                    state.isOtpResendAvailable
                        ? ''
                        : 'Resend OTP in 00:${countdown.toString().padLeft(2, '0')}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _AppColors.textLight,
                    ),
                  ),

                  if (state.isOtpResendAvailable)
                    TextButton(
                      onPressed: () => context.read<SellerLoginPageBloc>().add(
                        const SellerLoginOtpResendRequested(),
                      ),
                      child: Text(
                        'Resend OTP',
                        style: GoogleFonts.inter(
                          color: _AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  _PrimaryButton(
                    label: 'Verify',
                    isLoading: state.status == SellerLoginStatus.loading,
                    onPressed: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginOtpVerifySubmitted(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '4. Email OTP Verification',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _AppColors.textLight,
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
// OTP Box Row (shared for screens 4 & 7)
// ─────────────────────────────────────────────────────────────────────────────
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
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _AppColors.textDark,
            ),
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
                borderSide: const BorderSide(
                  color: _AppColors.primary,
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
    return _ResponsiveContainer(
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
                      colors: [_AppColors.primaryLight, _AppColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _AppColors.primary.withValues(alpha: 0.35),
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
                  color: _AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back!',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: _AppColors.textLight,
                ),
              ),
              const SizedBox(height: 48),
              _PrimaryButton(
                label: 'Go to Dashboard',
                onPressed: () {
                  context.read<SellerLoginPageBloc>().add(
                    const SellerLoginGoToDashboardPressed(),
                  );
                  Navigator.pushReplacementNamed(context, '/sellerDashboard');
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '5. Login Success',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _AppColors.textLight,
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
// Screen 6 – Forgot Password (Send OTP)
// ─────────────────────────────────────────────────────────────────────────────
class _ForgotPasswordScreen extends StatelessWidget {
  const _ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
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
                  _BackButton(
                    onTap: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginBackPressed(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _ScreenIllustration(
                      heroTag: 'forgot_pw_illustration',
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            size: 52,
                            color: _AppColors.primary,
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.question_mark,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'Forgot Password',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Enter your email and we'll\nsend you a link to reset\nyour password",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _AppColors.textLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _LoginTextField(
                    initialValue: state.forgotPasswordEmail,
                    hintText: 'john@gmail.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => context.read<SellerLoginPageBloc>().add(
                      SellerLoginForgotPasswordEmailChanged(v),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: 'Send Reset Link',
                    isLoading: state.status == SellerLoginStatus.loading,
                    onPressed: () => context.read<SellerLoginPageBloc>().add(
                      const SellerLoginForgotPasswordLinkSent(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '6. Forgot Password – Send Link',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _AppColors.textLight,
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
    return _ResponsiveContainer(
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
                      colors: [_AppColors.primaryLight, _AppColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _AppColors.primary.withValues(alpha: 0.35),
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
                  color: _AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent a password reset\nlink to your email.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: _AppColors.textLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              _PrimaryButton(
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
                    color: _AppColors.textLight,
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
// Shared back button
// ─────────────────────────────────────────────────────────────────────────────
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
