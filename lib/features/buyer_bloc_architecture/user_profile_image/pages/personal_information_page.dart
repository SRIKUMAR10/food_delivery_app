import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../user_profile_image_Bloc.dart';
import '../user_profile_models.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _profileLoaded = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    context.read<UserProfileBloc>().add(const LoadProfileStarted());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateControllers(UserProfile profile) {
    if (!_profileLoaded) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _profileLoaded = true;
    } else {
      if (_nameController.text.isEmpty && profile.name.isNotEmpty) {
        _nameController.text = profile.name;
      }
      if (_emailController.text.isEmpty && profile.email.isNotEmpty) {
        _emailController.text = profile.email;
      }
      if (_phoneController.text.isEmpty && profile.phone.isNotEmpty) {
        _phoneController.text = profile.phone;
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  void _onSave(UserProfile? currentProfile) {
    setState(() {
      _nameError = _validateName(_nameController.text);
      _emailError = _validateEmail(_emailController.text);
      _phoneError = _validatePhone(_phoneController.text);
    });

    if (_nameError != null || _emailError != null || _phoneError != null) {
      return;
    }

    final profileToSave = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: currentProfile?.address ?? '',
      homeAddress: currentProfile?.homeAddress ?? '',
      workAddress: currentProfile?.workAddress ?? '',
      otherAddress: currentProfile?.otherAddress ?? '',
      selectedAddressType: currentProfile?.selectedAddressType ?? 'Home',
      imageUrl: currentProfile?.imageUrl,
    );
    context.read<UserProfileBloc>().add(ProfileSaved(profileToSave));
  }

  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
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
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEF2A39), Color(0xFFFF5E6B)],
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
              constraints:
                  const BoxConstraints(maxWidth: 550, maxHeight: 650),
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
                        'Personal Information',
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
        title: const Text('Personal Information'),
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
        if (state is ProfileError) {
          _showSnack(context, state.message, isError: true);
        } else if (state is ProfileLoaded) {
          _populateControllers(state.profile);
          if (state.successMessage != null) {
            _showSnack(context, state.successMessage!);
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.pop(context);
            });
          }
          if (state.errorMessage != null) {
            _showSnack(context, state.errorMessage!, isError: true);
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
        }

        if (isLoading && !_profileLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildModernField(
                    label: 'Account User ID (UID)',
                    controller: TextEditingController(text: context.read<UserProfileBloc>().authService.currentUserId ?? ''),
                    icon: Icons.fingerprint_rounded,
                    enabled: false,
                    key: const ValueKey('uidField'),
                  ),
                  _buildModernField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    errorText: _nameError,
                    key: const ValueKey('fullNameField'),
                  ),
                  _buildModernField(
                    label: 'Email Address',
                    controller: _emailController,
                    icon: Icons.mail_outline,
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    key: const ValueKey('emailField'),
                  ),
                  _buildModernField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    icon: Icons.phone_android_outlined,
                    errorText: _phoneError,
                    keyboardType: TextInputType.phone,
                    key: const ValueKey('phoneField'),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      key: const ValueKey('savePersonalInformationButton'),
                      onPressed: isSaving
                          ? null
                          : () => _onSave(profile),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52121),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                              'Save Changes',
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
          ),
        );
      },
    );
  }

  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? errorText,
    Key? key,
    bool enabled = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final showError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: showError ? const Color(0xFFE52121) : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: key,
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, size: 20, color: const Color(0xFFEF2A39)),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: showError
                    ? const Color(0xFFE52121)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: showError
                    ? const Color(0xFFE52121)
                    : const Color(0xFFEF2A39),
                width: 1.5,
              ),
            ),
          ),
          onChanged: (_) {
            if (showError) {
              setState(() {
                if (key == const ValueKey('fullNameField')) {
                  _nameError = null;
                } else if (key == const ValueKey('emailField')) {
                  _emailError = null;
                } else if (key == const ValueKey('phoneField')) {
                  _phoneError = null;
                }
              });
            }
          },
        ),
        if (errorText != null && errorText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFE52121),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 24),
      ],
    );
  }
}
