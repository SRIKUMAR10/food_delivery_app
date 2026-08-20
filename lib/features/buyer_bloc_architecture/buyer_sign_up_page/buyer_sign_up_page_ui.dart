import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/widgets/auth_form_widgets.dart';
import '../buyer_otp_verification_page/buyer_otp_verification_page_ui.dart';
import 'buyer_sign_up_page_bloc.dart';
import 'buyer_sign_up_page_event.dart';
import 'buyer_sign_up_page_state.dart';

class BuyerSignUpPageUI extends StatefulWidget {
  const BuyerSignUpPageUI({super.key});

  @override
  State<BuyerSignUpPageUI> createState() => _BuyerSignUpPageUIState();
}

class _BuyerSignUpPageUIState extends State<BuyerSignUpPageUI> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController(text: '+91 ');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context, BuyerSignUpState state) {
    if (state.status == BuyerSignUpStatus.loading) return;
    context.read<BuyerSignUpBloc>().add(
          BuyerSignUpSubmitted(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            mobileNumber: _mobileController.text.trim(),
            password: _passwordController.text.trim(),
            confirmPassword: _confirmPasswordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuyerSignUpBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: BlocConsumer<BuyerSignUpBloc, BuyerSignUpState>(
                listener: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.clearSnackBars();

                    if (state.status == BuyerSignUpStatus.otpSent) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BuyerOtpVerificationPageUI(
                            fullName: state.fullName ?? '',
                            email: state.email ?? '',
                            mobileNumber: state.mobileNumber ?? '',
                            password: state.password ?? '',
                            verificationId: state.verificationId ?? '',
                          ),
                        ),
                      );
                    } else if (state.status == BuyerSignUpStatus.failure) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            state.errorMessage ?? 'Sign Up failed',
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
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Fill in the details to get started with FoodGo',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 28),
                        
                        // Full Name
                        const AuthFieldLabel('Full Name'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _fullNameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          decoration: authFieldDecoration(
                            hintText: 'John Doe',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Address (Optional)
                        const AuthFieldLabel('Email Address (Optional)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: authFieldDecoration(
                            hintText: 'john@example.com',
                            prefixIcon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mobile Number
                        const AuthFieldLabel('Mobile Number'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          decoration: authFieldDecoration(
                            prefixIcon: Icons.phone_android,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Create Password
                        const AuthFieldLabel('Create Password'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: state.isPasswordObscured,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: authFieldDecoration(
                            hintText: 'Create password',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => context
                                  .read<BuyerSignUpBloc>()
                                  .add(const BuyerSignUpTogglePasswordVisibility()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        const AuthFieldLabel('Confirm Password'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: state.isConfirmPasswordObscured,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmitted: (_) => _submitForm(context, state),
                          decoration: authFieldDecoration(
                            hintText: 'Confirm password',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isConfirmPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => context
                                  .read<BuyerSignUpBloc>()
                                  .add(const BuyerSignUpToggleConfirmPasswordVisibility()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Get OTP Button
                        AuthPrimaryButton(
                          label: 'Get OTP',
                          isLoading: state.status == BuyerSignUpStatus.loading,
                          onPressed: () => _submitForm(context, state),
                        ),
                      ],
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
