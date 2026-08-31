import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
import 'package:food_delivery_app/core/widgets/responsive_layout.dart';
import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';
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
  final _allergyNotesController = TextEditingController();
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
    _allergyNotesController.text = bloc.state.customAllergyNotes;
    _upiIdController.text = bloc.state.defaultUpiId ?? '';
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
    _allergyNotesController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuyerOnboardingVerificationBloc,
        BuyerOnboardingVerificationState>(
      listener: (context, state) {
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

        return Scaffold(
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
      case BuyerVerificationStep.dietaryPreferences:
        return _buildStep4DietaryPreferences(context, state);
      case BuyerVerificationStep.allergiesAndRestrictions:
        return _buildStep5AllergiesAndRestrictions(context, state);
      case BuyerVerificationStep.paymentSetup:
        return _buildStep6PaymentSetup(context, state);
      case BuyerVerificationStep.permissionsSetup:
        return _buildStep7PermissionsSetup(context, state);
      case BuyerVerificationStep.completionSuccess:
        return _buildStep8CompletionSuccess(context, state);
    }
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
          child: Stack(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: BuyerAppColors.fieldFill,
                backgroundImage: state.avatarUrl != null
                    ? NetworkImage(state.avatarUrl!)
                    : null,
                child: state.avatarUrl == null
                    ? const Icon(Icons.person, size: 48, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: BuyerAppColors.primary,
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
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
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerPersonalDetailsUpdated(
                    fullName: _fullNameController.text,
                    displayName: _displayNameController.text,
                    bio: _bioController.text,
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
              context.read<BuyerOnboardingVerificationBloc>().add(
                    BuyerContactUpdated(
                      email: _emailController.text,
                      phone: _phoneController.text.isNotEmpty
                          ? _phoneController.text
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
          onPressed: () {
            context
                .read<BuyerOnboardingVerificationBloc>()
                .add(const BuyerCurrentLocationRequested());
          },
          icon: const Icon(Icons.my_location, color: Colors.white),
          label: Text(
            state.isLocatingGps
                ? 'Detecting GPS Coordinates...'
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
        _buildTextField(
          controller: _addressController..text = state.formattedAddress,
          label: 'Complete Address / Landmark *',
          hint: 'Street, Sector, City, Pincode',
          icon: Icons.location_on_outlined,
          maxLines: 2,
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
                          BuyerAddressUpdated(
                            formattedAddress: _addressController.text,
                            houseFlatNo: _flatNoController.text,
                            landmark: _landmarkController.text,
                            addressTag: tag,
                            latitude: state.latitude,
                            longitude: state.longitude,
                          ),
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
            context.read<BuyerOnboardingVerificationBloc>().add(
                  BuyerAddressUpdated(
                    formattedAddress: _addressController.text,
                    houseFlatNo: _flatNoController.text,
                    landmark: _landmarkController.text,
                    addressTag: state.addressTag,
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
  // STEP 4: Dietary Preferences & Eating Habits
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep4DietaryPreferences(
      BuildContext context, BuyerOnboardingVerificationState state) {
    final diets = [
      {'name': 'Vegetarian', 'icon': '🥬'},
      {'name': 'Non-Vegetarian', 'icon': '🍗'},
      {'name': 'Vegan', 'icon': '🌱'},
      {'name': 'Eggetarian', 'icon': '🥚'},
      {'name': 'Halal', 'icon': '🥩'},
      {'name': 'Jain Friendly', 'icon': '🥦'},
    ];

    final spiceLevels = ['Mild 🟢', 'Medium 🟡', 'Spicy 🔴', 'Extra Spicy 🔥'];

    return Column(
      key: const ValueKey('step_4_diet'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: '🥗 Dietary Preferences & Taste',
          subtitle: 'We will personalize restaurant recommendations to match your eating style.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: diets.map((diet) {
            final name = diet['name']!;
            final icon = diet['icon']!;
            final isSelected = state.selectedDietaryTypes.contains(name);
            return FilterChip(
              avatar: Text(icon),
              label: Text(name),
              selected: isSelected,
              selectedColor: BuyerAppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: BuyerAppColors.primary,
              onSelected: (_) {
                context
                    .read<BuyerOnboardingVerificationBloc>()
                    .add(BuyerDietaryPreferenceToggled(name));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Preferred Spice Level:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: spiceLevels.map((lvl) {
            final isSelected = state.spicePreference == lvl.split(' ')[0];
            return ChoiceChip(
              label: Text(lvl),
              selected: isSelected,
              selectedColor: BuyerAppColors.primary.withValues(alpha: 0.2),
              onSelected: (selected) {
                if (selected) {
                  context.read<BuyerOnboardingVerificationBloc>().add(
                        BuyerSpicePreferenceChanged(lvl.split(' ')[0]),
                      );
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Continue to Food Allergies ➔',
          onPressed: () {
            context
                .read<BuyerOnboardingVerificationBloc>()
                .add(const BuyerVerificationNextStepPressed());
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 5: Food Allergies & Special Instructions
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep5AllergiesAndRestrictions(
      BuildContext context, BuyerOnboardingVerificationState state) {
    final commonAllergies = [
      'Peanuts / Nuts 🥜',
      'Dairy / Lactose 🥛',
      'Gluten / Wheat 🌾',
      'Soy 🫘',
      'Shellfish / Seafood 🦐',
      'Eggs 🥚',
      'Mushrooms 🍄',
    ];

    return Column(
      key: const ValueKey('step_5_allergies'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: '⚠️ Food Allergies & Safety Notes',
          subtitle: 'Our kitchen partners will be automatically alerted about your food safety.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: commonAllergies.map((allergy) {
            final isSelected = state.selectedAllergies.contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              selectedColor: Colors.amber.shade200,
              checkmarkColor: Colors.brown.shade800,
              onSelected: (_) {
                context
                    .read<BuyerOnboardingVerificationBloc>()
                    .add(BuyerAllergyToggled(allergy));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _allergyNotesController,
          label: 'Additional Special Instructions',
          hint: 'e.g. Please avoid MSG, extra crisp fries',
          icon: Icons.notes_outlined,
          maxLines: 2,
          onChanged: (val) {
            context
                .read<BuyerOnboardingVerificationBloc>()
                .add(BuyerCustomAllergyNotesChanged(val));
          },
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Continue to Payment Setup ➔',
          onPressed: () {
            context
                .read<BuyerOnboardingVerificationBloc>()
                .add(const BuyerVerificationNextStepPressed());
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 6: Payment Methods & Digital Wallet Setup
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep6PaymentSetup(
      BuildContext context, BuyerOnboardingVerificationState state) {
    final paymentModes = [
      {'name': 'UPI (GPay / PhonePe / Paytm)', 'icon': Icons.qr_code_2},
      {'name': 'Credit / Debit Cards', 'icon': Icons.credit_card},
      {'name': 'Net Banking', 'icon': Icons.account_balance},
      {'name': 'Cash on Delivery (COD)', 'icon': Icons.payments_outlined},
    ];

    return Column(
      key: const ValueKey('step_6_payments'),
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
                    context.read<BuyerOnboardingVerificationBloc>().add(
                          BuyerPaymentPreferenceSelected(
                            paymentMethod: state.preferredPaymentMethod,
                            activateBuyerWallet: val,
                          ),
                        );
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
                context.read<BuyerOnboardingVerificationBloc>().add(
                      BuyerPaymentPreferenceSelected(
                        paymentMethod: name,
                        activateBuyerWallet: state.activateBuyerWallet,
                      ),
                    );
              },
            ),
          );
        }),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Continue to Permissions ➔',
          onPressed: () {
            context
                .read<BuyerOnboardingVerificationBloc>()
                .add(const BuyerVerificationNextStepPressed());
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 7: App Permissions (GPS, FCM Notifications)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep7PermissionsSetup(
      BuildContext context, BuyerOnboardingVerificationState state) {
    return Column(
      key: const ValueKey('step_7_permissions'),
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
                  BuyerPermissionsUpdated(
                    locationGranted: val,
                    notificationsGranted: state.pushNotificationsGranted,
                    cameraGranted: state.cameraPermissionGranted,
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
                  BuyerPermissionsUpdated(
                    locationGranted: state.locationPermissionGranted,
                    notificationsGranted: val,
                    cameraGranted: state.cameraPermissionGranted,
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
                  BuyerPermissionsUpdated(
                    locationGranted: state.locationPermissionGranted,
                    notificationsGranted: state.pushNotificationsGranted,
                    cameraGranted: val,
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
                    locationGranted: true,
                    notificationsGranted: true,
                    cameraGranted: true,
                  ),
                );
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 8: Welcome Rewards & Verification Completion
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep8CompletionSuccess(
      BuildContext context, BuyerOnboardingVerificationState state) {
    return Column(
      key: const ValueKey('step_8_success'),
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
