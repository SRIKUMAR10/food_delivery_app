import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Delivery_Profile_page_bloc.dart';
import 'Delivery_Profile_page_event.dart';
import 'Delivery_Profile_page_repository.dart';
import 'Delivery_Profile_page_service.dart';
import 'Delivery_Profile_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_theme.dart';
import '../../../core/theme/delivery_app_typography.dart';
import '../Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import '../Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';

class DeliveryProfileStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'My Profile',
      'subtitle':
          'Keep your profile complete to get more delivery opportunities.',
      'uploadPhoto': 'Upload Photo',
      'personalInfo': 'Personal Information',
      'fullName': 'Full Name',
      'phone': 'Phone Number',
      'email': 'Email Address',
      'dob': 'Date of Birth',
      'gender': 'Gender',
      'vehicleType': 'Vehicle Type',
      'vehicleNumber': 'Vehicle Number',
      'licenseNumber': 'License Number',
      'licenseValidTill': 'License Valid Till',
      'male': 'Male',
      'female': 'Female',
      'scooter': 'Scooter',
      'bike': 'Bike',
      'car': 'Car',
      'uploadDocuments': 'Upload Documents',
      'documentsSub':
          'Upload clear scans of your documents to get verified faster.',
      'upload': 'Upload',
      'uploaded': 'Uploaded',
      'verified': 'Verified',
      'pending': 'Pending',
      'uploading': 'Uploading...',
      'profileCompletion': 'Profile Completion',
      'verificationStatus': 'Verification Status',
      'identity': 'Identity',
      'document': 'Document',
      'verifiedTag': 'Verified',
      'notVerifiedTag': 'Not Verified',
      'checklist': 'Profile Checklist',
      'saveContinue': 'Save & Continue',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'errorTitle': 'Something went wrong',
      'emptyTitle': 'No profile data',
      'emptySub':
          'Your profile appears to be empty. Refresh to load your details.',
      'saving': 'Saving...',
      'saved': 'Profile saved successfully',
      'checklist_personalDetails': 'Personal details completed',
      'checklist_vehicleInfo': 'Vehicle information provided',
      'checklist_drivingLicense': 'Driving license uploaded',
      'checklist_vehicleRc': 'Vehicle RC uploaded',
      'checklist_insurance': 'Insurance uploaded',
      'checklist_panCard': 'PAN card uploaded',
      'checklist_documentVerification': 'Document verification approved',
      'doc_drivingLicense': 'Driving License',
      'doc_vehicleRc': 'Vehicle RC',
      'doc_insurance': 'Insurance',
      'doc_panCard': 'PAN Card',
    },
    'ta': {
      'title': 'என் சுயவிவரம்',
      'subtitle':
          'கூடுதல் டெலிவரி வாய்ப்புகளைப் பெற உங்கள் சுயவிவரத்தை முழுமையாக வைத்திருங்கள்.',
      'uploadPhoto': 'புகைப்படம் பதிவேற்று',
      'personalInfo': 'தனிப்பட்ட தகவல்கள்',
      'fullName': 'முழு பெயர்',
      'phone': 'தொலைபேசி எண்',
      'email': 'மின்னஞ்சல்',
      'dob': 'பிறந்த தேதி',
      'gender': 'பாலினம்',
      'vehicleType': 'வாகன வகை',
      'vehicleNumber': 'வாகன எண்',
      'licenseNumber': 'உரிம எண்',
      'licenseValidTill': 'உரிமம் செல்லுபடியாகும் வரை',
      'male': 'ஆண்',
      'female': 'பெண்',
      'scooter': 'ஸ்கூட்டர்',
      'bike': 'பைக்',
      'car': 'கார்',
      'uploadDocuments': 'ஆவணங்களை பதிவேற்றவும்',
      'documentsSub':
          'விரைவாக சரிபார்ப்பிற்காக உங்கள் ஆவணங்களின் தெளிவான ஸ்கேன்களை பதிவேற்றவும்.',
      'upload': 'பதிவேற்று',
      'uploaded': 'பதிவேற்றப்பட்டது',
      'verified': 'சரிபார்க்கப்பட்டது',
      'pending': 'நிலுவையில்',
      'uploading': 'பதிவேற்றுகிறது...',
      'profileCompletion': 'சுயவிவர முழுமை',
      'verificationStatus': 'சரிபார்ப்பு நிலை',
      'identity': 'அடையாளம்',
      'document': 'ஆவணம்',
      'verifiedTag': 'சரிபார்க்கப்பட்டது',
      'notVerifiedTag': 'சரிபார்க்கப்படவில்லை',
      'checklist': 'சுயவிவர பட்டியல்',
      'saveContinue': 'சேமித்து தொடரவும்',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'refresh': 'புதுப்பிக்கவும்',
      'errorTitle': 'ஏதோ தவறு ஏற்பட்டது',
      'emptyTitle': 'சுயவிவர தரவு இல்லை',
      'emptySub': 'உங்கள் சுயவிவரம் காலியாக உள்ளது. விவரங்களை ஏற்ற புதுப்பிக்கவும்.',
      'saving': 'சேமிக்கிறது...',
      'saved': 'சுயவிவரம் வெற்றிகரமாக சேமிக்கப்பட்டது',
      'checklist_personalDetails': 'தனிப்பட்ட விவரங்கள் முடிந்தது',
      'checklist_vehicleInfo': 'வாகன தகவல்கள் வழங்கப்பட்டது',
      'checklist_drivingLicense': 'ஓட்டுநர் உரிமம் பதிவேற்றப்பட்டது',
      'checklist_vehicleRc': 'வாகன RC பதிவேற்றப்பட்டது',
      'checklist_insurance': 'காப்பீடு பதிவேற்றப்பட்டது',
      'checklist_panCard': 'PAN அட்டை பதிவேற்றப்பட்டது',
      'checklist_documentVerification': 'ஆவண சரிபார்ப்பு அங்கீகரிக்கப்பட்டது',
      'doc_drivingLicense': 'ஓட்டுநர் உரிமம்',
      'doc_vehicleRc': 'வாகன RC',
      'doc_insurance': 'காப்பீடு',
      'doc_panCard': 'PAN அட்டை',
    },
  };

  static String of(String key, String localeCode) {
    final localeMap = _strings[localeCode] ?? _strings['en']!;
    return localeMap[key] ?? _strings['en']![key]!;
  }
}

