import os
import re

code = """import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_profile_page__bloc.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';
import '../seller_store_details_page/seller_store_details_page__ui.dart';
import '../seller_payment_page/seller_payment_page_ui.dart';
import '../seller_forgot_password/seller_forgot_password_ui.dart';
import '../seller_setting_page/seller_setting_page__ui.dart';
import '../seller_setting_page/seller_setting_page__bloc.dart';
import '../seller_setting_page/seller_setting_page__event.dart';
import '../seller_wallet_page/seller_wallet_page__ui.dart';
import 'package:image_picker/image_picker.dart';

class SellerProfilePageUI extends StatelessWidget {
  const SellerProfilePageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerProfilePageBloc()..add(LoadProfile()),
      child: const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: SafeArea(
          child: ResponsiveProfileLayout(),
        ),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}

class ResponsiveProfileLayout extends StatelessWidget {
  const ResponsiveProfileLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return const Center(
            child: SizedBox(
              width: 800,
              child: ProfileContent(),
            ),
          );
        } else if (constraints.maxWidth > 600) {
          return const Center(
            child: SizedBox(
              width: 600,
              child: ProfileContent(),
            ),
          );
        }
        return const ProfileContent();
      },
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerProfilePageBloc, SellerProfilePageState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const ProfileSkeletonLoader();
        } else if (state is ProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ProfileLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Manage your account and business information',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const _EditProfileButton(),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Profile Banner Card
                  CustomPaint(
                    painter: _BannerBackgroundPainter(),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            spreadRadius: 4,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ResponsiveBannerContent(state: state),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Settings List Menu
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFF5F3FF),
                    title: 'Wallet',
                    subtitle: 'Manage your balance and transactions',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerWalletPage()));
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.storefront_outlined,
                    iconColor: const Color(0xFF3B82F6),
                    iconBgColor: const Color(0xFFEFF6FF),
                    title: 'Business Details',
                    subtitle: 'View and update your business information',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerStoreDetailsPage()));
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.account_balance_outlined,
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: const Color(0xFFECFDF5),
                    title: 'Bank Details',
                    subtitle: 'Manage your bank account and payout details',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerPaymentPage()));
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    iconColor: const Color(0xFFF59E0B),
                    iconBgColor: const Color(0xFFFFFBEB),
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerForgotPasswordPageUI()));
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.notifications_none_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFF5F3FF),
                    title: 'Notification Settings',
                    subtitle: 'Manage your notification preferences',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (context) => SellerSettingBloc(
                              repository: SellerSettingRepositoryImpl(),
                            )..add(LoadSellerSettings()),
                            child: const SellerSettingPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.logout,
                    iconColor: const Color(0xFFEF4444),
                    iconBgColor: const Color(0xFFFEF2F2),
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    onTap: () {
                      context.read<SellerProfilePageBloc>().add(LogoutRequested());
                    },
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _HoverableCardMenuItem(
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _HoverableCardMenuItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HoverableCardMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_HoverableCardMenuItem> createState() => _HoverableCardMenuItemState();
}

class _HoverableCardMenuItemState extends State<_HoverableCardMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 24 : 12,
              spreadRadius: _isHovered ? 2 : 0,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class ResponsiveBannerContent extends StatelessWidget {
  final ProfileLoaded state;
  const ResponsiveBannerContent({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        
        if (isMobile) {
          return Column(
            children: [
              _buildAvatar(context),
              const SizedBox(height: 24),
              _buildDetails(),
              const SizedBox(height: 24),
              _buildStatusCard(),
            ],
          );
        }
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(context),
            const SizedBox(width: 32),
            Expanded(child: _buildDetails()),
            const SizedBox(width: 16),
            _buildStatusCard(),
          ],
        );
      }
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFF3B30), Color(0xFF8B5CF6), Color(0xFFEC4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33FF3B30),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 4),
              image: DecorationImage(
                image: state.localImageBytes != null
                    ? MemoryImage(state.localImageBytes!) as ImageProvider
                    : NetworkImage(state.profileImageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: state.isImageUploading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE52929),
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _HoverableCameraButton(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                final bytes = await image.readAsBytes();
                final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
                if (context.mounted) {
                  context.read<SellerProfilePageBloc>().add(UpdateProfileImage(bytes, fileName));
                }
              }
            }
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.storeName.isEmpty ? 'Picarhub Restaurant' : state.storeName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.mail_outline, size: 20, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(state.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(state.phone, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16),
              SizedBox(width: 8),
              Text(
                'Role: Restaurant Owner',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today_outlined,
                iconColor: const Color(0xFFEF4444),
                title: 'Member Since',
                value: 'Jan 15, 2024',
              ),
              const SizedBox(height: 24),
              _buildInfoChip(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFFEF4444),
                title: 'Account Status',
                value: 'Verified',
                valueColor: const Color(0xFF10B981),
                valueBgColor: const Color(0xFFECFDF5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? valueColor,
    Color? valueBgColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: valueBgColor != null ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4) : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: valueBgColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HoverableCameraButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HoverableCameraButton({required this.onTap});
  @override
  State<_HoverableCameraButton> createState() => _HoverableCameraButtonState();
}

class _HoverableCameraButtonState extends State<_HoverableCameraButton> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          transform: Matrix4.identity()..scale(_isHovered ? 1.1 : 1.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF3B30), Color(0xFFE52929)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE52929).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: _isHovered ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _EditProfileButton extends StatefulWidget {
  const _EditProfileButton({Key? key}) : super(key: key);
  @override
  State<_EditProfileButton> createState() => _EditProfileButtonState();
}

class _EditProfileButtonState extends State<_EditProfileButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFFEE2E2) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(_isHovered ? 0.15 : 0.05),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, color: Color(0xFFE52929), size: 18),
              SizedBox(width: 8),
              Text(
                'Edit Profile',
                style: TextStyle(
                  color: Color(0xFFE52929),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 150, height: 40, color: Colors.grey.shade200),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 200, height: 30, color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    Container(width: 150, height: 16, color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    Container(width: 100, height: 16, color: Colors.grey.shade200),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only display on mobile, but since this is bound to bottomNavigationBar 
    // it's better to render a floating navigation bar similar to the main one.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return const SizedBox.shrink(); // Hide on desktop
        }
        return Container(
          margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                spreadRadius: 0,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Dashboard', false),
              _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders', false, badgeText: '3'),
              _buildNavItem(2, Icons.inbox_outlined, Icons.inbox_rounded, 'Products', false, badgeText: '4'),
              _buildNavItem(3, Icons.grid_view_outlined, Icons.grid_view_rounded, 'More', true),
            ],
          ),
        );
      }
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, bool isSelected, {String? badgeText}) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12) : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0x33FF3B30), Color(0x0AFF3B30)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: isSelected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(activeIcon, color: const Color(0xFFE52929), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFE52929),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(icon, color: const Color(0xFF64748B), size: 24),
                      if (badgeText != null)
                        Positioned(
                          top: -4,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE52929),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BannerBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    
    final paintBase = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFFF0F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    
    canvas.drawRRect(rRect, paintBase);

    canvas.save();
    canvas.clipRRect(rRect);

    final wavePaint1 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x22FF3B30), Color(0x118B5CF6)], 
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(size.width * 0.45, size.height);
    path1.quadraticBezierTo(size.width * 0.65, size.height * 0.3, size.width, size.height * 0.1);
    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, wavePaint1);

    final wavePaint2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x33FF3B30), Color(0x22EC4899)], 
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(size.width * 0.65, size.height);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width, size.height * 0.4);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, wavePaint2);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
"""

with open('d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print("Updated profile UI successfully")
