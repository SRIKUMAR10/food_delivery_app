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
import '../seller_customer_page/seller_customer_page__ui.dart';
import '../menu_category_management_page_/menu_category_management_page_ui.dart';
import '../overall_rating_page/overall_rating_page__ui.dart' as food_delivery_app_rating;
import '../seller_setting_page/seller_setting_page__ui.dart';
import '../seller_setting_page/seller_setting_page__bloc.dart';
import '../seller_setting_page/seller_setting_page__event.dart' show LoadSellerSettings;
import '../../../core/widgets/hoverable_widgets.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/services/google_places_service.dart';
import 'seller_google_address_search_dialog.dart';
import 'seller_verification_form_page.dart';
import '../seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';
import '../seller_auth_shared/onboarding_back_handler.dart';
import '../seller_auth_shared/seller_wizard_container.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';
import '../seller_ui_tokens.dart';

class SellerProfilePageUI extends StatelessWidget {
  final bool isOnboardingFlow;
  const SellerProfilePageUI({Key? key, this.isOnboardingFlow = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isOnboardingFlow,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (isOnboardingFlow) {
          await OnboardingBackHandler.handleBack(context, previousRoute: '/businessHours');
        }
      },
      child: BlocProvider(
        create: (context) => SellerProfilePageBloc(
          authService: context.read<IAuthService>(),
          profileRepository: context.read<ISellerProfileRepository>(),
        )..add(LoadProfile()),
        child: isOnboardingFlow
            ? SellerWizardContainer(
                stepIndex: 4,
                totalSteps: 8,
                stepBadge: 'Step 4 of 8 • Profile Branding & Live Switch',
                title: 'Profile Branding & Live Switch',
                subtitle: 'Upload store banner, logo, bio tagline, and store live switch',
                onBack: () => OnboardingBackHandler.handleBack(context, previousRoute: '/businessHours'),
                child: const ProfileContent(isOnboardingFlow: true),
              )
            : Scaffold(
                backgroundColor: const Color(0xFFF9FAFB),
                body: SafeArea(child: ResponsiveProfileLayout(isOnboardingFlow: isOnboardingFlow)),
              ),
      ),
    );
  }
}

class ResponsiveProfileLayout extends StatelessWidget {
  final bool isOnboardingFlow;
  const ResponsiveProfileLayout({Key? key, this.isOnboardingFlow = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1100) {
          return Center(
            child: SizedBox(width: 1100, child: ProfileContent(isOnboardingFlow: isOnboardingFlow)),
          );
        } else if (constraints.maxWidth > 768) {
          return Center(
            child: SizedBox(width: 768, child: ProfileContent(isOnboardingFlow: isOnboardingFlow)),
          );
        }
        return ProfileContent(isOnboardingFlow: isOnboardingFlow);
      },
    );
  }
}

