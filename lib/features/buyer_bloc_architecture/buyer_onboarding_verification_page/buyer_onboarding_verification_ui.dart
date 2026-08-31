import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
import 'package:food_delivery_app/core/widgets/responsive_layout.dart';
import 'package:food_delivery_app/core/services/google_maps_loader.dart';
import 'package:food_delivery_app/core/widgets/cached_map_tile.dart';
import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';
import '../user_profile_image/pages/google_address_search_dialog.dart';
import 'buyer_onboarding_verification_bloc.dart';
import 'buyer_onboarding_verification_event.dart';
import 'buyer_onboarding_verification_state.dart';

class BuyerOnboardingVerificationPage extends StatelessWidget {
  final String? initialFullName;
  final String? initialDisplayName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialAvatarUrl;
  final bool initialIsPhoneVerified;

  const BuyerOnboardingVerificationPage({
    super.key,
    this.initialFullName,
    this.initialDisplayName,
    this.initialEmail,
    this.initialPhone,
    this.initialAvatarUrl,
    this.initialIsPhoneVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuyerOnboardingVerificationBloc(
        initialFullName: initialFullName,
        initialDisplayName: initialDisplayName,
        initialEmail: initialEmail,
        initialPhone: initialPhone,
        initialAvatarUrl: initialAvatarUrl,
        initialIsPhoneVerified: initialIsPhoneVerified ||
            (initialPhone != null && initialPhone!.isNotEmpty),
      ),
      child: const _BuyerOnboardingVerificationView(),
    );
  }
}

class _BuyerOnboardingVerificationView extends StatefulWidget {
  const _BuyerOnboardingVerificationView();

  @override
  State<_BuyerOnboardingVerificationView> createState() =>
      _BuyerOnboardingVerificationViewState();
}

