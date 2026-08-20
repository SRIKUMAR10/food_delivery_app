import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/widgets/app_snack_bar.dart';

import '../user_profile_image_Bloc.dart';
import '../user_profile_models.dart';
import 'google_address_search_dialog.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

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
    final currentState = context.read<UserProfileBloc>().state;
    if (currentState is ProfileLoaded) {
      _initFromProfile(currentState.profile);
    }
    context.read<UserProfileBloc>().add(const LoadProfileStarted());
  }

  void _initFromProfile(UserProfile profile) {
    _homeAddress = profile.homeAddress;
    _workAddress = profile.workAddress;
    _otherAddress = profile.otherAddress;
    _selectedAddressType = profile.selectedAddressType;
    if (_selectedAddressType.isEmpty) _selectedAddressType = 'Home';

    if (_homeAddress.isEmpty &&
        _workAddress.isEmpty &&
        _otherAddress.isEmpty &&
        profile.address.isNotEmpty) {
      _homeAddress = profile.address;
    }
    _isInitialized = true;
  }

  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    AppSnackBar.show(context, message, isError: isError);
  }

  void _editAddressDialog(String type, String currentAddress) {
    GoogleAddressSearchDialog.show(
      context: context,
      addressType: type,
      currentAddress: currentAddress,
      onAddressSelected: (newAddress) {
        setState(() {
          if (type == 'Home') _homeAddress = newAddress;
          if (type == 'Work') _workAddress = newAddress;
          if (type == 'Other') _otherAddress = newAddress;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [BuyerAppColors.primary, Color(0xFFFF5E6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
              child: Card(
                elevation: 12,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      centerTitle: true,
                      title: const Text(
                        'My Addresses',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      automaticallyImplyLeading: false,
                    ),
                    body: _buildFormBody(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildFormBody(context),
    );
  }

  Widget _buildFormBody(BuildContext context) {
    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && !_isInitialized) {
          setState(() {
            _initFromProfile(state.profile);
          });
        }

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
          if (!_isInitialized) {
            _homeAddress = profile.homeAddress;
            _workAddress = profile.workAddress;
            _otherAddress = profile.otherAddress;
            _selectedAddressType = profile.selectedAddressType;
            if (_selectedAddressType.isEmpty) _selectedAddressType = 'Home';

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
            child: CircularProgressIndicator(color: BuyerAppColors.primary),
          );
        }

        return Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
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
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                        _buildAddressItem('Work', _workAddress),
                        Divider(
                          height: 1,
                          indent: 24,
                          endIndent: 24,
                          color: Colors.grey.withValues(alpha: 0.1),
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
                    key: const ValueKey('saveAddressChangesButton'),
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
                                  selectedAddressType: _selectedAddressType,
                                  address: selectedString,
                                ) ??
                                UserProfile.empty().copyWith(
                                  homeAddress: _homeAddress,
                                  workAddress: _workAddress,
                                  otherAddress: _otherAddress,
                                  selectedAddressType: _selectedAddressType,
                                  address: selectedString,
                                );
                            context.read<UserProfileBloc>().add(
                              ProfileSaved(profileToSave),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BuyerAppColors.primaryDeep,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressItem(String title, String details) {
    return InkWell(
      key: ValueKey('addressTile_$title'),
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
                        key: ValueKey('editAddressButton_$title'),
                        onTap: () => _editAddressDialog(title, details),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
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
            // ignore: deprecated_member_use
            Radio<String>(
              key: ValueKey('addressRadio_$title'),
              value: title,
              groupValue: _selectedAddressType,
              activeColor: BuyerAppColors.primary,
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
