import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Seller_SignUpPage/Seller_SignUpPage.dart';
import '../Seller_Add_Products/seller_add_product_screen.dart';
import '../Seller_ForgotPasswordPage/Seller_ForgotPasswordPage.dart'; // Import the new ForgotPasswordPage
import '../../Repository/seller_repository.dart';

class SellerLoginScreen extends StatefulWidget {
  const SellerLoginScreen({super.key}); // constructor-ஐ புதுப்பிக்கவும்

  @override
  State<SellerLoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SellerLoginScreen> {
  @override
  void initState() {
    super.initState();
    // பயனர் ஏற்கனவே லாகின் செய்திருந்தால், நேரடியாக Add Product பக்கத்திற்குச் செல்லவும்
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SellerAddProductScreen(),
          ),
        );
      }
    });
  }

  // --- KEEP YOUR EXISTING DATA / LOGIC HERE ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final SellerRepository _sellerRepository = SellerRepository();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        await _sellerRepository.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pop(context); // Dialog-ஐ மூட

        // வெற்றிகரமான Login-க்குப் பிறகு Seller Add Product பக்கத்திற்கு செல்லவும்
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const SellerAddProductScreen(),
          ),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Dialog-ஐ மூட
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _handleForgotPassword() {
    // Navigate to the ForgotPasswordPage without removing login from stack
    // so they can come back to login
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  void _handleSignUp() {
    // SignUp பக்கத்திற்குச் சென்று, தற்போதைய Login பக்கத்தை ஸ்டாக்கில் இருந்து நீக்கவும்.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SellerSignUpPage()),
    );
  }
  // --------------------------------------------

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return _buildWideLayout(constraints.maxWidth);
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          // 1. Top Section (Same as SignUpPage)
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

          // 2. Overlapping Card
          Padding(
            padding: const EdgeInsets.only(
              top: 410,
              left: 20.0,
              right: 20.0,
              bottom: 30.0,
            ),
            child: _buildLoginCard(),
          ),
        ],
      ),
    );
  }

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
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: _buildLoginCard(isDesktop: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard({bool isDesktop = false}) {
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
            controller: _emailController,
            hintText: "Enter Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
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
            controller: _passwordController,
            hintText: "Enter Password",
            icon: Icons.lock_outline,
            isPassword: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
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
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _handleLogin,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE52121),
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
                    child: Text(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
        color: const Color(0xFFECEFF6),
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
