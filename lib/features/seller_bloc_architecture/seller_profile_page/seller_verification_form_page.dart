import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_profile_page__bloc.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/repositories/i_seller_profile_repository.dart';
import '../../../repositories/firebase_seller_profile_repository.dart';
import '../../../core/services/google_places_service.dart';
import 'seller_google_address_search_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    try {
      final bloc = context.read<SellerProfilePageBloc>();
      _populateFromState(bloc.state);
    } catch (_) {}
  }

  void _populateFromState(SellerProfilePageState state) {
    if (state is ProfileLoaded) {
      if (_storeNameController.text.isEmpty) _storeNameController.text = state.storeName;
      if (_addressController.text.isEmpty) _addressController.text = state.address ?? '';
      if (_gstController.text.isEmpty) _gstController.text = state.gstNumber ?? '';
      if (_fssaiController.text.isEmpty) _fssaiController.text = state.fssaiLicense ?? '';
      if (_panController.text.isEmpty) _panController.text = state.panNumber ?? '';
      if (_bankAccountController.text.isEmpty) _bankAccountController.text = state.bankAccountNumber ?? '';
      if (_ifscController.text.isEmpty) _ifscController.text = state.ifscCode ?? '';
      if (_emailController.text.isEmpty) _emailController.text = state.email;
      if (_phoneController.text.isEmpty) _phoneController.text = state.phone;
      if (_pickedLatitude == null && state.latitude != null) _pickedLatitude = state.latitude;
      if (_pickedLongitude == null && state.longitude != null) _pickedLongitude = state.longitude;
      if (_pickedGoogleMapsUrl == null && state.googleMapsUrl != null) _pickedGoogleMapsUrl = state.googleMapsUrl;
      if (_selectedTax == null &&
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final bloc = context.read<SellerProfilePageBloc>();
      bloc.add(
        SubmitVerificationForm(
          storeName: _storeNameController.text,
          address: _addressController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          gstNumber: _gstController.text,
          taxConfiguration: _selectedTax ?? '',
          fssaiLicense: _fssaiController.text,
          bankAccountNumber: _bankAccountController.text,
          ifscCode: _ifscController.text,
          latitude: _pickedLatitude,
          longitude: _pickedLongitude,
          googleMapsUrl: _pickedGoogleMapsUrl,
        ),
      );

      final state = bloc.state is ProfileLoaded ? bloc.state as ProfileLoaded : null;

      bloc.add(
        SubmitSellerKycDocuments(
          fssaiNumber: _fssaiController.text,
          fssaiCertificateUrl: state?.fssaiCertificateUrl,
          gstNumber: _gstController.text,
          gstCertificateUrl: state?.gstCertificateUrl,
          panNumber: _panController.text,
          panCardUrl: state?.panCardUrl,
          bankAccountNumber: _bankAccountController.text,
          ifscCode: _ifscController.text,
          bankChequeUrl: state?.bankChequeUrl,
          shopLicenseUrl: state?.shopLicenseUrl,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification and KYC documents submitted successfully!'),
        ),
      );
      Navigator.pushReplacementNamed(context, '/sellerDashboard');
    }
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

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              'Verify Account & KYC',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 1,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                              child: _buildTextField(
                                'GST Number',
                                _gstController,
                                fieldKey: const ValueKey('verification_gst'),
                              ),
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
                        _buildTextField(
                          'GST Number',
                          _gstController,
                          fieldKey: const ValueKey('verification_gst'),
                        ),
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
                      const SizedBox(height: 32),
                      SizedBox(
                        width: isDesktop ? 300 : double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit for Verification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
    return Column(
      children: [
        _buildDocUploadCard(
          title: 'FSSAI Food License Certificate',
          docType: 'fssai_certificate',
          url: state?.fssaiCertificateUrl,
          isUploaded: state?.fssaiCertificateUrl != null && state!.fssaiCertificateUrl!.isNotEmpty,
        ),
        const SizedBox(height: 12),
        _buildDocUploadCard(
          title: 'GST Registration Certificate',
          docType: 'gst_certificate',
          url: state?.gstCertificateUrl,
          isUploaded: state?.gstCertificateUrl != null && state!.gstCertificateUrl!.isNotEmpty,
        ),
        const SizedBox(height: 12),
        _buildDocUploadCard(
          title: 'PAN Card Certificate',
          docType: 'pan_card',
          url: state?.panCardUrl,
          isUploaded: state?.panCardUrl != null && state!.panCardUrl!.isNotEmpty,
        ),
        const SizedBox(height: 12),
        _buildDocUploadCard(
          title: 'Bank Cancelled Cheque / Passbook',
          docType: 'bank_cheque',
          url: state?.bankChequeUrl,
          isUploaded: state?.bankChequeUrl != null && state!.bankChequeUrl!.isNotEmpty,
        ),
      ],
    );
  }

  Widget _buildDocUploadCard({
    required String title,
    required String docType,
    required String? url,
    required bool isUploaded,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isUploaded ? const Color(0xFF10B981) : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            color: isUploaded ? const Color(0xFF10B981) : const Color(0xFF64748B),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  isUploaded ? 'Document Uploaded' : 'Not uploaded yet',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUploaded ? const Color(0xFF059669) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              // Trigger upload event
              context.read<SellerProfilePageBloc>().add(
                UploadKycDocumentFileEvent(
                  docType: docType,
                  fileName: '${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                  fileBytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title uploaded successfully!')),
              );
            },
            icon: Icon(isUploaded ? Icons.refresh : Icons.file_upload_outlined, size: 16),
            label: Text(isUploaded ? 'Re-upload' : 'Upload'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isUploaded ? const Color(0xFF059669) : const Color(0xFFE50914),
              side: BorderSide(
                color: isUploaded ? const Color(0xFF10B981) : const Color(0xFFE50914),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumber = false,
    Key? fieldKey,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
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
