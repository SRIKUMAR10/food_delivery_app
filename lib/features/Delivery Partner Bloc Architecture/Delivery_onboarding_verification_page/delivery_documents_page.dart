import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_design_system.dart';
import '../delivery_document_preview_dialog.dart';
import 'delivery_onboarding_verification_bloc.dart';
import 'delivery_onboarding_verification_event.dart';
import 'delivery_onboarding_verification_repository.dart';
import 'delivery_onboarding_verification_state.dart';
import 'delivery_onboarding_verification_ui.dart';

class DeliveryDocumentsStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'pageTitle': 'Documents & Verification',
      'pageSubtitle':
          'Manage your 8-step KYC documents, vehicle licenses, and profile verifications.',
      'completionRate': '{completed} of {total} Steps Completed',
      'allStepsVerified': 'All Documents Verified',
      'verificationPending': 'Verification Incomplete',
      'verified': 'Verified',
      'underReview': 'Under Review',
      'actionRequired': 'Action Required',
      'incomplete': 'Incomplete',
      'completeAll': 'Complete Verification',
      'editStep': 'Edit / Verify',
      'viewDoc': 'Preview',
      'step1Title': 'Personal Details & Live Photo',
      'step1Desc': 'Full Name, DOB, Blood Group, Emergency Contact & Selfie',
      'step2Title': 'Contact & Phone Verification',
      'step2Desc': 'Verified Mobile number with OTP and Registered Email',
      'step3Title': 'Vehicle & Driving License',
      'step3Desc': 'Vehicle Registration, Model, Driving License & RC copy',
      'step4Title': 'Government KYC Documents',
      'step4Desc': '12-digit Aadhaar Card (Front/Back) and PAN Card',
      'step5Title': 'Bank Account & Payouts',
      'step5Desc': 'Bank Account, IFSC Code, Account Holder Name & UPI ID',
      'step6Title': 'Operating Zone & Preferences',
      'step6Desc': 'City, Hub/Zone, Base GPS Address, Shift & Delivery Radius',
      'step7Title': 'Hardware & Device Permissions',
      'step7Desc': 'GPS Location, Background Tracking, Camera & Notifications',
      'step8Title': 'Safety Kit & Activation',
      'step8Desc': 'Delivery Bag, Helmet, Code of Conduct & Welcome Bonus',
      'securityTitle': 'Bank-Grade 256-bit Data Encryption',
      'securitySubtitle':
          'All uploaded documents and bank details are encrypted and securely verified compliant with KYC standards.',
      'noDocUploaded': 'No document uploaded',
      'tapToVerify': 'Tap to complete this step',
    },
    'ta': {
      'pageTitle': 'ஆவணங்கள் மற்றும் சரிபார்ப்பு',
      'pageSubtitle':
          'உங்கள் 8-படி KYC ஆவணங்கள், வாகன உரிமங்கள் மற்றும் சுயவிவர சரிபார்ப்புகளை நிர்வகிக்கவும்.',
      'completionRate': '{total}-ல் {completed} படிகள் நிறைவடைந்துள்ளன',
      'allStepsVerified': 'அனைத்து ஆவணங்களும் சரிபார்க்கப்பட்டன',
      'verificationPending': 'சரிபார்ப்பு நிலுவையில் உள்ளது',
      'verified': 'சரிபார்க்கப்பட்டது',
      'underReview': 'மதிப்பாய்வில் உள்ளது',
      'actionRequired': 'நடவடிக்கை தேவை',
      'incomplete': 'முழுமையடையாதது',
      'completeAll': 'முழு சரிபார்ப்பை முடிக்கவும்',
      'editStep': 'திருத்து / சரிபார்',
      'viewDoc': 'முன்னோட்டம்',
      'step1Title': 'தனிப்பட்ட விவரங்கள் & செல்ஃபி',
      'step1Desc': 'முழு பெயர், பிறந்த தேதி, ரத்த வகை, அவசர தொடர்பு & செல்ஃபி',
      'step2Title': 'தொடர்பு & தொலைபேசி சரிபார்ப்பு',
      'step2Desc': 'OTP உடன் சரிபார்க்கப்பட்ட எண் மற்றும் மின்னஞ்சல்',
      'step3Title': 'வாகனம் & ஓட்டுநர் உரிமம்',
      'step3Desc': 'வாகன பதிவு எண், மாடல், ஓட்டுநர் உரிமம் & ஆர்சி நகல்',
      'step4Title': 'அரசு KYC ஆவணங்கள்',
      'step4Desc': '12 இலக்க ஆதார் அட்டை (முன்/பின்) மற்றும் பான் அட்டை',
      'step5Title': 'வங்கி கணக்கு & பணம் செலுத்துதல்',
      'step5Desc': 'வங்கி கணக்கு எண், IFSC குறியீடு, பெயர் & UPI ஐடி',
      'step6Title': 'இயக்க மண்டலம் & விருப்பத்தேர்வுகள்',
      'step6Desc': 'நகரம், மண்டலம், அடிப்படை ஜிபிஎஸ் முகவரி & ஷிப்ட்',
      'step7Title': 'சாதன அனுமதிகள்',
      'step7Desc': 'ஜிபிஎஸ் இருப்பிடம், பின்னணி கண்காணிப்பு, கேமரா & அறிவிப்புகள்',
      'step8Title': 'பாதுகாப்பு கிட் & செயல்படுத்தல்',
      'step8Desc': 'டெலிவரி பை, ஹெல்மெட், நடத்தை விதிகள் & போனஸ்',
      'securityTitle': 'வங்கி தரத்திலான 256-பிட் பாதுகாப்பு',
      'securitySubtitle':
          'பதிவேற்றப்பட்ட அனைத்து ஆவணங்களும் KYC விதிகளின்படி பாதுகாப்பாக குறியாக்கம் செய்யப்படுகின்றன.',
      'noDocUploaded': 'ஆவணம் பதிவேற்றப்படவில்லை',
      'tapToVerify': 'இப்படியை முடிக்க தட்டவும்',
    },
  };

  static String of(String key, [String localeCode = 'en']) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key] ?? key;
  }
}

