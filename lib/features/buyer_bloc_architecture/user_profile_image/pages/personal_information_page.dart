import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../user_profile_image_Bloc.dart';
import '../user_profile_models.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();


    // Trigger fetch if needed, though profile should already be loaded.
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
    if (_nameController.text != profile.name) {
      _nameController.text = profile.name;
    }
    if (_emailController.text != profile.email) {
      _emailController.text = profile.email;
    }
    if (_phoneController.text != profile.phone) {
      _phoneController.text = profile.phone;
    }

  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Personal Information'),
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
          } else if (state is ProfileLoaded) {
            _populateControllers(state.profile);
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

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildModernField("Full Name", _nameController, Icons.person_outline, key: const ValueKey('fullNameField')),
                  _buildModernField("Email Address", _emailController, Icons.mail_outline, key: const ValueKey('emailField')),
                  _buildModernField("Phone Number", _phoneController, Icons.phone_android_outlined, key: const ValueKey('phoneField')),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      key: const ValueKey('savePersonalInformationButton'),
                      onPressed: isSaving
                          ? null
                          : () {
                              final profileToSave = UserProfile(
                                name: _nameController.text,
                                email: _emailController.text,
                                phone: _phoneController.text,
                                address: profile?.address ?? '',
                                imageUrl: profile?.imageUrl,
                              );
                              context.read<UserProfileBloc>().add(ProfileSaved(profileToSave));
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
                              "Save Profile",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernField(
    String label,
    TextEditingController controller,
    IconData icon, {
    Key? key,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: key,
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFFEF2A39)),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
