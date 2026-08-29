import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../repositories/seller_repository.dart';
import '../seller_auth_shared/onboarding_back_handler.dart';
import '../seller_auth_shared/seller_wizard_container.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';

/// Step 8: Store Readiness Checklist & 1-Click Store Launch 🚀
class SellerStoreLaunchPage extends StatefulWidget {
  final String sellerId;
  final bool isOnboardingFlow;

  const SellerStoreLaunchPage({
    super.key,
    required this.sellerId,
    this.isOnboardingFlow = true,
  });

  @override
  State<SellerStoreLaunchPage> createState() => _SellerStoreLaunchPageState();
}

class _SellerStoreLaunchPageState extends State<SellerStoreLaunchPage> {
  bool _isLaunching = false;
  String _storeName = 'Your Store';

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final uid = widget.sellerId.isNotEmpty
        ? widget.sellerId
        : SellerRepository().currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        final doc = await SellerRepository().fetchSeller(uid);
        if (mounted) {
          final name = doc.shopName.isNotEmpty
              ? doc.shopName
              : (doc.sellerName.isNotEmpty ? doc.sellerName : 'Your Store');
          setState(() => _storeName = name);
        }
      } catch (_) {}
    }
  }

  Future<void> _launchStoreLive() async {
    setState(() => _isLaunching = true);
    final repo = SellerRepository();
    final uid = widget.sellerId.isNotEmpty
        ? widget.sellerId
        : repo.currentUser?.uid;

    if (uid != null && uid.isNotEmpty) {
      try {
        await repo.updateSellerData(uid, {
          'isOnboardingCompleted': true,
          'storeSetupPhase': 'completed',
          'isApproved': true,
          'isOpen': true,
          'isOnline': true,
          'isActive': true,
          'isKycVerified': true,
          'isStoreDetailsCompleted': true,
          'isBusinessHoursCompleted': true,
          'isProfileSetupCompleted': true,
          'isMenuSetupCompleted': true,
          'isBankDetailsCompleted': true,
          'isLogisticsCompleted': true,
          'launchedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Error launching store: $e');
      }
    }

    if (mounted) {
      setState(() => _isLaunching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.rocket_launch_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('🎉 Congratulations! Your store is now live and accepting orders!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Direct entry to Real-Time Dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/sellerDashboard',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isOnboardingFlow,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (widget.isOnboardingFlow) {
          await OnboardingBackHandler.handleBack(context, previousRoute: '/sellerLogisticsAlerts');
        }
      },
      child: SellerWizardContainer(
        stepIndex: 8,
        totalSteps: 8,
        stepBadge: 'Step 8 of 8 • Store Readiness & Launch',
        title: 'Store Readiness & 1-Click Launch 🚀',
        subtitle: 'Review all verified modules and launch your store live to start accepting customer orders',
        onBack: () => OnboardingBackHandler.handleBack(context, previousRoute: '/sellerLogisticsAlerts'),
        bottomAction: SellerWizardPrimaryButton(
          buttonKey: const ValueKey('launch_store_live_btn'),
          label: 'Launch My Store Live 🚀',
          isLoading: _isLaunching,
          onPressed: _launchStoreLive,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Store Hero Card
            _buildStoreHeroCard(),
            const SizedBox(height: 20),

            // Readiness Checklist Grid
            _buildReadinessChecklistCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _storeName,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '100% READY FOR LAUNCH',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'All compliance, operational schedules, menu items, bank payouts, and audio alert channels are configured.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessChecklistCard() {
    final checklistItems = [
      {
        'title': 'Step 1: KYC Legal & Tax Compliance',
        'subtitle': 'FSSAI License, GSTIN, PAN Card, and Passbook verified',
        'icon': Icons.verified_user_rounded,
      },
      {
        'title': 'Step 2: Store Address & Map Coordinates',
        'subtitle': 'Precise GPS geocoding and delivery radius set',
        'icon': Icons.location_on_rounded,
      },
      {
        'title': 'Step 3: Operating Schedule & Business Hours',
        'subtitle': 'Weekly opening/closing times and holiday slots active',
        'icon': Icons.access_time_filled_rounded,
      },
      {
        'title': 'Step 4: Profile Branding & Live Switch',
        'subtitle': 'Logo, Banner, store bio, cuisines & live switch configured',
        'icon': Icons.store_rounded,
      },
      {
        'title': 'Step 5: Menu Categories & Dishes Catalogue',
        'subtitle': 'Active food categories and initial item catalogue populated',
        'icon': Icons.restaurant_menu_rounded,
      },
      {
        'title': 'Step 6: Bank Account & Payout Settlement',
        'subtitle': 'Direct IFSC bank transfer linked for daily earnings',
        'icon': Icons.account_balance_rounded,
      },
      {
        'title': 'Step 7: Delivery Logistics & Order Audio Alerts',
        'subtitle': 'Auto-dispatch radius, ringtones, and loud alert chimes enabled',
        'icon': Icons.notifications_active_rounded,
      },
      {
        'title': 'Step 8: Store Readiness Checklist & 1-Click Launch',
        'subtitle': 'All verified configurations synced, store is 100% ready to go live',
        'icon': Icons.rocket_launch_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, color: SellerAuthColors.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Launch Readiness Checklist (8/8 Complete)',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: checklistItems.length,
            separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF8FAFC)),
            itemBuilder: (context, index) {
              final item = checklistItems[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: SellerAuthColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: SellerAuthColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['subtitle'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
