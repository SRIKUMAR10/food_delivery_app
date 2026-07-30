import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';
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
import '../../../repositories/seller_repository.dart';
import '../seller_login_page/seller_login_page_ui.dart';
import '../promotions_coupons_page_/promotions_coupons_page_ui.dart';
import '../business_hours_page_/business_hours_page_ui.dart';
import '../disputes_refunds_page_/disputes_refunds_page_ui.dart';
import '../chat_support_page_/chat_support_page_ui.dart';
import '../menu_category_management_page_/menu_category_management_page_ui.dart';
import '../overall_rating_page/overall_rating_page__ui.dart' as food_delivery_app_rating;

class SellerProfilePageUI extends StatelessWidget {
  const SellerProfilePageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerProfilePageBloc(
        authService: context.read<IAuthService>(),
        profileRepository: context.read<ISellerProfileRepository>(),
      )..add(LoadProfile()),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: ResponsiveProfileLayout()),
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
            child: SizedBox(width: 800, child: ProfileContent()),
          );
        } else if (constraints.maxWidth > 600) {
          return const Center(
            child: SizedBox(width: 600, child: ProfileContent()),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
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
                      ),
                      const _EditProfileButton(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile Banner Card
                  CustomPaint(
                    painter: _BannerBackgroundPainter(),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 24,
                            spreadRadius: 4,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ResponsiveBannerContent(state: state),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings List Menu
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isDesktop = constraints.maxWidth > 600;
                      final double itemWidth = isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;
                      
                      final List<Map<String, dynamic>> menuItems = [
                        {
                          'icon': Icons.account_balance_wallet_outlined,
                          'iconColor': const Color(0xFF8B5CF6),
                          'iconBgColor': const Color(0xFFF5F3FF),
                          'title': 'Wallet',
                          'subtitle': 'Manage your balance and transactions',
                          'onTap': () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerWalletPage()));
                          },
                        },
                        {
                          'icon': Icons.storefront_outlined,
                          'iconColor': const Color(0xFF3B82F6),
                          'iconBgColor': const Color(0xFFEFF6FF),
                          'title': 'Business Details',
                          'subtitle': 'View and update your business information',
                          'onTap': () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerStoreDetailsPage()));
                          },
                        },
                        {
                          'icon': Icons.account_balance_outlined,
                          'iconColor': const Color(0xFF10B981),
                          'iconBgColor': const Color(0xFFECFDF5),
                          'title': 'Bank Details',
                          'subtitle': 'Manage your bank account and payout details',
                          'onTap': () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerPaymentPage()));
                          },
                        },
                        {
                          'icon': Icons.restaurant_menu_outlined,
                          'iconColor': const Color(0xFFF43F5E),
                          'iconBgColor': const Color(0xFFFFF1F2),
                          'title': 'Menu Categories',
                          'subtitle': 'Select and reorder your menu categories',
                          'onTap': () {
                            final sellerId = SellerRepository().currentUser?.uid ?? 'test_seller';
                            Navigator.push(context, MaterialPageRoute(builder: (_) => MenuCategoryManagementPage(sellerId: sellerId)));
                          },
                        },
                        {
                          'icon': Icons.local_offer_outlined,
                          'iconColor': const Color(0xFF14B8A6),
                          'iconBgColor': const Color(0xFFF0FDFA),
                          'title': 'Promotions & Coupons',
                          'subtitle': 'Create and manage special offers',
                          'onTap': () {
                            final sellerId = SellerRepository().currentUser?.uid ?? 'test_seller';
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PromotionsCouponsPage(sellerId: sellerId)));
                          },
                        },
                        {
                          'icon': Icons.access_time_outlined,
                          'iconColor': const Color(0xFFF59E0B),
                          'iconBgColor': const Color(0xFFFFFBEB),
                          'title': 'Business Hours',
                          'subtitle': 'Set your store opening and closing times',
                          'onTap': () {
                            final sellerId = SellerRepository().currentUser?.uid ?? 'test_seller';
                            Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessHoursPage(sellerId: sellerId)));
                          },
                        },
                        {
                          'icon': Icons.gavel_outlined,
                          'iconColor': const Color(0xFF8B5CF6),
                          'iconBgColor': const Color(0xFFF5F3FF),
                          'title': 'Disputes & Refunds',
                          'subtitle': 'Manage customer disputes and refund requests',
                          'onTap': () {
                            final sellerId = SellerRepository().currentUser?.uid ?? 'test_seller';
                            Navigator.push(context, MaterialPageRoute(builder: (_) => DisputesRefundsPage(sellerId: sellerId)));
                          },
                        },
                        {
                          'icon': Icons.chat_bubble_outline,
                          'iconColor': const Color(0xFF06B6D4),
                          'iconBgColor': const Color(0xFFECFEFF),
                          'title': 'Support Chat',
                          'subtitle': 'Contact admin support or customers',
                          'onTap': () {
                            final sellerId = SellerRepository().currentUser?.uid ?? 'test_seller';
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatSupportPage(sellerId: sellerId)));
                          },
                        },
                        {
                          'icon': Icons.lock_outline,
                          'iconColor': const Color(0xFFF59E0B),
                          'iconBgColor': const Color(0xFFFFFBEB),
                          'title': 'Change Password',
                          'subtitle': 'Update your account password',
                          'onTap': () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerForgotPasswordPageUI()));
                          },
                        },
                        {
                          'icon': Icons.notifications_none_outlined,
                          'iconColor': const Color(0xFF8B5CF6),
                          'iconBgColor': const Color(0xFFF5F3FF),
                          'title': 'Notification Settings',
                          'subtitle': 'Manage your notification preferences',
                          'onTap': () {
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
                        },
                        {
                          'icon': Icons.star_border_outlined,
                          'iconColor': const Color(0xFFEAB308),
                          'iconBgColor': const Color(0xFFFEF9C3),
                          'title': 'Ratings & Reviews',
                          'subtitle': 'View customer feedback and ratings',
                          'onTap': () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const food_delivery_app_rating.OverallRatingPage()));
                          },
                        },
                        {
                          'icon': Icons.logout,
                          'iconColor': const Color(0xFFEF4444),
                          'iconBgColor': const Color(0xFFFEF2F2),
                          'title': 'Logout',
                          'subtitle': 'Sign out from your account',
                          'onTap': () async {
                            final repo = SellerRepository();
                            final uid = repo.currentUser?.uid;
                            if (uid != null) {
                              await repo.updateSellerData(uid, {'isOnline': false});
                            }
                            await repo.signOut();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const SellerLoginPageUI()),
                                (route) => false,
                              );
                            }
                          },
                        },
                      ];

                      return Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        children: List.generate(menuItems.length, (index) {
                          final item = menuItems[index];
                          return SizedBox(
                            width: itemWidth,
                            child: _HoverableCardMenuItem(
                              index: index,
                              icon: item['icon'] as IconData,
                              iconColor: item['iconColor'] as Color,
                              iconBgColor: item['iconBgColor'] as Color,
                              title: item['title'] as String,
                              subtitle: item['subtitle'] as String,
                              onTap: item['onTap'] as VoidCallback,
                            ),
                          );
                        }),
                      );
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



}

