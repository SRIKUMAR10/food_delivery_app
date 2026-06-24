import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';

import 'SignUpPage_Bloc.dart';
import 'SignUpPage_Event.dart';
import 'SignUpPage_State.dart';

class SignUpPageUI extends StatelessWidget {
  final FoodItem? foodItemToAccess;

  const SignUpPageUI({super.key, this.foodItemToAccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpBloc(userRepository: UserRepository()),
      child: _SignUpPageContent(foodItemToAccess: foodItemToAccess),
    );
  }
}

class _SignUpPageContent extends StatefulWidget {
  final FoodItem? foodItemToAccess;

  const _SignUpPageContent({this.foodItemToAccess});

  @override
  State<_SignUpPageContent> createState() => _SignUpPageContentState();
}

class _SignUpPageContentState extends State<_SignUpPageContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleSignUp(BuildContext context) {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    context.read<SignUpBloc>().add(
      SignUpSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FoodGoLoginScreenUI(foodItemToAccess: widget.foodItemToAccess),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpBloc, SignUpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SignUpStatus.loading) {
          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: Color(0xFFE52121)),
            ),
          );
        } else if (state.status == SignUpStatus.success) {
          // Close loading dialog
          Navigator.pop(context);
          _navigateToLogin();
        } else if (state.status == SignUpStatus.failure) {
          // Close loading dialog
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Signup failed'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFBF5F5), // App background color
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Desktop/Tablet layout if screen width is more than 800px
                if (constraints.maxWidth > 800) {
                  return _buildWideLayout(constraints.maxWidth, state);
                } else {
                  // Mobile layout
                  return _buildMobileLayout(state);
                }
              },
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // MOBILE LAYOUT
  // -------------------------------------------------------------
  Widget _buildMobileLayout(SignUpState state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          // Background and Top Content
          Container(
            height: 480,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFEEBC1), // Biscuit/Yellow color
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
                // FoodGo SVG logo
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

          // Overlapping SignUp Card
          Padding(
            padding: const EdgeInsets.only(
              top: 410,
              left: 20.0,
              right: 20.0,
              bottom: 30.0,
            ),
            child: _buildSignUpCard(state, isDesktop: false),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // DESKTOP / TABLET WEB LAYOUT
  // -------------------------------------------------------------
  Widget _buildWideLayout(double width, SignUpState state) {
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
            // Left side: Branding area
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
            // Right side: Sign-up form
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: _buildSignUpCard(state, isDesktop: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE SIGNUP CARD
  // -------------------------------------------------------------
  Widget _buildSignUpCard(SignUpState state, {bool isDesktop = false}) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // SignUp title
        Center(
          child: Text(
            "SignUp",
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 36 : 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Name field
        Text(
          "Name",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          hintText: "Enter Name",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),

        // Email field
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
          controller: _emailController,
          hintText: "Enter Email",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // Password field
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
          controller: _passwordController,
          hintText: "Enter Password",
          icon: Icons.lock_outline,
          isPassword: state.isPasswordObscured,
          suffixIcon: IconButton(
            icon: Icon(
              state.isPasswordObscured
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: () {
              context.read<SignUpBloc>().add(SignUpPasswordVisibilityToggled());
            },
          ),
        ),
        const SizedBox(height: 32),

        // Sign Up button
        Center(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _handleSignUp(context),
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: const Center(
                    child: Text(
                      "Sign Up",
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
        ),
        const SizedBox(height: 24),

        // Link for login
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _navigateToLogin,
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
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
    );

    // White card background and rounded corners only on mobile
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

  // Custom Text Field design
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF6), // Gray color of the input field
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
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
