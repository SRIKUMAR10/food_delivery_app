// lib/user_profile_image/user_profile_image_UI.dart
//
// The UI layer for the User Profile Drawer.
// Uses BlocConsumer to respond to state changes and rebuild the UI.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';
import 'transactions_page.dart';
import 'user_profile_image_Bloc.dart';
import 'user_profile_models.dart';

/// The User Profile Drawer that displays user info, edit form, and actions.
class UserProfileDrawer extends StatefulWidget {
  const UserProfileDrawer({super.key});

  @override
  State<UserProfileDrawer> createState() => _UserProfileDrawerState();
}

class _UserProfileDrawerState extends State<UserProfileDrawer> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    // Trigger the BLoC to fetch user data immediately upon initialization.
    context.read<UserProfileBloc>().add(const LoadProfileStarted());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Updates the text fields with the loaded profile data.
  void _populateControllers(UserProfile profile) {
    if (_nameController.text != profile.name)
      _nameController.text = profile.name;
    if (_emailController.text != profile.email)
      _emailController.text = profile.email;
    if (_phoneController.text != profile.phone)
      _phoneController.text = profile.phone;
    if (_addressController.text != profile.address)
      _addressController.text = profile.address;
  }

  /// Displays a modern, floating snackbar.
  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
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
    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          _showSnack(context, state.message, isError: true);
        } else if (state is ProfileSuccessAction) {
          _showSnack(context, state.message, isError: false);
          // Only navigate if the previous state wasn't indicating an upload.
          // This ensures we only pop back on a full profile save.
          if (state.message.contains('Profile saved')) {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, anim, secAnim) =>
                    const CurvedNavigationBarView(),
                transitionsBuilder: (context, anim, secAnim, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 500),
              ),
              (route) => false,
            );
          }
        } else if (state is SignOutSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const CurvedNavigationBarView(),
            ),
            (route) => false,
          );
        } else if (state is ProfileLoaded) {
          _populateControllers(state.profile);
        }
      },
      builder: (context, state) {
        bool isLoading = state is ProfileLoading;
        bool isSaving = false;
        double uploadProgress = 0.0;
        UserProfile? profile;

        if (state is ProfileLoaded) {
          profile = state.profile;
          uploadProgress = state.uploadProgress;
          isSaving = state.isSaving;
        }

        return Drawer(
          backgroundColor: const Color(0xFFF8F9FA), // Modern Light Background
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Profile Image Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              backgroundImage: profile?.imageUrl != null
                                  ? NetworkImage(profile!.imageUrl!)
                                  : null,
                              child: profile?.imageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xFFADB5BD),
                                    )
                                  : null,
                            ),
                          ),

                          // Circular progress overlay while image is uploading
                          if (uploadProgress > 0)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircularProgressIndicator(
                                        value: uploadProgress > 0
                                            ? uploadProgress
                                            : null,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        backgroundColor: Colors.white30,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(uploadProgress * 100).toInt()}%',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Camera Button for Image Selection
                          Positioned(
                            bottom: 0,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                if (uploadProgress == 0) {
                                  context.read<UserProfileBloc>().add(
                                    const ProfileImagePicked(),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF2A39),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Display Name and Email
                      Text(
                        _nameController.text.isEmpty
                            ? "Guest User"
                            : _nameController.text,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailController.text,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Fields wrapped in an Expanded container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 30),
                            children: [
                              _buildModernField(
                                "Full Name",
                                _nameController,
                                Icons.person_outline,
                              ),
                              _buildModernField(
                                "Email Address",
                                _emailController,
                                Icons.mail_outline,
                              ),
                              _buildModernField(
                                "Phone Number",
                                _phoneController,
                                Icons.phone_android_outlined,
                              ),
                              _buildModernField(
                                "Delivery Address",
                                _addressController,
                                Icons.location_on_outlined,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 10),

                              // View Transactions Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TransactionsPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE52121),
                                        Color(0xFFFF5252),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFE52121,
                                        ).withOpacity(0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'View Transactions',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Your payment history',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ),
                ),

                // Bottom Action Buttons (Save Profile & Sign Out)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        // Disable the button when it's actively saving.
                        child: ElevatedButton(
                          onPressed: isSaving || isLoading
                              ? null
                              : () {
                                  final profileToSave = UserProfile(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    phone: _phoneController.text,
                                    address: _addressController.text,
                                    imageUrl: profile?.imageUrl,
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
                              : Text(
                                  "Save Profile",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          context.read<UserProfileBloc>().add(
                            const SignOutRequested(),
                          );
                        },
                        child: Text(
                          "Sign Out",
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a customized text field equipped with modern design tokens.
  Widget _buildModernField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFFEF2A39)),
            filled: true,
            fillColor: enabled ? const Color(0xFFF8F9FA) : Colors.grey[100],
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
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
        ),
        // Adding breathing space between text fields.
        const SizedBox(height: 28),
      ],
    );
  }
}
