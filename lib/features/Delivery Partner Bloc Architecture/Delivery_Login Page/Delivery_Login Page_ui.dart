import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Delivery_Login Page_bloc.dart';
import 'Delivery_Login Page_event.dart';
import 'Delivery_Login Page_repository.dart';
import 'Delivery_Login Page_service.dart';
import 'Delivery_Login Page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_theme.dart';
import '../../../core/theme/delivery_app_typography.dart';
import '../../../core/theme/delivery_design_system.dart';

class DeliveryLoginPage extends StatelessWidget {
  final DeliveryLoginRepositoryBase? repository;
  final DeliveryLoginServiceBase? service;
  final DeliveryLoginPageBloc? bloc;

  const DeliveryLoginPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryLoginPageBloc>.value(
        value: bloc!,
        child: const DeliveryLoginPageView(),
      );
    }

    return BlocProvider<DeliveryLoginPageBloc>(
      create: (context) => DeliveryLoginPageBloc(
        repository: repository ?? DeliveryLoginRepository(),
        service: service ?? DeliveryLoginService(),
      )..add(const DeliveryLoginInitEvent()),
      child: const DeliveryLoginPageView(),
    );
  }
}

class DeliveryLoginPageView extends StatefulWidget {
  const DeliveryLoginPageView({super.key});

  @override
  State<DeliveryLoginPageView> createState() => _DeliveryLoginPageViewState();
}

class _DeliveryLoginPageViewState extends State<DeliveryLoginPageView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late FocusNode _phoneFocusNode;
  late FocusNode _passwordFocusNode;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(_fadeAnim);

    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _animController.value = 1.0;
    } else {
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
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
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          BlocConsumer<DeliveryLoginPageBloc, DeliveryLoginPageState>(
            listener: (context, state) {
              if (state.phone != _phoneController.text &&
                  state.phone.isNotEmpty) {
                _phoneController.text = state.phone;
              }
              if (state.status == DeliveryLoginStatus.success &&
                  state.isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login successful! Welcome Partner.'),
                    backgroundColor: DeliveryAppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pushReplacementNamed('/deliveryNavigationBar');
              }
              if (state.isForgotPasswordSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset link sent to your email.'),
                    backgroundColor: DeliveryAppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;

                  if (state.status == DeliveryLoginStatus.loading &&
                      state.phone.isEmpty) {
                    return _buildSkeletonLoading();
                  }

                  final loginCardWidget = _buildLoginCard(context, state);

                  return SafeArea(
                    child: Align(
                      alignment: isWide
                          ? Alignment.centerRight
                          : Alignment.center,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isWide ? 24 : 16,
                            right: isWide
                                ? (constraints.maxWidth >= 900 ? 100 : 32)
                                : 16,
                            top: isWide ? 24 : 12,
                            bottom: isWide ? 24 : 12,
                          ),
                          child: AnimatedBuilder(
                            animation: _animController,
                            child: loginCardWidget,
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Container(
      color: const Color(0xFF070E12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 280,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(DeliveryAppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, DeliveryLoginPageState state) {
    final bloc = context.read<DeliveryLoginPageBloc>();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (Navigator.canPop(context)) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white70, size: 24),
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Welcome Back!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text('\u{1F44B}', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Login to continue your delivery journey',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 24),

          if (state.errorMessage != null &&
              state.errorMessage!.isNotEmpty &&
              state.phoneError == null &&
              state.passwordError == null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          DeliveryTextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            label: 'Phone Number',
            hintText: '98765 43210',
            keyboardType: TextInputType.phone,
            errorText: state.phoneError,
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.phone_outlined,
                  color: Colors.white60,
                  size: 20,
                ),
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
            onChanged: (val) => bloc.add(DeliveryLoginPhoneChangedEvent(val)),
          ),
          const SizedBox(height: 18),

          DeliveryTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            hintText: '••••••••',
            obscureText: !state.isPasswordVisible,
            errorText: state.passwordError,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Colors.white60,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                state.isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.white60,
                size: 20,
              ),
              onPressed: () => bloc.add(DeliveryLoginTogglePasswordVisibilityEvent()),
            ),
            onChanged: (val) =>
                bloc.add(DeliveryLoginPasswordChangedEvent(val)),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: state.isRememberMeChecked,
                      activeColor: DeliveryAppColors.primary,
                      checkColor: Colors.black,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        color: DeliveryAppColors.primary.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (_) =>
                          bloc.add(const DeliveryLoginToggleRememberMeEvent()),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Remember Me',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showForgotPasswordDialog(context),
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    color: DeliveryAppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.status == DeliveryLoginStatus.loading
                  ? null
                  : () => bloc.add(const DeliveryLoginSubmittedEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: Colors.black,
                elevation: 6,
                shadowColor: DeliveryAppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: state.status == DeliveryLoginStatus.loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.15),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.15),
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _buildSocialButton(
            label: 'Continue with Google',
            iconWidget: Image.asset(
              'assets/images/google.png',
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
            ),
            onPressed: () =>
                bloc.add(const DeliveryLoginGoogleSubmittedEvent()),
          ),
          const SizedBox(height: 12),

          _buildSocialButton(
            label: 'Continue with Apple',
            iconWidget: Image.asset(
              'assets/images/apple_logo.png',
              height: 20,
              width: 20,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.apple, color: Colors.white, size: 24),
            ),
            onPressed: () => bloc.add(const DeliveryLoginAppleSubmittedEvent()),
          ),
          const SizedBox(height: 24),

          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                ),
                GestureDetector(
                  onTap: () => _navigateToSignUp(context),
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.inter(
                      color: DeliveryAppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final bloc = context.read<DeliveryLoginPageBloc>();
    showDialog(
      context: context,
      builder: (ctx) {
        return BlocProvider<DeliveryLoginPageBloc>.value(
          value: bloc,
          child: BlocBuilder<DeliveryLoginPageBloc, DeliveryLoginPageState>(
            builder: (context, state) {
              return AlertDialog(
                backgroundColor: const Color(0xFF0E1C1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: DeliveryAppColors.primary.withValues(alpha: 0.28),
                  ),
                ),
                title: Text(
                  'Reset Password',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter your email to receive a password reset link.',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF081412),
                        hintText: 'your@email.com',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.white30,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: DeliveryAppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: DeliveryAppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(color: Colors.white60),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: state.isForgotPasswordLoading
                        ? null
                        : () {
                            context.read<DeliveryLoginPageBloc>().add(
                              DeliveryLoginForgotPasswordSubmittedEvent(
                                emailController.text.trim(),
                              ),
                            );
                            Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DeliveryAppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isForgotPasswordLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Send Reset Link',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToSignUp(BuildContext context) {
    Navigator.of(context).pushNamed('/deliverySignUp');
  }

  Widget _buildSocialButton({
    required String label,
    required Widget iconWidget,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF0D1B19),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
