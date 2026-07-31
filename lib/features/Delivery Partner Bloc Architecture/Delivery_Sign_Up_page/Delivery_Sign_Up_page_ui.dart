import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Delivery_Sign_Up_page_bloc.dart';
import 'Delivery_Sign_Up_page_event.dart';
import 'Delivery_Sign_Up_page_repository.dart';
import 'Delivery_Sign_Up_page_service.dart';
import 'Delivery_Sign_Up_page_state.dart';
import '../Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_ui.dart';

class DeliverySignUpPage extends StatelessWidget {
  final DeliverySignUpRepositoryBase? repository;
  final DeliverySignUpServiceBase? service;
  final DeliverySignUpPageBloc? bloc;

  const DeliverySignUpPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliverySignUpPageBloc>.value(
        value: bloc!,
        child: const DeliverySignUpPageView(),
      );
    }

    return BlocProvider<DeliverySignUpPageBloc>(
      create: (context) => DeliverySignUpPageBloc(
        repository: repository ??
            DeliverySignUpRepository(),
        service: service ?? DeliverySignUpService(),
      )..add(const DeliverySignUpInitEvent()),
      child: const DeliverySignUpPageView(),
    );
  }
}

class DeliverySignUpPageView extends StatefulWidget {
  const DeliverySignUpPageView({super.key});

  @override
  State<DeliverySignUpPageView> createState() =>
      _DeliverySignUpPageViewState();
}

class _DeliverySignUpPageViewState extends State<DeliverySignUpPageView>
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
          BlocConsumer<DeliverySignUpPageBloc, DeliverySignUpPageState>(
            listener: (context, state) {
              if (state.status == DeliverySignUpStatus.otpSent &&
                  state.verificationId != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => DeliveryOtpVerificationPage(
                      verificationId: state.verificationId!,
                      name: state.name.trim(),
                      phone: state.phone.trim(),
                      email: state.email.trim(),
                      password: state.password,
                    ),
                  ),
                );
              }
              if (state.status == DeliverySignUpStatus.success &&
                  state.isSignedUp) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Account created successfully! Welcome Partner.'),
                    backgroundColor: Color(0xFF00E676),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;

                  return SafeArea(
                    child: Align(
                      alignment: isWide ? Alignment.centerRight : Alignment.center,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isWide ? 24 : 16,
                            right: isWide ? (constraints.maxWidth >= 900 ? 100 : 32) : 16,
                            top: isWide ? 24 : 12,
                            bottom: isWide ? 24 : 12,
                          ),
                          child: AnimatedBuilder(
                            animation: _animController,
                            child: _buildSignUpCard(context, state),
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

  Widget _buildSignUpCard(
      BuildContext context, DeliverySignUpPageState state) {
    final bloc = context.read<DeliverySignUpPageBloc>();

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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                color: Colors.white70, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Join as Partner',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your delivery partner account',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          if (state.errorMessage != null &&
              state.errorMessage!.isNotEmpty &&
              state.nameError == null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 20),
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

          _buildLabel('Full Name'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: 'John Doe',
            errorText: state.nameError,
            onChanged: (v) =>
                bloc.add(DeliverySignUpNameChanged(v)),
          ),
          const SizedBox(height: 16),

          _buildLabel('Phone Number'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: '98765 43210',
            prefix: '+91',
            keyboardType: TextInputType.phone,
            errorText: state.phoneError,
            onChanged: (v) =>
                bloc.add(DeliverySignUpPhoneChanged(v)),
          ),
          const SizedBox(height: 16),

          _buildLabel('Email Address'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: 'your@email.com',
            keyboardType: TextInputType.emailAddress,
            errorText: state.emailError,
            onChanged: (v) =>
                bloc.add(DeliverySignUpEmailChanged(v)),
          ),
          const SizedBox(height: 16),

          _buildLabel('Password'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            obscure: !state.isPasswordObscured,
            errorText: state.passwordError,
            onChanged: (v) =>
                bloc.add(DeliverySignUpPasswordChanged(v)),
            suffix: IconButton(
              icon: Icon(
                state.isPasswordObscured
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white60,
                size: 20,
              ),
              onPressed: () => bloc
                  .add(const DeliverySignUpPasswordVisibilityToggled()),
            ),
          ),
          const SizedBox(height: 16),

          _buildLabel('Confirm Password'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            obscure: !state.isConfirmPasswordObscured,
            errorText: state.confirmPasswordError,
            onChanged: (v) =>
                bloc.add(DeliverySignUpConfirmPasswordChanged(v)),
            suffix: IconButton(
              icon: Icon(
                state.isConfirmPasswordObscured
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white60,
                size: 20,
              ),
              onPressed: () => bloc.add(
                  const DeliverySignUpConfirmPasswordVisibilityToggled()),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Checkbox(
                value: state.termsAccepted,
                activeColor: const Color(0xFF00E676),
                checkColor: Colors.black,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: const Color(0xFF00E676).withOpacity(0.6),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (_) =>
                    bloc.add(const DeliverySignUpTermsToggled()),
              ),
              Flexible(
                child: Text(
                  'I accept the Terms & Conditions',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
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
              onPressed: state.status == DeliverySignUpStatus.loading
                  ? null
                  : () =>
                      bloc.add(const DeliverySignUpSubmitted()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                elevation: 6,
                shadowColor: const Color(0xFF00E676).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: state.status == DeliverySignUpStatus.loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 22),

          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Login',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF00E676),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    String? prefix,
    bool obscure = false,
    TextInputType? keyboardType,
    String? errorText,
    ValueChanged<String>? onChanged,
    Widget? suffix,
  }) {
    return TextField(
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF081412),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: const Color(0xFF00E676).withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF00E676), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorText: errorText,
        errorStyle: GoogleFonts.inter(
          color: Colors.redAccent,
          fontSize: 12,
        ),
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      prefix,
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
              )
            : null,
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
