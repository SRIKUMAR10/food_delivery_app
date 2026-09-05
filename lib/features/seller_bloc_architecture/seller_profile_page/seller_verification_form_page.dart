import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'seller_profile_page__bloc.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/repositories/i_seller_profile_repository.dart';
import '../../../repositories/firebase_seller_profile_repository.dart';
import '../../../core/services/google_places_service.dart';
import 'seller_google_address_search_dialog.dart';
import '../seller_auth_shared/onboarding_back_handler.dart';
import '../seller_auth_shared/seller_wizard_container.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';
import '../seller_ui_tokens.dart';
import '../../../core/services/gst_verification_service.dart';

class SellerVerificationFormPage extends StatelessWidget {
  final SellerProfilePageBloc? bloc;
  const SellerVerificationFormPage({Key? key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<SellerProfilePageBloc>.value(
        value: bloc!,
        child: const _SellerVerificationFormContentView(),
      );
    }

    try {
      final existingBloc = context.read<SellerProfilePageBloc>();
      return BlocProvider<SellerProfilePageBloc>.value(
        value: existingBloc,
        child: const _SellerVerificationFormContentView(),
      );
    } catch (_) {
      return BlocProvider<SellerProfilePageBloc>(
        create: (context) {
          IAuthService authService;
          ISellerProfileRepository profileRepo;
          try {
            authService = context.read<IAuthService>();
          } catch (_) {
            authService = FirebaseAuthService();
          }
          try {
            profileRepo = context.read<ISellerProfileRepository>();
          } catch (_) {
            profileRepo = FirebaseSellerProfileRepository();
          }
          return SellerProfilePageBloc(
            authService: authService,
            profileRepository: profileRepo,
          )..add(LoadProfile());
        },
        child: const _SellerVerificationFormContentView(),
      );
    }
  }
}

class _SellerVerificationFormContentView extends StatefulWidget {
  const _SellerVerificationFormContentView({Key? key}) : super(key: key);

  @override
  State<_SellerVerificationFormContentView> createState() =>
      _SellerVerificationFormContentViewState();
}