class _BuyerOnboardingVerificationViewState
    extends State<_BuyerOnboardingVerificationView> {
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _addressController = TextEditingController();
  final _flatNoController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _upiIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BuyerOnboardingVerificationBloc>();
    _fullNameController.text = bloc.state.fullName;
    _displayNameController.text = bloc.state.displayName;
    _bioController.text = bloc.state.bio;
    _phoneController.text = bloc.state.phone;
    _emailController.text = bloc.state.email;
    _addressController.text = bloc.state.formattedAddress;
    _flatNoController.text = bloc.state.houseFlatNo;
    _landmarkController.text = bloc.state.landmark;
    _upiIdController.text = bloc.state.defaultUpiId ?? '';

    // Real-time Firestore auto-fetch for authenticated buyer
    bloc.add(const BuyerVerificationAutoFetchRequested());
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _addressController.dispose();
    _flatNoController.dispose();
    _landmarkController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuyerOnboardingVerificationBloc,
        BuyerOnboardingVerificationState>(
      listener: (context, state) {
        if (state.fullName.isNotEmpty && _fullNameController.text.isEmpty) {
          _fullNameController.text = state.fullName;
        }
        if (state.displayName.isNotEmpty && _displayNameController.text.isEmpty) {
          _displayNameController.text = state.displayName;
        }
        if (state.bio.isNotEmpty && _bioController.text.isEmpty) {
          _bioController.text = state.bio;
        }
        if (state.email.isNotEmpty && _emailController.text.isEmpty) {
          _emailController.text = state.email;
        }
        if (state.phone.isNotEmpty && _phoneController.text.isEmpty) {
          _phoneController.text = state.phone;
        }
        if (state.formattedAddress.isNotEmpty &&
            _addressController.text != state.formattedAddress) {
          _addressController.text = state.formattedAddress;
        }
        if (state.houseFlatNo.isNotEmpty &&
            _flatNoController.text != state.houseFlatNo) {
          _flatNoController.text = state.houseFlatNo;
        }
        if (state.landmark.isNotEmpty &&
            _landmarkController.text != state.landmark) {
          _landmarkController.text = state.landmark;
        }
        if (state.defaultUpiId != null &&
            state.defaultUpiId!.isNotEmpty &&
            _upiIdController.text.isEmpty) {
          _upiIdController.text = state.defaultUpiId!;
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.status == BuyerVerificationStatus.success &&
            state.currentStep == BuyerVerificationStep.completionSuccess) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const CurvedNavigationBarView(),
                ),
                (route) => false,
              );
            }
          });
        }
      },
      builder: (context, state) {
        final currentStepIndex =
            BuyerVerificationStep.values.indexOf(state.currentStep);
        final totalSteps = BuyerVerificationStep.values.length;
        final progress = (currentStepIndex + 1) / totalSteps;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (currentStepIndex > 0) {
              context
                  .read<BuyerOnboardingVerificationBloc>()
                  .add(const BuyerVerificationPreviousStepPressed());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please complete all 6 steps to activate your buyer account.'),
                  backgroundColor: BuyerAppColors.primaryDeep,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: BuyerAppColors.pageBackground,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              centerTitle: true,
              leading: currentStepIndex > 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black87, size: 20),
                      onPressed: () {
                        context
                            .read<BuyerOnboardingVerificationBloc>()
                            .add(const BuyerVerificationPreviousStepPressed());
                      },
                    )
                  : null,
              title: Text(
                'Step ${currentStepIndex + 1} of $totalSteps',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      BuyerAppColors.primary),
                  minHeight: 4,
                ),
              ),
            ),
            body: SafeArea(
              child: ResponsiveHelper.isWide(context)
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 550),
                        child: _buildStepContent(context, state),
                      ),
                    )
                  : _buildStepContent(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(
      BuildContext context, BuyerOnboardingVerificationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _resolveStepWidget(context, state),
      ),
    );
  }

  Widget _resolveStepWidget(
      BuildContext context, BuyerOnboardingVerificationState state) {
    switch (state.currentStep) {
      case BuyerVerificationStep.personalDetails:
        return _buildStep1PersonalDetails(context, state);
      case BuyerVerificationStep.contactVerification:
        return _buildStep2ContactVerification(context, state);
      case BuyerVerificationStep.addressSelection:
        return _buildStep3AddressSelection(context, state);
      case BuyerVerificationStep.paymentSetup:
        return _buildStep4PaymentSetup(context, state);
      case BuyerVerificationStep.permissionsSetup:
        return _buildStep5PermissionsSetup(context, state);
      case BuyerVerificationStep.completionSuccess:
        return _buildStep6CompletionSuccess(context, state);
    }
  }

  void _showPhotoOptionsModal(
      BuildContext context, BuyerOnboardingVerificationState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (!kIsWeb &&
                    (defaultTargetPlatform == TargetPlatform.android ||
                        defaultTargetPlatform == TargetPlatform.iOS))
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: BuyerAppColors.fieldFill,
                      child: Icon(Icons.camera_alt, color: BuyerAppColors.primary),
                    ),
                    title: const Text('Take Photo',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.read<BuyerOnboardingVerificationBloc>().add(
                            const BuyerAvatarPickRequested(
                                source: ImageSource.camera),
                          );
                    },
                  ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: BuyerAppColors.fieldFill,
                    child: Icon(Icons.photo_library, color: BuyerAppColors.primary),
                  ),
                  title: const Text('Choose from Gallery / Files',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    context.read<BuyerOnboardingVerificationBloc>().add(
                          const BuyerAvatarPickRequested(
                              source: ImageSource.gallery),
                        );
                  },
                ),
                if (state.avatarUrl != null || state.localAvatarBytes != null)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade50,
                      child:
                          const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: const Text('Remove Photo',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.read<BuyerOnboardingVerificationBloc>().add(
                            const BuyerAvatarRemoved(),
                          );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 1: Personal Details & Avatar
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep1PersonalDetails(
      BuildContext context, BuyerOnboardingVerificationState state) {
    return Column(
      key: const ValueKey('step_1_personal'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: '👤 Personal Identity & Avatar',
          subtitle: 'Tell us how you would like restaurants and riders to recognize you.',
        ),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () => _showPhotoOptionsModal(context, state),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BuyerAppColors.fieldFill,
                    border: Border.all(
                      color: BuyerAppColors.primary.withValues(alpha: 0.3),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: state.isUploadingAvatar
                        ? const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: BuyerAppColors.primary,
                              ),
                            ),
                          )
                        : state.localAvatarBytes != null
                            ? Image.memory(
                                state.localAvatarBytes!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              )
                            : state.avatarUrl != null &&
                                    state.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    state.avatarUrl!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.person,
                                                size: 48, color: Colors.grey),
                                  )
                                : const Icon(Icons.person,
                                    size: 48, color: Colors.grey),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: BuyerAppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name *',
          hint: 'e.g. Anand Kumar',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _displayNameController,
          label: 'Display Name (Nickname)',
          hint: 'e.g. Anand',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _bioController,
          label: 'Short Bio (Optional)',
          hint: 'e.g. Food enthusiast & South Indian cuisine lover',
          icon: Icons.edit_note_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Continue to Contact Verification ➔',
          onPressed: () {
            final name = _fullNameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter your full name.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerPersonalDetailsUpdated(
                    fullName: name,
                    displayName: _displayNameController.text.trim(),
                    bio: _bioController.text.trim(),
                  ),
                );
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 2: Contact & Phone Verification
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep2ContactVerification(
      BuildContext context, BuyerOnboardingVerificationState state) {
    final isVerified = state.isPhoneVerified;

    return Column(
      key: const ValueKey('step_2_contact'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: '📱 Contact & Phone Verification',
          subtitle: isVerified
              ? 'Your mobile number is verified and linked to your FoodGo account.'
              : 'Verify your phone number to receive real-time order SMS & OTP alerts.',
        ),
        const SizedBox(height: 24),
        if (isVerified) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phone Number Verified ✅',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.phone.isNotEmpty
                            ? state.phone
                            : (_phoneController.text.isNotEmpty
                                ? _phoneController.text
                                : 'Verified Mobile'),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address *',
            hint: 'buyer@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),
          _buildPrimaryButton(
            label: 'Continue to Delivery Address ➔',
            onPressed: () {
              final email = _emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid email address.'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              context.read<BuyerOnboardingVerificationBloc>().add(
                    BuyerContactUpdated(
                      email: email,
                      phone: _phoneController.text.isNotEmpty
                          ? _phoneController.text.trim()
                          : state.phone,
                    ),
                  );
              context
                  .read<BuyerOnboardingVerificationBloc>()
                  .add(const BuyerVerificationNextStepPressed());
            },
          ),
        ] else ...[
          _buildTextField(
            controller: _phoneController,
            label: 'Mobile Number *',
            hint: '+91 98765 43210',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address *',
            hint: 'buyer@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          if (state.status != BuyerVerificationStatus.otpSent)
            OutlinedButton.icon(
              onPressed: () {
                context.read<BuyerOnboardingVerificationBloc>().add(
                      BuyerContactUpdated(
                        email: _emailController.text,
                        phone: _phoneController.text,
                      ),
                    );
                context
                    .read<BuyerOnboardingVerificationBloc>()
                    .add(const BuyerSendOtpRequested());
              },
              icon: const Icon(Icons.send, color: BuyerAppColors.primary),
              label: const Text('Send 6-Digit OTP Code',
                  style: TextStyle(color: BuyerAppColors.primary)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: BuyerAppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          if (state.status == BuyerVerificationStatus.otpSent) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _otpController,
              label: 'Enter 6-Digit OTP',
              hint: '••••••',
              icon: Icons.lock_clock_outlined,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                context
                    .read<BuyerOnboardingVerificationBloc>()
                    .add(BuyerOtpCodeChanged(val));
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.otpCountdown > 0
                      ? 'Resend code in ${state.otpCountdown}s'
                      : 'Did not receive OTP?',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                if (state.isOtpResendAvailable)
                  TextButton(
                    onPressed: () {
                      context
                          .read<BuyerOnboardingVerificationBloc>()
                          .add(const BuyerSendOtpRequested());
                    },
                    child: const Text('Resend OTP',
                        style: TextStyle(
                            color: BuyerAppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPrimaryButton(
              label: 'Verify OTP & Continue ➔',
              isLoading: state.status == BuyerVerificationStatus.loading,
              onPressed: () {
                context
                    .read<BuyerOnboardingVerificationBloc>()
                    .add(const BuyerVerifyOtpPressed());
              },
            ),
          ],
        ],
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 3: Delivery Address & Map Geolocation
  // ───────────────────────────────────────────────────────────────────────────
  void _openAddressSearchDialog(
      BuildContext context, BuyerOnboardingVerificationState state) {
    GoogleAddressSearchDialog.show(
      context: context,
      addressType: state.addressTag.isNotEmpty ? state.addressTag : 'Home',
      currentAddress: _addressController.text.isNotEmpty
          ? _addressController.text
          : state.formattedAddress,
      onAddressSelected: (selectedAddress) {
        setState(() {
          _addressController.text = selectedAddress;
        });
        context.read<BuyerOnboardingVerificationBloc>().add(
              BuyerAddressLocationSelected(
                formattedAddress: selectedAddress,
                latitude: state.latitude ?? 13.0827,
                longitude: state.longitude ?? 80.2707,
                houseFlatNo: _flatNoController.text,
                landmark: _landmarkController.text,
                addressTag: state.addressTag,
              ),
            );
      },
    );
  }

  Widget _buildMapPreview(
      BuildContext context, BuyerOnboardingVerificationState state) {
    final hasCoords = state.latitude != null && state.longitude != null;
    final lat = state.latitude ?? 13.0827;
    final lng = state.longitude ?? 80.2707;
    final LatLng centerLatLng = LatLng(lat, lng);

    final bool isNativeDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
    final bool shouldUseFallback =
        isNativeDesktop || (kIsWeb && !isGoogleMapsJsReady());

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: shouldUseFallback
                ? CachedMapTile(
                    tileUrl:
                        'https://tile.openstreetmap.org/15/${((lng + 180.0) / 360.0 * 32768).floor()}/${((1.0 - math.log(math.tan(lat * math.pi / 180.0) + 1.0 / math.cos(lat * math.pi / 180.0)) / math.pi) / 2.0 * 32768).floor()}.png',
                    fallbackTileUrl:
                        'https://a.tile.openstreetmap.fr/hot/15/${((lng + 180.0) / 360.0 * 32768).floor()}/${((1.0 - math.log(math.tan(lat * math.pi / 180.0) + 1.0 / math.cos(lat * math.pi / 180.0)) / math.pi) / 2.0 * 32768).floor()}.png',
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: centerLatLng,
                      zoom: 15.0,
                    ),
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('buyer_delivery_pin'),
                        position: centerLatLng,
                        infoWindow: InfoWindow(
                          title: state.addressTag.isNotEmpty
                              ? state.addressTag
                              : 'Delivery Location',
                          snippet: state.formattedAddress.isNotEmpty
                              ? state.formattedAddress
                              : 'Selected Address',
                        ),
                      ),
                    },
                  ),
          ),
          // Center Marker overlay if fallback tile is used
          if (shouldUseFallback)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.addressTag.isNotEmpty
                          ? state.addressTag
                          : 'Delivery Location',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(
                    Icons.location_on,
                    size: 38,
                    color: BuyerAppColors.primary,
                  ),
                ],
              ),
            ),
          // Top live coordinates badge
          if (hasCoords)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.gps_fixed, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Bottom overlay button to search / adjust pin on map
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton.icon(
              onPressed: () => _openAddressSearchDialog(context, state),
              icon: const Icon(Icons.map, size: 16, color: Colors.white),
              label: const Text(
                'Adjust Pin on Map',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BuyerAppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3AddressSelection(
      BuildContext context, BuyerOnboardingVerificationState state) {
    return Column(
      key: const ValueKey('step_3_address'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: '📍 Primary Delivery Address',
          subtitle: 'Pin your location for accurate real-time delivery estimates and tracking.',
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: state.isLocatingGps
              ? null
              : () {
                  context
                      .read<BuyerOnboardingVerificationBloc>()
                      .add(const BuyerCurrentLocationRequested());
                },
          icon: state.isLocatingGps
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.my_location, color: Colors.white),
          label: Text(
            state.isLocatingGps
                ? 'Detecting Real-Time GPS...'
                : 'Use My Current GPS Location',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        _buildMapPreview(context, state),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Complete Address / Landmark *',
          hint: 'Street, Sector, City, Pincode',
          icon: Icons.location_on_outlined,
          maxLines: 2,
          suffixIcon: IconButton(
            tooltip: 'Pick on Google Maps / Search Places',
            icon: const Icon(Icons.location_searching, color: BuyerAppColors.primary),
            onPressed: () => _openAddressSearchDialog(context, state),
          ),
          onChanged: (val) {
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerAddressLocationSelected(
                    formattedAddress: val,
                    latitude: state.latitude ?? 13.0827,
                    longitude: state.longitude ?? 80.2707,
                    houseFlatNo: _flatNoController.text,
                    landmark: _landmarkController.text,
                    addressTag: state.addressTag,
                  ),
                );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _flatNoController,
                label: 'Flat / Door No',
                hint: 'A-402',
                icon: Icons.door_front_door_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _landmarkController,
                label: 'Nearby Landmark',
                hint: 'Near Metro Station',
                icon: Icons.flag_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Save Address As:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: ['Home', 'Work', 'Other'].map((tag) {
            final isSelected = state.addressTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                selectedColor: BuyerAppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? BuyerAppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    context.read<BuyerOnboardingVerificationBloc>().add(
                          BuyerAddressTagChanged(tag),
                        );
                  }
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Save Address & Continue ➔',
          onPressed: () {
            final address = _addressController.text.trim();
            if (address.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter or pin your delivery address.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerAddressUpdated(
                    formattedAddress: address,
                    houseFlatNo: _flatNoController.text.trim(),
                    landmark: _landmarkController.text.trim(),
                    addressTag: state.addressTag.isNotEmpty ? state.addressTag : 'Home',
                    latitude: state.latitude,
                    longitude: state.longitude,
                  ),
                );
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 4: Payment Methods & Digital Wallet Setup
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep4PaymentSetup(
      BuildContext context, BuyerOnboardingVerificationState state) {
    final paymentModes = [
      {'name': 'UPI (GPay / PhonePe / Paytm)', 'icon': Icons.qr_code_2},
      {'name': 'Credit / Debit Cards', 'icon': Icons.credit_card},
      {'name': 'Net Banking', 'icon': Icons.account_balance},
      {'name': 'Cash on Delivery (COD)', 'icon': Icons.payments_outlined},
    ];

    return Column(
      key: const ValueKey('step_4_payments'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: '💳 Payment Preference & In-App Wallet',
          subtitle: 'Enable quick 1-tap checkout and activate your Food Delivery Wallet.',
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: BuyerAppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.account_balance_wallet,
                      color: BuyerAppColors.primary),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Activate Buyer Wallet',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Get ₹100 Welcome cashback on completion',
                          style: TextStyle(color: Colors.green, fontSize: 13)),
                    ],
                  ),
                ),
                Switch(
                  value: state.activateBuyerWallet,
                  activeColor: BuyerAppColors.primary,
                  onChanged: (val) {
                    context
                        .read<BuyerOnboardingVerificationBloc>()
                        .add(BuyerWalletToggled(val));
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Preferred Payment Method:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        ...paymentModes.map((mode) {
          final name = mode['name'] as String;
          final icon = mode['icon'] as IconData;
          final isSelected = state.preferredPaymentMethod == name;
          return Card(
            elevation: isSelected ? 2 : 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? BuyerAppColors.primary : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              leading: Icon(icon, color: isSelected ? BuyerAppColors.primary : Colors.grey),
              title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: BuyerAppColors.primary)
                  : null,
              onTap: () {
                context
                    .read<BuyerOnboardingVerificationBloc>()
                    .add(BuyerPaymentMethodChanged(name));
              },
            ),
          );
        }),
        if (state.preferredPaymentMethod.startsWith('UPI')) ...[
          const SizedBox(height: 14),
          _buildTextField(
            controller: _upiIdController,
            label: 'Default UPI ID (Optional)',
            hint: 'e.g. yourname@okhdfcbank',
            icon: Icons.alternate_email,
            onChanged: (val) {
              // Real-time local state update
            },
          ),
        ],
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Continue to Permissions ➔',
          onPressed: () {
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerPaymentPreferenceSelected(
                    paymentMethod: state.preferredPaymentMethod,
                    defaultUpiId: _upiIdController.text.trim().isNotEmpty
                        ? _upiIdController.text.trim()
                        : state.defaultUpiId,
                    activateBuyerWallet: state.activateBuyerWallet,
                  ),
                );
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 5: App Permissions (GPS, FCM Notifications)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep5PermissionsSetup(
      BuildContext context, BuyerOnboardingVerificationState state) {
    return Column(
      key: const ValueKey('step_5_permissions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: '🔔 App Permissions & Notifications',
          subtitle: 'Enable permissions to enjoy live 60 FPS GPS tracking and instant alerts.',
        ),
        const SizedBox(height: 20),
        _buildPermissionTile(
          icon: Icons.location_on,
          title: 'Fine GPS Location',
          subtitle: 'Required for real-time delivery rider tracking and delivery fee estimation.',
          isGranted: state.locationPermissionGranted,
          onToggle: (val) {
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerSinglePermissionToggled(
                    permissionType: 'location',
                    isGranted: val,
                  ),
                );
          },
        ),
        const SizedBox(height: 12),
        _buildPermissionTile(
          icon: Icons.notifications_active,
          title: 'Push Notifications',
          subtitle: 'Receive updates when food is being cooked, dispatched, or arrives at your door.',
          isGranted: state.pushNotificationsGranted,
          onToggle: (val) {
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerSinglePermissionToggled(
                    permissionType: 'notifications',
                    isGranted: val,
                  ),
                );
          },
        ),
        const SizedBox(height: 12),
        _buildPermissionTile(
          icon: Icons.camera_alt,
          title: 'Camera & Gallery',
          subtitle: 'Allows uploading avatar pictures and dish feedback review photos.',
          isGranted: state.cameraPermissionGranted,
          onToggle: (val) {
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerSinglePermissionToggled(
                    permissionType: 'camera',
                    isGranted: val,
                  ),
                );
          },
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Review & Activate Account ➔',
          onPressed: () {
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerPermissionsUpdated(
                    locationGranted: state.locationPermissionGranted,
                    notificationsGranted: state.pushNotificationsGranted,
                    cameraGranted: state.cameraPermissionGranted,
                  ),
                );
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 6: Welcome Rewards & Verification Completion
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep6CompletionSuccess(
      BuildContext context, BuyerOnboardingVerificationState state) {
    return Column(
      key: const ValueKey('step_6_success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 54,
          backgroundColor: Colors.green,
          child: Icon(Icons.check_circle_outline, size: 64, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          '🎉 Verification & Setup Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Welcome to the platform, ${state.fullName.isNotEmpty ? state.fullName : "Food Lover"}! Your preferences and wallet have been activated.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, size: 38, color: Colors.deepOrange),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WELCOME REWARD UNLOCKED',
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const Text('₹100 Flat Discount',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    Text('Coupon Code: ${state.welcomeCouponCode}',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        _buildPrimaryButton(
          label: 'Start Ordering Delicious Food 🍔',
          isLoading: state.status == BuyerVerificationStatus.loading,
          onPressed: () {
            context
                .read<BuyerOnboardingVerificationBloc>()
                .add(const BuyerCompleteVerificationSubmitted());
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helper Widgets
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: BuyerAppColors.primary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: BuyerAppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required ValueChanged<bool> onToggle,
  }) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isGranted
              ? Colors.green.shade100
              : BuyerAppColors.primary.withValues(alpha: 0.1),
          child: Icon(icon,
              color: isGranted ? Colors.green.shade800 : BuyerAppColors.primary),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Switch(
          value: isGranted,
          activeColor: Colors.green,
          onChanged: onToggle,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: BuyerAppColors.primary,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
