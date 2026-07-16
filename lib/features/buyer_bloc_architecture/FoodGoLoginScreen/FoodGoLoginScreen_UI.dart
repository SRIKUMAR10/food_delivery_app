import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'package:google_fonts/google_fonts.dart';

import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';
import '../ForgotPasswordPage/ForgotPasswordPage_UI.dart';
import '../Sign_Up_Page/SignUpPage_UI.dart';

import 'FoodGoLoginScreen_Bloc.dart';
import 'FoodGoLoginScreen_Event.dart';
import 'FoodGoLoginScreen_State.dart';

/// The entry point for the FoodGo Login Screen.
/// This widget provides the FoodGoLoginBloc to its children and wraps the responsive UI view.
class FoodGoLoginScreenUI extends StatelessWidget {
  final FoodItem? foodItemToAccess;

  const FoodGoLoginScreenUI({super.key, this.foodItemToAccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Attempt to read UserRepository from context, otherwise instantiate it directly.
        final repo = context.read<UserRepository?>() ?? UserRepository();
        return FoodGoLoginBloc(userRepository: repo);
      },
      child: _FoodGoLoginView(foodItemToAccess: foodItemToAccess),
    );
  }
}

class _FoodGoLoginView extends StatefulWidget {
  final FoodItem? foodItemToAccess;
  const _FoodGoLoginView({this.foodItemToAccess});

  @override
  State<_FoodGoLoginView> createState() => _FoodGoLoginViewState();
}

class _FoodGoLoginViewState extends State<_FoodGoLoginView> {
  final _formKey = GlobalKey<FormState>();

  /// Navigates to the Forgot Password Screen.
  void _handleForgotPassword() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreenUI()),
    );
  }

  /// Navigates to the Sign Up Screen and passes the requested food item.
  void _handleSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SignUpPageUI(foodItemToAccess: widget.foodItemToAccess),
      ),
    );
  }

  /// Validates the form and dispatches the submit event to the BLoC.
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<FoodGoLoginBloc>().add(const LoginSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5),
      body: SafeArea(
        child: BlocConsumer<FoodGoLoginBloc, FoodGoLoginState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              // Upon successful login, navigate to the main application view.
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const CurvedNavigationBarView(),
                ),
                (route) => false,
              );
            } else if (state.status == LoginStatus.failure) {
              // Show a snackbar displaying the error message.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Render web/desktop layout if width is greater than 800px, otherwise render mobile layout.
                if (constraints.maxWidth > 800) {
                  return _buildWideLayout(context, state);
                } else {
                  return _buildMobileLayout(context, state);
                }
              },
            );
          },
        ),
      ),
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(BuildContext context, FoodGoLoginState state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          // Top Decorative Section containing the illustration and logo.
          Container(
            height: 480,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFEEBC1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/Sign up.png',
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.fastfood,
                    size: 150,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  'assets/images/FoodGo.svg',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) => Text(
                    "FoodGo",
                    style: GoogleFonts.poppins(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlapping Form Card.
          Padding(
            padding: const EdgeInsets.only(
              top: 410,
              left: 20.0,
              right: 20.0,
              bottom: 30.0,
            ),
            child: _buildLoginCard(context, state, isDesktop: false),
          ),
        ],
      ),
    );
  }

  // --- Web Layout ---
  Widget _buildWideLayout(BuildContext context, FoodGoLoginState state) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 750),
        margin: const EdgeInsets.all(32),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Panel containing branding and illustration.
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFFFEEBC1),
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Sign up.png',
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    SvgPicture.asset('assets/images/FoodGo.svg', height: 60),
                  ],
                ),
              ),
            ),
            // Right Panel containing the login form.
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: _buildLoginCard(context, state, isDesktop: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Shared Login Card ---
  Widget _buildLoginCard(
    BuildContext context,
    FoodGoLoginState state, {
    bool isDesktop = false,
  }) {
    final bloc = context.read<FoodGoLoginBloc>();

    final cardContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              "LogIn",
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 36 : 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Email",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            initialValue: state.email,
            hintText: "Enter Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => bloc.add(LoginEmailChanged(val)),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter your email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            "Password",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            initialValue: state.password,
            hintText: "Enter Password",
            icon: Icons.lock_outline,
            isPassword: state.obscurePassword,
            onChanged: (val) => bloc.add(LoginPasswordChanged(val)),
            validator: (val) {
              if (val == null || val.isEmpty)
                return 'Please enter your password';
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
                size: 20,
              ),
              onPressed: () {
                bloc.add(const LoginPasswordVisibilityToggled());
              },
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _handleForgotPassword,
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: MouseRegion(
              cursor: state.status == LoginStatus.loading
                  ? SystemMouseCursors.wait
                  : SystemMouseCursors.click,
              child: GestureDetector(
                onTap: state.status == LoginStatus.loading
                    ? null
                    : _handleLogin,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE52121),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE52121).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: state.status == LoginStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Log In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have account? ",
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: _handleSignUp,
                  child: Text(
                    "SignUp",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return cardContent;
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: cardContent,
      );
    }
  }

  // --- Reusable TextField Widget ---
  Widget _buildTextField({
    required String initialValue,
    required String hintText,
    required IconData icon,
    required ValueChanged<String> onChanged,
    bool isPassword = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        validator: validator,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54, size: 20),
          hintText: hintText,
          suffixIcon: suffixIcon,
          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
