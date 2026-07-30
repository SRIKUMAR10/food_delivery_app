import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Delivery_Login Page_page_bloc.dart';
import 'Delivery_Login Page_page_event.dart';
import 'Delivery_Login Page_page_repository.dart';
import 'Delivery_Login Page_page_service.dart';
import 'Delivery_Login Page_page_state.dart';

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

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

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
      backgroundColor: const Color(0xFF091015),
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
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
          BlocConsumer<DeliveryLoginPageBloc, DeliveryLoginPageState>(
        listener: (context, state) {
          if (state.phone != _phoneController.text && state.phone.isNotEmpty) {
            _phoneController.text = state.phone;
          }
          if (state.status == DeliveryLoginStatus.success && state.isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful! Welcome Partner.'),
                backgroundColor: Color(0xFF00E676),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              if (state.status == DeliveryLoginStatus.loading && state.phone.isEmpty) {
                return _buildSkeletonLoading();
              }

              final loginCardWidget = _buildLoginCard(context, state);

              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 16,
                        vertical: isDesktop ? 24 : 12,
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
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 280,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
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
        color: const Color(0xFF091413).withOpacity(0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
              const Text(
                '👋',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Login to continue your delivery journey',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
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

          // Phone field label
          Text(
            'Phone Number',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF081412),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.25)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
              ),
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.phone_outlined, color: Colors.white60, size: 20),
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
              hintText: '98765 43210',
              hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (val) => bloc.add(DeliveryLoginPhoneChangedEvent(val)),
          ),
          const SizedBox(height: 18),

          // Password field label
          Text(
            'Password',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !state.isPasswordVisible,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF081412),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.25)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
              ),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  state.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white60,
                  size: 20,
                ),
                onPressed: () => bloc.add(const DeliveryLoginTogglePasswordVisibilityEvent()),
              ),
              hintText: '••••••••••',
              hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (val) => bloc.add(DeliveryLoginPasswordChangedEvent(val)),
          ),
          const SizedBox(height: 14),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: state.isRememberMeChecked,
                      activeColor: const Color(0xFF00E676),
                      checkColor: Colors.black,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        color: const Color(0xFF00E676).withOpacity(0.6),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (_) => bloc.add(const DeliveryLoginToggleRememberMeEvent()),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Remember Me',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset instructions sent to your registered phone.'),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00E676),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.status == DeliveryLoginStatus.loading
                  ? null
                  : () => bloc.add(const DeliveryLoginSubmittedEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                elevation: 6,
                shadowColor: const Color(0xFF00E676).withOpacity(0.4),
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
                        const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 22),

          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.white.withOpacity(0.15),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.white.withOpacity(0.15),
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Google Button
          _buildSocialButton(
            label: 'Continue with Google',
            iconWidget: Image.asset(
              'assets/images/google.png',
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
            ),
            onPressed: () => bloc.add(const DeliveryLoginGoogleSubmittedEvent()),
          ),
          const SizedBox(height: 12),

          // Apple Button
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

          // Footer Sign Up text
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigating to Delivery Partner Registration...'),
                    ),
                  );
                },
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00E676),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          side: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
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
