import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_delivery_app/core/services/bank_ifsc_service.dart';
import 'package:food_delivery_app/core/services/delivery_city_zone_service.dart';
import 'package:food_delivery_app/core/services/google_places_service.dart';
import 'package:food_delivery_app/core/theme/delivery_app_colors.dart';
import 'package:food_delivery_app/core/widgets/responsive_layout.dart';
import '../delivery_image_picker_helper.dart';
import '../delivery_document_preview_dialog.dart';
import '../Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import '../Delivery_Profile_page/delivery_google_address_search_dialog.dart';
import 'delivery_bank_ifsc_search_dialog.dart';
import 'delivery_city_zone_search_dialog.dart';
import 'delivery_onboarding_verification_bloc.dart';
import 'delivery_onboarding_verification_event.dart';
import 'delivery_onboarding_verification_state.dart';

class DeliveryOnboardingVerificationPage extends StatelessWidget {
  final DeliveryVerificationStep? initialStep;
  final String? initialFullName;
  final String? initialDisplayName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialAvatarUrl;
  final bool initialIsPhoneVerified;

  const DeliveryOnboardingVerificationPage({
    super.key,
    this.initialStep,
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
      create: (context) => DeliveryOnboardingVerificationBloc(
        initialStep: initialStep,
        initialFullName: initialFullName,
        initialDisplayName: initialDisplayName,
        initialEmail: initialEmail,
        initialPhone: initialPhone,
        initialAvatarUrl: initialAvatarUrl,
        initialIsPhoneVerified: initialIsPhoneVerified ||
            (initialPhone != null && initialPhone!.isNotEmpty),
      )..add(const DeliveryVerificationAutoFetchRequested()),
      child: const _DeliveryOnboardingVerificationView(),
    );
  }
}

class _DeliveryOnboardingVerificationView extends StatefulWidget {
  const _DeliveryOnboardingVerificationView();

  @override
  State<_DeliveryOnboardingVerificationView> createState() =>
      _DeliveryOnboardingVerificationViewState();
}

