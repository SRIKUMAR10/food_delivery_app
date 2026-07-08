import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_event.dart';

class SellerSignUpPageUI extends StatelessWidget {
  const SellerSignUpPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpBackPressed()),
        ),
      ),
      body: BlocConsumer<SellerSignUpPageBloc, SellerSignUpPageState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpErrorDismissed()),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state.step) {
            case SellerSignUpStep.welcome:
              return _buildWelcomeScreen(context, state);
            case SellerSignUpStep.personalDetails:
              return _buildPersonalDetailsScreen(context, state);
            case SellerSignUpStep.contactPassword:
              return _buildContactPasswordScreen(context, state);
            case SellerSignUpStep.otpVerification:
              return _buildOtpScreen(context, state);
            case SellerSignUpStep.emailVerification:
              return _buildEmailVerificationScreen(context, state);
            case SellerSignUpStep.signUpSuccess:
              return _buildSuccessScreen(context, state);
          }
        },
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, SellerSignUpPageState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Seller ஆக பதிவு செய்யுங்கள்!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            key: const Key('getStartedButton'),
            onPressed: () {
              context.read<SellerSignUpPageBloc>().add(const SellerSignUpGetStartedPressed());
            },
            child: const Text('Create Account'),
          ),
          TextButton(
            onPressed: () {
              context.read<SellerSignUpPageBloc>().add(const SellerSignUpLoginNavigated());
            },
            child: const Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsScreen(BuildContext context, SellerSignUpPageState state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TextFormField(
          key: const Key('nameField'),
          initialValue: state.name,
          decoration: InputDecoration(
            labelText: 'Full Name',
            errorText: state.nameError,
          ),
          onChanged: (value) => context.read<SellerSignUpPageBloc>().add(SellerSignUpNameChanged(value)),
        ),
        TextFormField(
          key: const Key('shopNameField'),
          initialValue: state.shopName,
          decoration: InputDecoration(
            labelText: 'Shop Name',
            errorText: state.shopNameError,
          ),
          onChanged: (value) => context.read<SellerSignUpPageBloc>().add(SellerSignUpShopNameChanged(value)),
        ),
        TextFormField(
          key: const Key('businessDetailsField'),
          initialValue: state.businessDetails,
          decoration: InputDecoration(
            labelText: 'Business Details',
            errorText: state.businessDetailsError,
          ),
          onChanged: (value) => context.read<SellerSignUpPageBloc>().add(SellerSignUpBusinessDetailsChanged(value)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            context.read<SellerSignUpPageBloc>().add(const SellerSignUpPersonalDetailsSubmitted());
          },
          child: const Text('Next'),
        )
      ],
    );
  }

  Widget _buildContactPasswordScreen(BuildContext context, SellerSignUpPageState state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TextFormField(
          key: const Key('phoneField'),
          initialValue: state.phone,
          decoration: InputDecoration(
            labelText: 'Phone',
            errorText: state.phoneError,
          ),
          onChanged: (value) => context.read<SellerSignUpPageBloc>().add(SellerSignUpPhoneChanged(value)),
        ),
        TextFormField(
          key: const Key('emailField'),
          initialValue: state.email,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: state.emailError,
          ),
          onChanged: (value) => context.read<SellerSignUpPageBloc>().add(SellerSignUpEmailChanged(value)),
        ),
        TextFormField(
          key: const Key('passwordField'),
          initialValue: state.password,
          obscureText: state.isPasswordObscured,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: state.passwordError,
            suffixIcon: IconButton(
              icon: Icon(state.isPasswordObscured ? Icons.visibility : Icons.visibility_off),
              onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpPasswordVisibilityToggled()),
            )
          ),
          onChanged: (value) => context.read<SellerSignUpPageBloc>().add(SellerSignUpPasswordChanged(value)),
        ),
        TextFormField(
          key: const Key('confirmPasswordField'),
          initialValue: state.confirmPassword,
          obscureText: state.isConfirmPasswordObscured,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            errorText: state.confirmPasswordError,
            suffixIcon: IconButton(
              icon: Icon(state.isConfirmPasswordObscured ? Icons.visibility : Icons.visibility_off),
              onPressed: () => context.read<SellerSignUpPageBloc>().add(const SellerSignUpConfirmPasswordVisibilityToggled()),
            )
          ),
          onChanged: (value) => context.read<SellerSignUpPageBloc>().add(SellerSignUpConfirmPasswordChanged(value)),
        ),
        CheckboxListTile(
          title: const Text('I accept the terms and conditions'),
          value: state.termsAccepted,
          onChanged: (value) => context.read<SellerSignUpPageBloc>().add(const SellerSignUpTermsToggled()),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            context.read<SellerSignUpPageBloc>().add(const SellerSignUpContactSubmitted());
          },
          child: state.status == SellerSignUpStatus.loading 
              ? const CircularProgressIndicator() 
              : const Text('Create Account / Send OTP'),
        )
      ],
    );
  }

  Widget _buildOtpScreen(BuildContext context, SellerSignUpPageState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Enter OTP sent to ${state.phone}'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Container(
                width: 40,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  initialValue: state.otpDigits[index],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    context.read<SellerSignUpPageBloc>().add(SellerSignUpOtpDigitChanged(index: index, digit: value));
                  },
                ),
              );
            }),
          ),
          if (state.otpError != null) 
            Text(state.otpError!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(
            key: const Key('verifyOtpButton'),
            onPressed: () {
              context.read<SellerSignUpPageBloc>().add(const SellerSignUpOtpVerifySubmitted());
            },
            child: state.status == SellerSignUpStatus.loading 
              ? const CircularProgressIndicator() 
              : const Text('Verify OTP'),
          ),
          const SizedBox(height: 10),
          if (state.otpCountdown > 0)
            Text('Resend OTP in ${state.otpCountdown}s')
          else
            TextButton(
              onPressed: () {
                context.read<SellerSignUpPageBloc>().add(const SellerSignUpOtpResendRequested());
              },
              child: const Text('Resend OTP'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmailVerificationScreen(BuildContext context, SellerSignUpPageState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Verification email sent!'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<SellerSignUpPageBloc>().add(const SellerSignUpEmailVerifyCheckPressed());
            },
            child: const Text('I have verified'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context, SellerSignUpPageState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 20),
          Text('வரவேற்கிறோம், ${state.name}!', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            key: const Key('goToDashboardButton'),
            onPressed: () {
              context.read<SellerSignUpPageBloc>().add(const SellerSignUpGoToDashboardPressed());
            },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }
}