class DeliveryProfilePage extends StatelessWidget {
  final DeliveryProfileRepositoryBase? repository;
  final DeliveryProfileServiceBase? service;
  final DeliveryProfileBloc? bloc;

  const DeliveryProfilePage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryProfileBloc>.value(
        value: bloc!,
        child: const DeliveryProfilePageView(),
      );
    }

    return BlocProvider<DeliveryProfileBloc>(
      create: (context) => DeliveryProfileBloc(
        repository: repository ?? DeliveryProfileRepository(),
        service: service ?? DeliveryProfileService(),
      )..add(const DeliveryProfileInitEvent()),
      child: const DeliveryProfilePageView(),
    );
  }
}

class DeliveryProfilePageView extends StatelessWidget {
  const DeliveryProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryProfileBloc, DeliveryProfileState>(
      listener: (context, state) {
        if (state.saveStatus == DeliveryProfileSaveStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                DeliveryProfileStrings.of('saved', state.localeCode),
              ),
              backgroundColor: DeliveryAppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
            ),
          );

          final isProfileComplete = state.fullName.trim().isNotEmpty &&
              state.phone.trim().isNotEmpty &&
              state.vehicleType.trim().isNotEmpty &&
              state.vehicleNumber.trim().isNotEmpty &&
              state.licenseNumber.trim().isNotEmpty;

