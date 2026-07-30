import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Delivery_onboarding_page_bloc.dart';
import 'Delivery_onboarding_page_event.dart';
import 'Delivery_onboarding_page_state.dart';

class DeliveryOnboardingPageUI extends StatefulWidget {
  const DeliveryOnboardingPageUI({super.key});

  @override
  State<DeliveryOnboardingPageUI> createState() =>
      _DeliveryOnboardingPageUIState();
}

class _DeliveryOnboardingPageUIState extends State<DeliveryOnboardingPageUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
    context.read<DeliveryOnboardingPageBloc>().add(
          const DeliveryOnboardingInitEvent(),
        );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF090D14),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E676),
        surface: Color(0xFF121A24),
      ),
    );

    return Theme(
      data: themeData,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Delivery_onboarding.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(color: Colors.black.withOpacity(0.55)),
            SafeArea(
            child: BlocConsumer<DeliveryOnboardingPageBloc,
                DeliveryOnboardingPageState>(
              listener: (context, state) {
                if (state.isStarted) {
                  Navigator.of(context).pushReplacementNamed('/deliverylogin');
                } else if (state.isNavigatingToLogin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigating to Partner Login...'),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == DeliveryOnboardingStatus.loading) {
                  return _buildSkeletonLoading();
                }

                if (state.status == DeliveryOnboardingStatus.error) {
                  return _buildErrorView(
                    context,
                    state.errorMessage ?? 'An error occurred',
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 960 && constraints.maxHeight >= 650;
                        if (isDesktop) {
                          return Center(
                            child: Container(
                              width: 1080,
                              height: 680,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Row(
                                children: [
                                  // Left Hero Panel
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F1420).withOpacity(0.95),
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.white.withOpacity(0.08),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLogoHeader(),
                                          const Spacer(),
                                          Center(
                                            child: Image.asset(
                                              'assets/images/Delivery_scooter.png',
                                              height: 250,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const Spacer(),
                                          RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Deliver Happiness,\n',
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                    height: 1.2,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'Every Day!',
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF00E676),
                                                    height: 1.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Join thousands of delivery partners and earn more with flexible hours, real-time tracking, and secure payments — all in one app.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white60,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          _buildGradientActionButton(context),
                                          const SizedBox(height: 16),
                                          _buildLoginLink(context),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Right Features Panel
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0A0E17).withOpacity(0.80),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildFeaturesTitle(),
                                              _buildLanguageSelector(context, state),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          _buildTitleIndicator(),
                                          const SizedBox(height: 24),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: state.features.length,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 16,
                                              crossAxisSpacing: 16,
                                              childAspectRatio: 1.35,
                                            ),
                                            itemBuilder: (context, index) {
                                              final feature = state.features[index];
                                              return _buildFeatureCard(feature);
                                            },
                                          ),
                                          const Spacer(),
                                          _buildStatsBanner(state.partnerStats),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Mobile View layout
                        return Column(
                          children: [
                            _buildHeader(context, state),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Column(
                                  children: [
                                    _buildHeroLeftSection(
                                      context,
                                      state,
                                    ),
                                    const SizedBox(height: 32),
                                    _buildFeaturesRightSection(
                                      context,
                                      state,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF00E676).withOpacity(0.25),
            ),
          ),
          child: const Icon(
            Icons.electric_scooter_rounded,
            color: Color(0xFF00E676),
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'DeliverGo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Delivery Partner App',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientActionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00E676),
            Color(0xFF09D261),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<DeliveryOnboardingPageBloc>().add(
                const DeliveryOnboardingGetStartedClickedEvent(),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          context.read<DeliveryOnboardingPageBloc>().add(
                const DeliveryOnboardingLoginClickedEvent(),
              );
        },
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              TextSpan(
                text: 'Login',
                style: TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesTitle() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Why Partner with ',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: 'DeliverGo?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00E676),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleIndicator() {
    return Container(
      width: 40,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFF00E676),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    DeliveryOnboardingPageState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF121B26).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedLanguage,
          dropdownColor: const Color(0xFF0E1520),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white70,
            size: 18,
          ),
          items: ['English', 'Tamil', 'Hindi', 'Spanish']
              .map(
                (lang) => DropdownMenuItem(
                  value: lang,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        size: 14,
                        color: Color(0xFF00E676),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lang,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              context.read<DeliveryOnboardingPageBloc>().add(
                    DeliveryOnboardingLanguageChangedEvent(val),
                  );
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DeliveryOnboardingPageState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00E676).withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.electric_scooter_rounded,
                  color: Color(0xFF00E676),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'DeliverGo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Delivery Partner App',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildLanguageSelector(context, state),
        ],
      ),
    );
  }

  Widget _buildHeroLeftSection(
    BuildContext context,
    DeliveryOnboardingPageState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Delivery Scooter Illustration
        Image.asset(
          'assets/images/Delivery_scooter.png',
          height: 260,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 32),

        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Deliver Happiness,\n',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'Every Day!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00E676),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Join thousands of delivery partners and earn more with flexible hours, real-time tracking, and secure payments — all in one app.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white60,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),

        // Action Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              context.read<DeliveryOnboardingPageBloc>().add(
                    const DeliveryOnboardingGetStartedClickedEvent(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF00E676).withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildLoginLink(context),
      ],
    );
  }

  Widget _buildFeaturesRightSection(
    BuildContext context,
    DeliveryOnboardingPageState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeaturesTitle(),
        const SizedBox(height: 6),
        _buildTitleIndicator(),
        const SizedBox(height: 24),

        // 2x2 Feature Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final feature = state.features[index];
            return _buildFeatureCard(feature);
          },
        ),

        const SizedBox(height: 24),

        // Bottom Stats Banner
        _buildStatsBanner(state.partnerStats),
      ],
    );
  }

  Widget _buildFeatureCard(OnboardingFeatureItem feature) {
    IconData getIcon(String key) {
      switch (key) {
        case 'fast_delivery':
          return Icons.rocket_launch_rounded;
        case 'flexible_earnings':
          return Icons.account_balance_wallet_rounded;
        case 'live_tracking':
          return Icons.radar_rounded;
        case 'secure_payments':
          return Icons.verified_user_rounded;
        default:
          return Icons.star_rounded;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B121C).withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E676).withOpacity(0.08),
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  blurRadius: 8,
                )
              ],
            ),
            child: Icon(
              getIcon(feature.iconKey),
              color: const Color(0xFF00E676),
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            feature.description,
            style: const TextStyle(
              fontSize: 10.5,
              color: Colors.white54,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBanner(List<PartnerStatItem> stats) {
    IconData getStatIcon(String key) {
      switch (key) {
        case 'partners':
          return Icons.people_alt_outlined;
        case 'speed':
          return Icons.speed_rounded;
        case 'rating':
          return Icons.star_rounded;
        case 'support':
          return Icons.headset_mic_outlined;
        default:
          return Icons.info_outline;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B121C).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getStatIcon(stat.iconKey),
                  color: const Color(0xFF00E676),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    stat.label,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF00E676),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DeliveryOnboardingPageBloc>().add(
                    const DeliveryOnboardingRefreshEvent(),
                  );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF00E676).withOpacity(0.4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(20, size.height * 0.7);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.95,
      size.width - 20,
      size.height * 0.3,
    );

    canvas.drawPath(path, paintLine);

    final dotPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.fill;

    final dotGlow = Paint()
      ..color = const Color(0xFF00E676).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(20, size.height * 0.7), 10, dotGlow);
    canvas.drawCircle(Offset(20, size.height * 0.7), 5, dotPaint);

    canvas.drawCircle(Offset(size.width - 20, size.height * 0.3), 10, dotGlow);
    canvas.drawCircle(Offset(size.width - 20, size.height * 0.3), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

