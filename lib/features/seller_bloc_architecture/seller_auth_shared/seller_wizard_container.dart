import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seller_auth_shared_widgets.dart';

/// Universal responsive wrapper for all Seller Onboarding & Store Setup Wizard pages.
/// Enforces consistent container width across Desktop (> 900px -> 860px), Tablet (680px), and Mobile (100%),
/// unified header with progress badge & bar, and green primary action buttons.
class SellerWizardContainer extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final String stepBadge;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget child;
  final Widget? bottomAction;
  final Widget? headerTrailing;
  final bool showProgress;
  final double maxWidth;

  const SellerWizardContainer({
    super.key,
    required this.stepIndex,
    this.totalSteps = 8,
    required this.stepBadge,
    required this.title,
    required this.subtitle,
    this.onBack,
    required this.child,
    this.bottomAction,
    this.headerTrailing,
    this.showProgress = true,
    this.maxWidth = 860.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final horizontalPadding = isDesktop ? 28.0 : (isTablet ? 20.0 : 16.0);

    final double effectiveMaxWidth = isDesktop
        ? maxWidth
        : (isTablet ? 680.0 : double.infinity);

    final double progressValue = (stepIndex / totalSteps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            child: Column(
              children: [
                // 1. Unified Wizard Header & Progress Bar
                SellerWizardHeader(
                  stepIndex: stepIndex,
                  totalSteps: totalSteps,
                  stepBadge: stepBadge,
                  title: title,
                  subtitle: subtitle,
                  onBack: onBack,
                  headerTrailing: headerTrailing,
                  showProgress: showProgress,
                  progressValue: progressValue,
                  horizontalPadding: horizontalPadding,
                ),

                // 2. Scrollable Body Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        child,
                        if (bottomAction != null) ...[
                          const SizedBox(height: 32),
                          bottomAction!,
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Unified Header component for all wizard steps with multi-segment step indicator.
class SellerWizardHeader extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final String stepBadge;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget? headerTrailing;
  final bool showProgress;
  final double progressValue;
  final double horizontalPadding;

  const SellerWizardHeader({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.stepBadge,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.headerTrailing,
    required this.showProgress,
    required this.progressValue,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final int percent = ((stepIndex / (totalSteps > 0 ? totalSteps : 1)) * 100).round().clamp(0, 100);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Multi-Segment Step Indicator Track
          if (showProgress && totalSteps > 1) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8.0,
              ),
              child: Row(
                children: List.generate(totalSteps, (index) {
                  final stepNum = index + 1;
                  final isCompleted = stepNum < stepIndex;
                  final isCurrent = stepNum == stepIndex;

                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? SellerAuthColors.primary
                            : (isCurrent
                                ? SellerAuthColors.primary
                                : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: SellerAuthColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],

          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: showProgress ? 4.0 : 12.0,
              bottom: 12.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (onBack != null) ...[
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Step Badge Pill & Progress Indicator Row
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: SellerAuthColors.primarySurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: SellerAuthColors.primaryLight.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: SellerAuthColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      stepBadge,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: SellerAuthColors.primary,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$percent% Completed',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (headerTrailing != null) ...[
                  const SizedBox(width: 12),
                  headerTrailing!,
                ],
              ],
            ),
          ),
          if (showProgress)
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(SellerAuthColors.primary),
              minHeight: 2,
            ),
        ],
      ),
    );
  }
}

/// Standardized Primary CTA Button matching the Login Theme Green for all wizard steps.
class SellerWizardPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;
  final Key? buttonKey;
  final double height;

  const SellerWizardPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon = Icons.arrow_forward_rounded,
    this.buttonKey,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        key: buttonKey,
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SellerAuthColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SellerAuthColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          elevation: 2,
          shadowColor: SellerAuthColors.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 20, color: Colors.white),
                ],
              ),
      ),
    );
  }
}