          if (isProfileComplete) {
            try {
              context
                  .read<DeliveryNavigationBarPageBloc>()
                  .add(const DeliveryNavigationBarTabChangedEvent(0));
            } catch (_) {}
          }
        } else if (state.errorMessage != null &&
            state.status != DeliveryProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return KeyedSubtree(
          key: const Key('dp_profile_page'),
          child: switch (state.status) {
            DeliveryProfileStatus.initial ||
            DeliveryProfileStatus.loading =>
              const _ProfileSkeleton(),
            DeliveryProfileStatus.error => _ErrorView(state: state),
            DeliveryProfileStatus.empty => _EmptyView(state: state),
            DeliveryProfileStatus.loaded =>
              _ProfileLoadedView(state: state),
          },
        );
      },
    );
  }
}

class _ProfileLoadedView extends StatelessWidget {
  final DeliveryProfileState state;

  const _ProfileLoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(state: state),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 1024;
                    final isTablet = constraints.maxWidth >= 600;

                    final Widget mainColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileImageSection(state: state),
                        const SizedBox(height: 20),
                        _PersonalInfoCard(state: state),
                        const SizedBox(height: 20),
                        _DocumentsCard(state: state),
                      ],
                    );

                    final Widget sideColumn = Column(
                      children: [
                        _CompletionCard(state: state),
                        const SizedBox(height: 20),
                        _VerificationCard(state: state),
                        const SizedBox(height: 20),
                        _ChecklistCard(state: state),
                      ],
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: mainColumn),
                          const SizedBox(width: 24),
                          SizedBox(width: 340, child: sideColumn),
                        ],
                      );
                    }

                    if (isTablet) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: mainColumn),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: sideColumn),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        mainColumn,
                        const SizedBox(height: 20),
                        _CompletionCard(state: state),
                        const SizedBox(height: 20),
                        _VerificationCard(state: state),
                        const SizedBox(height: 20),
                        _ChecklistCard(state: state),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _SaveBar(state: state, localeCode: localeCode),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final DeliveryProfileState state;

  const _ProfileHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DeliveryProfileStrings.of('title', state.localeCode),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DeliveryProfileStrings.of('subtitle', state.localeCode),
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ],
    );
  }
}

class _ProfileImageSection extends StatelessWidget {
  final DeliveryProfileState state;

  const _ProfileImageSection({required this.state});

