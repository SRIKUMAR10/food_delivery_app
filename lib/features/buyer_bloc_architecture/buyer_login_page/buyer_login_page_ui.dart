import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';
import '../buyer_sign_up_page/buyer_sign_up_page_ui.dart';
import '../buyer_forgot_password_page/buyer_forgot_password_page_ui.dart';
import 'buyer_login_page_bloc.dart';
import 'buyer_login_page_event.dart';
import 'buyer_login_page_state.dart';

class BuyerLoginPageUI extends StatefulWidget {
  const BuyerLoginPageUI({super.key});

  @override
  State<BuyerLoginPageUI> createState() => _BuyerLoginPageUIState();
}

class _BuyerLoginPageUIState extends State<BuyerLoginPageUI> {
  final TextEditingController _phoneController = TextEditingController(text: '+91 ');
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuyerLoginBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: BlocConsumer<BuyerLoginBloc, BuyerLoginState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.errorMessage != current.errorMessage,
                listener: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.clearSnackBars();

                    if (state.status == BuyerLoginStatus.success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Login successful! Welcome back.'),
                          backgroundColor: Color(0xFFE52121),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const CurvedNavigationBarView(),
                          ),
                          (route) => false,
                        );
                      }
                    } else if (state.status == BuyerLoginStatus.failure) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            state.errorMessage ?? 'Incorrect password. Please try again.',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  });
                },
                builder: (context, state) {
                  final isWide = MediaQuery.of(context).size.width > 768;

                  final leftBanner = Container(
                    padding: const EdgeInsets.all(32),
                    color: const Color(0xFFFFE6AD),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              'assets/images/Sign up.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/chef.png',
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/FoodGo.svg',
                              height: 36,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'FoodGo',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE52121),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );

                  final rightForm = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                          child: Text(
                            'LogIn',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Phone Number or Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFEEF0F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Enter Phone Number or Email (+91...)',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: state.isPasswordObscured,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                context
                                    .read<BuyerLoginBloc>()
                                    .add(const BuyerLoginTogglePasswordVisibility());
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEEF0F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BuyerForgotPasswordPageUI(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.status == BuyerLoginStatus.loading
                                ? null
                                : () {
                                    context.read<BuyerLoginBloc>().add(
                                          BuyerLoginSubmitted(
                                            phone: _phoneController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE52121),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: state.status == BuyerLoginStatus.loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have account? ",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const BuyerSignUpPageUI(),
                                  ),
                                );
                              },
                              child: const Text(
                                'SignUp',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: const [
                            Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or continue with',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () {
                            context.read<BuyerLoginBloc>().add(const BuyerLoginGoogleSubmitted());
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/google.png', height: 20, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: Colors.red)),
                              const SizedBox(width: 10),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            context.read<BuyerLoginBloc>().add(const BuyerLoginSubmitted(phone: 'guest', password: 'guest'));
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/apple_logo.png', height: 20, errorBuilder: (c, e, s) => const Icon(Icons.apple, color: Colors.black)),
                              const SizedBox(width: 10),
                              const Text(
                                'Continue with Apple',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  return Container(
                    constraints: const BoxConstraints(maxWidth: 960),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isWide
                        ? IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 5, child: leftBanner),
                                Expanded(
                                  flex: 6,
                                  child: SingleChildScrollView(
                                    child: rightForm,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 280, child: leftBanner),
                                rightForm,
                              ],
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
