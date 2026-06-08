import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../FoodGoLoginScreen/FoodGoLoginScreen.dart';
import '../Repository/user_repository.dart';
import '../home_Page/home_Page.dart'; // FoodItem definition-க்காக தேவை

class SignUpPage extends StatefulWidget {
  final FoodItem? foodItemToAccess; // லாகினுக்குப் பிறகு செல்ல வேண்டிய டேட்டா

  const SignUpPage({super.key, this.foodItemToAccess});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // -------------------------------------------------------------
  // KEEPING YOUR EXACT LOGIC / CONTROLLERS UNCHANGED
  // -------------------------------------------------------------
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final UserRepository _userRepository = UserRepository();

  Future<void> _handleSignUp() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _userRepository.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context); // Dialog-ஐ மூட
      _navigateToLogin();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Dialog-ஐ மூட
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _navigateToLogin() {
    // Login பக்கத்திற்குச் சென்று, தற்போதைய SignUp பக்கத்தை ஸ்டாக்கில் இருந்து நீக்கவும்.
    // இது அங்கீகாரப் பக்கங்களின் ஸ்டாக் குவிவதைத் தடுக்கிறது மற்றும்
    // Login முதல் பக்கமாக இருந்தால் பின் பொத்தான் பயன்பாட்டை விட்டு வெளியேற அனுமதிக்கிறது.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FoodGoLoginScreen(
          foodItemToAccess: widget
              .foodItemToAccess, // திரும்பவும் லாகின் பக்கத்திற்கு அனுப்பவும்
        ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5), // ஆப்-இன் பின்னணி நிறம்
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // திரையின் அகலம் 800px-க்கு மேல் இருந்தால் Desktop/Tablet வடிவமைப்பு
            if (constraints.maxWidth > 800) {
              return _buildWideLayout(constraints.maxWidth);
            } else {
              // மொபைல் வடிவமைப்பு (Exact match to your image)
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // MOBILE LAYOUT (Exact Image Match)
  // -------------------------------------------------------------
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Stack(
        children: [
          // 1. பின்னணி மற்றும் மேல் பகுதி (Background & Top Content)
          Container(
            height: 480, // Increased height to provide more room for branding
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFEEBC1), // பிஸ்கட்/மஞ்சள் நிறம்
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // உணவுப் படம் (Food Image)
                Image.asset(
                  'assets/images/Sign up.png',
                  height: 220, // Adjusted height for better vertical balance
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.fastfood,
                    size: 150,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                // FoodGo SVG லோகோ
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

          // 2. வெள்ளை நிற கார்டு (Overlapping SignUp Card)
          Padding(
            padding: const EdgeInsets.only(
              top: 410, // Shifted downward so the logo above is fully visible
              left: 20.0,
              right: 20.0,
              bottom: 30.0,
            ),
            child: _buildSignUpCard(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // DESKTOP / TABLET WEB LAYOUT (Side-by-Side)
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
            // இடது பக்கம்: பிராண்டிங் பகுதி
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
            // வலது பக்கம்: சைன்-அப் படிவம்
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: _buildSignUpCard(isDesktop: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE SIGNUP CARD (Styled exactly like your image)
  // -------------------------------------------------------------
  Widget _buildSignUpCard({bool isDesktop = false}) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // SignUp தலைப்பு
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

        // Name புலம்
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

        // Email புலம்
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

        // Password புலம்
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
        const SizedBox(height: 32),

        // Sign Up பொத்தான் (Button)
        Center(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _handleSignUp,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE52121), // பிரகாசமான சிவப்பு நிறம்
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

        // Login செய்வதற்கான லிங்க்
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

    // மொபைலில் மட்டும் வெள்ளை கார்டு பின்னணி மற்றும் வளைந்த ஓரங்கள்
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

  // பொதுவான டெக்ஸ்ட் ஃபீல்டு வடிவமைப்பு (Custom Text Field)
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
        color: const Color(0xFFECEFF6), // உள்ளீட்டு புலத்தின் சாம்பல் நிறம்
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
