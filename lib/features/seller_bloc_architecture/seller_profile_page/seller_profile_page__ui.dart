import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';
import 'seller_profile_page__bloc.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';
import '../seller_store_details_page/seller_store_details_page__ui.dart';
import '../seller_payment_page/seller_payment_page_ui.dart';
import '../seller_forgot_password/seller_forgot_password_ui.dart';
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
import '../seller_setting_page/seller_setting_page__ui.dart';
import '../seller_setting_page/seller_setting_page__bloc.dart';
import '../seller_setting_page/seller_setting_page__event.dart' show LoadSellerSettings;

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
        backgroundColor: Color(0xFFF9FAFB),
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
        if (constraints.maxWidth > 1100) {
          return const Center(
            child: SizedBox(width: 1100, child: ProfileContent()),
          );
        } else if (constraints.maxWidth > 768) {
          return const Center(
            child: SizedBox(width: 768, child: ProfileContent()),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF111827), fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SellerProfilePageBloc>().add(LoadProfile()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE52929),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProfileLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Restaurant Profile',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage branding, delivery logistics, operations & business settings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _EditProfileButton(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cover Banner & Overlay Avatar Card
                  _RestaurantBannerCard(state: state),
                  const SizedBox(height: 20),

                  // Operational Quick Control Bar
                  _OperationalQuickBar(state: state),
                  const SizedBox(height: 24),

                  // Profile Detail Sections Grid
                  _ProfileSectionsGrid(state: state),
                  const SizedBox(height: 24),

                  // Settings & Features Menu Grid Header
                  const Text(
                    'Store Management & Operations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings List Menu Grid
                  _MenuGrid(state: state),
                  const SizedBox(height: 80),
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

class _RestaurantBannerCard extends StatelessWidget {
  final ProfileLoaded state;

  const _RestaurantBannerCard({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Cover Banner Image with Edit Button
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    image: state.localCoverBytes != null
                        ? DecorationImage(
                            image: MemoryImage(state.localCoverBytes!),
                            fit: BoxFit.cover,
                          )
                        : (state.coverImageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(state.coverImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: (state.coverImageUrl.isEmpty && state.localCoverBytes == null)
                      ? Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE52929), Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.panorama_outlined, color: Colors.white70, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'Add Cover Banner',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                if (state.isCoverUploading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black38,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                // Cover Edit Camera Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: _HoverIconButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Cover Banner',
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
                        if (context.mounted) {
                          context.read<SellerProfilePageBloc>().add(
                                UpdateCoverImage(bytes, fileName),
                              );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),

            // Profile Info Header with Avatar Overlay
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isMobile = constraints.maxWidth < 600;
                  return isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -60),
                              child: _buildAvatar(context),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -40),
                              child: _buildDetails(context),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -50),
                              child: _buildAvatar(context),
                            ),
                            const SizedBox(width: 24),
                            Expanded(child: _buildDetails(context)),
                          ],
                        );
                },
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
            if (state.profileImageUrl.isNotEmpty || state.localImageBytes != null) {
              _showImagePreview(context);
            }
          },
          child: Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE52929), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33E52929),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 3),
                image: state.localImageBytes != null
                    ? DecorationImage(
                        image: MemoryImage(state.localImageBytes!),
                        fit: BoxFit.cover,
                      )
                    : (state.profileImageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(state.profileImageUrl),
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
              child: state.isImageUploading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE52929)))
                  : (state.profileImageUrl.isEmpty && state.localImageBytes == null
                      ? const Icon(Icons.storefront, size: 40, color: Color(0xFF9CA3AF))
                      : null),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _HoverableCameraButton(
            onTap: () async {
              final picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                final bytes = await image.readAsBytes();
                final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
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

  Widget _buildDetails(BuildContext context) {
    final displayName = state.storeName.isNotEmpty
        ? state.storeName
        : (state.ownerName?.isNotEmpty == true ? state.ownerName! : 'Set Restaurant Name');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            _VerificationStatusBadge(status: state.verificationStatus, isVerified: state.isVerified),
          ],
        ),
        if (state.ownerName?.isNotEmpty == true && state.ownerName != state.storeName) ...[
          const SizedBox(height: 4),
          Text(
            'Owner: ${state.ownerName}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            if (state.email.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mail_outline, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Text(state.email, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                ],
              ),
            if (state.phone.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Text(state.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                ],
              ),
            if (state.address?.isNotEmpty == true)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Text(
                    state.address!.length > 30 ? '${state.address!.substring(0, 30)}...' : state.address!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(color: Colors.transparent),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: state.localImageBytes != null
                  ? Image.memory(state.localImageBytes!, width: 320, height: 320, fit: BoxFit.cover)
                  : Image.network(state.profileImageUrl, width: 320, height: 320, fit: BoxFit.cover),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationalQuickBar extends StatelessWidget {
  final ProfileLoaded state;

  const _OperationalQuickBar({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _buildAcceptingOrdersToggle(context),
          _buildStoreOpenToggle(context),
          _buildLogisticsSummary(context),
        ],
      ),
    );
  }

  Widget _buildAcceptingOrdersToggle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.isAcceptingOrders ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            boxShadow: [
              BoxShadow(
                color: (state.isAcceptingOrders ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                    .withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Accepting Orders (Rush Mode)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            Text(
              state.isAcceptingOrders ? 'Live & receiving orders' : 'Paused / Rush mode active',
              style: TextStyle(
                fontSize: 12,
                color: state.isAcceptingOrders ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Switch(
          value: state.isAcceptingOrders,
          activeColor: const Color(0xFF10B981),
          onChanged: (val) {
            context.read<SellerProfilePageBloc>().add(ToggleAcceptingOrders(val));
          },
        ),
      ],
    );
  }

  Widget _buildStoreOpenToggle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          state.isOpen ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
          size: 20,
          color: state.isOpen ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Store Status',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            Text(
              state.isOpen ? 'Open for Customers' : 'Closed',
              style: TextStyle(
                fontSize: 12,
                color: state.isOpen ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Switch(
          value: state.isOpen,
          activeColor: const Color(0xFF3B82F6),
          onChanged: (val) {
            context.read<SellerProfilePageBloc>().add(ToggleStoreOpenStatus(val));
          },
        ),
      ],
    );
  }

  Widget _buildLogisticsSummary(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 20, color: Color(0xFF8B5CF6)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Avg Prep Time',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            Text(
              '${state.estimatedPrepTimeMinutes} mins',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileSectionsGrid extends StatelessWidget {
  final ProfileLoaded state;

  const _ProfileSectionsGrid({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 700;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBrandingCard(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLocationLogisticsCard(context)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCuisineCard(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildScheduleCard(context)),
                ],
              ),
            ] else ...[
              _buildBrandingCard(context),
              const SizedBox(height: 16),
              _buildLocationLogisticsCard(context),
              const SizedBox(height: 16),
              _buildCuisineCard(context),
              const SizedBox(height: 16),
              _buildScheduleCard(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBrandingCard(BuildContext context) {
    return _SectionCard(
      title: 'Branding & Description',
      icon: Icons.storefront_outlined,
      iconColor: const Color(0xFFE52929),
      onEdit: () => _showEditIdentityDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Restaurant Name', state.storeName.isNotEmpty ? state.storeName : 'Not set'),
          _buildInfoRow('Owner / Licensee', state.ownerName?.isNotEmpty == true ? state.ownerName! : 'Not set'),
          _buildInfoRow(
            'Description',
            state.restaurantDescription?.isNotEmpty == true ? state.restaurantDescription! : 'Add restaurant bio & specialties...',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationLogisticsCard(BuildContext context) {
    return _SectionCard(
      title: 'Location & Delivery Logistics',
      icon: Icons.delivery_dining_outlined,
      iconColor: const Color(0xFF3B82F6),
      onEdit: () => _showEditLogisticsDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Physical Address', state.address?.isNotEmpty == true ? state.address! : 'Not set'),
          _buildInfoRow('Delivery Radius', '${state.deliveryRadius.toStringAsFixed(1)} km'),
          _buildInfoRow('Min Order Amount', '₹${state.minimumOrderValue.toStringAsFixed(2)}'),
          _buildInfoRow(
            'Delivery Fee Breakdown',
            'Base: ₹${state.deliveryFeeSettings.baseFee.toStringAsFixed(0)} | +₹${state.deliveryFeeSettings.perKmFee.toStringAsFixed(0)}/km | Free > ₹${state.deliveryFeeSettings.freeDeliveryThreshold.toStringAsFixed(0)}',
          ),
          if (state.latitude != null && state.longitude != null)
            _buildInfoRow('GPS Coordinates', '${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)}'),
        ],
      ),
    );
  }

  Widget _buildCuisineCard(BuildContext context) {
    return _SectionCard(
      title: 'Cuisine Categories',
      icon: Icons.restaurant_menu_outlined,
      iconColor: const Color(0xFFF59E0B),
      onEdit: () => _showEditCuisinesDialog(context),
      child: state.cuisines.isEmpty
          ? const Text('No cuisines selected. Click Edit to add tags.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.cuisines.map((c) {
                return Chip(
                  label: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  backgroundColor: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    final holidays = state.weeklyHoliday.isEmpty ? 'None' : state.weeklyHoliday.join(', ');
    return _SectionCard(
      title: 'Operating Hours & Schedule',
      icon: Icons.access_time_outlined,
      iconColor: const Color(0xFF10B981),
      onEdit: () => _showEditScheduleDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Opening Time', state.openingHours?.isNotEmpty == true ? state.openingHours! : '09:00 AM'),
          _buildInfoRow('Closing Time', state.closingTime?.isNotEmpty == true ? state.closingTime! : '11:00 PM'),
          _buildInfoRow('Weekly Holidays', holidays),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF111827), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showEditIdentityDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: state.storeName);
    final ownerCtrl = TextEditingController(text: state.ownerName ?? '');
    final descCtrl = TextEditingController(text: state.restaurantDescription ?? '');
    final emailCtrl = TextEditingController(text: state.email);
    final phoneCtrl = TextEditingController(text: state.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Branding & Identity', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Restaurant Name')),
              TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'Owner / Licensee Name')),
              TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description / Bio')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Contact Email')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Contact Phone')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<SellerProfilePageBloc>().add(
                    UpdateRestaurantIdentity(
                      storeName: nameCtrl.text.trim(),
                      ownerName: ownerCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    ),
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE52929), foregroundColor: Colors.white),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showEditLogisticsDialog(BuildContext context) {
    final addrCtrl = TextEditingController(text: state.address ?? '');
    final radiusCtrl = TextEditingController(text: state.deliveryRadius.toString());
    final minOrderCtrl = TextEditingController(text: state.minimumOrderValue.toString());
    final prepCtrl = TextEditingController(text: state.estimatedPrepTimeMinutes.toString());
    final baseFeeCtrl = TextEditingController(text: state.deliveryFeeSettings.baseFee.toString());
    final perKmCtrl = TextEditingController(text: state.deliveryFeeSettings.perKmFee.toString());
    final freeThresholdCtrl = TextEditingController(text: state.deliveryFeeSettings.freeDeliveryThreshold.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Location & Delivery Logistics', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Physical Address')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: radiusCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Radius (km)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: minOrderCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Min Order (₹)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: prepCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Prep Time (mins)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: baseFeeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Base Fee (₹)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: perKmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Per km Fee (₹)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: freeThresholdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Free Delivery Threshold (₹)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newSettings = DeliveryFeeSettings(
                baseFee: double.tryParse(baseFeeCtrl.text.trim()) ?? 20.0,
                perKmFee: double.tryParse(perKmCtrl.text.trim()) ?? 5.0,
                freeDeliveryThreshold: double.tryParse(freeThresholdCtrl.text.trim()) ?? 500.0,
              );
              context.read<SellerProfilePageBloc>().add(
                    UpdateLocationDetails(address: addrCtrl.text.trim()),
                  );
              context.read<SellerProfilePageBloc>().add(
                    UpdateLogisticsSettings(
                      minimumOrderValue: double.tryParse(minOrderCtrl.text.trim()) ?? 150.0,
                      deliveryRadius: double.tryParse(radiusCtrl.text.trim()) ?? 10.0,
                      deliveryFeeSettings: newSettings,
                      estimatedPrepTimeMinutes: int.tryParse(prepCtrl.text.trim()) ?? 25,
                    ),
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE52929), foregroundColor: Colors.white),
            child: const Text('Save Logistics'),
          ),
        ],
      ),
    );
  }

  void _showEditCuisinesDialog(BuildContext context) {
    final available = [
      'South Indian',
      'North Indian',
      'Biryani',
      'Chinese',
      'Fast Food',
      'Desserts',
      'Beverages',
      'Italian',
      'Bakery',
      'Street Food',
    ];
    final selected = List<String>.from(state.cuisines);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Manage Cuisine Categories', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: available.map((c) {
              final isSel = selected.contains(c);
              return FilterChip(
                label: Text(c),
                selected: isSel,
                selectedColor: const Color(0xFFFEE2E2),
                checkmarkColor: const Color(0xFFE52929),
                labelStyle: TextStyle(
                  color: isSel ? const Color(0xFFE52929) : const Color(0xFF1E293B),
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (val) {
                  setDialogState(() {
                    if (val) {
                      selected.add(c);
                    } else {
                      selected.remove(c);
                    }
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                context.read<SellerProfilePageBloc>().add(UpdateCuisines(selected));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE52929), foregroundColor: Colors.white),
              child: const Text('Save Cuisines'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditScheduleDialog(BuildContext context) {
    final openCtrl = TextEditingController(text: state.openingHours ?? '09:00 AM');
    final closeCtrl = TextEditingController(text: state.closingTime ?? '11:00 PM');
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final selectedHolidays = List<String>.from(state.weeklyHoliday);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Operating Hours & Holidays', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: openCtrl, decoration: const InputDecoration(labelText: 'Opening Time (e.g. 09:00 AM)')),
                TextField(controller: closeCtrl, decoration: const InputDecoration(labelText: 'Closing Time (e.g. 11:00 PM)')),
                const SizedBox(height: 16),
                const Text('Weekly Holidays', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: days.map((d) {
                    final isHol = selectedHolidays.contains(d);
                    return FilterChip(
                      label: Text(d),
                      selected: isHol,
                      selectedColor: const Color(0xFFFEE2E2),
                      checkmarkColor: const Color(0xFFE52929),
                      onSelected: (val) {
                        setDialogState(() {
                          if (val) {
                            selectedHolidays.add(d);
                          } else {
                            selectedHolidays.remove(d);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                context.read<SellerProfilePageBloc>().add(
                      UpdateBusinessHoursSchedule(
                        openingHours: openCtrl.text.trim(),
                        closingTime: closeCtrl.text.trim(),
                        weeklyHoliday: selectedHolidays,
                      ),
                    );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE52929), foregroundColor: Colors.white),
              child: const Text('Save Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onEdit;
  final Widget child;

  const _SectionCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onEdit,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF6B7280)),
                onPressed: onEdit,
                splashRadius: 20,
                tooltip: 'Edit Section',
              ),
            ],
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}

class _VerificationStatusBadge extends StatelessWidget {
  final String status;
  final bool isVerified;

  const _VerificationStatusBadge({Key? key, required this.status, required this.isVerified}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool verified = isVerified || status.toLowerCase() == 'verified';
    final Color color = verified ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final Color bgColor = verified ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7);
    final IconData icon = verified ? Icons.check_circle_outline : Icons.schedule_outlined;
    final String label = verified ? 'Verified' : (status.isNotEmpty ? status.toUpperCase() : 'PENDING');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HoverIconButton({required this.icon, required this.label, required this.onTap});

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : Colors.black54,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white70),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: _isHovered ? const Color(0xFF1E293B) : Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _isHovered ? const Color(0xFF1E293B) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
          padding: const EdgeInsets.all(8),
          transform: Matrix4.identity()..scale(_isHovered ? 1.15 : 1.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF3B30), Color(0xFFE52929)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE52929).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SellerStoreDetailsPage()),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFFEE2E2) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.tune_outlined, color: Color(0xFFE52929), size: 16),
              SizedBox(width: 6),
              Text(
                'Store Settings',
                style: TextStyle(
                  color: Color(0xFFE52929),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  final ProfileLoaded state;

  const _MenuGrid({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 700;
        final double itemWidth = isDesktop ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;

        final List<Map<String, dynamic>> menuItems = [
          {
            'icon': Icons.account_balance_wallet_outlined,
            'iconColor': const Color(0xFF8B5CF6),
            'iconBgColor': const Color(0xFFF5F3FF),
            'title': 'Wallet',
            'subtitle': 'Manage your balance and transactions',
            'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerWalletPage())),
          },
          {
            'icon': Icons.storefront_outlined,
            'iconColor': const Color(0xFF3B82F6),
            'iconBgColor': const Color(0xFFEFF6FF),
            'title': 'Business Details',
            'subtitle': 'View and update your business information',
            'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerStoreDetailsPage())),
          },
          {
            'icon': Icons.account_balance_outlined,
            'iconColor': const Color(0xFF10B981),
            'iconBgColor': const Color(0xFFECFDF5),
            'title': 'Bank Details',
            'subtitle': 'Manage your bank account and payout details',
            'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerPaymentPage())),
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
            'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerForgotPasswordPageUI())),
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
            'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const food_delivery_app_rating.OverallRatingPage())),
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
          spacing: 20,
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
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.06 : 0.02),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ],
              ),
            ),
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
          Container(width: 200, height: 36, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 20),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(24)),
          ),
          const SizedBox(height: 20),
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(height: 160, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(height: 160, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