class DeliveryDocumentsPage extends StatelessWidget {
  final DeliveryOnboardingVerificationBloc? bloc;
  final DeliveryOnboardingVerificationRepository? repository;
  final String localeCode;

  const DeliveryDocumentsPage({
    super.key,
    this.bloc,
    this.repository,
    this.localeCode = 'en',
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryOnboardingVerificationBloc>.value(
        value: bloc!,
        child: DeliveryDocumentsView(localeCode: localeCode),
      );
    }

    try {
      final existingBloc = context.read<DeliveryOnboardingVerificationBloc?>();
      if (existingBloc != null) {
        return DeliveryDocumentsView(localeCode: localeCode);
      }
    } catch (_) {}

    return BlocProvider<DeliveryOnboardingVerificationBloc>(
      create: (context) => DeliveryOnboardingVerificationBloc(
        repository: repository ?? DeliveryOnboardingVerificationRepository(),
      )..add(const DeliveryVerificationAutoFetchRequested()),
      child: DeliveryDocumentsView(localeCode: localeCode),
    );
  }
}

class DeliveryDocumentsView extends StatelessWidget {
  final String localeCode;

  const DeliveryDocumentsView({
    super.key,
    this.localeCode = 'en',
  });

  void _openStep(BuildContext context, DeliveryVerificationStep step) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliveryOnboardingVerificationPage(
          initialStep: step,
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context
            .read<DeliveryOnboardingVerificationBloc>()
            .add(const DeliveryVerificationAutoFetchRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryOnboardingVerificationBloc,
        DeliveryOnboardingVerificationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B1219),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;
              final isTablet =
                  constraints.maxWidth >= 640 && constraints.maxWidth < 1024;
              final horizontalPadding = isDesktop ? 32.0 : 16.0;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(context),
                          const SizedBox(height: 20),
                          _buildProgressOverviewCard(context, state),
                          const SizedBox(height: 24),
                          _buildSectionTitle(context, state),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: _buildCardsGrid(
                      context,
                      state,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        32,
                      ),
                      child: _buildSecurityBanner(context),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: DeliveryAppColors.primaryDark.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: DeliveryAppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: const Icon(
            Icons.folder_shared_outlined,
            color: DeliveryAppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DeliveryDocumentsStrings.of('pageTitle', localeCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                DeliveryDocumentsStrings.of('pageSubtitle', localeCode),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressOverviewCard(
    BuildContext context,
    DeliveryOnboardingVerificationState state,
  ) {
    final completed = state.completedStepsCount;
    const total = 8;
    final progress = state.overallProgressPercentage;
    final isAllDone = completed == total;

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final isCompact = cardConstraints.maxWidth < 600;

        Widget progressDetails = Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5.5,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAllDone
                          ? DeliveryAppColors.primary
                          : const Color(0xFF38BDF8),
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isAllDone
                              ? DeliveryDocumentsStrings.of(
                                  'allStepsVerified',
                                  localeCode,
                                )
                              : DeliveryDocumentsStrings.of(
                                  'verificationPending',
                                  localeCode,
                                ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isAllDone
                              ? DeliveryAppColors.primaryDark
                                  .withValues(alpha: 0.25)
                              : const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAllDone
                              ? DeliveryDocumentsStrings.of(
                                  'verified',
                                  localeCode,
                                )
                              : DeliveryDocumentsStrings.of(
                                  'underReview',
                                  localeCode,
                                ),
                          style: TextStyle(
                            color: isAllDone
                                ? DeliveryAppColors.primary
                                : const Color(0xFFF59E0B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DeliveryDocumentsStrings.of('completionRate', localeCode)
                        .replaceAll('{completed}', '$completed')
                        .replaceAll('{total}', '$total'),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final actionBtn = ElevatedButton.icon(
          onPressed: () => _openStep(context, state.currentStep),
          icon: Icon(
            isAllDone ? Icons.check_circle : Icons.launch,
            size: 15,
          ),
          label: Text(
            DeliveryDocumentsStrings.of('completeAll', localeCode),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: DeliveryAppColors.primary,
            foregroundColor: const Color(0xFF041E11),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAllDone
                  ? [const Color(0xFF0F2E1E), const Color(0xFF091F14)]
                  : [const Color(0xFF101B2B), const Color(0xFF0B1420)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAllDone
                  ? DeliveryAppColors.primary.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: isAllDone
                    ? DeliveryAppColors.primaryDark.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              if (isCompact) ...[
                progressDetails,
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: actionBtn,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: progressDetails),
                    const SizedBox(width: 14),
                    actionBtn,
                  ],
                ),
              ],
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAllDone
                        ? DeliveryAppColors.primary
                        : const Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    DeliveryOnboardingVerificationState state,
  ) {
    return const Text(
      '8 Verification Steps & Documents',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildCardsGrid(
    BuildContext context,
    DeliveryOnboardingVerificationState state, {
    required bool isDesktop,
    required bool isTablet,
  }) {
    final int crossAxisCount = isDesktop ? 2 : (isTablet ? 2 : 1);

    final stepConfigs = [
      _StepCardConfig(
        step: DeliveryVerificationStep.personalDetails,
        stepNumber: 1,
        titleKey: 'step1Title',
        descKey: 'step1Desc',
        icon: Icons.person_pin_rounded,
        isValid: state.isStep1Valid,
        infoText: state.fullName.isNotEmpty
            ? '${state.fullName} • ${state.bloodGroup.isNotEmpty ? state.bloodGroup : "Blood Group: N/A"}${state.dob.isNotEmpty ? " • DOB: ${state.dob}" : ""}'
            : null,
        documents: [
          _DocPreview(
            label: 'Driver Selfie',
            bytes: state.localAvatarBytes,
            url: state.avatarUrl,
          ),
        ],
      ),
      _StepCardConfig(
        step: DeliveryVerificationStep.contactVerification,
        stepNumber: 2,
        titleKey: 'step2Title',
        descKey: 'step2Desc',
        icon: Icons.mark_email_read_rounded,
        isValid: state.isStep2Valid,
        infoText: state.phone.isNotEmpty
            ? '${state.phone} (${state.isPhoneVerified ? "OTP Verified" : "OTP Pending"})\n${state.email}'
            : null,
        documents: const [],
      ),
      _StepCardConfig(
        step: DeliveryVerificationStep.vehicleAndLicense,
        stepNumber: 3,
        titleKey: 'step3Title',
        descKey: 'step3Desc',
        icon: Icons.two_wheeler_rounded,
        isValid: state.isStep3Valid,
        infoText: state.vehicleNumber.isNotEmpty
            ? '${state.vehicleType} • ${state.vehicleNumber}\nDL: ${state.drivingLicenseNumber}${state.dlExpiryDate.isNotEmpty ? " (Exp: ${state.dlExpiryDate})" : ""}'
            : null,
        documents: [
          _DocPreview(
            label: 'DL Front',
            bytes: state.dlFrontBytes,
            url: state.dlFrontUrl,
          ),
          _DocPreview(
            label: 'DL Back',
            bytes: state.dlBackBytes,
            url: state.dlBackUrl,
          ),
          _DocPreview(
            label: 'RC Book',
            bytes: state.rcBookBytes,
            url: state.rcBookUrl,
          ),
        ],
      ),
      _StepCardConfig(
        step: DeliveryVerificationStep.kycDocuments,
        stepNumber: 4,
        titleKey: 'step4Title',
        descKey: 'step4Desc',
        icon: Icons.badge_rounded,
        isValid: state.isStep4Valid,
        infoText: state.aadhaarNumber.isNotEmpty || state.panNumber.isNotEmpty
            ? 'Aadhaar: ${state.aadhaarNumber.isNotEmpty ? state.aadhaarNumber : "Not provided"}\nPAN: ${state.panNumber.isNotEmpty ? state.panNumber : "Not provided"}'
            : null,
        documents: [
          _DocPreview(
            label: 'Aadhaar Front',
            bytes: state.aadhaarFrontBytes,
            url: state.aadhaarFrontUrl,
          ),
          _DocPreview(
            label: 'Aadhaar Back',
            bytes: state.aadhaarBackBytes,
            url: state.aadhaarBackUrl,
          ),
          _DocPreview(
            label: 'PAN Card',
            bytes: state.panCardBytes,
            url: state.panCardUrl,
          ),
        ],
      ),
      _StepCardConfig(
        step: DeliveryVerificationStep.bankAndPayouts,
        stepNumber: 5,
        titleKey: 'step5Title',
        descKey: 'step5Desc',
        icon: Icons.account_balance_rounded,
        isValid: state.isStep5Valid,
        infoText: state.bankAccountNumber.isNotEmpty
            ? 'A/C: ••••${state.bankAccountNumber.length > 4 ? state.bankAccountNumber.substring(state.bankAccountNumber.length - 4) : state.bankAccountNumber} • IFSC: ${state.ifscCode}\nUPI: ${state.upiId} (${state.payoutFrequency})'
            : null,
        documents: const [],
      ),
      _StepCardConfig(
        step: DeliveryVerificationStep.zoneAndPreferences,
        stepNumber: 6,
        titleKey: 'step6Title',
        descKey: 'step6Desc',
        icon: Icons.location_on_rounded,
        isValid: state.isStep6Valid,
        infoText: state.city.isNotEmpty
            ? 'City: ${state.city} • Zone: ${state.operatingZone}\nRadius: ${state.deliveryRadiusKm.toStringAsFixed(0)} km • ${state.preferredShift} (${state.workType})'
            : null,
        documents: const [],
      ),
      _StepCardConfig(
        step: DeliveryVerificationStep.hardwarePermissions,
        stepNumber: 7,
        titleKey: 'step7Title',
        descKey: 'step7Desc',
        icon: Icons.phonelink_lock_rounded,
        isValid: state.isStep7Valid,
        infoText: state.locationPermissionGranted
            ? 'GPS Tracking: Granted\nCamera: ${state.cameraPermissionGranted ? "Granted" : "Pending"} • Notifications: ${state.pushNotificationsGranted ? "Enabled" : "Disabled"}'
            : 'Permissions Required for Order Dispatch',
        documents: const [],
      ),
      _StepCardConfig(
        step: DeliveryVerificationStep.safetyKitAndActivation,
        stepNumber: 8,
        titleKey: 'step8Title',
        descKey: 'step8Desc',
        icon: Icons.verified_user_rounded,
        isValid: state.isStep8Valid,
        infoText: state.hasDeliveryBag && state.hasHelmet
            ? 'Delivery Bag & Helmet Confirmed • ${state.welcomeBonusCode} (₹${state.welcomeBonusAmount.toStringAsFixed(0)})\nCode of Conduct Accepted'
            : 'Safety Kit Verification & Bonus Activation',
        documents: const [],
      ),
    ];

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 185,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = stepConfigs[index];
          return _StepDocumentCard(
            config: item,
            localeCode: localeCode,
            onTap: () => _openStep(context, item.step),
          );
        },
        childCount: stepConfigs.length,
      ),
    );
  }

  Widget _buildSecurityBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF1E293B),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF38BDF8),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryDocumentsStrings.of('securityTitle', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DeliveryDocumentsStrings.of('securitySubtitle', localeCode),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocPreview {
  final String label;
  final dynamic bytes;
  final String? url;

  const _DocPreview({
    required this.label,
    this.bytes,
    this.url,
  });

  bool get isUploaded => bytes != null || (url != null && url!.isNotEmpty);
}

class _StepCardConfig {
  final DeliveryVerificationStep step;
  final int stepNumber;
  final String titleKey;
  final String descKey;
  final IconData icon;
  final bool isValid;
  final String? infoText;
  final List<_DocPreview> documents;

  const _StepCardConfig({
    required this.step,
    required this.stepNumber,
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.isValid,
    this.infoText,
    this.documents = const [],
  });

  List<_DocPreview> get uploadedDocs =>
      documents.where((d) => d.isUploaded).toList();
}

class _StepDocumentCard extends StatefulWidget {
  final _StepCardConfig config;
  final String localeCode;
  final VoidCallback onTap;

  const _StepDocumentCard({
    required this.config,
    required this.localeCode,
    required this.onTap,
  });

  @override
  State<_StepDocumentCard> createState() => _StepDocumentCardState();
}

class _StepDocumentCardState extends State<_StepDocumentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.config;
    final uploadedDocs = item.uploadedDocs;

    return Semantics(
      button: true,
      label:
          'Step ${item.stepNumber}: ${DeliveryDocumentsStrings.of(item.titleKey, widget.localeCode)}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color:
                _isHovered ? const Color(0xFF14202D) : const Color(0xFF0F1722),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isValid
                  ? DeliveryAppColors.primary
                      .withValues(alpha: _isHovered ? 0.4 : 0.2)
                  : (_isHovered
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06)),
              width: 1.2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: item.isValid
                          ? DeliveryAppColors.primaryDark.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: Key('dp_doc_card_step_${item.stepNumber}'),
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.isValid
                                ? DeliveryAppColors.primaryDark
                                    .withValues(alpha: 0.15)
                                : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.isValid
                                ? DeliveryAppColors.primary
                                : const Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'STEP ${item.stepNumber}',
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  _buildStatusBadge(item.isValid),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DeliveryDocumentsStrings.of(
                                  item.titleKey,
                                  widget.localeCode,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.infoText ??
                          DeliveryDocumentsStrings.of(
                            item.descKey,
                            widget.localeCode,
                          ),
                      style: TextStyle(
                        color: item.infoText != null
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF64748B),
                        fontSize: 11.5,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (uploadedDocs.isNotEmpty)
                          Expanded(child: _buildPreviewActions(uploadedDocs))
                        else
                          Flexible(
                            child: Text(
                              DeliveryDocumentsStrings.of(
                                'tapToVerify',
                                widget.localeCode,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DeliveryDocumentsStrings.of(
                                'editStep',
                                widget.localeCode,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF38BDF8),
                              size: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewActions(List<_DocPreview> docs) {
    if (docs.length == 1) {
      final doc = docs.first;
      return InkWell(
        onTap: () {
          DeliveryDocumentPreviewDialog.show(
            context: context,
            title: doc.label,
            documentBytes: doc.bytes,
            documentUrl: doc.url,
          );
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.remove_red_eye_outlined,
                color: DeliveryAppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                DeliveryDocumentsStrings.of('viewDoc', widget.localeCode),
                style: const TextStyle(
                  color: DeliveryAppColors.primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: docs.map((doc) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                DeliveryDocumentPreviewDialog.show(
                  context: context,
                  title: doc.label,
                  documentBytes: doc.bytes,
                  documentUrl: doc.url,
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: DeliveryAppColors.primary.withValues(alpha: 0.3),
                    width: 0.7,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      color: DeliveryAppColors.primary,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      doc.label,
                      style: const TextStyle(
                        color: DeliveryAppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(bool isValid) {
    if (isValid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: DeliveryAppColors.primaryDark.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: DeliveryAppColors.primary.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: DeliveryAppColors.primary,
              size: 11,
            ),
            const SizedBox(width: 4),
            Text(
              DeliveryDocumentsStrings.of('verified', widget.localeCode),
              style: const TextStyle(
                color: DeliveryAppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: Color(0xFFF59E0B),
            size: 11,
          ),
          const SizedBox(width: 4),
          Text(
            DeliveryDocumentsStrings.of('incomplete', widget.localeCode),
            style: const TextStyle(
              color: Color(0xFFF59E0B),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
