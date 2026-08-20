import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/widgets/responsive_layout.dart';

import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';
import '../buyer_login_page/buyer_login_page_ui.dart';
import 'onboarding_page_Bloc.dart';
import 'onboarding_page_Event.dart';
import 'onboarding_page_State.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

/// The main entry point for the Onboarding Page UI.
/// It wraps the view in a BlocProvider.
class OnboardingPage extends StatelessWidget {
  final VoidCallback? onNavigateToCart;

  const OnboardingPage({super.key, this.onNavigateToCart});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingPageBloc(authService: context.read<IAuthService>()),
      child: OnboardingPageView(onNavigateToCart: onNavigateToCart),
    );
  }
}

/// The actual View of the Onboarding Page.
class OnboardingPageView extends StatelessWidget {
  final VoidCallback? onNavigateToCart;

  const OnboardingPageView({super.key, this.onNavigateToCart});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingPageBloc, OnboardingPageState>(
      listener: (context, state) {
        if (state is OnboardingNavigateToLogin) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const BuyerLoginPageUI(),
            ),
            (route) => false,
          );
        } else if (state is OnboardingNavigateToHome ||
            state is OnboardingAuthenticated) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const CurvedNavigationBarView(),
            ),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<OnboardingPageBloc, OnboardingPageState>(
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
          if (state is OnboardingAuthWaiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFFBF5F5),
              body: Center(
                child: CircularProgressIndicator(color: BuyerAppColors.primaryDeep),
              ),
            );
          }

          // Default / OnboardingUnauthenticated
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (ResponsiveHelper.isWide(context)) {
                    return _buildWideLayout(context, constraints);
                  } else {
                    return _buildMobileLayout(context, constraints);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the layout suitable for Mobile screens.
  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    final double screenHeight = constraints.maxHeight;
    final bool isSmallScreen = screenHeight < 650;

    final double topSpacing = isSmallScreen ? 12.0 : 24.0;
    final double imageSpacing = isSmallScreen ? 16.0 : 32.0;
    final double titleSpacing = isSmallScreen ? 12.0 : 16.0;
    final double subtitleSpacing = isSmallScreen ? 16.0 : 32.0;
    final double buttonSpacing = isSmallScreen ? 20.0 : 40.0;
    final double bottomSpacing = isSmallScreen ? 12.0 : 24.0;

    final double chefImageHeight = screenHeight * (isSmallScreen ? 0.3 : 0.4);

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topSpacing),
              // Chef illustration image
              Image.asset(
                'assets/images/chef.png',
                height: chefImageHeight,
                fit: BoxFit.contain,
              ),
              SizedBox(height: imageSpacing),
              // Title text
              const Text(
                'The Fastest\nFood Delivery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              SizedBox(height: titleSpacing),
              // Subtitle description text
              const Text(
                'Craving something delicious?\nOrder now and get your favorites\ndelivered fast!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              SizedBox(height: subtitleSpacing),
              SizedBox(height: buttonSpacing),
              // Get Started Button
              HoverButton(
                key: const ValueKey('onboardingNextButton'),
                onTap: () {
                  context.read<OnboardingPageBloc>().add(
                    OnboardingGetStartedPressed(isWebLayout: false),
                  );
                },
                text: 'Get Started',
              ),
              SizedBox(height: bottomSpacing),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the layout suitable for Web and larger screens.
  Widget _buildWideLayout(BuildContext context, BoxConstraints constraints) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left column: Chef illustration with premium background radial gradient
            Expanded(
              flex: 5,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: constraints.maxWidth * 0.35,
                      height: constraints.maxWidth * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7A4A28).withValues(alpha: 0.08),
                            const Color(0xFF7A4A28).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/chef.png',
                      height: constraints.maxHeight * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
            // Right column: Tagline, Title, Subtitle, and Button
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tagline container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A4A28).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '⚡ Express Delivery',
                          style: TextStyle(
                            color: Color(0xFF7A4A28),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      const Text(
                        'The Fastest\nFood Delivery',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Subtitle
                      const Text(
                        'Craving something delicious? Order now and get your favorites delivered right to your doorstep in record time.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Get Started Button
                      HoverButton(
                        key: const ValueKey('onboardingNextButton_web'),
                        onTap: () {
                          context.read<OnboardingPageBloc>().add(
                            OnboardingGetStartedPressed(isWebLayout: true),
                          );
                        },
                        text: 'Get Started',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom button that scales and changes color on hover.
class HoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;

  const HoverButton({super.key, required this.onTap, required this.text});

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
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
          curve: Curves.easeInOut,
          width: _isHovered ? 280 : 260,
          height: 56,
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFF965D37)
                : const Color(0xFF7A4A28),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: const Color(0xFF7A4A28).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: AnimatedScale(
            scale: _isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
