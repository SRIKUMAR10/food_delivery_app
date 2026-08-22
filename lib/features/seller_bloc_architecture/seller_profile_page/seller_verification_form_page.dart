import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_profile_page__bloc.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';
import '../../../core/services/google_places_service.dart';
import 'seller_google_address_search_dialog.dart';

class SellerVerificationFormPage extends StatefulWidget {
  const SellerVerificationFormPage({Key? key}) : super(key: key);

  @override
  State<SellerVerificationFormPage> createState() =>
      _SellerVerificationFormPageState();
}

class _SellerVerificationFormPageState
    extends State<SellerVerificationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  final _fssaiController = TextEditingController();
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
    final bloc = context.read<SellerProfilePageBloc>();
    if (bloc.state is ProfileLoaded) {
      final state = bloc.state as ProfileLoaded;
      _storeNameController.text = state.storeName;
      _addressController.text = state.address ?? '';
      _gstController.text = state.gstNumber ?? '';
      _fssaiController.text = state.fssaiLicense ?? '';
      _bankAccountController.text = state.bankAccountNumber ?? '';
      _ifscController.text = state.ifscCode ?? '';
      _emailController.text = state.email;
      _phoneController.text = state.phone;
      _selectedTax =
          (state.taxConfiguration != null && state.taxConfiguration!.isNotEmpty)
          ? state.taxConfiguration
          : null;
    }
  }

  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _fssaiController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<SellerProfilePageBloc>().add(
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification form submitted successfully!'),
        ),
      );
      Navigator.pop(context); // Go back to Profile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Verify Account',
          style: TextStyle(color: Colors.black),
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
                  _buildSectionTitle('Business Details'),
                  const SizedBox(height: 12),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Store / Restaurant Name',
                            _storeNameController,
                            fieldKey: const ValueKey('verification_store_name'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'FSSAI License',
                            _fssaiController,
                            fieldKey: const ValueKey('verification_fssai'),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildTextField(
                      'Store / Restaurant Name',
                      _storeNameController,
                      fieldKey: const ValueKey('verification_store_name'),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'FSSAI License',
                      _fssaiController,
                      fieldKey: const ValueKey('verification_fssai'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildAddressFieldWithPicker(),
                  const SizedBox(height: 12),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Email Address',
                            _emailController,
                            fieldKey: const ValueKey('verification_email'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'Phone Number',
                            _phoneController,
                            isNumber: true,
                            fieldKey: const ValueKey('verification_phone'),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildTextField(
                      'Email Address',
                      _emailController,
                      fieldKey: const ValueKey('verification_email'),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Phone Number',
                      _phoneController,
                      isNumber: true,
                      fieldKey: const ValueKey('verification_phone'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField('GST Number', _gstController, fieldKey: const ValueKey('verification_gst')),
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
                    _buildTaxDropdown(),
                  ],

                  const SizedBox(height: 32),
                  _buildSectionTitle('Bank Details'),
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
    return TextFormField(
      key: const ValueKey('verification_address'),
      controller: _addressController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Full Address',
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
