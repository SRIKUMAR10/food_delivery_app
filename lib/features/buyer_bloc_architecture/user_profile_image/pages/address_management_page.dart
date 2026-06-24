import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../user_profile_image_Bloc.dart';
import '../user_profile_models.dart';

class AddressManagementPage extends StatefulWidget {
  const AddressManagementPage({super.key});

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  // Local state for addresses so we can edit before saving
  String _homeAddress = '';
  String _workAddress = '';
  String _otherAddress = '';
  String _selectedAddressType = 'Home';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(const LoadProfileStarted());
  }

  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _editAddressDialog(String type, String currentAddress) {
    final TextEditingController controller = TextEditingController(
      text: currentAddress,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit $type Address',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter full address...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF2A39)),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (type == 'Home') _homeAddress = controller.text;
                if (type == 'Work') _workAddress = controller.text;
                if (type == 'Other') _otherAddress = controller.text;
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF2A39),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            _showSnack(context, state.message, isError: true);
          } else if (state is ProfileSuccessAction) {
            _showSnack(context, state.message, isError: false);
            if (state.message.contains('Profile saved')) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          bool isLoading = state is ProfileLoading;
          bool isSaving = false;
          UserProfile? profile;

          if (state is ProfileLoaded) {
            profile = state.profile;
            isSaving = state.isSaving;
            // Initialize local state if not done yet
            if (!_isInitialized) {
              _homeAddress = profile.homeAddress;
              _workAddress = profile.workAddress;
              _otherAddress = profile.otherAddress;
              _selectedAddressType = profile.selectedAddressType;
              if (_selectedAddressType.isEmpty) _selectedAddressType = 'Home';

              // Fallback for older profiles that only had 'address'
              if (_homeAddress.isEmpty &&
                  _workAddress.isEmpty &&
                  _otherAddress.isEmpty &&
                  profile.address.isNotEmpty) {
                _homeAddress = profile.address;
              }
              _isInitialized = true;
            }
          }

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEF2A39)),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return Center(
                child: Container(
                  width: isDesktop ? 600 : double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              _buildAddressItem('Home', _homeAddress),
                              Divider(
                                height: 1,
                                indent: 24,
                                endIndent: 24,
                                color: Colors.grey.withOpacity(0.1),
                              ),
                              _buildAddressItem('Work', _workAddress),
                              Divider(
                                height: 1,
                                indent: 24,
                                endIndent: 24,
                                color: Colors.grey.withOpacity(0.1),
                              ),
                              _buildAddressItem('Other', _otherAddress),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () {
                                  final selectedString =
                                      _selectedAddressType == 'Home'
                                      ? _homeAddress
                                      : _selectedAddressType == 'Work'
                                      ? _workAddress
                                      : _otherAddress;

                                  final profileToSave =
                                      profile?.copyWith(
                                        homeAddress: _homeAddress,
                                        workAddress: _workAddress,
                                        otherAddress: _otherAddress,
                                        selectedAddressType:
                                            _selectedAddressType,
                                        address: selectedString,
                                      ) ??
                                      UserProfile.empty().copyWith(
                                        homeAddress: _homeAddress,
                                        workAddress: _workAddress,
                                        otherAddress: _otherAddress,
                                        selectedAddressType:
                                            _selectedAddressType,
                                        address: selectedString,
                                      );
                                  context.read<UserProfileBloc>().add(
                                    ProfileSaved(profileToSave),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF2A39),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Save Address",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressItem(String title, String details) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAddressType = title;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _editAddressDialog(title, details),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    details.isEmpty ? 'Tap edit to add address' : details,
                    style: TextStyle(
                      fontSize: 14,
                      color: details.isEmpty
                          ? Colors.black38
                          : const Color(0xFF6C757D),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Radio<String>(
              value: title,
              groupValue: _selectedAddressType,
              activeColor: const Color(0xFFEF2A39),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedAddressType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
