abstract class BuyerForgotPasswordServiceBase {
  String? validatePhone(String phone);
  String? validateOtp(String otp);
  String? validatePassword(String password);
  String? validateConfirmPassword(String password, String confirmPassword);
}

class BuyerForgotPasswordService implements BuyerForgotPasswordServiceBase {
  @override
  String? validatePhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final digits = clean.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return 'Please enter phone number';
    }
    if (digits.length < 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  @override
  String? validateOtp(String otp) {
    final clean = otp.trim();
    if (clean.isEmpty) {
      return 'Please enter OTP code';
    }
    if (clean.length < 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  @override
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter new password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your new password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}

