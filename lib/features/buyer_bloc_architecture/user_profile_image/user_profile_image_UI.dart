import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Order Page/order_UI.dart';
import '../Order Page/order_repository.dart';
import 'transactions_page.dart';
import 'user_profile_image_Bloc.dart';
import 'user_profile_models.dart';

// Child Pages
import 'pages/personal_information_page.dart';
import 'pages/address_management_page.dart';
import 'pages/payment_methods_page.dart';

import 'pages/notification_settings_page.dart';
import 'pages/app_settings_page.dart';
import 'pages/help_support_page.dart';

class UserProfileDrawer extends StatefulWidget {
  const UserProfileDrawer({super.key});

  @override
  State<UserProfileDrawer> createState() => _UserProfileDrawerState();
}

class _UserProfileDrawerState extends State<UserProfileDrawer> {
  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(const LoadProfileStarted());
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
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
              Navigator.pop(ctx);
              context.read<UserProfileBloc>().add(const SignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF2A39),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          _showSnack(context, state.message, isError: true);
        } else if (state is SignOutSuccess) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      builder: (context, state) {
        double uploadProgress = 0.0;
        UserProfile? profile;

        if (state is ProfileLoaded) {
          profile = state.profile;
          uploadProgress = state.uploadProgress;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA), // Modern light background
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Profile'),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildDesktopLayout(profile, uploadProgress);
              }
              return _buildMobileLayout(profile, uploadProgress);
            },
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(UserProfile? profile, double uploadProgress) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildProfileHeader(profile, uploadProgress),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSettingsMenus(),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildLogoutButton(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(UserProfile? profile, double uploadProgress) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Profile Info & Logout)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProfileHeader(profile, uploadProgress),
                  const SizedBox(height: 64),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
          // Right Column (Settings Menus)
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildSettingsMenus(),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Hero(
              tag: 'profile_image_preview',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFFEF2A39)),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 48,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? profile, double uploadProgress) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (profile?.imageUrl != null && uploadProgress == 0) {
                  _showImagePreview(context, profile!.imageUrl!);
                }
              },
              child: Hero(
                tag: 'profile_image_preview',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: profile?.imageUrl != null
                        ? NetworkImage(profile!.imageUrl!)
                        : null,
                    onBackgroundImageError: profile?.imageUrl != null
                        ? (_, __) {}
                        : null,
                    child: profile?.imageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFFADB5BD),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            if (uploadProgress > 0)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: uploadProgress > 0 ? uploadProgress : null,
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  if (uploadProgress == 0) {
                    context.read<UserProfileBloc>().add(
                      const ProfileImagePicked(),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF2A39),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
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
        const SizedBox(height: 20),
        Text(
          profile?.name.isNotEmpty == true ? profile!.name : 'Guest User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF212529),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          profile?.email ?? '',
          style: const TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSettingsMenus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Account Settings'),
        _buildMenuCard([
          _buildMenuItem(
            key: const ValueKey('personalInformationMenuItem'),
            icon: Icons.person_outline,
            title: 'Personal Information',
            onTap: () {
              final bloc = context.read<UserProfileBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const PersonalInformationPage(),
                  ),
                ),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            onTap: () {
              final bloc = context.read<UserProfileBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const AddressManagementPage(),
                  ),
                ),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
              );
            },
          ),
        ]),
        const SizedBox(height: 24),

        _buildSectionHeader('Activity'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'My Orders',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderPageUI(orderRepository: OrderRepository()),
              ),
            ),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsPage(),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        _buildSectionHeader('Account Tools'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.history_rounded,
            title: 'View Transactions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsPage()),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        _buildSectionHeader('App Settings'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppSettingsPage()),
            ),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportPage()),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFEF2A39),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFEF2A39), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withValues(alpha: 0.1),
      indent: 56,
      endIndent: 16,
    );
  }

  Widget _buildMenuItem({
    Key? key,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF2A39).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFFEF2A39)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212529),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