  String get _initials {
    final parts = state.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'DP';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Container(
      key: const Key('dp_profile_image_section'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Semantics(
            label: '${state.fullName} profile photo',
            image: true,
            child: Container(
              key: const Key('dp_profile_avatar'),
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [DeliveryAppColors.primary, DeliveryAppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DeliveryAppColors.primaryDark.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: state.avatarPath == null
                        ? Text(
                            _initials,
                            style: const TextStyle(
                              color: Color(0xFF061208),
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: state.avatarPath!,
                              fit: BoxFit.cover,
                              width: 92,
                              height: 92,
                              memCacheWidth: 184, memCacheHeight: 184, placeholder: (_, __) => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: DeliveryAppColors.primary)), errorWidget: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Color(0xFF061208),
                                size: 40,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2530),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DeliveryAppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        color: DeliveryAppColors.primary,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  state.email,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  state.phone,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('dp_profile_upload_photo'),
                  onPressed: () => context
                      .read<DeliveryProfileBloc>()
                      .add(const DeliveryProfilePickImageEvent()),
                  icon: const Icon(Icons.add_a_photo, size: 16),
                  label: Text(
                    DeliveryProfileStrings.of('uploadPhoto', localeCode),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DeliveryAppColors.primary,
                    side: const BorderSide(color: DeliveryAppColors.primaryDark),
                    minimumSize: const Size(140, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

class _PersonalInfoCard extends StatelessWidget {
  final DeliveryProfileState state;

  const _PersonalInfoCard({required this.state});

  void _dispatch(BuildContext context, String field, String value) {
    context
        .read<DeliveryProfileBloc>()
        .add(DeliveryProfileUpdateFieldEvent(field: field, value: value));
  }

  Widget _textField(
    BuildContext context, {
    required String key,
    required String label,
    required String value,
    required String field,
    TextInputType? keyboardType,
    String? hint,
  }) {
    final String localeCode = state.localeCode;
    return TextFormField(
      key: Key(key),
      initialValue: value,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: DeliveryProfileStrings.of(label, localeCode),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFF0B1219),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DeliveryAppColors.primaryDark),
        ),
      ),
      onChanged: (value) => _dispatch(context, field, value),
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String key,
    required String label,
    required String value,
    required String field,
    required List<String> options,
  }) {
    final String localeCode = state.localeCode;
    final String? normalizedValue = value.isEmpty
        ? null
        : options.firstWhere(
            (opt) => opt.toLowerCase() == value.toLowerCase(),
            orElse: () => options.first,
          );

    return DropdownButtonFormField<String>(
      key: Key(key),
      initialValue: normalizedValue,
      dropdownColor: const Color(0xFF0D141C),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: DeliveryProfileStrings.of(label, localeCode),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFF0B1219),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DeliveryAppColors.primaryDark),
        ),
      ),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text(
              DeliveryProfileStrings.of(option, localeCode),
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) _dispatch(context, field, value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Container(
      key: const Key('dp_profile_personal_info'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline,
                  color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliveryProfileStrings.of('personalInfo', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool twoColumns = constraints.maxWidth >= 600;
              final Widget fullNameField = _textField(
                context,
                key: 'dp_profile_full_name',
                label: 'fullName',
                value: state.fullName,
                field: 'fullName',
              );
              final Widget phoneField = _textField(
                context,
                key: 'dp_profile_phone',
                label: 'phone',
                value: state.phone,
                field: 'phone',
                keyboardType: TextInputType.phone,
              );
              final Widget emailField = _textField(
                context,
                key: 'dp_profile_email',
                label: 'email',
                value: state.email,
                field: 'email',
                keyboardType: TextInputType.emailAddress,
              );
              final Widget dobField = _textField(
                context,
                key: 'dp_profile_dob',
                label: 'dob',
                value: state.dob,
                field: 'dob',
                hint: 'DD-MM-YYYY',
              );
              final Widget genderField = _dropdown(
                context,
                key: 'dp_profile_gender',
                label: 'gender',
                value: state.gender,
                field: 'gender',
                options: const ['male', 'female'],
              );
              final Widget vehicleTypeField = _dropdown(
                context,
                key: 'dp_profile_vehicle_type',
                label: 'vehicleType',
                value: state.vehicleType,
                field: 'vehicleType',
                options: const ['scooter', 'bike', 'car'],
              );
              final Widget vehicleNumberField = _textField(
                context,
                key: 'dp_profile_vehicle_number',
                label: 'vehicleNumber',
                value: state.vehicleNumber,
                field: 'vehicleNumber',
              );
              final Widget licenseNumberField = _textField(
                context,
                key: 'dp_profile_license_number',
                label: 'licenseNumber',
                value: state.licenseNumber,
                field: 'licenseNumber',
              );
              final Widget licenseValidTillField = _textField(
                context,
                key: 'dp_profile_license_valid_till',
                label: 'licenseValidTill',
                value: state.licenseValidTill,
                field: 'licenseValidTill',
                hint: 'DD-MM-YYYY',
              );

              if (twoColumns) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: fullNameField),
                        const SizedBox(width: 12),
                        Expanded(child: phoneField),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: emailField),
                        const SizedBox(width: 12),
                        Expanded(child: dobField),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: genderField),
                        const SizedBox(width: 12),
                        Expanded(child: vehicleTypeField),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: vehicleNumberField),
                        const SizedBox(width: 12),
                        Expanded(child: licenseNumberField),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: licenseValidTillField),
                        const SizedBox(width: 12),
                        Expanded(child: const SizedBox()),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  fullNameField,
                  const SizedBox(height: 12),
                  phoneField,
                  const SizedBox(height: 12),
                  emailField,
                  const SizedBox(height: 12),
                  dobField,
                  const SizedBox(height: 12),
                  genderField,
                  const SizedBox(height: 12),
                  vehicleTypeField,
                  const SizedBox(height: 12),
                  vehicleNumberField,
                  const SizedBox(height: 12),
                  licenseNumberField,
                  const SizedBox(height: 12),
                  licenseValidTillField,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  final DeliveryProfileState state;

  const _DocumentsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Container(
      key: const Key('dp_profile_documents'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_open,
                  color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryProfileStrings.of('uploadDocuments', localeCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliveryProfileStrings.of('documentsSub', localeCode),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < state.documents.length; i++) ...[
            _DocumentTile(
              document: state.documents[i],
              localeCode: localeCode,
            ),
            if (i != state.documents.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final DeliveryProfileDocument document;
  final String localeCode;

  const _DocumentTile({
    required this.document,
    required this.localeCode,
  });

  Color get _statusColor {
    switch (document.status) {
      case DeliveryProfileDocumentStatus.verified:
        return DeliveryAppColors.primary;
      case DeliveryProfileDocumentStatus.uploaded:
        return const Color(0xFF4FC3F7);
      case DeliveryProfileDocumentStatus.uploading:
        return const Color(0xFFFBBF24);
      case DeliveryProfileDocumentStatus.notUploaded:
        return const Color(0xFF64748B);
    }
  }

  String get _statusLabel {
    switch (document.status) {
      case DeliveryProfileDocumentStatus.verified:
        return DeliveryProfileStrings.of('verified', localeCode);
      case DeliveryProfileDocumentStatus.uploaded:
        return DeliveryProfileStrings.of('uploaded', localeCode);
      case DeliveryProfileDocumentStatus.uploading:
        return DeliveryProfileStrings.of('uploading', localeCode);
      case DeliveryProfileDocumentStatus.notUploaded:
        return DeliveryProfileStrings.of('pending', localeCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String label = DeliveryProfileStrings.of(
      'doc_${document.id}',
      localeCode,
    );
    final bool isUploading = document.isUploading;
    return Container(
      key: Key('dp_profile_doc_${document.id}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1219),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(document.icon, color: _statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (document.isVerified)
                const Icon(Icons.verified, color: DeliveryAppColors.primary, size: 20)
              else if (!isUploading)
                OutlinedButton(
                  key: Key('dp_profile_upload_${document.id}'),
                  onPressed: () => context
                      .read<DeliveryProfileBloc>()
                      .add(DeliveryProfileUploadDocumentEvent(document.id)),
                  child: Text(
                    DeliveryProfileStrings.of('upload', localeCode),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DeliveryAppColors.primary,
                    side: const BorderSide(color: DeliveryAppColors.primaryDark),
                    minimumSize: const Size(76, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${(document.progress * 100).round()}%',
                    style: const TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (isUploading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                key: Key('dp_profile_doc_progress_${document.id}'),
                value: document.progress,
                minHeight: 6,
                backgroundColor: DeliveryAppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation(DeliveryAppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final DeliveryProfileState state;

  const _CompletionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    final double value = (state.completionPercentage / 100).clamp(0.0, 1.0);
    return Container(
      key: const Key('dp_profile_completion_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DeliveryAppColors.primaryDark.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            DeliveryProfileStrings.of('profileCompletion', localeCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Profile completion ${state.completionPercentage}%',
            child: SizedBox(
              key: const Key('dp_profile_completion_ring'),
              width: 116,
              height: 116,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: DeliveryAppColors.surfaceLight,
                    valueColor:
                        const AlwaysStoppedAnimation(DeliveryAppColors.primary),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.completionPercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'complete',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final DeliveryProfileState state;

  const _VerificationCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    final rows = <(String, bool, IconData)>[
      ('phone', state.isPhoneVerified, Icons.phone_outlined),
      ('email', state.isEmailVerified, Icons.email_outlined),
      ('identity', state.isIdentityVerified, Icons.verified_user_outlined),
      ('document', state.isDocumentVerified, Icons.description_outlined),
    ];
    return Container(
      key: const Key('dp_profile_verification_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryProfileStrings.of('verificationStatus', localeCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final (key, verified, icon) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    verified ? Icons.check_circle : Icons.cancel,
                    color: verified
                        ? DeliveryAppColors.primary
                        : const Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Icon(icon, color: const Color(0xFF94A3B8), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DeliveryProfileStrings.of(key, localeCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      key: Key('dp_profile_verification_$key'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: verified
                            ? DeliveryAppColors.primaryDark.withValues(alpha: 0.12)
                            : DeliveryAppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        verified
                            ? DeliveryProfileStrings.of(
                                'verifiedTag',
                                localeCode,
                              )
                            : DeliveryProfileStrings.of(
                                'notVerifiedTag',
                                localeCode,
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: verified
                              ? DeliveryAppColors.primary
                              : const Color(0xFFFCA5A5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _ChecklistCard extends StatelessWidget {
  final DeliveryProfileState state;

  const _ChecklistCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Container(
      key: const Key('dp_profile_checklist_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryProfileStrings.of('checklist', localeCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in state.checklist)
            Semantics(
              checked: item.isComplete,
              label: DeliveryProfileStrings.of(
                'checklist_${item.id}',
                localeCode,
              ),
              child: Padding(
                key: Key('dp_profile_checklist_${item.id}'),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      item.isComplete
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: item.isComplete
                          ? DeliveryAppColors.primary
                          : const Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DeliveryProfileStrings.of(
                          'checklist_${item.id}',
                          localeCode,
                        ),
                        style: TextStyle(
                          color: item.isComplete
                              ? const Color(0xFFE8FFF3)
                              : const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: item.isComplete
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final DeliveryProfileState state;
  final String localeCode;

  const _SaveBar({required this.state, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final bool saving = state.saveStatus == DeliveryProfileSaveStatus.saving;
    return Container(
      key: const Key('dp_profile_save_bar'),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewPadding.bottom > 0 ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF060B11),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            key: const Key('dp_profile_save_button'),
            onPressed: saving
                ? null
                : () =>
                    context.read<DeliveryProfileBloc>().add(
                          const DeliveryProfileSaveEvent(),
                        ),
            style: FilledButton.styleFrom(
              backgroundColor: DeliveryAppColors.primaryDark,
              disabledBackgroundColor: DeliveryAppColors.buttonSecondary,
              foregroundColor: const Color(0xFF06120B),
              disabledForegroundColor: const Color(0xFF64748B),
              minimumSize: const Size(180, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF64748B),
                    ),
                  )
                : const Icon(Icons.arrow_forward, size: 18),
            label: Text(
              saving
                  ? DeliveryProfileStrings.of('saving', localeCode)
                  : DeliveryProfileStrings.of('saveContinue', localeCode),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  Widget _box({
    required double width,
    required double height,
    BorderRadius radius = const BorderRadius.all(Radius.circular(10)),
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: radius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('dp_profile_skeleton'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 180, height: 24),
          const SizedBox(height: 12),
          _box(width: 300, height: 12),
          const SizedBox(height: 24),
          _box(
            width: double.infinity,
            height: 132,
            radius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 20),
          _box(
            width: double.infinity,
            height: 320,
            radius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final DeliveryProfileState state;

  const _ErrorView({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Center(
      key: const Key('dp_profile_error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFF87171),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryProfileStrings.of('errorTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.errorMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('dp_profile_retry'),
              onPressed: () => context
                  .read<DeliveryProfileBloc>()
                  .add(const DeliveryProfileRetryEvent()),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                DeliveryProfileStrings.of('retry', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final DeliveryProfileState state;

  const _EmptyView({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Center(
      key: const Key('dp_profile_empty'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0D141C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off_outlined,
                color: Color(0xFF64748B),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryProfileStrings.of('emptyTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryProfileStrings.of('emptySub', localeCode),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('dp_profile_refresh'),
              onPressed: () => context
                  .read<DeliveryProfileBloc>()
                  .add(const DeliveryProfileRetryEvent()),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                DeliveryProfileStrings.of('refresh', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
