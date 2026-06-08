import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

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

  void _handleSignUp() {
    // உங்கள் தற்போதைய சைன்-அப் லாஜிக் இங்கே வரும்
    debugPrint("Name: ${_nameController.text}");
    debugPrint("Email: ${_emailController.text}");
    debugPrint("Password: ${_passwordController.text}");
  }

  void _navigateToLogin() {
    // லாகின் பக்கத்திற்கு செல்லும் லாஜிக்
    debugPrint("Navigate to Login Screen");
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
                  errorBuilder: (context, error, stackTrace) => const Text(
                    "FoodGo",
                    style: TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
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
        const Center(
          child: Text(
            "SignUp",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Name புலம்
        const Text(
          "Name",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
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
        const Text(
          "Email",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
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
        const Text(
          "Password",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          hintText: "Enter Password",
          icon: Icons
              .more_horiz, // படத்தில் உள்ளவாறு மூன்று புள்ளிகள் போன்ற ஐகான்
          isPassword: true,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
              const Text(
                "Already have an account? ",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _navigateToLogin,
                  child: const Text(
                    "Login",
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF6), // உள்ளீட்டு புலத்தின் சாம்பல் நிறம்
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54, size: 20),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
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