class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 200, height: 36, borderRadius: 8),
          SizedBox(height: 20),
          SkeletonBox(
            height: 220,
            width: double.infinity,
            borderRadius: 24,
          ),
          SizedBox(height: 20),
          SkeletonBox(
            height: 70,
            width: double.infinity,
            borderRadius: 20,
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SkeletonBox(height: 160, borderRadius: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: SkeletonBox(height: 160, borderRadius: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  final bool isOnboardingFlow;
  const ProfileContent({Key? key, this.isOnboardingFlow = false}) : super(key: key);

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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isOnboardingFlow || Navigator.canPop(context)) ...[
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (isOnboardingFlow) {
                                      OnboardingBackHandler.handleBack(context, previousRoute: '/businessHours');
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Color(0xFF1E293B),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ] else if (SellerDrawerProvider.of(context) != null) ...[
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: SellerDrawerProvider.of(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.menu_rounded,
                                      color: Color(0xFF1E293B),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isOnboardingFlow) ...[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: const Text(
                                        'Step 4 of 8 (Profile Branding & Live Switch)',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E40AF)),
                                      ),
                                    ),
                                  ],
                                  const Text(
                                    'Store Profile',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Manage branding, delivery logistics, operations & business settings',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
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
                  if (isOnboardingFlow) ...[
                    const SizedBox(height: 24),
                    SellerWizardPrimaryButton(
                      buttonKey: const ValueKey('continue_to_menu_categories_btn'),
                      label: 'Save & Continue to Menu Categories',
                      onPressed: () async {
                        if (state.storeName.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please provide your Store Name before proceeding.'),
                              backgroundColor: Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final repo = SellerRepository();
                        final uid = repo.currentUser?.uid;
                        if (uid != null && uid.isNotEmpty) {
                          try {
                            await repo.updateSellerData(uid, {'isProfileSetupCompleted': true});
                          } catch (_) {}
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile branding saved! Moving to Step 5: Menu Categories.'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            '/menuCategories',
                            arguments: {
                              'isOnboardingFlow': true,
                              'sellerId': uid ?? '',
                            },
                          );
                        }
                      },
                    ),
                  ],
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
                  child: HoverableButton(
                    height: 32,
                    color: Colors.black54,
                    borderColor: Colors.white70,
                    onPressed: () async {
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Cover Banner',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
          child: HoverableCard(
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
            hoverScale: 1.15,
            borderRadius: BorderRadius.circular(32),
            child: Container(
              padding: const EdgeInsets.all(8),
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
          activeThumbColor: const Color(0xFF10B981),
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
          activeThumbColor: const Color(0xFF3B82F6),
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
            ] else ...[
              _buildBrandingCard(context),
              const SizedBox(height: 16),
              _buildLocationLogisticsCard(context),
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
    final bloc = context.read<SellerProfilePageBloc>();
    final nameCtrl = TextEditingController(text: state.storeName);
    final ownerCtrl = TextEditingController(text: state.ownerName ?? '');
    final descCtrl = TextEditingController(text: state.restaurantDescription ?? '');
    final emailCtrl = TextEditingController(text: state.email);
    final phoneCtrl = TextEditingController(text: state.phone);

    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider<SellerProfilePageBloc>.value(
        value: bloc,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_outlined, color: Color(0xFFE52929), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Edit Branding & Identity',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Update store name, owner info and public contact details',
                              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  _buildDialogTextField(
                    controller: nameCtrl,
                    label: 'Restaurant Name',
                    hint: 'e.g. Ahbi Food Restaurant',
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildDialogTextField(
                    controller: ownerCtrl,
                    label: 'Owner / Licensee Name',
                    hint: 'e.g. Ahbi Kumar',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _buildDialogTextField(
                    controller: descCtrl,
                    label: 'Description / Bio',
                    hint: 'Describe your specialties, flavors, and history...',
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogTextField(
                          controller: emailCtrl,
                          label: 'Contact Email',
                          hint: 'restaurant@gmail.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDialogTextField(
                          controller: phoneCtrl,
                          label: 'Contact Phone',
                          hint: '+91 9876543210',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          bloc.add(
                            UpdateRestaurantIdentity(
                              storeName: nameCtrl.text.trim(),
                              ownerName: ownerCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                            ),
                          );
                          Navigator.of(dialogCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Branding & identity updated successfully!'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE52929),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditLogisticsDialog(BuildContext context) {
    final bloc = context.read<SellerProfilePageBloc>();
    final addrCtrl = TextEditingController(text: state.address ?? '');
    final radiusCtrl = TextEditingController(text: state.deliveryRadius.toString());
    final minOrderCtrl = TextEditingController(text: state.minimumOrderValue.toString());
    final prepCtrl = TextEditingController(text: state.estimatedPrepTimeMinutes.toString());
    final baseFeeCtrl = TextEditingController(text: state.deliveryFeeSettings.baseFee.toString());
    final perKmCtrl = TextEditingController(text: state.deliveryFeeSettings.perKmFee.toString());
    final freeThresholdCtrl = TextEditingController(text: state.deliveryFeeSettings.freeDeliveryThreshold.toString());
    double? pickedLat = state.latitude;
    double? pickedLng = state.longitude;
    String? pickedMapsUrl = state.googleMapsUrl;
    bool isLocatingGps = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider<SellerProfilePageBloc>.value(
        value: bloc,
        child: StatefulBuilder(
          builder: (stateCtx, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Badge & Close Button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF3B82F6), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Edit Location & Delivery Logistics',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Configure restaurant GPS location, coverage radius, and pricing',
                                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Section 1: Physical Location & Pinning Actions
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.pin_drop_outlined, color: Color(0xFFE52929), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Store Address & GPS Location',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: addrCtrl,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                            decoration: InputDecoration(
                              labelText: 'Physical Address',
                              hintText: 'Enter complete store address...',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 24),
                                child: Icon(Icons.store_mall_directory_outlined, color: Color(0xFF6B7280), size: 20),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE52929), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: const ValueKey('sellerLogisticsGpsButton'),
                                  onPressed: isLocatingGps
                                      ? null
                                      : () async {
                                          setDialogState(() => isLocatingGps = true);
                                          try {
                                            final details = await GooglePlacesService.instance.getCurrentLocationAddress();
                                            if (details != null && context.mounted) {
                                              final lat = details.latitude ?? 13.0827;
                                              final lng = details.longitude ?? 80.2707;
                                              addrCtrl.text = details.formattedAddress;
                                              pickedLat = lat;
                                              pickedLng = lng;
                                              pickedMapsUrl = 'https://www.google.com/maps?q=$lat,$lng';
                                              setDialogState(() => isLocatingGps = false);
                                            } else if (context.mounted) {
                                              setDialogState(() => isLocatingGps = false);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Could not retrieve GPS location. Please check location permissions.'),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              setDialogState(() => isLocatingGps = false);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Location error: $e')),
                                              );
                                            }
                                          }
                                        },
                                  icon: isLocatingGps
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE52929)),
                                        )
                                      : const Icon(Icons.my_location_rounded, color: Color(0xFFE52929), size: 16),
                                  label: Text(
                                    isLocatingGps ? 'Locating...' : 'Detect GPS',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE52929)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: const ValueKey('sellerLogisticsMapButton'),
                                  onPressed: () async {
                                    final result = await SellerGoogleAddressSearchDialog.show(
                                      context: context,
                                      addressType: 'Restaurant',
                                      currentAddress: addrCtrl.text.trim(),
                                      onAddressSelected: (selection) {
                                        setDialogState(() {
                                          addrCtrl.text = selection.address;
                                          pickedLat = selection.latitude;
                                          pickedLng = selection.longitude;
                                          pickedMapsUrl = selection.effectiveGoogleMapsUrl;
                                        });
                                      },
                                    );
                                    if (result != null) {
                                      setDialogState(() {
                                        addrCtrl.text = result.address;
                                        pickedLat = result.latitude;
                                        pickedLng = result.longitude;
                                        pickedMapsUrl = result.effectiveGoogleMapsUrl;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.map_outlined, color: Color(0xFF3B82F6), size: 16),
                                  label: const Text(
                                    'Pick on Map',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF93C5FD)),
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (pickedLat != null && pickedLng != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Coordinates: ${pickedLat!.toStringAsFixed(4)}, ${pickedLng!.toStringAsFixed(4)}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Coverage & Minimum Order
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.radar_outlined, color: Color(0xFF3B82F6), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Delivery Coverage & Order Limits',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogTextField(
                                  controller: radiusCtrl,
                                  label: 'Radius (km)',
                                  hint: '10',
                                  icon: Icons.radar,
                                  suffixText: 'km',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDialogTextField(
                                  controller: minOrderCtrl,
                                  label: 'Min Order (₹)',
                                  hint: '150',
                                  icon: Icons.shopping_bag_outlined,
                                  prefixText: '₹',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Fulfillment & Delivery Fees
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.payments_outlined, color: Color(0xFF10B981), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Pricing & Preparation Logistics',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogTextField(
                                  controller: prepCtrl,
                                  label: 'Prep Time (mins)',
                                  hint: '25',
                                  icon: Icons.timer_outlined,
                                  suffixText: 'mins',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDialogTextField(
                                  controller: baseFeeCtrl,
                                  label: 'Base Fee (₹)',
                                  hint: '25',
                                  icon: Icons.receipt_long_outlined,
                                  prefixText: '₹',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogTextField(
                                  controller: perKmCtrl,
                                  label: 'Per km Fee (₹)',
                                  hint: '5',
                                  icon: Icons.add_road_outlined,
                                  suffixText: '₹/km',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDialogTextField(
                                  controller: freeThresholdCtrl,
                                  label: 'Free Delivery Threshold (₹)',
                                  hint: '500',
                                  icon: Icons.local_shipping_outlined,
                                  prefixText: '₹',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dialog Actions (Cancel & Save Logistics)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            final double baseFee = double.tryParse(baseFeeCtrl.text.trim()) ?? 20.0;
                            final double perKmFee = double.tryParse(perKmCtrl.text.trim()) ?? 5.0;
                            final double freeThreshold = double.tryParse(freeThresholdCtrl.text.trim()) ?? 500.0;
                            final double minOrder = double.tryParse(minOrderCtrl.text.trim()) ?? 150.0;
                            final double deliveryRadius = double.tryParse(radiusCtrl.text.trim()) ?? 10.0;
                            final int prepTime = int.tryParse(prepCtrl.text.trim()) ?? 25;

                            final newSettings = DeliveryFeeSettings(
                              baseFee: baseFee,
                              perKmFee: perKmFee,
                              freeDeliveryThreshold: freeThreshold,
                            );

                            bloc.add(
                              UpdateLocationDetails(
                                address: addrCtrl.text.trim(),
                                latitude: pickedLat,
                                longitude: pickedLng,
                                googleMapsUrl: pickedMapsUrl,
                              ),
                            );

                            bloc.add(
                              UpdateLogisticsSettings(
                                minimumOrderValue: minOrder,
                                deliveryRadius: deliveryRadius,
                                deliveryFeeSettings: newSettings,
                                estimatedPrepTimeMinutes: prepTime,
                              ),
                            );

                            Navigator.of(dialogCtx).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Location & delivery logistics updated successfully!'),
                                backgroundColor: Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Save Logistics', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE52929),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
    String? suffixText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
        prefixText: prefixText != null ? '$prefixText ' : null,
        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        suffixText: suffixText,
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B7280), fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE52929), width: 1.5),
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
    final statusLower = status.toLowerCase();
    final bool verified = isVerified || statusLower == 'verified' || statusLower == 'approved';
    final bool inReview = statusLower == 'in_review';
    final bool rejected = statusLower == 'rejected';

    Color color;
    Color bgColor;
    IconData icon;
    String label;

    if (verified) {
      color = const Color(0xFF10B981);
      bgColor = const Color(0xFFECFDF5);
      icon = Icons.check_circle_outline;
      label = 'KYC Verified';
    } else if (inReview) {
      color = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFFFBEB);
      icon = Icons.hourglass_top_outlined;
      label = 'In Review';
    } else if (rejected) {
      color = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFEF2F2);
      icon = Icons.error_outline;
      label = 'KYC Rejected';
    } else {
      color = const Color(0xFF3B82F6);
      bgColor = const Color(0xFFEFF6FF);
      icon = Icons.shield_outlined;
      label = 'Verify KYC';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<SellerProfilePageBloc>.value(
              value: context.read<SellerProfilePageBloc>(),
              child: const SellerVerificationFormPage(),
            ),
          ),
        );
      },
      child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.storefront_outlined,
                color: Color(0xFFE52929),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Edit Profile',
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

  void _openSellerScopedPage(
    BuildContext context,
    Widget Function(String sellerId) pageBuilder,
  ) {
    final sellerId = SellerRepository().currentUser?.uid ?? '';
    if (sellerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pageBuilder(sellerId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 700;
        final double itemWidth = isDesktop ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;

        final List<Map<String, dynamic>> menuItems = [
          {
            'icon': Icons.verified_user_outlined,
            'iconColor': state.isKycApproved ? const Color(0xFF10B981) : const Color(0xFFE52929),
            'iconBgColor': state.isKycApproved ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
            'title': 'KYC & Verification',
            'subtitle': state.isKycApproved
                ? 'KYC Verified ✓'
                : (state.isKycInReview
                    ? 'In Review ⏳'
                    : (state.isKycRejected ? 'Rejected ⚠ (Re-upload)' : 'Upload documents for approval')),
            'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider<SellerProfilePageBloc>.value(
                  value: context.read<SellerProfilePageBloc>(),
                  child: const SellerVerificationFormPage(),
                ),
              ),
            ),
          },
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
            'icon': Icons.people_outline,
            'iconColor': const Color(0xFF3B82F6),
            'iconBgColor': const Color(0xFFEFF6FF),
            'title': 'Customer Insights',
            'subtitle': 'View regular customers and order activity',
            'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellerCustomerPage()),
            ),
          },
          {
            'icon': Icons.restaurant_menu_outlined,
            'iconColor': const Color(0xFFF43F5E),
            'iconBgColor': const Color(0xFFFFF1F2),
            'title': 'Menu Categories',
            'subtitle': 'Select and reorder your menu categories',
            'onTap': () => _openSellerScopedPage(
              context,
              (id) => MenuCategoryManagementPage(sellerId: id),
            ),
          },
          {
            'icon': Icons.local_offer_outlined,
            'iconColor': const Color(0xFF14B8A6),
            'iconBgColor': const Color(0xFFF0FDFA),
            'title': 'Promotions & Coupons',
            'subtitle': 'Create and manage special offers',
            'onTap': () => _openSellerScopedPage(
              context,
              (id) => PromotionsCouponsPage(sellerId: id),
            ),
          },
          {
            'icon': Icons.access_time_outlined,
            'iconColor': const Color(0xFFF59E0B),
            'iconBgColor': const Color(0xFFFFFBEB),
            'title': 'Business Hours',
            'subtitle': 'Set your store opening and closing times',
            'onTap': () => _openSellerScopedPage(
              context,
              (id) => BusinessHoursPage(sellerId: id),
            ),
          },
          {
            'icon': Icons.gavel_outlined,
            'iconColor': const Color(0xFF8B5CF6),
            'iconBgColor': const Color(0xFFF5F3FF),
            'title': 'Disputes & Refunds',
            'subtitle': 'Manage customer disputes and refund requests',
            'onTap': () => _openSellerScopedPage(
              context,
              (id) => DisputesRefundsPage(sellerId: id),
            ),
          },
          {
            'icon': Icons.chat_bubble_outline,
            'iconColor': const Color(0xFF06B6D4),
            'iconBgColor': const Color(0xFFECFEFF),
            'title': 'Support Chat',
            'subtitle': 'Contact admin support or customers',
            'onTap': () => _openSellerScopedPage(
              context,
              (id) => ChatSupportPage(sellerId: id),
            ),
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
              child: HoverableCard(
                onTap: item['onTap'] as VoidCallback,
                hoverScale: 1.02,
                borderRadius: BorderRadius.circular(SellerUiTokens.radiusCard),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(SellerUiTokens.radiusCard),
                    border: Border.all(color: SellerUiTokens.borderSubtle),
                    boxShadow: SellerUiTokens.cardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item['iconBgColor'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['iconColor'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'] as String,
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
            );
          }),
        );
      },
    );
  }
}