class _DeliveryOnboardingVerificationViewState
    extends State<_DeliveryOnboardingVerificationView> {
  // Step 1 Controllers
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _bioController = TextEditingController();

  // Step 2 Controllers
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  // Step 3 Controllers
  final _vehicleNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _dlNumberController = TextEditingController();
  final _dlExpiryController = TextEditingController();

  // Step 4 Controllers
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();

  // Step 5 Controllers
  final _bankAccountController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _upiIdController = TextEditingController();

  // Step 6 Controllers
  final _cityController = TextEditingController();
  final _cityFocusNode = FocusNode();
  final _zoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _flatNoController = TextEditingController();
  final _landmarkController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  /// Tracks which steps have been attempted by user so inline field errors show up instantly
  final Set<DeliveryVerificationStep> _attemptedSteps = {};

  // Bank IFSC Search & Verification state
  BankBranchInfo? _verifiedBankInfo;
  bool _isValidatingIfsc = false;
  Timer? _ifscDebounceTimer;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<DeliveryOnboardingVerificationBloc>();
    _syncControllersFromState(bloc.state, force: true);

    _dobController.addListener(() {
      if (mounted) {
        _syncStep1(
            context, context.read<DeliveryOnboardingVerificationBloc>().state);
      }
    });
    _dlExpiryController.addListener(() {
      if (mounted) {
        _syncStep3(
            context, context.read<DeliveryOnboardingVerificationBloc>().state);
      }
    });
  }

  void _syncControllersFromState(
    DeliveryOnboardingVerificationState state, {
    bool force = false,
  }) {
    void syncText(TextEditingController controller, String value) {
      if (value.isNotEmpty && (force || controller.text.trim().isEmpty)) {
        if (controller.text != value) {
          controller.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          );
        }
      }
    }

    syncText(_fullNameController, state.fullName);
    syncText(_displayNameController, state.displayName);
    syncText(_dobController, state.dob);
    syncText(_emergencyNameController, state.emergencyContactName);
    syncText(_emergencyPhoneController, state.emergencyContactPhone);
    syncText(_bioController, state.bio);
    syncText(_phoneController, state.phone);
    syncText(_emailController, state.email);
    syncText(_vehicleNumberController, state.vehicleNumber);
    syncText(_vehicleModelController, state.vehicleModel);
    syncText(_dlNumberController, state.drivingLicenseNumber);
    syncText(_dlExpiryController, state.dlExpiryDate);
    syncText(_aadhaarController, state.aadhaarNumber);
    syncText(_panController, state.panNumber);
    syncText(_bankAccountController, state.bankAccountNumber);
    syncText(_confirmAccountController, state.confirmAccountNumber);
    syncText(_ifscController, state.ifscCode);
    syncText(_bankNameController, state.bankName);
    syncText(_accountHolderController, state.accountHolderName);
    syncText(_upiIdController, state.upiId);
    syncText(_cityController, state.city);
    syncText(_zoneController, state.operatingZone);
    syncText(_addressController, state.formattedAddress);
    syncText(_flatNoController, state.houseFlatNo);
    syncText(_landmarkController, state.landmark);

    if (state.ifscCode.isNotEmpty && _verifiedBankInfo == null) {
      final cached = BankIfscService.instance.searchBanks(state.ifscCode);
      if (cached.isNotEmpty && cached.first.ifsc.toUpperCase() == state.ifscCode.toUpperCase()) {
        _verifiedBankInfo = cached.first;
      }
    }
  }

  @override
  void dispose() {
    _ifscDebounceTimer?.cancel();
    _fullNameController.dispose();
    _displayNameController.dispose();
    _dobController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    _dlNumberController.dispose();
    _dlExpiryController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _bankAccountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _upiIdController.dispose();
    _cityController.dispose();
    _cityFocusNode.dispose();
    _zoneController.dispose();
    _addressController.dispose();
    _flatNoController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  /// Cross-platform image picker helper (Camera / Gallery / Desktop files)
  Future<void> _pickImage({
    required ImageSource source,
    required Function(Uint8List bytes, String fileName) onImagePicked,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        onImagePicked(bytes, file.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: DeliveryAppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog(
      Function(Uint8List bytes, String fileName) onImagePicked, {String title = 'Document'}) {
    DeliveryImagePickerHelper.showPicker(
      context: context,
      title: title,
      onImagePicked: onImagePicked,
      enableCamera: true,
      allowPdf: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      listener: (context, state) {
        _syncControllersFromState(state);

        if (state.status == DeliveryVerificationStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: DeliveryAppColors.error,
            ),
          );
        } else if (state.status == DeliveryVerificationStatus.success) {
          _showCompletionSuccessDialog(context, state);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: DeliveryAppColors.background,
          appBar: _buildAppBar(context, state),
          body: ResponsiveLayout(
            mobileBody: (ctx) =>
                _buildMainContent(context, state, isDesktop: false),
            desktopBody: (ctx) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: _buildMainContent(context, state, isDesktop: true),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomActionBar(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final stepNumber = state.currentStep.index + 1;
    return AppBar(
      backgroundColor: DeliveryAppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: DeliveryAppColors.textPrimary),
        onPressed: () {
          if (state.currentStep.index > 0) {
            final prevStep = DeliveryVerificationStep
                .values[state.currentStep.index - 1];
            context
                .read<DeliveryOnboardingVerificationBloc>()
                .add(DeliveryVerificationStepChanged(prevStep));
          } else {
            Navigator.maybePop(context);
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partner Onboarding & KYC',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DeliveryAppColors.textPrimary,
            ),
          ),
          Text(
            'Step $stepNumber of 8 — ${_getStepTitle(state.currentStep)}',
            style: const TextStyle(
              fontSize: 12,
              color: DeliveryAppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6),
        child: LinearProgressIndicator(
          value: stepNumber / 8.0,
          backgroundColor: DeliveryAppColors.surface,
          valueColor:
              const AlwaysStoppedAnimation<Color>(DeliveryAppColors.primary),
          minHeight: 4,
        ),
      ),
    );
  }

  String _getStepTitle(DeliveryVerificationStep step) {
    switch (step) {
      case DeliveryVerificationStep.personalDetails:
        return 'Personal Details & Selfie';
      case DeliveryVerificationStep.contactVerification:
        return 'Phone OTP & Email';
      case DeliveryVerificationStep.vehicleAndLicense:
        return 'Vehicle & Driving License';
      case DeliveryVerificationStep.kycDocuments:
        return 'Identity & Government KYC';
      case DeliveryVerificationStep.bankAndPayouts:
        return 'Bank & Instant Payouts';
      case DeliveryVerificationStep.zoneAndPreferences:
        return 'Operating Zone & GPS Base';
      case DeliveryVerificationStep.hardwarePermissions:
        return 'Permissions & Telemetry';
      case DeliveryVerificationStep.safetyKitAndActivation:
        return 'Safety Kit & Final Submit';
    }
  }

  Widget _buildMainContent(
      BuildContext context, DeliveryOnboardingVerificationState state,
      {required bool isDesktop}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepBreadcrumbs(context, state),
          const SizedBox(height: 24),
          _buildCurrentStepBody(context, state),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStepBreadcrumbs(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(8, (index) {
          final isCompleted = index < state.currentStep.index;
          final isCurrent = index == state.currentStep.index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                if (index <= state.currentStep.index) {
                  context.read<DeliveryOnboardingVerificationBloc>().add(
                        DeliveryVerificationStepChanged(
                            DeliveryVerificationStep.values[index]),
                      );
                } else {
                  setState(() {
                    _attemptedSteps.add(state.currentStep);
                  });
                  final err = state.validateStep(state.currentStep);
                  if (err != null) {
                    _showValidationSnackBar(err);
                    return;
                  }
                  context.read<DeliveryOnboardingVerificationBloc>().add(
                        DeliveryVerificationStepChanged(
                            DeliveryVerificationStep.values[index]),
                      );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? DeliveryAppColors.primary
                      : (isCompleted
                          ? DeliveryAppColors.success.withOpacity(0.2)
                          : DeliveryAppColors.surface),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent
                        ? DeliveryAppColors.primary
                        : (isCompleted
                            ? DeliveryAppColors.success
                            : DeliveryAppColors.border),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted)
                      const Icon(Icons.check,
                          size: 14, color: DeliveryAppColors.success)
                    else
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Colors.white
                              : DeliveryAppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      _getStepShortName(DeliveryVerificationStep.values[index]),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent
                            ? Colors.white
                            : (isCompleted
                                ? DeliveryAppColors.textPrimary
                                : DeliveryAppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getStepShortName(DeliveryVerificationStep step) {
    switch (step) {
      case DeliveryVerificationStep.personalDetails:
        return 'Profile';
      case DeliveryVerificationStep.contactVerification:
        return 'Phone';
      case DeliveryVerificationStep.vehicleAndLicense:
        return 'Vehicle/DL';
      case DeliveryVerificationStep.kycDocuments:
        return 'KYC ID';
      case DeliveryVerificationStep.bankAndPayouts:
        return 'Bank';
      case DeliveryVerificationStep.zoneAndPreferences:
        return 'Zone';
      case DeliveryVerificationStep.hardwarePermissions:
        return 'Perms';
      case DeliveryVerificationStep.safetyKitAndActivation:
        return 'Activation';
    }
  }

  Widget _buildCurrentStepBody(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    switch (state.currentStep) {
      case DeliveryVerificationStep.personalDetails:
        return _buildStep1PersonalDetails(context, state);
      case DeliveryVerificationStep.contactVerification:
        return _buildStep2Contact(context, state);
      case DeliveryVerificationStep.vehicleAndLicense:
        return _buildStep3Vehicle(context, state);
      case DeliveryVerificationStep.kycDocuments:
        return _buildStep4Kyc(context, state);
      case DeliveryVerificationStep.bankAndPayouts:
        return _buildStep5Bank(context, state);
      case DeliveryVerificationStep.zoneAndPreferences:
        return _buildStep6Zone(context, state);
      case DeliveryVerificationStep.hardwarePermissions:
        return _buildStep7Permissions(context, state);
      case DeliveryVerificationStep.safetyKitAndActivation:
        return _buildStep8SafetyActivation(context, state);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 1: Personal Details & Avatar/Selfie
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep1PersonalDetails(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final hasAttempted = _attemptedSteps.contains(DeliveryVerificationStep.personalDetails);
    final hasPhoto = state.localAvatarBytes != null ||
        (state.avatarUrl != null && state.avatarUrl!.isNotEmpty);

    final nameError = hasAttempted && _fullNameController.text.trim().length < 3
        ? 'Full name is mandatory (minimum 3 characters)'
        : null;
    final dobError = hasAttempted && _dobController.text.trim().isEmpty
        ? 'Date of birth is mandatory (DD/MM/YYYY)'
        : null;
    final emerNameError = hasAttempted && _emergencyNameController.text.trim().length < 2
        ? 'Emergency contact person name is mandatory'
        : null;
    final cleanEmerPhone = _emergencyPhoneController.text.replaceAll(RegExp(r'\D'), '');
    final emerPhoneError = hasAttempted && cleanEmerPhone.length < 10
        ? 'Valid 10-digit emergency contact phone number is mandatory'
        : null;
    final photoError = hasAttempted && !hasPhoto
        ? 'Live driver selfie photo is mandatory for verification'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Personal Information & Driver Selfie',
          'Enter your official identification details and capture a clear live photo for rider verification.',
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              InkWell(
                onTap: () => _showImageSourceDialog((bytes, fileName) {
                  context.read<DeliveryOnboardingVerificationBloc>().add(
                        DeliveryAvatarPicked(
                            bytes: bytes, fileName: fileName),
                      );
                }, title: 'Driver Live Selfie'),
                borderRadius: BorderRadius.circular(55),
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DeliveryAppColors.surface,
                        border: Border.all(
                          color: photoError != null
                              ? DeliveryAppColors.error
                              : (hasPhoto
                                  ? DeliveryAppColors.success
                                  : DeliveryAppColors.primary),
                          width: photoError != null ? 3.0 : 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (photoError != null
                                    ? DeliveryAppColors.error
                                    : (hasPhoto
                                        ? DeliveryAppColors.success
                                        : DeliveryAppColors.primary))
                                .withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DeliveryFastImage(
                        imageBytes: state.localAvatarBytes,
                        imageUrl: state.avatarUrl,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        isCircle: true,
                        placeholder: const Icon(Icons.person,
                            size: 55, color: DeliveryAppColors.textSecondary),
                        errorWidget: const Icon(Icons.person,
                            size: 55, color: DeliveryAppColors.textSecondary),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: photoError != null
                              ? DeliveryAppColors.error
                              : (hasPhoto ? DeliveryAppColors.success : DeliveryAppColors.primary),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasPhoto ? Icons.refresh : Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Live Driver Selfie *',
                      style: TextStyle(
                          color: DeliveryAppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  if (hasPhoto) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle,
                        size: 14, color: DeliveryAppColors.success),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showImageSourceDialog((bytes, fileName) {
                        context.read<DeliveryOnboardingVerificationBloc>().add(
                              DeliveryAvatarPicked(
                                  bytes: bytes, fileName: fileName),
                            );
                      }, title: 'Driver Live Selfie'),
                      child: const Text(
                        '(Tap to Change)',
                        style: TextStyle(
                          color: DeliveryAppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (photoError != null) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 14, color: DeliveryAppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      photoError,
                      style: const TextStyle(
                          color: DeliveryAppColors.error,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name (as per Driving License) *',
          hint: 'e.g. Rahul Kumar',
          icon: Icons.person_outline,
          errorText: nameError,
          onChanged: (val) {
            setState(() {});
            _syncStep1(context, state);
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _displayNameController,
          label: 'Display Name / Nickname',
          hint: 'e.g. Rahul K.',
          icon: Icons.badge_outlined,
          onChanged: (val) => _syncStep1(context, state),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _dobController,
                label: 'Date of Birth (DD/MM/YYYY) *',
                hint: '08/08/2006',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.datetime,
                onTap: () => _selectDateOfBirth(context, state),
                onIconTap: () => _selectDateOfBirth(context, state),
                errorText: dobError,
                onChanged: (val) {
                  setState(() {});
                  _syncStep1(context, state);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Blood Group *',
                value: state.bloodGroup,
                items: const [
                  'A+',
                  'A-',
                  'B+',
                  'B-',
                  'O+',
                  'O-',
                  'AB+',
                  'AB-'
                ],
                onChanged: (val) {
                  if (val != null) {
                    context
                        .read<DeliveryOnboardingVerificationBloc>()
                        .add(DeliveryPersonalDetailsChanged(
                          fullName: _fullNameController.text,
                          displayName: _displayNameController.text,
                          dob: _dobController.text,
                          gender: state.gender,
                          bloodGroup: val,
                          emergencyContactName: _emergencyNameController.text,
                          emergencyContactPhone: _emergencyPhoneController.text,
                          bio: _bioController.text,
                        ));
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Gender *',
          value: state.gender,
          items: const ['Male', 'Female', 'Other'],
          onChanged: (val) {
            if (val != null) {
              context
                  .read<DeliveryOnboardingVerificationBloc>()
                  .add(DeliveryPersonalDetailsChanged(
                    fullName: _fullNameController.text,
                    displayName: _displayNameController.text,
                    dob: _dobController.text,
                    gender: val,
                    bloodGroup: state.bloodGroup,
                    emergencyContactName: _emergencyNameController.text,
                    emergencyContactPhone: _emergencyPhoneController.text,
                    bio: _bioController.text,
                  ));
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyNameController,
          label: 'Emergency Contact Person Name *',
          hint: 'e.g. Suresh Kumar (Brother)',
          icon: Icons.contact_phone_outlined,
          errorText: emerNameError,
          onChanged: (val) {
            setState(() {});
            _syncStep1(context, state);
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyPhoneController,
          label: 'Emergency Contact Phone Number *',
          hint: 'e.g. 9876543210',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          errorText: emerPhoneError,
          onChanged: (val) {
            setState(() {});
            _syncStep1(context, state);
          },
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth(
      BuildContext context, DeliveryOnboardingVerificationState state) async {
    final now = DateTime.now();
    DateTime initialDate = DateTime(2006, 8, 8);

    if (_dobController.text.trim().isNotEmpty) {
      final parts = _dobController.text.trim().split(RegExp(r'[-/.]'));
      if (parts.length == 3) {
        if (parts[0].length == 4) {
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2]);
          if (y != null && m != null && d != null) {
            initialDate = DateTime(y, m, d);
          }
        } else {
          final d = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final y = int.tryParse(parts[2]);
          if (y != null && m != null && d != null) {
            initialDate = DateTime(y, m, d);
          }
        }
      }
    }

    final firstDate = DateTime(1940, 1, 1);
    final lastDate = DateTime(now.year, now.month, now.day);
    final safeInitial = initialDate.isBefore(firstDate)
        ? firstDate
        : (initialDate.isAfter(lastDate) ? lastDate : initialDate);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      builder: (pickerContext, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: DeliveryAppColors.surface,
            colorScheme: const ColorScheme.dark(
              primary: DeliveryAppColors.primary,
              onPrimary: Colors.white,
              surface: DeliveryAppColors.surface,
              onSurface: Colors.white,
              onSurfaceVariant: Colors.white,
              surfaceContainerHighest: DeliveryAppColors.surfaceLight,
            ),
            dialogBackgroundColor: DeliveryAppColors.surface,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: DeliveryAppColors.primary,
              selectionColor: DeliveryAppColors.primary.withOpacity(0.4),
              selectionHandleColor: DeliveryAppColors.primary,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: DeliveryAppColors.surfaceLight,
              labelStyle: const TextStyle(
                color: DeliveryAppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelStyle: const TextStyle(
                color: DeliveryAppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DeliveryAppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: DeliveryAppColors.primary,
                  width: 2,
                ),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
              bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
              titleLarge: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              headlineLarge: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              headlineMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: DeliveryAppColors.surface,
              headerBackgroundColor: DeliveryAppColors.surface,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              weekdayStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              dayStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              yearStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: DeliveryAppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: DeliveryAppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      final formattedDob = '$day/$month/$year';

      setState(() {
        _dobController.text = formattedDob;
      });
      _syncStep1(context, state);
    }
  }

  void _syncStep1(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    context.read<DeliveryOnboardingVerificationBloc>().add(
          DeliveryPersonalDetailsChanged(
            fullName: _fullNameController.text,
            displayName: _displayNameController.text,
            dob: _dobController.text,
            gender: state.gender,
            bloodGroup: state.bloodGroup,
            emergencyContactName: _emergencyNameController.text,
            emergencyContactPhone: _emergencyPhoneController.text,
            bio: _bioController.text,
          ),
        );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 2: Contact & Phone/OTP Verification
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep2Contact(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final hasAttempted = _attemptedSteps.contains(DeliveryVerificationStep.contactVerification);
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final phoneError = hasAttempted && cleanPhone.length < 10
        ? 'Primary 10-digit mobile number is mandatory'
        : (!state.isPhoneVerified && hasAttempted
            ? 'Mobile number OTP verification is mandatory *'
            : null);
    final emailError = hasAttempted && (!_emailController.text.contains('@') || !_emailController.text.contains('.'))
        ? 'Valid email address is mandatory (e.g. rider@example.com)'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Contact & Phone OTP Verification',
          'Verify your primary phone number via 6-digit SMS OTP code and provide an official email address.',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: 'Primary Mobile Number *',
          hint: '9876543210',
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          enabled: !state.isPhoneVerified,
          errorText: phoneError,
          suffix: state.isPhoneVerified
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: DeliveryAppColors.success, size: 18),
                      SizedBox(width: 4),
                      Text('Verified',
                          style: TextStyle(
                              color: DeliveryAppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                )
              : TextButton(
                  onPressed: state.isOtpResendAvailable ||
                          state.status == DeliveryVerificationStatus.initial
                      ? () => context
                          .read<DeliveryOnboardingVerificationBloc>()
                          .add(const DeliverySendPhoneOtpRequested())
                      : null,
                  child: Text(
                    state.status == DeliveryVerificationStatus.otpSent
                        ? 'Resend in ${state.otpCountdown}s'
                        : 'Send OTP',
                    style: TextStyle(
                      color: state.isOtpResendAvailable ||
                              state.status == DeliveryVerificationStatus.initial
                          ? DeliveryAppColors.primary
                          : DeliveryAppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          onChanged: (val) {
            setState(() {});
            context.read<DeliveryOnboardingVerificationBloc>().add(
                  DeliveryContactChanged(
                      phone: val, email: _emailController.text),
                );
          },
        ),
        if (!state.isPhoneVerified &&
            (state.status == DeliveryVerificationStatus.otpSent ||
                state.status == DeliveryVerificationStatus.failure ||
                hasAttempted)) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _otpController,
            label: 'Enter 6-digit SMS Code *',
            hint: '123456',
            icon: Icons.lock_clock_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
            errorText: hasAttempted && !state.isPhoneVerified
                ? 'Please enter and verify 6-digit SMS OTP code'
                : null,
            suffix: TextButton(
              onPressed: () {
                context.read<DeliveryOnboardingVerificationBloc>().add(
                      DeliveryVerifyPhoneOtpRequested(_otpController.text),
                    );
              },
              child: const Text('Verify Code',
                  style: TextStyle(
                      color: DeliveryAppColors.success,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email Address *',
          hint: 'rider@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: emailError,
          onChanged: (val) {
            setState(() {});
            context.read<DeliveryOnboardingVerificationBloc>().add(
                  DeliveryContactChanged(
                      phone: _phoneController.text, email: val),
                );
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 3: Vehicle & Driving License
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep3Vehicle(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final hasAttempted = _attemptedSteps.contains(DeliveryVerificationStep.vehicleAndLicense);
    final vehicleOptions = [
      {'type': 'Motorcycle', 'icon': Icons.two_wheeler, 'label': 'Motorcycle'},
      {'type': 'Scooter', 'icon': Icons.moped, 'label': 'Scooter'},
      {'type': 'Electric Vehicle', 'icon': Icons.electric_bike, 'label': 'EV Bike'},
      {'type': 'Bicycle', 'icon': Icons.pedal_bike, 'label': 'Bicycle'},
    ];

    final isMotorVehicle = state.vehicleType != 'Bicycle';
    final vehNumError = hasAttempted && isMotorVehicle && _vehicleNumberController.text.trim().isEmpty
        ? 'Vehicle registration plate number is mandatory'
        : null;
    final vehModelError = hasAttempted && isMotorVehicle && _vehicleModelController.text.trim().isEmpty
        ? 'Vehicle make and model is mandatory'
        : null;
    final dlNumError = hasAttempted && isMotorVehicle && _dlNumberController.text.trim().length < 6
        ? 'Valid Driving License number is mandatory'
        : null;
    final dlExpiryError = hasAttempted && isMotorVehicle && _dlExpiryController.text.trim().isEmpty
        ? 'Driving License expiry date is mandatory (DD/MM/YYYY)'
        : null;

    final dlFrontMissing = hasAttempted && isMotorVehicle &&
        (state.dlFrontBytes == null && (state.dlFrontUrl == null || state.dlFrontUrl!.isEmpty));
    final dlBackMissing = hasAttempted && isMotorVehicle &&
        (state.dlBackBytes == null && (state.dlBackUrl == null || state.dlBackUrl!.isEmpty));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Vehicle & Driving License Details',
          'Select your delivery vehicle type and upload your Driving License and Vehicle RC documents.',
        ),
        const SizedBox(height: 20),
        const Text('Select Delivery Vehicle *',
            style: TextStyle(
                color: DeliveryAppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: vehicleOptions.map((opt) {
            final isSelected = state.vehicleType == opt['type'];
            return InkWell(
              onTap: () {
                context
                    .read<DeliveryOnboardingVerificationBloc>()
                    .add(DeliveryVehicleDetailsChanged(
                      vehicleType: opt['type'] as String,
                      vehicleNumber: _vehicleNumberController.text,
                      vehicleModel: _vehicleModelController.text,
                      drivingLicenseNumber: _dlNumberController.text,
                      dlExpiryDate: _dlExpiryController.text,
                    ));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DeliveryAppColors.primary.withOpacity(0.15)
                      : DeliveryAppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? DeliveryAppColors.primary
                        : DeliveryAppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(opt['icon'] as IconData,
                        size: 20,
                        color: isSelected
                            ? DeliveryAppColors.primary
                            : DeliveryAppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      opt['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? DeliveryAppColors.primary
                            : DeliveryAppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (state.vehicleType != 'Bicycle') ...[
          const SizedBox(height: 20),
          _buildTextField(
            controller: _vehicleNumberController,
            label: 'Vehicle Registration Plate Number *',
            hint: 'e.g. TN-07-AB-1234',
            icon: Icons.format_list_numbered,
            errorText: vehNumError,
            onChanged: (val) {
              setState(() {});
              _syncStep3(context, state);
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _vehicleModelController,
            label: 'Vehicle Make & Model *',
            hint: 'e.g. Honda Activa 6G / Hero Splendor',
            icon: Icons.directions_bike,
            errorText: vehModelError,
            onChanged: (val) {
              setState(() {});
              _syncStep3(context, state);
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _dlNumberController,
            label: 'Driving License Number *',
            hint: 'e.g. TN0720180012345',
            icon: Icons.badge_outlined,
            errorText: dlNumError,
            onChanged: (val) {
              setState(() {});
              _syncStep3(context, state);
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _dlExpiryController,
            label: 'DL Expiry Date (DD/MM/YYYY) *',
            hint: '31/12/2030',
            icon: Icons.event,
            keyboardType: TextInputType.datetime,
            onTap: () => _selectDlExpiryDate(context, state),
            onIconTap: () => _selectDlExpiryDate(context, state),
            errorText: dlExpiryError,
            onChanged: (val) {
              setState(() {});
              _syncStep3(context, state);
            },
          ),
          const SizedBox(height: 20),
          const Text('Driving License Document Photos *',
              style: TextStyle(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDocumentUploadTile(
                  title: 'DL Front Side *',
                  bytes: state.dlFrontBytes,
                  url: state.dlFrontUrl,
                  errorText: dlFrontMissing ? 'DL Front photo mandatory' : null,
                  onTap: () => _showImageSourceDialog((bytes, fileName) {
                    context.read<DeliveryOnboardingVerificationBloc>().add(
                          DeliveryDlDocumentPicked(
                            isFront: true,
                            bytes: bytes,
                            fileName: fileName,
                          ),
                        );
                  }, title: 'Driving License Front Side'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDocumentUploadTile(
                  title: 'DL Back Side *',
                  bytes: state.dlBackBytes,
                  url: state.dlBackUrl,
                  errorText: dlBackMissing ? 'DL Back photo mandatory' : null,
                  onTap: () => _showImageSourceDialog((bytes, fileName) {
                    context.read<DeliveryOnboardingVerificationBloc>().add(
                          DeliveryDlDocumentPicked(
                            isFront: false,
                            bytes: bytes,
                            fileName: fileName,
                          ),
                        );
                  }, title: 'Driving License Back Side'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDocumentUploadTile(
            title: 'Vehicle RC Book Copy (Optional)',
            bytes: state.rcBookBytes,
            url: state.rcBookUrl,
            onTap: () => _showImageSourceDialog((bytes, fileName) {
              context.read<DeliveryOnboardingVerificationBloc>().add(
                    DeliveryRcDocumentPicked(bytes: bytes, fileName: fileName),
                  );
            }, title: 'Vehicle RC Book Copy'),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDlExpiryDate(
      BuildContext context, DeliveryOnboardingVerificationState state) async {
    final now = DateTime.now();
    DateTime initialDate = DateTime(now.year + 5, now.month, now.day);

    if (_dlExpiryController.text.trim().isNotEmpty) {
      final parts = _dlExpiryController.text.trim().split(RegExp(r'[-/.]'));
      if (parts.length == 3) {
        if (parts[0].length == 4) {
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2]);
          if (y != null && m != null && d != null) {
            initialDate = DateTime(y, m, d);
          }
        } else {
          final d = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final y = int.tryParse(parts[2]);
          if (y != null && m != null && d != null) {
            initialDate = DateTime(y, m, d);
          }
        }
      }
    }

    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 30, 12, 31);
    final safeInitial = initialDate.isBefore(firstDate)
        ? firstDate
        : (initialDate.isAfter(lastDate) ? lastDate : initialDate);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select DL Expiry Date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      builder: (pickerContext, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: DeliveryAppColors.surface,
            colorScheme: const ColorScheme.dark(
              primary: DeliveryAppColors.primary,
              onPrimary: Colors.white,
              surface: DeliveryAppColors.surface,
              onSurface: Colors.white,
              onSurfaceVariant: Colors.white,
              surfaceContainerHighest: DeliveryAppColors.surfaceLight,
            ),
            dialogBackgroundColor: DeliveryAppColors.surface,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: DeliveryAppColors.primary,
              selectionColor: DeliveryAppColors.primary.withOpacity(0.4),
              selectionHandleColor: DeliveryAppColors.primary,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: DeliveryAppColors.surfaceLight,
              labelStyle: const TextStyle(
                color: DeliveryAppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelStyle: const TextStyle(
                color: DeliveryAppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DeliveryAppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: DeliveryAppColors.primary,
                  width: 2,
                ),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
              bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
              titleLarge: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              headlineLarge: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              headlineMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: DeliveryAppColors.surface,
              headerBackgroundColor: DeliveryAppColors.surface,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              weekdayStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              dayStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              yearStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: DeliveryAppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: DeliveryAppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      final formattedExpiry = '$day/$month/$year';

      setState(() {
        _dlExpiryController.text = formattedExpiry;
      });
      _syncStep3(context, state);
    }
  }

  void _syncStep3(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    context.read<DeliveryOnboardingVerificationBloc>().add(
          DeliveryVehicleDetailsChanged(
            vehicleType: state.vehicleType,
            vehicleNumber: _vehicleNumberController.text,
            vehicleModel: _vehicleModelController.text,
            drivingLicenseNumber: _dlNumberController.text,
            dlExpiryDate: _dlExpiryController.text,
          ),
        );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 4: Identity & KYC Documents
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep4Kyc(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final hasAttempted = _attemptedSteps.contains(DeliveryVerificationStep.kycDocuments);
    final cleanAadhaar = _aadhaarController.text.replaceAll(RegExp(r'\D'), '');
    final cleanPan = _panController.text.trim().toUpperCase();

    final hasAadhaar = cleanAadhaar.length == 12;
    final hasPan = cleanPan.length == 10;
    final idNumberMissing = hasAttempted && !hasAadhaar && !hasPan;

    final aadhaarError = idNumberMissing
        ? 'Please enter 12-digit Aadhaar Number or 10-character PAN Card'
        : null;
    final panError = hasAttempted && cleanPan.isNotEmpty && !hasPan
        ? 'PAN card number must be exactly 10 alphanumeric characters'
        : null;

    final hasAadhaarImg = (state.aadhaarFrontBytes != null ||
            (state.aadhaarFrontUrl != null && state.aadhaarFrontUrl!.isNotEmpty)) &&
        (state.aadhaarBackBytes != null ||
            (state.aadhaarBackUrl != null && state.aadhaarBackUrl!.isNotEmpty));
    final hasPanImg = state.panCardBytes != null ||
        (state.panCardUrl != null && state.panCardUrl!.isNotEmpty);

    final kycImgMissing = hasAttempted && !hasAadhaarImg && !hasPanImg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Identity & Government KYC Verification',
          'Provide your Aadhaar or PAN card details and upload clear document scans for background verification.',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _aadhaarController,
          label: 'Aadhaar Card / National ID (12 Digits) *',
          hint: '1234 5678 9012',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          maxLength: 12,
          errorText: aadhaarError,
          onChanged: (val) {
            setState(() {});
            _syncStep4(context);
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDocumentUploadTile(
                title: 'Aadhaar Front',
                bytes: state.aadhaarFrontBytes,
                url: state.aadhaarFrontUrl,
                errorText: kycImgMissing ? 'Front scan required' : null,
                onTap: () => _showImageSourceDialog((bytes, fileName) {
                  context.read<DeliveryOnboardingVerificationBloc>().add(
                        DeliveryKycDocumentPicked(
                          docType: 'aadhaar',
                          isFront: true,
                          bytes: bytes,
                          fileName: fileName,
                        ),
                      );
                }, title: 'Aadhaar Front Side'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDocumentUploadTile(
                title: 'Aadhaar Back',
                bytes: state.aadhaarBackBytes,
                url: state.aadhaarBackUrl,
                errorText: kycImgMissing ? 'Back scan required' : null,
                onTap: () => _showImageSourceDialog((bytes, fileName) {
                  context.read<DeliveryOnboardingVerificationBloc>().add(
                        DeliveryKycDocumentPicked(
                          docType: 'aadhaar',
                          isFront: false,
                          bytes: bytes,
                          fileName: fileName,
                        ),
                      );
                }, title: 'Aadhaar Back Side'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _panController,
          label: 'PAN Card Number (10 Characters) *',
          hint: 'ABCDE1234F',
          icon: Icons.account_balance_wallet_outlined,
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          errorText: panError,
          onChanged: (val) {
            setState(() {});
            _syncStep4(context);
          },
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadTile(
          title: 'PAN Card Photo',
          bytes: state.panCardBytes,
          url: state.panCardUrl,
          onTap: () => _showImageSourceDialog((bytes, fileName) {
            context.read<DeliveryOnboardingVerificationBloc>().add(
                  DeliveryKycDocumentPicked(
                    docType: 'pan',
                    isFront: true,
                    bytes: bytes,
                    fileName: fileName,
                  ),
                );
          }, title: 'PAN Card Document Photo'),
        ),
      ],
    );
  }

  void _syncStep4(BuildContext context) {
    context.read<DeliveryOnboardingVerificationBloc>().add(
          DeliveryKycDetailsChanged(
            aadhaarNumber: _aadhaarController.text,
            panNumber: _panController.text,
          ),
        );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 5: Bank Details & Instant Payouts
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep5Bank(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final hasAttempted = _attemptedSteps.contains(DeliveryVerificationStep.bankAndPayouts);
    final holderError = hasAttempted && _accountHolderController.text.trim().isEmpty
        ? 'Account holder name is mandatory'
        : null;
    final accNumError = hasAttempted && _bankAccountController.text.trim().length < 8
        ? 'Valid bank account number is mandatory'
        : null;
    final confirmAccError = hasAttempted && _confirmAccountController.text.trim() != _bankAccountController.text.trim()
        ? 'Bank account numbers do not match'
        : null;
    final ifscError = hasAttempted && _ifscController.text.trim().length != 11
        ? 'Valid 11-character IFSC code is mandatory (e.g. SBIN0001234)'
        : null;
    final upiError = hasAttempted && (_upiIdController.text.trim().isEmpty || !_upiIdController.text.contains('@'))
        ? 'Valid UPI ID is mandatory for instant payouts (e.g. rahul@okhdfcbank)'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Bank Account & Instant Payout Settings',
          'Enter your bank details for direct trip fare settlements and instant daily UPI payouts.',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _accountHolderController,
          label: 'Account Holder Name *',
          hint: 'e.g. Rahul Kumar',
          icon: Icons.person_outline,
          errorText: holderError,
          onChanged: (val) {
            setState(() {});
            _syncStep5(context, state);
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _bankAccountController,
          label: 'Bank Account Number *',
          hint: 'e.g. 12345678901234',
          icon: Icons.account_balance,
          keyboardType: TextInputType.number,
          errorText: accNumError,
          onChanged: (val) {
            setState(() {});
            _syncStep5(context, state);
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmAccountController,
          label: 'Confirm Bank Account Number *',
          hint: 'Re-enter account number',
          icon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          errorText: confirmAccError,
          onChanged: (val) {
            setState(() {});
            _syncStep5(context, state);
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _ifscController,
          label: 'Bank IFSC Code *',
          hint: 'e.g. SBIN0001234',
          icon: Icons.domain,
          textCapitalization: TextCapitalization.characters,
          maxLength: 11,
          errorText: ifscError,
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isValidatingIfsc)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(DeliveryAppColors.primary),
                    ),
                  ),
                ),
              Tooltip(
                message: 'Search Bank / Branch IFSC',
                child: IconButton(
                  key: const Key('search_ifsc_button'),
                  icon: const Icon(
                    Icons.travel_explore_rounded,
                    color: DeliveryAppColors.primary,
                    size: 22,
                  ),
                  onPressed: () => _openIfscSearchDialog(state),
                ),
              ),
            ],
          ),
          onChanged: (val) => _onIfscFieldChanged(val, state),
        ),
        if (_verifiedBankInfo != null)
          _buildVerifiedBankCard(_verifiedBankInfo!, state)
        else ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: InkWell(
              key: const Key('find_ifsc_shortcut_link'),
              onTap: () => _openIfscSearchDialog(state),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 14,
                      color: DeliveryAppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Don\'t know your IFSC code? Tap here to search bank & branch',
                      style: TextStyle(
                        color: DeliveryAppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildTextField(
          controller: _upiIdController,
          label: 'UPI ID for Instant Daily Payouts *',
          hint: 'e.g. rahul@okaxis / 9876543210@paytm',
          icon: Icons.payment,
          errorText: upiError,
          onChanged: (val) {
            setState(() {});
            _syncStep5(context, state);
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Payout Settlement Frequency *',
          value: state.payoutFrequency,
          items: const ['Daily', 'Weekly'],
          onChanged: (val) {
            if (val != null) {
              context
                  .read<DeliveryOnboardingVerificationBloc>()
                  .add(DeliveryBankDetailsChanged(
                    bankAccountNumber: _bankAccountController.text,
                    confirmAccountNumber: _confirmAccountController.text,
                    ifscCode: _ifscController.text,
                    bankName: _bankNameController.text,
                    accountHolderName: _accountHolderController.text,
                    upiId: _upiIdController.text,
                    payoutFrequency: val,
                  ));
            }
          },
        ),
      ],
    );
  }

  Future<void> _openIfscSearchDialog(
      DeliveryOnboardingVerificationState state) async {
    final selected = await DeliveryBankIfscSearchDialog.show(
      context: context,
      initialQuery: _ifscController.text.trim().isNotEmpty
          ? _ifscController.text.trim()
          : null,
    );

    if (selected != null && mounted) {
      setState(() {
        _ifscController.text = selected.ifsc;
        _bankNameController.text = selected.bankName;
        _verifiedBankInfo = selected;
        _isValidatingIfsc = false;
      });
      _syncStep5(context, state);
    }
  }

  void _onIfscFieldChanged(
      String val, DeliveryOnboardingVerificationState state) {
    final cleaned = val.trim().toUpperCase();
    _ifscDebounceTimer?.cancel();

    if (cleaned.length == 11 && BankIfscService.isValidIfscFormat(cleaned)) {
      setState(() {
        _isValidatingIfsc = true;
      });
      _ifscDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
        final info = await BankIfscService.instance.lookupIfsc(cleaned);
        if (mounted && _ifscController.text.trim().toUpperCase() == cleaned) {
          setState(() {
            _isValidatingIfsc = false;
            _verifiedBankInfo = info;
            if (info != null && info.bankName.isNotEmpty) {
              _bankNameController.text = info.bankName;
            }
          });
          _syncStep5(context, state);
        }
      });
    } else {
      if (_verifiedBankInfo != null && _verifiedBankInfo!.ifsc != cleaned) {
        setState(() {
          _verifiedBankInfo = null;
          _isValidatingIfsc = false;
        });
      }
    }

    setState(() {});
    _syncStep5(context, state);
  }

  Widget _buildVerifiedBankCard(
      BankBranchInfo info, DeliveryOnboardingVerificationState state) {
    return Container(
      key: const Key('verified_bank_card'),
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DeliveryAppColors.primary.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: DeliveryAppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.bankName,
                      style: const TextStyle(
                        color: DeliveryAppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.branch} Branch • ${info.city}, ${info.state}',
                      style: const TextStyle(
                        color: DeliveryAppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.successBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DeliveryAppColors.successBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: DeliveryAppColors.success, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: DeliveryAppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (info.address.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              info.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: DeliveryAppColors.textSecondary.withOpacity(0.65),
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  if (info.upi) _buildSettlementChip('UPI'),
                  if (info.imps) _buildSettlementChip('IMPS'),
                  if (info.neft) _buildSettlementChip('NEFT'),
                ],
              ),
              InkWell(
                onTap: () => _openIfscSearchDialog(state),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    'Change Bank / Branch',
                    style: TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: DeliveryAppColors.primaryLight,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _syncStep5(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    context.read<DeliveryOnboardingVerificationBloc>().add(
          DeliveryBankDetailsChanged(
            bankAccountNumber: _bankAccountController.text,
            confirmAccountNumber: _confirmAccountController.text,
            ifscCode: _ifscController.text,
            bankName: _bankNameController.text,
            accountHolderName: _accountHolderController.text,
            upiId: _upiIdController.text,
            payoutFrequency: state.payoutFrequency,
          ),
        );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 6: Operating Zone & Work Preferences (GPS Address Search)
  // ───────────────────────────────────────────────────────────────────────────
  void _openCityZoneSearch(
      BuildContext context, DeliveryOnboardingVerificationState state,
      {String? initialZone}) {
    DeliveryCityZoneSearchDialog.show(
      context: context,
      initialCity:
          _cityController.text.isNotEmpty ? _cityController.text : 'Chennai',
      initialZone: initialZone ??
          (_zoneController.text.isNotEmpty ? _zoneController.text : null),
      onSelectionSelected: (selection) {
        setState(() {
          _cityController.text = selection.city;
          _zoneController.text = selection.operatingZone;
        });
        context.read<DeliveryOnboardingVerificationBloc>().add(
              DeliveryZonePreferencesChanged(
                city: selection.city,
                operatingZone: selection.operatingZone,
                preferredShift: state.preferredShift,
                workType: state.workType,
                deliveryRadiusKm: state.deliveryRadiusKm,
                formattedAddress: _addressController.text.isNotEmpty
                    ? _addressController.text
                    : (selection.hubDescription ?? state.formattedAddress),
                houseFlatNo: _flatNoController.text,
                landmark: _landmarkController.text,
                latitude: selection.latitude ?? state.latitude,
                longitude: selection.longitude ?? state.longitude,
              ),
            );
      },
    );
  }

  Widget _buildStep6Zone(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final hasAttempted = _attemptedSteps.contains(DeliveryVerificationStep.zoneAndPreferences);
    final cityError = hasAttempted && _cityController.text.trim().isEmpty
        ? 'Delivery city is mandatory'
        : null;
    final zoneError = hasAttempted && _zoneController.text.trim().isEmpty
        ? 'Operating zone / hub is mandatory'
        : null;
    final addressError = hasAttempted && _addressController.text.trim().isEmpty
        ? 'Base address is mandatory. Please tap "Locate on Map"'
        : null;
    final flatError = hasAttempted && _flatNoController.text.trim().isEmpty
        ? 'House / Door / Flat number is mandatory'
        : null;

    final availableCities = DeliveryCityZoneService.instance.getCityNames();
    final currentCity = _cityController.text.trim().isNotEmpty
        ? _cityController.text.trim()
        : 'Chennai';
    final availableZones =
        DeliveryCityZoneService.instance.getZoneNamesForCity(currentCity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Operating Zone & GPS Base Location',
          'Pinpoint your home address via GPS / Google Places and select your preferred delivery hub & shift.',
        ),
        const SizedBox(height: 20),

        // 1. Delivery City Selector (Interactive Searchable Autocomplete Dropdown)
        Container(
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cityError != null
                  ? DeliveryAppColors.error
                  : DeliveryAppColors.border,
              width: cityError != null ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: RawAutocomplete<String>(
            textEditingController: _cityController,
            focusNode: _cityFocusNode,
            optionsBuilder: (TextEditingValue textEditingValue) async {
              final query = textEditingValue.text.trim();
              final allCatalogCities =
                  DeliveryCityZoneService.instance.getCityNames();
              if (query.isEmpty) {
                return allCatalogCities;
              }

              // 1. Instant local catalog matches
              final localMatches = allCatalogCities
                  .where((city) =>
                      city.toLowerCase().contains(query.toLowerCase()))
                  .toList();

              // 2. Fetch live worldwide Google Places / Maps city predictions
              try {
                final livePredictions =
                    await GooglePlacesService.instance.searchCities(query);
                final Set<String> combined = {...localMatches};
                for (final p in livePredictions) {
                  if (p.mainText.trim().isNotEmpty) {
                    combined.add(p.mainText.trim());
                  }
                }
                return combined.toList();
              } catch (_) {
                return localMatches;
              }
            },
            onSelected: (String selection) async {
              setState(() {
                _cityController.text = selection;
                final newZones = DeliveryCityZoneService.instance
                    .getZoneNamesForCity(selection);
                if (!newZones.contains(_zoneController.text) &&
                    newZones.isNotEmpty) {
                  _zoneController.text = newZones.first;
                }
              });
              _syncStep6(context, state);

              // Sync GPS coordinates if catalog or live Google Place
              final catalogCity =
                  DeliveryCityZoneService.instance.findCityByName(selection);
              if (catalogCity != null) {
                context.read<DeliveryOnboardingVerificationBloc>().add(
                      DeliveryZonePreferencesChanged(
                        city: selection,
                        operatingZone: _zoneController.text,
                        preferredShift: state.preferredShift,
                        workType: state.workType,
                        deliveryRadiusKm: state.deliveryRadiusKm,
                        formattedAddress: _addressController.text,
                        houseFlatNo: _flatNoController.text,
                        landmark: _landmarkController.text,
                        latitude: catalogCity.latitude,
                        longitude: catalogCity.longitude,
                      ),
                    );
              } else {
                try {
                  final details = await GooglePlacesService.instance
                      .getPlaceDetails(selection);
                  if (details != null &&
                      details.latitude != null &&
                      details.longitude != null) {
                    context.read<DeliveryOnboardingVerificationBloc>().add(
                          DeliveryZonePreferencesChanged(
                            city: selection,
                            operatingZone: _zoneController.text,
                            preferredShift: state.preferredShift,
                            workType: state.workType,
                            deliveryRadiusKm: state.deliveryRadiusKm,
                            formattedAddress: _addressController.text,
                            houseFlatNo: _flatNoController.text,
                            landmark: _landmarkController.text,
                            latitude: details.latitude,
                            longitude: details.longitude,
                          ),
                        );
                  }
                } catch (_) {}
              }
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(
                  color: DeliveryAppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Delivery City *',
                  labelStyle: TextStyle(
                    color: cityError != null
                        ? DeliveryAppColors.error
                        : DeliveryAppColors.textSecondary,
                    fontSize: 12,
                  ),
                  hintText: 'Type to search city (e.g. Chennai, Bengaluru...)',
                  hintStyle: TextStyle(
                    color: DeliveryAppColors.textSecondary.withOpacity(0.5),
                    fontSize: 13,
                  ),
                  icon: Icon(
                    Icons.location_city,
                    color: cityError != null
                        ? DeliveryAppColors.error
                        : DeliveryAppColors.primary,
                    size: 20,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear,
                              size: 16,
                              color: DeliveryAppColors.textSecondary),
                          onPressed: () {
                            controller.clear();
                            setState(() {});
                            _syncStep6(context, state);
                          },
                          splashRadius: 16,
                        ),
                      const Icon(Icons.arrow_drop_down,
                          color: DeliveryAppColors.primary),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    final newZones = DeliveryCityZoneService.instance
                        .getZoneNamesForCity(val);
                    if (!newZones.contains(_zoneController.text) &&
                        newZones.isNotEmpty) {
                      _zoneController.text = newZones.first;
                    }
                  });
                  _syncStep6(context, state);
                },
                onSubmitted: (val) {
                  onFieldSubmitted();
                  _syncStep6(context, state);
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  elevation: 8,
                  child: Container(
                    width: MediaQuery.of(context).size.width > 700
                        ? 560
                        : MediaQuery.of(context).size.width - 48,
                    constraints: const BoxConstraints(maxHeight: 250),
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: DeliveryAppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: DeliveryAppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: DeliveryAppColors.border,
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final city = options.elementAt(index);
                          final isSelected = _cityController.text
                                  .trim()
                                  .toLowerCase() ==
                              city.toLowerCase();
                          final cityInfo = DeliveryCityZoneService.instance
                              .findCityByName(city);
                          return InkWell(
                            onTap: () => onSelected(city),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              color: isSelected
                                  ? DeliveryAppColors.primary.withOpacity(0.12)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_city,
                                    size: 18,
                                    color: isSelected
                                        ? DeliveryAppColors.primary
                                        : DeliveryAppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          city,
                                          style: TextStyle(
                                            color: isSelected
                                                ? DeliveryAppColors.primary
                                                : DeliveryAppColors.textPrimary,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                        Text(
                                          cityInfo != null
                                              ? '${cityInfo.state} • ${cityInfo.hubs.length} Delivery Hubs'
                                              : 'Worldwide Delivery Location • Dynamic Hubs',
                                          style: const TextStyle(
                                            color: DeliveryAppColors
                                                .textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: DeliveryAppColors.primary,
                                        size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (cityError != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: DeliveryAppColors.error),
                const SizedBox(width: 4),
                Text(
                  cityError,
                  style: const TextStyle(
                    color: DeliveryAppColors.error,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        // 2. Operating Zone / Hub Selector (City-Specific Dropdown + Map Hub Launcher)
        Container(
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: zoneError != null
                  ? DeliveryAppColors.error
                  : DeliveryAppColors.border,
              width: zoneError != null ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Operating Zone / Hub ($currentCity) *',
                    style: const TextStyle(
                      color: DeliveryAppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  InkWell(
                    onTap: () => _openCityZoneSearch(context, state,
                        initialZone: _zoneController.text),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pin_drop_outlined,
                              size: 14, color: DeliveryAppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Hub Map',
                            style: TextStyle(
                              color: DeliveryAppColors.primary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.map,
                      color: DeliveryAppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: availableZones.contains(_zoneController.text)
                            ? _zoneController.text
                            : (availableZones.isNotEmpty
                                ? availableZones.first
                                : null),
                        isExpanded: true,
                        dropdownColor: DeliveryAppColors.surface,
                        style: const TextStyle(
                          color: DeliveryAppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: DeliveryAppColors.primary),
                        items: availableZones
                            .map((z) =>
                                DropdownMenuItem(value: z, child: Text(z)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _zoneController.text = val;
                            });
                            _syncStep6(context, state);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (zoneError != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: DeliveryAppColors.error),
                const SizedBox(width: 4),
                Text(
                  zoneError,
                  style: const TextStyle(
                    color: DeliveryAppColors.error,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Preferred Shift *',
          value: state.preferredShift,
          items: const ['Morning', 'Evening', 'Night', 'Flexible'],
          onChanged: (val) {
            if (val != null) {
              context
                  .read<DeliveryOnboardingVerificationBloc>()
                  .add(DeliveryZonePreferencesChanged(
                    city: _cityController.text,
                    operatingZone: _zoneController.text,
                    preferredShift: val,
                    workType: state.workType,
                    deliveryRadiusKm: state.deliveryRadiusKm,
                    formattedAddress: _addressController.text,
                    houseFlatNo: _flatNoController.text,
                    landmark: _landmarkController.text,
                    latitude: state.latitude,
                    longitude: state.longitude,
                  ));
            }
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Work Engagement Type *',
          value: state.workType,
          items: const ['Full-Time', 'Part-Time', 'Weekend'],
          onChanged: (val) {
            if (val != null) {
              context
                  .read<DeliveryOnboardingVerificationBloc>()
                  .add(DeliveryZonePreferencesChanged(
                    city: _cityController.text,
                    operatingZone: _zoneController.text,
                    preferredShift: state.preferredShift,
                    workType: val,
                    deliveryRadiusKm: state.deliveryRadiusKm,
                    formattedAddress: _addressController.text,
                    houseFlatNo: _flatNoController.text,
                    landmark: _landmarkController.text,
                    latitude: state.latitude,
                    longitude: state.longitude,
                  ));
            }
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: addressError != null
                    ? DeliveryAppColors.error
                    : DeliveryAppColors.border,
                width: addressError != null ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GPS Base Address *',
                      style: TextStyle(
                          color: DeliveryAppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  TextButton.icon(
                    onPressed: () {
                      DeliveryGoogleAddressSearchDialog.show(
                        context: context,
                        addressType: 'Home',
                        currentAddress: _addressController.text,
                        onAddressSelected: (result) {
                          setState(() {
                            _addressController.text = result.address;
                          });
                          context
                              .read<DeliveryOnboardingVerificationBloc>()
                              .add(DeliveryZonePreferencesChanged(
                                city: _cityController.text,
                                operatingZone: _zoneController.text,
                                preferredShift: state.preferredShift,
                                workType: state.workType,
                                deliveryRadiusKm: state.deliveryRadiusKm,
                                formattedAddress: result.address,
                                houseFlatNo: _flatNoController.text,
                                landmark: _landmarkController.text,
                                latitude: result.latitude,
                                longitude: result.longitude,
                              ));
                        },
                      );
                    },
                    icon: const Icon(Icons.my_location,
                        size: 16, color: DeliveryAppColors.primary),
                    label: const Text('Locate on Map',
                        style: TextStyle(
                            color: DeliveryAppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _addressController,
                label: 'Formatted Address *',
                hint: 'Tap "Locate on Map" to autofill with GPS',
                icon: Icons.home_outlined,
                maxLines: 2,
                errorText: addressError,
                onChanged: (val) {
                  setState(() {});
                  _syncStep6(context, state);
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _flatNoController,
                      label: 'House / Door No *',
                      hint: 'Flat 4B',
                      icon: Icons.door_front_door_outlined,
                      errorText: flatError,
                      onChanged: (val) {
                        setState(() {});
                        _syncStep6(context, state);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _landmarkController,
                      label: 'Landmark',
                      hint: 'Near Bus Stop',
                      icon: Icons.place_outlined,
                      onChanged: (val) => _syncStep6(context, state),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _syncStep6(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    context.read<DeliveryOnboardingVerificationBloc>().add(
          DeliveryZonePreferencesChanged(
            city: _cityController.text,
            operatingZone: _zoneController.text,
            preferredShift: state.preferredShift,
            workType: state.workType,
            deliveryRadiusKm: state.deliveryRadiusKm,
            formattedAddress: _addressController.text,
            houseFlatNo: _flatNoController.text,
            landmark: _landmarkController.text,
            latitude: state.latitude,
            longitude: state.longitude,
          ),
        );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 7: Permissions & Hardware Setup
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep7Permissions(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final hasAttempted = _attemptedSteps.contains(DeliveryVerificationStep.hardwarePermissions);
    final locationError = hasAttempted && !state.locationPermissionGranted
        ? 'High-Accuracy GPS permission is mandatory for customer tracking'
        : null;
    final cameraError = hasAttempted && !state.cameraPermissionGranted
        ? 'Camera access permission is mandatory for delivery photo proof'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'App Permissions & Hardware Telemetry',
          'Enable critical device permissions to receive live trip dispatches, navigation audio, and doorstep photo verification.',
        ),
        const SizedBox(height: 20),
        _buildPermissionTile(
          icon: Icons.location_on,
          title: 'High-Accuracy GPS Location *',
          subtitle:
              'Used for real-time customer trip tracking and proximity order dispatch matching.',
          value: state.locationPermissionGranted,
          errorText: locationError,
          onChanged: (val) => _syncStep7(context, state, location: val),
        ),
        const SizedBox(height: 12),
        _buildPermissionTile(
          icon: Icons.notifications_active,
          title: 'Push Notifications & Ringtone',
          subtitle:
              'Receive immediate loud audible alerts when new high-earning orders are dispatched.',
          value: state.pushNotificationsGranted,
          onChanged: (val) => _syncStep7(context, state, notif: val),
        ),
        const SizedBox(height: 12),
        _buildPermissionTile(
          icon: Icons.camera_alt,
          title: 'Camera & Storage Access *',
          subtitle:
              'Required for contactless delivery photo proof and document upload scans.',
          value: state.cameraPermissionGranted,
          errorText: cameraError,
          onChanged: (val) => _syncStep7(context, state, camera: val),
        ),
        const SizedBox(height: 12),
        _buildPermissionTile(
          icon: Icons.battery_charging_full,
          title: 'Disable Battery Optimization',
          subtitle:
              'Keeps GPS active in background so you never miss an incoming trip while app is minimized.',
          value: state.batteryOptimizationDisabled,
          onChanged: (val) => _syncStep7(context, state, battery: val),
        ),
      ],
    );
  }

  void _syncStep7(
      BuildContext context, DeliveryOnboardingVerificationState state,
      {bool? location, bool? notif, bool? camera, bool? battery}) {
    context.read<DeliveryOnboardingVerificationBloc>().add(
          DeliveryPermissionsChanged(
            locationPermissionGranted:
                location ?? state.locationPermissionGranted,
            backgroundLocationGranted:
                location ?? state.backgroundLocationGranted,
            pushNotificationsGranted: notif ?? state.pushNotificationsGranted,
            cameraPermissionGranted: camera ?? state.cameraPermissionGranted,
            batteryOptimizationDisabled:
                battery ?? state.batteryOptimizationDisabled,
          ),
        );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 8: Safety Gear, Guidelines & Final Activation
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep8SafetyActivation(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final hasAttempted = _attemptedSteps.contains(DeliveryVerificationStep.safetyKitAndActivation);
    final bagError = hasAttempted && !state.hasDeliveryBag
        ? 'Insulated food delivery bag is required for food safety'
        : null;
    final helmetError = hasAttempted && !state.hasHelmet
        ? 'Certified safety helmet is mandatory for all delivery partners'
        : null;
    final conductError = hasAttempted && !state.acknowledgedCodeOfConduct
        ? 'You must accept the Partner Code of Conduct to activate account'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Safety Gear & Partner Activation',
          'Confirm your delivery safety kit and agree to the Partner Code of Conduct to activate your rider account.',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DeliveryAppColors.primary.withOpacity(0.2),
                DeliveryAppColors.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: DeliveryAppColors.primary.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: DeliveryAppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_giftcard,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('₹500 Welcome Bonus Unlocked!',
                        style: TextStyle(
                            color: DeliveryAppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      'Complete your first 5 trips within 7 days to claim your ₹${state.welcomeBonusAmount.toInt()} bonus into your wallet.',
                      style: const TextStyle(
                          color: DeliveryAppColors.textSecondary,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCheckboxTile(
          title: 'I have an Insulated Food Delivery Bag *',
          subtitle:
              'Ensures hot and fresh food delivery quality for all customer orders.',
          value: state.hasDeliveryBag,
          errorText: bagError,
          onChanged: (val) {
            context.read<DeliveryOnboardingVerificationBloc>().add(
                  DeliverySafetyAndKitChanged(
                    hasDeliveryBag: val ?? false,
                    hasHelmet: state.hasHelmet,
                    acknowledgedCodeOfConduct: state.acknowledgedCodeOfConduct,
                  ),
                );
          },
        ),
        const SizedBox(height: 12),
        _buildCheckboxTile(
          title: 'I have a Certified Safety Helmet *',
          subtitle:
              'Safety is our top priority. Helmet is mandatory for all two-wheeler riders.',
          value: state.hasHelmet,
          errorText: helmetError,
          onChanged: (val) {
            context.read<DeliveryOnboardingVerificationBloc>().add(
                  DeliverySafetyAndKitChanged(
                    hasDeliveryBag: state.hasDeliveryBag,
                    hasHelmet: val ?? false,
                    acknowledgedCodeOfConduct: state.acknowledgedCodeOfConduct,
                  ),
                );
          },
        ),
        const SizedBox(height: 12),
        _buildCheckboxTile(
          title: 'I accept the Partner Code of Conduct & Guidelines *',
          subtitle:
              'I agree to uphold polite customer communication, hygiene standards, and road safety rules.',
          value: state.acknowledgedCodeOfConduct,
          errorText: conductError,
          onChanged: (val) {
            context.read<DeliveryOnboardingVerificationBloc>().add(
                  DeliverySafetyAndKitChanged(
                    hasDeliveryBag: state.hasDeliveryBag,
                    hasHelmet: state.hasHelmet,
                    acknowledgedCodeOfConduct: val ?? false,
                  ),
                );
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UI Helpers & Reusable Widgets with Inline Error Alerts
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DeliveryAppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: DeliveryAppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    int? maxLength,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    VoidCallback? onIconTap,
    Widget? suffix,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    final effectiveIconTap = onIconTap ?? onTap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? DeliveryAppColors.error : DeliveryAppColors.border,
              width: hasError ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            enabled: enabled,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            style: const TextStyle(
                color: DeliveryAppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: label,
              labelStyle: TextStyle(
                  color: hasError
                      ? DeliveryAppColors.error
                      : DeliveryAppColors.textSecondary,
                  fontSize: 12),
              hintText: hint,
              hintStyle: TextStyle(
                  color: DeliveryAppColors.textSecondary.withOpacity(0.5),
                  fontSize: 13),
              icon: InkWell(
                onTap: enabled ? effectiveIconTap : null,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(icon,
                      color: hasError
                          ? DeliveryAppColors.error
                          : DeliveryAppColors.primary,
                      size: 20),
                ),
              ),
              suffixIcon: suffix,
              counterText: '',
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: DeliveryAppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: DeliveryAppColors.error,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DeliveryAppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: DeliveryAppColors.textSecondary, fontSize: 11)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              dropdownColor: DeliveryAppColors.surface,
              style: const TextStyle(
                  color: DeliveryAppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              icon: const Icon(Icons.arrow_drop_down,
                  color: DeliveryAppColors.primary),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadTile({
    required String title,
    required Uint8List? bytes,
    required String? url,
    required VoidCallback onTap,
    String? errorText,
  }) {
    final hasImage = bytes != null || (url != null && url.isNotEmpty);
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 125,
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? DeliveryAppColors.error
                  : (hasImage
                      ? DeliveryAppColors.success
                      : DeliveryAppColors.border),
              width: hasError || hasImage ? 1.8 : 1,
            ),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DeliveryFastImage(
                        imageBytes: bytes,
                        imageUrl: url,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.35),
                              Colors.transparent,
                              Colors.black.withOpacity(0.85),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Top Row: Uploaded Status Tag + Zoom Preview Button
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: DeliveryAppColors.success.withOpacity(0.6),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: DeliveryAppColors.success, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'Uploaded',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => DeliveryDocumentPreviewDialog.show(
                                context: context,
                                title: title,
                                documentUrl: url,
                                documentBytes: bytes,
                                onReupload: onTap,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 3),
                                    Text(
                                      'View',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bottom Row: Document Name + Dedicated Change Button
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: onTap,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: DeliveryAppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DeliveryAppColors.primary
                                          .withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.refresh,
                                        color: Colors.white, size: 12),
                                    SizedBox(width: 3),
                                    Text(
                                      'Change',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            color: hasError
                                ? DeliveryAppColors.error
                                : DeliveryAppColors.primary,
                            size: 28),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: TextStyle(
                              color: hasError
                                  ? DeliveryAppColors.error
                                  : DeliveryAppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        const Text('Tap to upload photo',
                            style: TextStyle(
                                color: DeliveryAppColors.textSecondary,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: DeliveryAppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: DeliveryAppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? DeliveryAppColors.error : DeliveryAppColors.border,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (hasError ? DeliveryAppColors.error : DeliveryAppColors.primary)
                      .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: hasError
                        ? DeliveryAppColors.error
                        : DeliveryAppColors.primary,
                    size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: DeliveryAppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: DeliveryAppColors.textSecondary,
                            fontSize: 11,
                            height: 1.3)),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeColor: DeliveryAppColors.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: DeliveryAppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: DeliveryAppColors.error,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? DeliveryAppColors.error
                  : (value
                      ? DeliveryAppColors.primary
                      : DeliveryAppColors.border),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: value,
                activeColor: DeliveryAppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: onChanged,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: DeliveryAppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: DeliveryAppColors.textSecondary,
                            fontSize: 11,
                            height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: DeliveryAppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: DeliveryAppColors.error,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Bottom Action Bar (Next / Previous / Submit)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBottomActionBar(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    final isLastStep =
        state.currentStep == DeliveryVerificationStep.safetyKitAndActivation;
    final isUploading =
        state.status == DeliveryVerificationStatus.uploadingFiles;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        border: const Border(
          top: BorderSide(color: DeliveryAppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.currentStep.index > 0) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: isUploading
                      ? null
                      : () {
                          final prevStep = DeliveryVerificationStep
                              .values[state.currentStep.index - 1];
                          context
                              .read<DeliveryOnboardingVerificationBloc>()
                              .add(DeliveryVerificationStepChanged(prevStep));
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DeliveryAppColors.textPrimary,
                    side: const BorderSide(color: DeliveryAppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isUploading ? null : () => _onNextOrSubmit(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeliveryAppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastStep
                                ? 'Submit Application'
                                : 'Next Step (${state.currentStep.index + 2}/8)',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isLastStep
                                ? Icons.verified_user
                                : Icons.arrow_forward,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: DeliveryAppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onNextOrSubmit(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    setState(() {
      _attemptedSteps.add(state.currentStep);
    });

    if (state.currentStep == DeliveryVerificationStep.personalDetails) {
      _syncStep1(context, state);
    } else if (state.currentStep == DeliveryVerificationStep.contactVerification) {
      context.read<DeliveryOnboardingVerificationBloc>().add(
            DeliveryContactChanged(
              phone: _phoneController.text,
              email: _emailController.text,
            ),
          );
    } else if (state.currentStep == DeliveryVerificationStep.vehicleAndLicense) {
      _syncStep3(context, state);
    } else if (state.currentStep == DeliveryVerificationStep.kycDocuments) {
      _syncStep4(context);
    } else if (state.currentStep == DeliveryVerificationStep.bankAndPayouts) {
      _syncStep5(context, state);
    } else if (state.currentStep == DeliveryVerificationStep.zoneAndPreferences) {
      _syncStep6(context, state);
    }

    final currentState = context.read<DeliveryOnboardingVerificationBloc>().state;
    final error = currentState.validateStep(currentState.currentStep);
    if (error != null) {
      _showValidationSnackBar(error);
      return;
    }

    if (currentState.currentStep ==
        DeliveryVerificationStep.safetyKitAndActivation) {
      context
          .read<DeliveryOnboardingVerificationBloc>()
          .add(const DeliverySubmitVerificationApplication());
    } else {
      final nextStep =
          DeliveryVerificationStep.values[currentState.currentStep.index + 1];
      context
          .read<DeliveryOnboardingVerificationBloc>()
          .add(DeliveryVerificationStepChanged(nextStep));
    }
  }

  void _showCompletionSuccessDialog(
      BuildContext context, DeliveryOnboardingVerificationState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: DeliveryAppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: DeliveryAppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Application Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DeliveryAppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                state.successMessage ??
                    'Your Delivery Partner verification application has been submitted successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: DeliveryAppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeliveryNavigationBarPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DeliveryAppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Go to Rider Dashboard',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
