import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Delivery_OTP_Verification_page_bloc.dart';
import 'Delivery_OTP_Verification_page_event.dart';
import 'Delivery_OTP_Verification_page_repository.dart';
import 'Delivery_OTP_Verification_page_state.dart';

class DeliveryOtpVerificationPage extends StatelessWidget {
  final String verificationId;
  final String name;
  final String phone;
  final String email;
  final String password;

  const DeliveryOtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryOtpVerificationBloc>(
      create: (context) => DeliveryOtpVerificationBloc(
        repository: DeliveryOtpVerificationRepository(),
        verificationId: verificationId,
        name: name,
        phone: phone,
        email: email,
        password: password,
      ),
      child: const DeliveryOtpVerificationPageView(),
    );
  }
}

class DeliveryOtpVerificationPageView extends StatefulWidget {
  const DeliveryOtpVerificationPageView({super.key});

  @override
  State<DeliveryOtpVerificationPageView> createState() =>
      _DeliveryOtpVerificationPageViewState();
}

class _DeliveryOtpVerificationPageViewState
    extends State<DeliveryOtpVerificationPageView>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  void _onDigitChanged(int index, String value, BuildContext context) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _updateOtpToBloc(context);
  }

  void _onKeyBack(int index, RawKeyEvent event, BuildContext context) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  void _updateOtpToBloc(BuildContext context) {
    final otpStr = _controllers.map((c) => c.text).join();
    context
        .read<DeliveryOtpVerificationBloc>()
        .add(DeliveryOtpChangedEvent(otpStr));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091015),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Delivery_Login_scooter.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF091015)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.90),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          BlocConsumer<DeliveryOtpVerificationBloc,
              DeliveryOtpVerificationState>(
            listener: (context, state) {
              if (state.status == DeliveryOtpStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Account Created Successfully! Please login to continue.',
                    ),
                    backgroundColor: Color(0xFF00E676),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/deliveryLogin',
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 460),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: const Color(0xFF091413).withOpacity(0.92),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF00E676).withOpacity(0.30),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: const Color(0xFF00E676).withOpacity(0.10),
                                blurRadius: 40,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Verify Phone Number',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    color: Colors.white60,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'We have sent a 6-digit verification code via SMS to ',
                                    ),
                                    TextSpan(
                                      text: state.phone.startsWith('+')
                                          ? state.phone
                                          : '+91 ${state.phone}',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF00E676),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  'Change Phone Number?',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF00E676),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (state.errorMessage != null &&
                                  state.errorMessage!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.redAccent.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          state.errorMessage!,
                                          style: GoogleFonts.inter(
                                            color: Colors.redAccent,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // 6-digit OTP Pinput Field Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: 48,
                                    height: 56,
                                    child: RawKeyboardListener(
                                      focusNode: FocusNode(),
                                      onKey: (event) =>
                                          _onKeyBack(index, event, context),
                                      child: TextField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        maxLength: 1,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          counterText: '',
                                          filled: true,
                                          fillColor: const Color(0xFF081412),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: const Color(0xFF00E676)
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF00E676),
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) => _onDigitChanged(
                                            index, val, context),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.isResendEnabled
                                        ? "Didn't receive code?"
                                        : 'Resend code in ${state.resendSeconds}s',
                                    style: GoogleFonts.inter(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: state.isResendEnabled
                                        ? () {
                                            for (var c in _controllers) {
                                              c.clear();
                                            }
                                            context
                                                .read<
                                                    DeliveryOtpVerificationBloc>()
                                                .add(
                                                  const DeliveryOtpResendRequestedEvent(),
                                                );
                                          }
                                        : null,
                                    child: Text(
                                      'Resend OTP',
                                      style: GoogleFonts.inter(
                                        color: state.isResendEnabled
                                            ? const Color(0xFF00E676)
                                            : Colors.white30,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: state.status ==
                                          DeliveryOtpStatus.loading
                                      ? null
                                      : () {
                                          context
                                              .read<
                                                  DeliveryOtpVerificationBloc>()
                                              .add(
                                                const DeliveryOtpVerifySubmittedEvent(),
                                              );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E676),
                                    foregroundColor: Colors.black,
                                    elevation: 6,
                                    shadowColor: const Color(0xFF00E676)
                                        .withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: state.status ==
                                          DeliveryOtpStatus.loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.black),
                                          ),
                                        )
                                      : Text(
                                          'Verify OTP & Complete Sign Up',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
