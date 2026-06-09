import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../FoodGoLoginScreen/FoodGoLoginScreen.dart'; // To navigate back to login

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      debugPrint("Reset password for: ${_emailController.text}");
      // Implement actual password reset logic here
      // For now, simulate sending a link and navigate back to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset link sent to ${_emailController.text}"),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        _navigateToLogin();
      });
    }
  }

  void _navigateToLogin() {
    // Navigate to the Login page and remove the current ForgotPassword page from the stack.
    // This prevents the stack of authentication pages from building up.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FoodGoLoginScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5), // App background color
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Desktop/Tablet layout if width > 800px
            if (constraints.maxWidth > 800) {
              return _buildWideLayout(constraints.maxWidth);
            } else {
              // Mobile layout
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // MOBILE LAYOUT (Consistent with Login/SignUp)
  // -------------------------------------------------------------
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          // 1. Background and Top Content (reused from Login/SignUp)
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
                // Food Image (reused for consistent branding)
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
                    style: GoogleFonts.poppins(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. White Overlapping Card
          Padding(
            padding: const EdgeInsets.only(
              top: 410, // Shifted downward so the logo above is fully visible
              left: 20.0,
              right: 20.0,
              bottom: 30.0,
            ),
            child: _buildForgotPasswordCard(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // DESKTOP / TABLET WEB LAYOUT (Consistent with Login/SignUp)
  // -------------------------------------------------------------
  Widget _buildWideLayout(double width) {
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
            // Left Side: Branding Area
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
            // Right Side: Forgot Password Form
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: _buildForgotPasswordCard(isDesktop: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE FORGOT PASSWORD CARD (Styled consistently)
  // -------------------------------------------------------------
  Widget _buildForgotPasswordCard({bool isDesktop = false}) {
    final cardContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Center(
            child: Text(
              "Forgot Password",
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 36 : 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Instruction Text
          Center(
            // Centering the instruction text
            child: Text(
              "Enter your email address below and we'll send you a link to reset your password.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Email Field Label
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
          // Email Text Field
          _buildTextField(
            controller: _emailController,
            hintText: "Enter Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Submit Button
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _handleResetPassword,
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
                  child: const Center(
                    child: Text(
                      "Submit",
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

          // Back to Login Link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Remember your password? ",
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

  // Common Text Field styling (Custom Text Field)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Added validator for form fields
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF6), // Gray color for input field
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
        validator: validator, // Apply the validator
      ),
    );
  }
}