class _SellerVerificationFormContentViewState
    extends State<_SellerVerificationFormContentView> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  final _fssaiController = TextEditingController();
  final _panController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedTax; // For Tax Dropdown
  double? _pickedLatitude;
  double? _pickedLongitude;
  String? _pickedGoogleMapsUrl;
  bool _isLocatingGps = false;
  String? _uploadingDocType;

  @override
  void initState() {
    super.initState();
    try {
      final bloc = context.read<SellerProfilePageBloc>();
      _populateFromState(bloc.state, force: true);
    } catch (_) {}
  }

  void _populateFromState(SellerProfilePageState state, {bool force = false}) {
    if (state is ProfileLoaded) {
      if (_storeNameController.text.isEmpty || (force && state.storeName.isNotEmpty)) {
        _storeNameController.text = state.storeName;
      }
      if (_addressController.text.isEmpty || (force && state.address != null && state.address!.isNotEmpty)) {
        _addressController.text = state.address ?? '';
      }
      if (_gstController.text.isEmpty || (force && state.gstNumber != null && state.gstNumber!.isNotEmpty)) {
        _gstController.text = state.gstNumber ?? '';
      }
      if (_fssaiController.text.isEmpty || (force && state.fssaiLicense != null && state.fssaiLicense!.isNotEmpty)) {
        _fssaiController.text = state.fssaiLicense ?? '';
      }
      if (_panController.text.isEmpty || (force && state.panNumber != null && state.panNumber!.isNotEmpty)) {
        _panController.text = state.panNumber ?? '';
      }
      if (_bankAccountController.text.isEmpty || (force && state.bankAccountNumber != null && state.bankAccountNumber!.isNotEmpty)) {
        _bankAccountController.text = state.bankAccountNumber ?? '';
      }
      if (_ifscController.text.isEmpty || (force && state.ifscCode != null && state.ifscCode!.isNotEmpty)) {
        _ifscController.text = state.ifscCode ?? '';
      }
      if (_emailController.text.isEmpty || (force && state.email.isNotEmpty)) {
        _emailController.text = state.email;
      }
      if (_phoneController.text.isEmpty || (force && state.phone.isNotEmpty)) {
        _phoneController.text = state.phone;
      }
      if (_pickedLatitude == null && state.latitude != null) _pickedLatitude = state.latitude;
      if (_pickedLongitude == null && state.longitude != null) _pickedLongitude = state.longitude;
      if (_pickedGoogleMapsUrl == null && state.googleMapsUrl != null) _pickedGoogleMapsUrl = state.googleMapsUrl;
      if ((_selectedTax == null || force) &&
          state.taxConfiguration != null &&
          state.taxConfiguration!.isNotEmpty) {
        _selectedTax = state.taxConfiguration;
      }
    }
  }

  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _fssaiController.dispose();
    _panController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _hasAttemptedSubmit = false;

  bool _isDocUploaded(String? url) {
    return url != null && url.trim().isNotEmpty;
  }

  bool _areAllKycDocumentsUploaded(ProfileLoaded? state) {
    if (state == null) return false;
    final bool hasFssai = _isDocUploaded(state.fssaiCertificateUrl);
    final bool hasGst = _isDocUploaded(state.gstCertificateUrl);
    final bool hasPan = _isDocUploaded(state.panCardUrl);
    final bool hasCheque = _isDocUploaded(state.bankChequeUrl);
    return hasFssai && hasGst && hasPan && hasCheque;
  }

  List<String> _getMissingKycDocumentTitles(ProfileLoaded? state) {
    final List<String> missing = [];
    if (state == null) {
      return [
        'FSSAI Food License Certificate',
        'GST Registration Certificate',
        'PAN Card Certificate',
        'Bank Cancelled Cheque / Passbook',
      ];
    }
    if (!_isDocUploaded(state.fssaiCertificateUrl)) {
      missing.add('FSSAI Food License Certificate');
    }
    if (!_isDocUploaded(state.gstCertificateUrl)) {
      missing.add('GST Registration Certificate');
    }
    if (!_isDocUploaded(state.panCardUrl)) {
      missing.add('PAN Card Certificate');
    }
    if (!_isDocUploaded(state.bankChequeUrl)) {
      missing.add('Bank Cancelled Cheque / Passbook');
    }
    return missing;
  }

  void _submitForm() {
    setState(() {
      _hasAttemptedSubmit = true;
    });

    final bool isFormValid = _formKey.currentState?.validate() ?? false;
    final bloc = context.read<SellerProfilePageBloc>();
    final state = bloc.state is ProfileLoaded ? bloc.state as ProfileLoaded : null;
    final bool allDocsUploaded = _areAllKycDocumentsUploaded(state);

    if (!isFormValid || !allDocsUploaded) {
      final missingDocs = _getMissingKycDocumentTitles(state);
      String errorMessage;
      if (!isFormValid && !allDocsUploaded) {
        errorMessage = 'Please complete required form fields and upload all mandatory KYC documents (${missingDocs.length} missing).';
      } else if (!allDocsUploaded) {
        errorMessage = 'Please upload all mandatory KYC Document Certificates (${missingDocs.length} missing) before continuing.';
      } else {
        errorMessage = 'Please fix the highlighted errors in the form.';
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    final gstin = _gstController.text.trim().toUpperCase();
    if (gstin.isNotEmpty) {
      final check = GstVerificationService.validateGst(gstin, matchPan: _panController.text.trim());
      if (!check.isValid) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    check.errorMessage ?? 'Invalid GSTIN format',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    bloc.add(
      SubmitVerificationForm(
        storeName: _storeNameController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        gstNumber: gstin,
        taxConfiguration: _selectedTax ?? '',
        fssaiLicense: _fssaiController.text.trim(),
        bankAccountNumber: _bankAccountController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        latitude: _pickedLatitude,
        longitude: _pickedLongitude,
        googleMapsUrl: _pickedGoogleMapsUrl,
      ),
    );

    bloc.add(
      SubmitSellerKycDocuments(
        fssaiNumber: _fssaiController.text.trim(),
        fssaiCertificateUrl: state?.fssaiCertificateUrl,
        gstNumber: _gstController.text.trim(),
        gstCertificateUrl: state?.gstCertificateUrl,
        panNumber: _panController.text.trim(),
        panCardUrl: state?.panCardUrl,
        bankAccountNumber: _bankAccountController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        bankChequeUrl: state?.bankChequeUrl,
        shopLicenseUrl: state?.shopLicenseUrl,
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('KYC documents submitted! Continuing to Step 2: Store Details.'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushReplacementNamed(
      context,
      '/sellerStoreDetails',
      arguments: {'isOnboardingFlow': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerProfilePageBloc, SellerProfilePageState>(
      listener: (context, state) {
        _populateFromState(state);
      },
      builder: (context, state) {
        final profileLoaded = state is ProfileLoaded ? state : null;
        final kycStatus = profileLoaded?.kycStatus ?? 'pending';
        final isVerified = profileLoaded?.isVerified ?? false;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await OnboardingBackHandler.handleBack(context, isFirstStep: true);
          },
          child: SellerWizardContainer(
            stepIndex: 1,
            totalSteps: 8,
            stepBadge: 'Step 1 of 8 • KYC Compliance',
            title: 'Verify Account & KYC',
            subtitle: 'Upload mandatory government licenses and bank details for automated payouts',
            onBack: () => OnboardingBackHandler.handleBack(context, isFirstStep: true),
            bottomAction: SellerWizardPrimaryButton(
              buttonKey: const ValueKey('verification_submit_button'),
              label: 'Save & Continue to Store Details',
              onPressed: _submitForm,
            ),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 768;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKycStatusBanner(kycStatus, isVerified, profileLoaded?.kycRejectionReason),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Business Details'),
                      const SizedBox(height: 12),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Store Name',
                                _storeNameController,
                                fieldKey: const ValueKey('verification_store_name'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'FSSAI License Number',
                                _fssaiController,
                                fieldKey: const ValueKey('verification_fssai'),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildTextField(
                          'Store Name',
                          _storeNameController,
                          fieldKey: const ValueKey('verification_store_name'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          'FSSAI License Number',
                          _fssaiController,
                          fieldKey: const ValueKey('verification_fssai'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildAddressFieldWithPicker(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Contact Details'),
                      const SizedBox(height: 12),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Business Email',
                                _emailController,
                                fieldKey: const ValueKey('verification_email'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'Business Phone',
                                _phoneController,
                                isNumber: true,
                                fieldKey: const ValueKey('verification_phone'),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildTextField(
                          'Business Email',
                          _emailController,
                          fieldKey: const ValueKey('verification_email'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          'Business Phone',
                          _phoneController,
                          isNumber: true,
                          fieldKey: const ValueKey('verification_phone'),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildSectionTitle('Tax & Registration Details'),
                      const SizedBox(height: 12),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildGstFieldWithLiveVerification(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'PAN Card Number',
                                _panController,
                                fieldKey: const ValueKey('verification_pan'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTaxDropdown()),
                          ],
                        )
                      else ...[
                        _buildGstFieldWithLiveVerification(),
                        const SizedBox(height: 12),
                        _buildTextField(
                          'PAN Card Number',
                          _panController,
                          fieldKey: const ValueKey('verification_pan'),
                        ),
                        const SizedBox(height: 12),
                        _buildTaxDropdown(),
                      ],
                      const SizedBox(height: 24),
                      _buildSectionTitle('Bank Account Details'),
                      const SizedBox(height: 12),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Bank Account Number',
                                _bankAccountController,
                                isNumber: true,
                                fieldKey: const ValueKey('verification_bank'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'IFSC Code',
                                _ifscController,
                                fieldKey: const ValueKey('verification_ifsc'),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildTextField(
                          'Bank Account Number',
                          _bankAccountController,
                          isNumber: true,
                          fieldKey: const ValueKey('verification_bank'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          'IFSC Code',
                          _ifscController,
                          fieldKey: const ValueKey('verification_ifsc'),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildSectionTitle('KYC Document Certificates'),
                      const SizedBox(height: 12),
                      _buildKycDocumentCards(profileLoaded),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKycStatusBanner(String status, bool isVerified, String? reason) {
    Color bg;
    Color border;
    Color text;
    IconData icon;
    String label;
    String desc;

    if (isVerified || status == 'verified' || status == 'approved') {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFF10B981);
      text = const Color(0xFF065F46);
      icon = Icons.verified;
      label = 'KYC Verified';
      desc = 'Your restaurant KYC is verified and active for payouts.';
    } else if (status == 'in_review') {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFF59E0B);
      text = const Color(0xFF92400E);
      icon = Icons.hourglass_top;
      label = 'KYC In Review';
      desc = 'Your submitted documents are under verification by the admin team.';
    } else if (status == 'rejected') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFEF4444);
      text = const Color(0xFF991B1B);
      icon = Icons.error_outline;
      label = 'KYC Rejected';
      desc = reason != null && reason.isNotEmpty
          ? 'Reason: $reason. Please re-upload updated certificates.'
          : 'Documents were rejected. Please check and re-upload.';
    } else {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFF3B82F6);
      text = const Color(0xFF1E40AF);
      icon = Icons.info_outline;
      label = 'KYC Pending';
      desc = 'Please complete your KYC document upload to enable automated payouts.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: border, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 13, color: text.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycDocumentCards(ProfileLoaded? state) {
    final isGeneralUploading = state?.isKycUploading ?? false;
    final bool hasFssai = _isDocUploaded(state?.fssaiCertificateUrl);
    final bool hasGst = _isDocUploaded(state?.gstCertificateUrl);
    final bool hasPan = _isDocUploaded(state?.panCardUrl);
    final bool hasCheque = _isDocUploaded(state?.bankChequeUrl);

    int uploadedCount = 0;
    if (hasFssai) uploadedCount++;
    if (hasGst) uploadedCount++;
    if (hasPan) uploadedCount++;
    if (hasCheque) uploadedCount++;

    final bool allDone = uploadedCount == 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: allDone ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: allDone ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                allDone ? Icons.check_circle_rounded : Icons.folder_shared_outlined,
                size: 20,
                color: allDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  allDone
                      ? 'All 4 KYC Document Certificates Uploaded'
                      : 'Upload Mandatory Document Certificates ($uploadedCount of 4 uploaded)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: allDone ? const Color(0xFF065F46) : const Color(0xFF334155),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: allDone ? SellerUiTokens.success : SellerUiTokens.borderMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$uploadedCount/4',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: allDone ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_hasAttemptedSubmit && !allDone)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.6)),
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All 4 certificate documents are mandatory. Please upload all missing certificates below to proceed.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        _buildDocUploadCard(
          title: 'FSSAI Food License Certificate',
          docType: 'fssai_certificate',
          url: state?.fssaiCertificateUrl,
          isUploaded: hasFssai,
          isUploading: _uploadingDocType == 'fssai_certificate' || (_uploadingDocType == null && isGeneralUploading),
        ),
        const SizedBox(height: 14),
        _buildDocUploadCard(
          title: 'GST Registration Certificate',
          docType: 'gst_certificate',
          url: state?.gstCertificateUrl,
          isUploaded: hasGst,
          isUploading: _uploadingDocType == 'gst_certificate' || (_uploadingDocType == null && isGeneralUploading),
        ),
        const SizedBox(height: 14),
        _buildDocUploadCard(
          title: 'PAN Card Certificate',
          docType: 'pan_card',
          url: state?.panCardUrl,
          isUploaded: hasPan,
          isUploading: _uploadingDocType == 'pan_card' || (_uploadingDocType == null && isGeneralUploading),
        ),
        const SizedBox(height: 14),
        _buildDocUploadCard(
          title: 'Bank Cancelled Cheque / Passbook',
          docType: 'bank_cheque',
          url: state?.bankChequeUrl,
          isUploaded: hasCheque,
          isUploading: _uploadingDocType == 'bank_cheque' || (_uploadingDocType == null && isGeneralUploading),
        ),
      ],
    );
  }

  Widget _buildDocUploadCard({
    required String title,
    required String docType,
    required String? url,
    required bool isUploaded,
    required bool isUploading,
  }) {
    final bool hasValidUrl = isUploaded && url != null && url.isNotEmpty;
    final bool isMissingError = _hasAttemptedSubmit && !hasValidUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: ValueKey('kyc_card_$docType'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMissingError ? const Color(0xFFFFFBFB) : Colors.white,
            borderRadius: BorderRadius.circular(SellerUiTokens.radiusCard),
            border: Border.all(
              color: isMissingError
                  ? SellerUiTokens.error
                  : (hasValidUrl ? SellerUiTokens.success : SellerUiTokens.borderMuted),
              width: (isMissingError || hasValidUrl) ? 1.5 : 1.0,
            ),
            boxShadow: hasValidUrl
                ? [
                    BoxShadow(
                      color: SellerUiTokens.success.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : (isMissingError
                    ? [
                        BoxShadow(
                          color: SellerUiTokens.error.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null),
          ),
          child: Row(
            children: [
              // Left-side live thumbnail / document preview
              GestureDetector(
                key: ValueKey('kyc_thumbnail_$docType'),
                onTap: hasValidUrl
                    ? () => _showDocumentPreview(context, title, url, docType: docType)
                    : () => _pickAndUploadKycDocument(context, docType, title),
                child: _buildLeftThumbnailPreview(
                  url: url,
                  isUploaded: hasValidUrl,
                  isUploading: isUploading,
                  title: title,
                  docType: docType,
                ),
              ),
              const SizedBox(width: 14),
              // Document details and title
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hasValidUrl
                      ? () => _showDocumentPreview(context, title, url, docType: docType)
                      : () => _pickAndUploadKycDocument(context, docType, title),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasValidUrl
                                      ? const Color(0xFF10B981)
                                      : (isMissingError ? const Color(0xFFEF4444) : Colors.grey.shade400),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                hasValidUrl ? 'Document Uploaded' : 'Not uploaded yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasValidUrl
                                      ? const Color(0xFF059669)
                                      : (isMissingError ? const Color(0xFFDC2626) : Colors.grey.shade600),
                                  fontWeight:
                                      hasValidUrl ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          if (hasValidUrl)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 11,
                                    color: Color(0xFF3B82F6),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Tap to view',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isUploading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFE50914),
                  ),
                )
              else ...[
                if (hasValidUrl)
                  IconButton(
                    key: ValueKey('kyc_preview_btn_$docType'),
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 20,
                      color: Color(0xFF3B82F6),
                    ),
                    tooltip: 'Preview Document',
                    onPressed: () =>
                        _showDocumentPreview(context, title, url, docType: docType),
                  ),
                OutlinedButton.icon(
                  key: ValueKey('kyc_upload_btn_$docType'),
                  onPressed: () =>
                      _pickAndUploadKycDocument(context, docType, title),
                  icon: Icon(
                    hasValidUrl ? Icons.refresh : Icons.file_upload_outlined,
                    size: 16,
                  ),
                  label: Text(hasValidUrl ? 'Re-upload' : 'Upload'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasValidUrl
                        ? const Color(0xFF059669)
                        : const Color(0xFFE50914),
                    side: BorderSide(
                      color: hasValidUrl
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE50914),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isMissingError)
          Padding(
            key: ValueKey('kyc_error_alert_$docType'),
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '* Mandatory document. Please select and upload $title.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLeftThumbnailPreview({
    required String? url,
    required bool isUploaded,
    required bool isUploading,
    required String title,
    required String docType,
  }) {
    const double size = 52.0;

    if (isUploading) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE50914).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Color(0xFFE50914),
            ),
          ),
        ),
      );
    }

    if (isUploaded && url != null && url.isNotEmpty) {
      final isPdf = url.toLowerCase().contains('.pdf');
      if (isPdf) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFE50914).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.picture_as_pdf_rounded,
                color: Color(0xFFE50914),
                size: 24,
              ),
              SizedBox(height: 2),
              Text(
                'PDF',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE50914),
                ),
              ),
            ],
          ),
        );
      }

      // Live Image Thumbnail Preview
      return Tooltip(
        message: 'Tap to preview $title',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF10B981),
              width: 1.5,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6.5),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFECFDF5),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default Not Uploaded Placeholder (matching design screenshot)
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.upload_file_outlined,
          color: Color(0xFF64748B),
          size: 24,
        ),
      ),
    );
  }

  Future<void> _pickAndUploadKycDocument(
    BuildContext context,
    String docType,
    String docTitle,
  ) async {
    final bloc = context.read<SellerProfilePageBloc>();
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (isMobile) {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Upload $docTitle',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF3B82F6)),
                  ),
                  title: const Text('Take Photo (Camera)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Capture certificate directly with camera', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickWithImagePicker(bloc, docType, docTitle, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Color(0xFF10B981)),
                  ),
                  title: const Text('Photo Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Choose image from device photo gallery', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickWithImagePicker(bloc, docType, docTitle, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_open_outlined, color: Color(0xFFE50914)),
                  ),
                  title: const Text('Browse Files (Image / PDF)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Select file from device documents storage', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickWithFilePicker(bloc, docType, docTitle);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    } else {
      await _pickWithFilePicker(bloc, docType, docTitle);
    }
  }

  Future<void> _pickWithImagePicker(
    SellerProfilePageBloc bloc,
    String docType,
    String docTitle,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        setState(() => _uploadingDocType = docType);
        final bytes = await file.readAsBytes();
        final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        bloc.add(
          UploadKycDocumentFileEvent(
            docType: docType,
            fileName: fileName,
            fileBytes: bytes,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$docTitle uploaded successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingDocType = null);
    }
  }

  Future<void> _pickWithFilePicker(
    SellerProfilePageBloc bloc,
    String docType,
    String docTitle,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        Uint8List? bytes = platformFile.bytes;
        if (bytes == null && platformFile.path != null && !kIsWeb) {
          final f = File(platformFile.path!);
          if (await f.exists()) {
            bytes = await f.readAsBytes();
          }
        }

        if (bytes != null && bytes.isNotEmpty) {
          setState(() => _uploadingDocType = docType);
          final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}_${platformFile.name}';
          bloc.add(
            UploadKycDocumentFileEvent(
              docType: docType,
              fileName: fileName,
              fileBytes: bytes,
            ),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$docTitle uploaded successfully!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      try {
        final picker = ImagePicker();
        final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (file != null) {
          setState(() => _uploadingDocType = docType);
          final bytes = await file.readAsBytes();
          final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          bloc.add(
            UploadKycDocumentFileEvent(
              docType: docType,
              fileName: fileName,
              fileBytes: bytes,
            ),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$docTitle uploaded successfully!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        }
      } catch (innerError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to select file: $innerError'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _uploadingDocType = null);
    }
  }

  void _showDocumentPreview(
    BuildContext context,
    String title,
    String url, {
    String? docType,
  }) {
    final isPdf = url.toLowerCase().contains('.pdf');

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 680, maxHeight: 680),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPdf
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.verified_outlined,
                          color: isPdf
                              ? const Color(0xFFE50914)
                              : const Color(0xFF10B981),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Uploaded Certificate Document',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (docType != null)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _pickAndUploadKycDocument(context, docType, title);
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Re-upload'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFE50914),
                          ),
                        ),
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Document Content / Zoomable Image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF0F172A),
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.5,
                          panEnabled: true,
                          scaleEnabled: true,
                          child: Center(
                            child: isPdf
                                ? Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.picture_as_pdf,
                                          size: 72,
                                          color: Color(0xFFE50914),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'PDF document format uploaded successfully',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            url,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFFCBD5E1),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Image.network(
                                    url,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, progress) {
                                      if (progress == null) return child;
                                      final double? expected = progress
                                          .expectedTotalBytes
                                          ?.toDouble();
                                      final double? current = progress
                                          .cumulativeBytesLoaded
                                          .toDouble();
                                      final double? value = (expected != null &&
                                              expected > 0)
                                          ? current! / expected
                                          : null;
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value: value,
                                              color: const Color(0xFFE50914),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Loading high quality preview...',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                        Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.broken_image_outlined,
                                            size: 56,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Unable to preview certificate image',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'The document is uploaded. You can re-upload if needed.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Footer hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.zoom_in,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tip: Pinch or double-tap image to zoom in/out',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildGstFieldWithLiveVerification() {
    final text = _gstController.text.trim().toUpperCase();
    final result = text.isNotEmpty
        ? GstVerificationService.validateGst(text, matchPan: _panController.text.trim())
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: const ValueKey('verification_gst'),
          controller: _gstController,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'GST Number (Optional)',
            hintText: 'e.g. 33AAAAA0000A1Z5',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: text.isNotEmpty
                ? Icon(
                    result?.isValid == true ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    color: result?.isValid == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() {});
          },
          validator: (val) {
            if (val == null || val.trim().isEmpty) return null;
            final check = GstVerificationService.validateGst(val, matchPan: _panController.text.trim());
            if (!check.isValid) {
              return check.errorMessage ?? 'Please enter a valid 15-character GSTIN';
            }
            return null;
          },
        ),
        if (result != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: result.isValid ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: result.isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.isValid ? Icons.verified_outlined : Icons.error_outline_rounded,
                  size: 14,
                  color: result.isValid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    result.isValid
                        ? '${result.stateName} (${result.stateCode}) • ${result.entityType}${result.isChecksumValid ? " • Verified" : ""}'
                        : (result.errorMessage ?? 'Invalid GSTIN format'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: result.isValid ? const Color(0xFF065F46) : const Color(0xFF991B1B),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumber = false,
    bool isOptional = false,
    String? Function(String?)? validator,
    Key? fieldKey,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textCapitalization: (label.contains('PAN') || label.contains('IFSC') || label.contains('GST'))
          ? TextCapitalization.characters
          : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: isOptional ? '$label (Optional)' : '$label *',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: validator ??
          (value) {
            if (label.contains('GST')) {
              if (value != null && value.trim().isNotEmpty) {
                final result = GstVerificationService.validateGst(
                  value,
                  matchPan: _panController.text.trim(),
                );
                if (!result.isValid) {
                  return result.errorMessage ?? 'Please enter a valid 15-character GSTIN';
                }
              }
              return null;
            }
            if (isOptional) return null;
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label';
            }
            if (label.contains('Email')) {
              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
            } else if (label.contains('Phone')) {
              final phoneDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (phoneDigits.length < 10) {
                return 'Please enter a valid 10-digit phone number';
              }
            } else if (label.contains('FSSAI')) {
              final fssaiDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (fssaiDigits.length != 14) {
                return 'FSSAI License number must be exactly 14 digits';
              }
            } else if (label.contains('PAN Card')) {
              final panRegex = RegExp(r'^[A-Za-z]{5}[0-9]{4}[A-Za-z]{1}$');
              if (!panRegex.hasMatch(value.trim())) {
                return 'Enter valid PAN (e.g. ABCDE1234F)';
              }
            } else if (label.contains('IFSC')) {
              final ifscRegex = RegExp(r'^[A-Za-z]{4}0[A-Za-z0-9]{6}$');
              if (!ifscRegex.hasMatch(value.trim())) {
                return 'Enter valid 11-char IFSC code (e.g. HDFC0001234)';
              }
            }
            return null;
          },
    );
  }

  Widget _buildAddressFieldWithPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: const ValueKey('verification_address'),
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Full Address (GPS Linked)',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const ValueKey('verification_gps_button'),
                  tooltip: 'Detect GPS Location',
                  icon: _isLocatingGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE50914),
                          ),
                        )
                      : const Icon(Icons.my_location_rounded, color: Color(0xFFE50914), size: 20),
                  onPressed: _isLocatingGps
                      ? null
                      : () async {
                          setState(() => _isLocatingGps = true);
                          try {
                            final details =
                                await GooglePlacesService.instance.getCurrentLocationAddress();
                            if (details != null && mounted) {
                              final lat = details.latitude ?? 13.0827;
                              final lng = details.longitude ?? 80.2707;
                              setState(() {
                                _addressController.text = details.formattedAddress;
                                _pickedLatitude = lat;
                                _pickedLongitude = lng;
                                _pickedGoogleMapsUrl = 'https://www.google.com/maps?q=$lat,$lng';
                                _isLocatingGps = false;
                              });
                            } else if (mounted) {
                              setState(() => _isLocatingGps = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not retrieve GPS location. Please check location permissions.',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => _isLocatingGps = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Location error: $e')),
                              );
                            }
                          }
                        },
                ),
                IconButton(
                  key: const ValueKey('verification_map_button'),
                  tooltip: 'Pick on Map',
                  icon: const Icon(Icons.map_outlined, color: Color(0xFFE50914), size: 20),
                  onPressed: () async {
                    final result = await SellerGoogleAddressSearchDialog.show(
                      context: context,
                      addressType: 'Restaurant',
                      currentAddress: _addressController.text.trim(),
                      onAddressSelected: (selection) {
                        _addressController.text = selection.address;
                        _pickedLatitude = selection.latitude;
                        _pickedLongitude = selection.longitude;
                        _pickedGoogleMapsUrl = selection.effectiveGoogleMapsUrl;
                      },
                    );
                    if (result != null) {
                      _addressController.text = result.address;
                      _pickedLatitude = result.latitude;
                      _pickedLongitude = result.longitude;
                      _pickedGoogleMapsUrl = result.effectiveGoogleMapsUrl;
                    }
                  },
                ),
              ],
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Full Address';
            }
            return null;
          },
        ),
        if (_pickedLatitude != null && _pickedLongitude != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF059669)),
                const SizedBox(width: 6),
                Text(
                  'GPS Linked: ${_pickedLatitude!.toStringAsFixed(4)}, ${_pickedLongitude!.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaxDropdown() {
    return DropdownButtonFormField<String>(
      key: const ValueKey('verification_tax'),
      initialValue: _selectedTax,
      decoration: InputDecoration(
        labelText: 'Tax Configurations',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [
        DropdownMenuItem(value: '0%', child: Text('0% GST')),
        DropdownMenuItem(value: '5%', child: Text('5% GST')),
        DropdownMenuItem(value: '12%', child: Text('12% GST')),
        DropdownMenuItem(value: '18%', child: Text('18% GST')),
        DropdownMenuItem(value: '28%', child: Text('28% GST')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedTax = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select Tax Configuration';
        }
        return null;
      },
    );
  }
}
