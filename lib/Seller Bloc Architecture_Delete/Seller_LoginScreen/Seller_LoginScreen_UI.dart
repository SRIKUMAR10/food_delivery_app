import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:food_delivery_app/repositories/seller_repository.dart';

import '../Seller_SignUpPage/Seller_SignUpPage_UI.dart';
import '../Seller_Add_Products/seller_add_product_screen.dart';
import '../Seller_Add_Products/seller_product_bloc.dart';
import '../Seller_ForgotPasswordPage/Seller_ForgotPasswordPage_UI.dart';
import 'Seller_LoginScreen_Bloc.dart';
import 'Seller_LoginScreen_Event.dart';
import 'Seller_LoginScreen_State.dart';

/// The entry point for the Seller Login Screen.
/// This widget provides the SellerLoginBloc to its children and wraps the responsive UI view.
class SellerLoginScreenUI extends StatelessWidget {
  final SellerRepository? repository;
  const SellerLoginScreenUI({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerLoginBloc(sellerRepository: repository),
      child: _SellerLoginView(repository: repository),
    );
  }
}

class _SellerLoginView extends StatefulWidget {
  final SellerRepository? repository;
  const _SellerLoginView({this.repository});

  @override
  State<_SellerLoginView> createState() => _SellerLoginViewState();
}

class _SellerLoginViewState extends State<_SellerLoginView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // If seller is already logged in, navigate directly to Add Product page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = widget.repository ?? SellerRepository();
      try {
        if (repo.currentUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => SellerProductBloc(),
                child: const SellerAddProductScreen(),
              ),
            ),
          );
        }
      } catch (_) {}
    });
  }

  /// Validates the form and dispatches the submit event to the BLoC.
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<SellerLoginBloc>().add(const SellerLoginSubmitted());
    }
  }

  /// Navigates to the ForgotPasswordPage without removing login from the stack.
  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SellerForgotPasswordScreenUI(),
      ),
    );
  }

  /// Navigates to SignUp page and removes the current Login page from the stack.
  void _handleSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SellerSignUpScreenUI()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5), // App background color
      body: SafeArea(
        child: BlocConsumer<SellerLoginBloc, SellerLoginState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == SellerLoginStatus.success) {
              // Navigate to Seller Add Product page after successful Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (_) => SellerProductBloc(),
                    child: const SellerAddProductScreen(),
                  ),
                ),
                (route) => false,
              );
            } else if (state.status == SellerLoginStatus.failure) {
              // Show an error snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                ),
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
  Widget _buildMobileLayout(BuildContext context, SellerLoginState state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          // Top Decorative Section containing the illustration and logo.
          Container(
            height: 480,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFEEBC1), // Biscuit/yellow color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // Food Image
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
                // FoodGo SVG Logo
                SvgPicture.asset(
                  'assets/images/FoodGo.svg',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) => Text(
                    "FoodGo",
                    style: TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
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
  Widget _buildWideLayout(BuildContext context, SellerLoginState state) {
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
              color: Colors.black.withOpacity(0.1),
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
    SellerLoginState state, {
    bool isDesktop = false,
  }) {
    final bloc = context.read<SellerLoginBloc>();

    final cardContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Center(
            child: Text(
              "LogIn",
              style: TextStyle(
                fontSize: isDesktop ? 36 : 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Email Field Label
          Text(
            "Email",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),

          // Email Text Field
          _buildTextField(
            key: const ValueKey('sellerEmailField'),
            initialValue: state.email,
            hintText: "Enter Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => bloc.add(SellerLoginEmailChanged(val)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Field Label
          Text(
            "Password",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),

          // Password Text Field
          _buildTextField(
            key: const ValueKey('sellerPasswordField'),
            initialValue: state.password,
            hintText: "Enter Password",
            icon: Icons.lock_outline,
            isPassword: state.obscurePassword,
            onChanged: (val) => bloc.add(SellerLoginPasswordChanged(val)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              if (value.trim().length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
                size: 20,
              ),
              onPressed: () =>
                  bloc.add(const SellerLoginPasswordVisibilityToggled()),
            ),
          ),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: const Color(0xFFE52121),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          Center(
            child: MouseRegion(
              cursor: state.status == SellerLoginStatus.loading
                  ? SystemMouseCursors.wait
                  : SystemMouseCursors.click,
              child: GestureDetector(
                key: const ValueKey('sellerSubmitButton'),
                onTap: state.status == SellerLoginStatus.loading
                    ? null
                    : _handleLogin,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE52121), // Bright red color
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE52121).withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: state.status == SellerLoginStatus.loading
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

          // Sign Up Link
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _handleSignUp,
                    child: Text(
                      "SignUp",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // White card background and rounded corners only for mobile layout
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
              color: Colors.black.withOpacity(0.04),
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
    Key? key,
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
        color: const Color(0xFFECEFF6), // Gray color for input field
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        key: key,
        initialValue: initialValue,
        onChanged: onChanged,
        obscureText: isPassword,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54, size: 20),
          hintText: hintText,
          suffixIcon: suffixIcon,
          hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
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
