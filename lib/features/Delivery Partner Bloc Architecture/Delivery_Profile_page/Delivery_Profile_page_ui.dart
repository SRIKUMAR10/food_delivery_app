import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Profile_page_bloc.dart';
import 'Delivery_Profile_page_event.dart';
import 'Delivery_Profile_page_repository.dart';
import 'Delivery_Profile_page_service.dart';
import 'Delivery_Profile_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/widgets/logout_button.dart';
import '../../../core/services/google_places_service.dart';
import 'delivery_google_address_search_dialog.dart';
import '../delivery_image_picker_helper.dart';
import '../delivery_document_preview_dialog.dart';
import '../Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import '../Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      'address': 'Residential Address',
      'dob': 'Date of Birth',
      'gender': 'Gender',
      'vehicleInfo': 'Vehicle Information',
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
      'partnerId': 'Partner ID',
      'joined': 'Joined',
      'rating': 'Rating',
      'deliveries': 'Deliveries',
      'actions': 'Account Actions',
      'editProfile': 'Edit Profile',
      'changePhoto': 'Change Photo',
      'updateVehicle': 'Update Vehicle',
      'updatePhone': 'Update Phone',
      'updateEmail': 'Update Email',
      'changePassword': 'Change Password',
      'logout': 'Log Out',
      'deactivate': 'Deactivate Account',
      'logoutConfirm': 'Are you sure you want to log out?',
      'deactivateConfirm':
          'Are you sure you want to deactivate your delivery account?',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'update': 'Update',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmNewPassword': 'Confirm New Password',
      'active': 'Active',
      'inactive': 'Inactive',
      'approved': 'Approved',
      'pendingApproval': 'Pending',
      'inReview': 'In Review',
      'rejected': 'Rejected',
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
      'address': 'முகவரி',
      'dob': 'பிறந்த தேதி',
      'gender': 'பாலினம்',
      'vehicleInfo': 'வாகன தகவல்கள்',
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
      'partnerId': 'பங்குதாரர் ஐடி',
      'joined': 'இணைந்தது',
      'rating': 'மதிப்பீடு',
      'deliveries': 'டெலிவரிகள்',
      'actions': 'கணக்கு நடவடிக்கைகள்',
      'editProfile': 'சுயவிவரத்தைத் திருத்து',
      'changePhoto': 'புகைப்படத்தை மாற்றவும்',
      'updateVehicle': 'வாகனத்தை மாற்றவும்',
      'updatePhone': 'தொலைபேசி எண்ணை மாற்றவும்',
      'updateEmail': 'மின்னஞ்சலை மாற்றவும்',
      'changePassword': 'கடவுச்சொல்லை மாற்றவும்',
      'logout': 'வெளியேறு',
      'deactivate': 'கணக்கை முடக்கவும்',
      'logoutConfirm': 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?',
      'deactivateConfirm': 'உங்கள் டெலிவரி கணக்கை நிச்சயமாக முடக்க விரும்புகிறீர்களா?',
      'cancel': 'ரத்துசெய்',
      'confirm': 'உறுதிப்படுத்து',
      'update': 'புதுப்பி',
      'currentPassword': 'தற்போதைய கடவுச்சொல்',
      'newPassword': 'புதிய கடவுச்சொல்',
      'confirmNewPassword': 'புதிய கடவுச்சொல்லை உறுதிப்படுத்து',
      'active': 'செயலில்',
      'inactive': 'செயலற்றது',
      'approved': 'அங்கீகரிக்கப்பட்டது',
      'pendingApproval': 'நிலுவையில்',
      'inReview': 'பரிசீலனையில்',
      'rejected': 'நிராகரிக்கப்பட்டது',
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
    return localeMap[key] ?? _strings['en']![key] ?? key;
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
      listenWhen: (previous, current) =>
          previous.saveStatus != current.saveStatus ||
          previous.actionMessage != current.actionMessage ||
          (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null),
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
        } else if (state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              backgroundColor: DeliveryAppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
            padding: const EdgeInsets.all(24),
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
                        _VehicleInfoCard(state: state),
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
                        _ProfileActionsCard(state: state),
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
                          SizedBox(width: 360, child: sideColumn),
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
                        _ProfileActionsCard(state: state),
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
    final localeCode = state.localeCode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryProfileStrings.of('title', localeCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DeliveryProfileStrings.of('subtitle', localeCode),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _LanguageToggle(state: state),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _HeaderBadge(
                icon: Icons.badge_outlined,
                label: state.partnerCode,
                color: DeliveryAppColors.info,
              ),
              _HeaderBadge(
                icon: Icons.star,
                label: '${state.rating.toStringAsFixed(1)} ★',
                color: Colors.amber,
              ),
              _HeaderBadge(
                icon: Icons.moped,
                label:
                    '${state.totalDeliveries} ${DeliveryProfileStrings.of('deliveries', localeCode)}',
                color: DeliveryAppColors.primary,
              ),
              if (state.joiningDate.isNotEmpty)
                _HeaderBadge(
                  icon: Icons.calendar_today,
                  label:
                      '${DeliveryProfileStrings.of('joined', localeCode)}: ${state.joiningDate}',
                  color: Colors.purpleAccent,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final DeliveryProfileState state;

  const _LanguageToggle({required this.state});

  @override
  Widget build(BuildContext context) {
    final isTamil = state.localeCode == 'ta';
    return InkWell(
      onTap: () {
        context.read<DeliveryProfileBloc>().add(
              DeliveryProfileLocaleChangedEvent(isTamil ? 'en' : 'ta'),
            );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: DeliveryAppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: DeliveryAppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16, color: DeliveryAppColors.primary),
            const SizedBox(width: 6),
            Text(
              isTamil ? 'தமிழ்' : 'English',
              style: const TextStyle(
                color: DeliveryAppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                DeliveryImagePickerHelper.showPicker(
                  context: context,
                  title: 'Profile Photo',
                  enableCamera: true,
                  onImagePicked: (bytes, fileName) async {
                    try {
                      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'partner';
                      final ref = FirebaseStorage.instance
                          .ref('delivery_partners/$uid/avatar_$fileName');
                      final uploadTask = await ref.putData(bytes);
                      final downloadUrl = await uploadTask.ref.getDownloadURL();
                      if (context.mounted) {
                        context.read<DeliveryProfileBloc>().add(
                              DeliveryProfileUpdateFieldEvent(
                                field: 'avatarPath',
                                value: downloadUrl,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile photo updated successfully!'),
                            backgroundColor: DeliveryAppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        context.read<DeliveryProfileBloc>().add(
                              const DeliveryProfilePickImageEvent(),
                            );
                      }
                    }
                  },
                );
              },
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
                          : DeliveryFastImage(
                              imageUrl: state.avatarPath,
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                              isCircle: true,
                              placeholder: Text(
                                _initials,
                                style: const TextStyle(
                                  color: Color(0xFF061208),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              errorWidget: const Icon(
                                Icons.person,
                                color: Color(0xFF061208),
                                size: 40,
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.fullName.isEmpty ? 'Delivery Partner' : state.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusPill(
                      label: state.isActive
                          ? DeliveryProfileStrings.of('active', localeCode)
                          : DeliveryProfileStrings.of('inactive', localeCode),
                      isActive: state.isActive,
                    ),
                  ],
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
                    minimumSize: const Size(140, 44),
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

class _StatusPill extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StatusPill({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? DeliveryAppColors.success : DeliveryAppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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
                  overflow: TextOverflow.ellipsis,
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
              final Widget addressField = _AddressPickerField(
                state: state,
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
                        Expanded(child: addressField),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: dobField),
                        const SizedBox(width: 12),
                        Expanded(child: genderField),
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
                  addressField,
                  const SizedBox(height: 12),
                  dobField,
                  const SizedBox(height: 12),
                  genderField,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddressPickerField extends StatefulWidget {
  final DeliveryProfileState state;

  const _AddressPickerField({required this.state});

  @override
  State<_AddressPickerField> createState() => _AddressPickerFieldState();
}

class _AddressPickerFieldState extends State<_AddressPickerField> {
  late final TextEditingController _controller;
  bool _isLocatingGps = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.address);
  }

  @override
  void didUpdateWidget(covariant _AddressPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.address != widget.state.address &&
        _controller.text != widget.state.address) {
      _controller.text = widget.state.address;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dispatch(BuildContext context, DeliveryProfileUpdateFieldEvent event) {
    context.read<DeliveryProfileBloc>().add(event);
  }

  Future<void> _detectGps(BuildContext context) async {
    setState(() => _isLocatingGps = true);
    try {
      final details = await GooglePlacesService.instance.getCurrentLocationAddress();
      if (details != null && mounted) {
        final lat = details.latitude ?? 13.0827;
        final lng = details.longitude ?? 80.2707;
        _controller.text = details.formattedAddress;
        _dispatch(
          context,
          DeliveryProfileUpdateFieldEvent(
            field: 'address',
            value: details.formattedAddress,
            latitude: lat,
            longitude: lng,
            googleMapsUrl: 'https://www.google.com/maps?q=$lat,$lng',
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not retrieve GPS location. Please check location permissions.',
            ),
            backgroundColor: DeliveryAppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e'),
            backgroundColor: DeliveryAppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocatingGps = false);
      }
    }
  }

  Future<void> _openMapPicker(BuildContext context) async {
    final result = await DeliveryGoogleAddressSearchDialog.show(
      context: context,
      addressType: 'Home',
      currentAddress: _controller.text.trim(),
      onAddressSelected: (selection) {
        _controller.text = selection.address;
        _dispatch(
          context,
          DeliveryProfileUpdateFieldEvent(
            field: 'address',
            value: selection.address,
            latitude: selection.latitude,
            longitude: selection.longitude,
            googleMapsUrl: selection.effectiveGoogleMapsUrl,
          ),
        );
      },
    );
    if (result != null) {
      _controller.text = result.address;
      _dispatch(
        context,
        DeliveryProfileUpdateFieldEvent(
          field: 'address',
          value: result.address,
          latitude: result.latitude,
          longitude: result.longitude,
          googleMapsUrl: result.effectiveGoogleMapsUrl,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String localeCode = widget.state.localeCode;
    return TextFormField(
      key: const Key('dp_profile_address'),
      controller: _controller,
      maxLines: 2,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: DeliveryProfileStrings.of('address', localeCode),
        hintText: 'House/Street, Area, City',
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
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('dp_profile_address_gps'),
              tooltip: 'Detect GPS Location',
              icon: _isLocatingGps
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DeliveryAppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      color: DeliveryAppColors.primary,
                      size: 20,
                    ),
              onPressed: _isLocatingGps ? null : () => _detectGps(context),
            ),
            IconButton(
              key: const Key('dp_profile_address_map'),
              tooltip: 'Pick on Map',
              icon: const Icon(
                Icons.map_outlined,
                color: DeliveryAppColors.primary,
                size: 20,
              ),
              onPressed: () => _openMapPicker(context),
            ),
          ],
        ),
      ),
      onChanged: (value) => _dispatch(
        context,
        DeliveryProfileUpdateFieldEvent(field: 'address', value: value),
      ),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  final DeliveryProfileState state;

  const _VehicleInfoCard({required this.state});

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
    String? hint,
  }) {
    final String localeCode = state.localeCode;
    return TextFormField(
      key: Key(key),
      initialValue: value,
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
      key: const Key('dp_profile_vehicle_info'),
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
              const Icon(Icons.two_wheeler,
                  color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliveryProfileStrings.of('vehicleInfo', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool twoColumns = constraints.maxWidth >= 600;
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
                hint: 'e.g. TN 01 AB 1234',
              );
              final Widget licenseNumberField = _textField(
                context,
                key: 'dp_profile_license_number',
                label: 'licenseNumber',
                value: state.licenseNumber,
                field: 'licenseNumber',
                hint: 'DL number',
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
                        Expanded(child: vehicleTypeField),
                        const SizedBox(width: 12),
                        Expanded(child: vehicleNumberField),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: licenseNumberField),
                        const SizedBox(width: 12),
                        Expanded(child: licenseValidTillField),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliveryProfileStrings.of('documentsSub', localeCode),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
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
    final bool hasDoc = document.isUploaded || document.isVerified;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: hasDoc
          ? () => DeliveryDocumentPreviewDialog.show(
                context: context,
                title: label,
                documentUrl: document.documentUrl,
                docType: document.id,
                status: document.isVerified ? 'verified' : 'uploaded',
                onReupload: () => _pickAndUpload(context, label),
              )
          : () => _pickAndUpload(context, label),
      child: Container(
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
                        overflow: TextOverflow.ellipsis,
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
                if (isUploading)
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
                  )
                else if (hasDoc) ...[
                  IconButton(
                    tooltip: 'View Document',
                    icon: const Icon(Icons.visibility_outlined,
                        color: DeliveryAppColors.primary, size: 22),
                    onPressed: () => DeliveryDocumentPreviewDialog.show(
                      context: context,
                      title: label,
                      documentUrl: document.documentUrl,
                      docType: document.id,
                      status: document.isVerified ? 'verified' : 'uploaded',
                      onReupload: () => _pickAndUpload(context, label),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (document.isVerified)
                    const Icon(Icons.verified,
                        color: DeliveryAppColors.primary, size: 20)
                  else
                    OutlinedButton(
                      key: Key('dp_profile_upload_${document.id}'),
                      onPressed: () => _pickAndUpload(context, label),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DeliveryAppColors.primary,
                        side:
                            const BorderSide(color: DeliveryAppColors.primaryDark),
                        minimumSize: const Size(64, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                ] else
                  OutlinedButton(
                    key: Key('dp_profile_upload_${document.id}'),
                    onPressed: () => _pickAndUpload(context, label),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DeliveryAppColors.primary,
                      side:
                          const BorderSide(color: DeliveryAppColors.primaryDark),
                      minimumSize: const Size(76, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      DeliveryProfileStrings.of('upload', localeCode),
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
    ),
  );
}

  void _pickAndUpload(BuildContext context, String docTitle) {
    context.read<DeliveryProfileBloc>().add(
          DeliveryProfileUploadDocumentEvent(document.id),
        );
    DeliveryImagePickerHelper.showPicker(
      context: context,
      title: docTitle,
      enableCamera: true,
      allowPdf: true,
      onImagePicked: (bytes, fileName) async {
        try {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? 'partner';
          final ref = FirebaseStorage.instance
              .ref('delivery_partners/$uid/kyc/${document.id}_$fileName');
          final uploadTask = await ref.putData(bytes);
          final downloadUrl = await uploadTask.ref.getDownloadURL();
          if (context.mounted) {
            context.read<DeliveryProfileBloc>().add(
                  DeliveryProfileUploadDocumentEvent(
                    document.id,
                    filePath: downloadUrl,
                  ),
                );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$docTitle uploaded successfully!'),
                backgroundColor: DeliveryAppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (_) {
          if (context.mounted) {
            context.read<DeliveryProfileBloc>().add(
                  DeliveryProfileUploadDocumentEvent(document.id),
                );
          }
        }
      },
    );
  }
}

class _ProfileActionsCard extends StatelessWidget {
  final DeliveryProfileState state;

  const _ProfileActionsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final localeCode = state.localeCode;
    return Container(
      key: const Key('dp_profile_actions_card'),
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
              const Icon(Icons.settings_outlined,
                  color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliveryProfileStrings.of('actions', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionRow(
            keyName: 'dp_profile_action_change_password',
            icon: Icons.lock_outline,
            title: DeliveryProfileStrings.of('changePassword', localeCode),
            color: Colors.white,
            onTap: () => _showChangePasswordDialog(context, localeCode),
          ),
          const SizedBox(height: 8),
          _ActionRow(
            keyName: 'dp_profile_action_logout',
            icon: Icons.logout,
            title: DeliveryProfileStrings.of('logout', localeCode),
            color: Colors.amber,
            onTap: () => _showLogoutDialog(context, localeCode),
          ),
          const SizedBox(height: 8),
          _ActionRow(
            keyName: 'dp_profile_action_deactivate',
            icon: Icons.power_settings_new,
            title: DeliveryProfileStrings.of('deactivate', localeCode),
            color: DeliveryAppColors.error,
            onTap: () => _showDeactivateDialog(context, localeCode),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, String localeCode) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DeliveryProfileStrings.of('changePassword', localeCode),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('dp_change_pass_current'),
              controller: currentPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: DeliveryProfileStrings.of('currentPassword', localeCode),
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0B1219),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('dp_change_pass_new'),
              controller: newPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: DeliveryProfileStrings.of('newPassword', localeCode),
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0B1219),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('dp_change_pass_confirm'),
              controller: confirmPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText:
                    DeliveryProfileStrings.of('confirmNewPassword', localeCode),
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0B1219),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              DeliveryProfileStrings.of('cancel', localeCode),
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            key: const Key('dp_change_pass_submit'),
            onPressed: () {
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: DeliveryAppColors.error,
                  ),
                );
                return;
              }
              context.read<DeliveryProfileBloc>().add(
                    DeliveryProfileChangePasswordEvent(
                      currentPassword: currentPassController.text.trim(),
                      newPassword: newPassController.text.trim(),
                    ),
                  );
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DeliveryAppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: Text(
              DeliveryProfileStrings.of('update', localeCode),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, String localeCode) {
    showLogoutConfirmDialog(
      context,
      title: DeliveryProfileStrings.of('logout', localeCode),
      message: DeliveryProfileStrings.of('logoutConfirm', localeCode),
      confirmLabel: DeliveryProfileStrings.of('logout', localeCode),
      confirmColor: Colors.amber,
      confirmForegroundColor: Colors.black,
      confirmButtonKey: 'dp_logout_confirm_btn',
      backgroundColor: const Color(0xFF161B22),
      titleColor: Colors.white,
      contentColor: const Color(0xFF94A3B8),
      cancelColor: const Color(0xFF94A3B8),
      onConfirm: () async {
        context.read<DeliveryProfileBloc>().add(const DeliveryProfileLogoutEvent());
      },
    );
  }

  void _showDeactivateDialog(BuildContext context, String localeCode) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DeliveryProfileStrings.of('deactivate', localeCode),
          style: const TextStyle(
              color: DeliveryAppColors.error, fontWeight: FontWeight.w700),
        ),
        content: Text(
          DeliveryProfileStrings.of('deactivateConfirm', localeCode),
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              DeliveryProfileStrings.of('cancel', localeCode),
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            key: const Key('dp_deactivate_confirm_btn'),
            onPressed: () {
              context
                  .read<DeliveryProfileBloc>()
                  .add(const DeliveryProfileDeactivateAccountEvent());
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DeliveryAppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              DeliveryProfileStrings.of('deactivate', localeCode),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String keyName;
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({
    required this.keyName,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key(keyName),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1219),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: color.withValues(alpha: 0.6)),
          ],
        ),
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
    return Semantics(
      label: 'Profile completion ${state.completionPercentage}%',
      child: Container(
        key: const Key('dp_profile_completion_card'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0D141C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DeliveryProfileStrings.of('profileCompletion', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.completionPercentage}%',
                style: const TextStyle(
                  color: DeliveryAppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              key: const Key('dp_profile_progress_bar'),
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFF1E2631),
              valueColor:
                  const AlwaysStoppedAnimation(DeliveryAppColors.primary),
            ),
          ),
        ],
      ),
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
    final List<_VerificationItemData> items = [
      _VerificationItemData(
        id: 'phone',
        icon: Icons.phone_android,
        label: DeliveryProfileStrings.of('phone', localeCode),
        isVerified: state.isPhoneVerified,
      ),
      _VerificationItemData(
        id: 'email',
        icon: Icons.alternate_email,
        label: DeliveryProfileStrings.of('email', localeCode),
        isVerified: state.isEmailVerified,
      ),
      _VerificationItemData(
        id: 'identity',
        icon: Icons.person_search,
        label: DeliveryProfileStrings.of('identity', localeCode),
        isVerified: state.isIdentityVerified,
      ),
      _VerificationItemData(
        id: 'document',
        icon: Icons.verified_user,
        label: DeliveryProfileStrings.of('document', localeCode),
        isVerified: state.isDocumentVerified,
      ),
    ];

    return Container(
      key: const Key('dp_profile_verification_card'),
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
              const Icon(Icons.shield_outlined,
                  color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliveryProfileStrings.of('verificationStatus', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            _VerificationRow(item: items[i], localeCode: localeCode),
            if (i != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _VerificationItemData {
  final String id;
  final IconData icon;
  final String label;
  final bool isVerified;

  const _VerificationItemData({
    required this.id,
    required this.icon,
    required this.label,
    required this.isVerified,
  });
}

class _VerificationRow extends StatelessWidget {
  final _VerificationItemData item;
  final String localeCode;

  const _VerificationRow({
    required this.item,
    required this.localeCode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVerified = item.isVerified;
    final Color badgeColor =
        isVerified ? DeliveryAppColors.primary : const Color(0xFF64748B);
    final String badgeText = isVerified
        ? DeliveryProfileStrings.of('verifiedTag', localeCode)
        : DeliveryProfileStrings.of('notVerifiedTag', localeCode);

    return Container(
      key: Key('dp_profile_verif_${item.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1219),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 18, color: badgeColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
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
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined,
                  color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliveryProfileStrings.of('checklist', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < state.checklist.length; i++) ...[
            _ChecklistTile(
              item: state.checklist[i],
              localeCode: localeCode,
            ),
            if (i != state.checklist.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final DeliveryProfileChecklistItem item;
  final String localeCode;

  const _ChecklistTile({
    required this.item,
    required this.localeCode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = item.isComplete;
    final String label = DeliveryProfileStrings.of(
      'checklist_${item.id}',
      localeCode,
    );
    return Semantics(
      checked: isDone,
      label: label,
      child: Row(
        key: Key('dp_profile_check_${item.id}'),
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? DeliveryAppColors.primary : const Color(0xFF475569),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDone ? Colors.white : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
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
    final isSaving = state.saveStatus == DeliveryProfileSaveStatus.saving;
    return Container(
      key: const Key('dp_profile_save_bar'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          key: const Key('dp_profile_save_button'),
          onPressed: isSaving
              ? null
              : () => context
                  .read<DeliveryProfileBloc>()
                  .add(const DeliveryProfileSaveEvent()),
          style: ElevatedButton.styleFrom(
            backgroundColor: DeliveryAppColors.primary,
            foregroundColor: const Color(0xFF061208),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isSaving
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF061208),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DeliveryProfileStrings.of('saving', localeCode),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Text(
                  DeliveryProfileStrings.of('saveContinue', localeCode),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('dp_profile_skeleton'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
            ),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: DeliveryAppColors.error, size: 54),
            const SizedBox(height: 16),
            Text(
              DeliveryProfileStrings.of('errorTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('dp_profile_retry'),
              onPressed: () => context
                  .read<DeliveryProfileBloc>()
                  .add(const DeliveryProfileRetryEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: const Color(0xFF061208),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                DeliveryProfileStrings.of('retry', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined,
                color: Color(0xFF64748B), size: 54),
            const SizedBox(height: 16),
            Text(
              DeliveryProfileStrings.of('emptyTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryProfileStrings.of('emptySub', localeCode),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('dp_profile_refresh'),
              onPressed: () => context
                  .read<DeliveryProfileBloc>()
                  .add(const DeliveryProfileRetryEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primary,
                foregroundColor: const Color(0xFF061208),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                DeliveryProfileStrings.of('refresh', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