class _HoverableCardMenuItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int index;

  const _HoverableCardMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<_HoverableCardMenuItem> createState() => _HoverableCardMenuItemState();
}

class _HoverableCardMenuItemState extends State<_HoverableCardMenuItem> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _entryController;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()..translate(_isHovered ? 6.0 : 0.0, 0.0),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF9CA3AF),
                          size: 24,
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
    );
  }
}

class ResponsiveBannerContent extends StatelessWidget {
  final ProfileLoaded state;
  const ResponsiveBannerContent({Key? key, required this.state})
    : super(key: key);

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
      },
    );
  }

  void _showImagePreview(BuildContext context) {
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
              tag: 'seller_profile_image_preview',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: state.localImageBytes != null
                    ? Image.memory(
                        state.localImageBytes!,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        state.profileImageUrl,
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
                              child: CircularProgressIndicator(
                                color: Color(0xFFE52929),
                              ),
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

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            if (!state.isImageUploading) {
              _showImagePreview(context);
            }
          },
          child: Hero(
            tag: 'seller_profile_image_preview',
            child: AnimatedContainer(
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
                        child: CircularProgressIndicator(color: Color(0xFFE52929)),
                      )
                    : null,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _HoverableCameraButton(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                final bytes = await image.readAsBytes();
                final fileName =
                    '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
                if (context.mounted) {
                  context.read<SellerProfilePageBloc>().add(
                    UpdateProfileImage(bytes, fileName),
                  );
                }
              }
            },
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
            Text(
              state.email,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.phone_outlined,
              size: 20,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              state.phone,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
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
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF10B981),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Role: ${state.role == 'seller' ? 'Restaurant Owner' : state.role}',
                style: const TextStyle(
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
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                value: '${_getMonth(state.createdAt.month)} ${state.createdAt.day}, ${state.createdAt.year}',
              ),
              const SizedBox(height: 24),
              _buildInfoChip(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFFEF4444),
                title: 'Account Status',
                value: state.isVerified ? 'Verified' : 'Pending',
                valueColor: state.isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                valueBgColor: state.isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
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
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
              padding: valueBgColor != null
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
                  : EdgeInsets.zero,
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

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return month >= 1 && month <= 12 ? months[month - 1] : '';
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
                color: const Color(0xFFE52929).withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: _isHovered ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SellerStoreDetailsPage()),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFEF4444,
                ).withValues(alpha: _isHovered ? 0.1 : 0.05),
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
                    Container(
                      width: 200,
                      height: 30,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 150,
                      height: 16,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 100,
                      height: 16,
                      color: Colors.grey.shade200,
                    ),
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
    path1.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.3,
      size.width,
      size.height * 0.1,
    );
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
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.5,
      size.width,
      size.height * 0.4,
    );
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, wavePaint2);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
