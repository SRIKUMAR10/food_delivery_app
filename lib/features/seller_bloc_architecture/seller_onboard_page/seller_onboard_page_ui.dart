import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/primary_button.dart';

import 'seller_onboard_page_bloc.dart';
import 'seller_onboard_page_event.dart';
import 'seller_onboard_page_state.dart';

class SellerOnboardPageUI extends StatelessWidget {
  const SellerOnboardPageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerOnboardPageBloc(),
      child: const SellerOnboardView(),
    );
  }
}

class SellerOnboardView extends StatefulWidget {
  const SellerOnboardView({Key? key}) : super(key: key);

  @override
  State<SellerOnboardView> createState() => _SellerOnboardViewState();
}

class _SellerOnboardViewState extends State<SellerOnboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutQuart,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout configuration

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<SellerOnboardPageBloc, SellerOnboardPageState>(
        listener: (context, state) {
          if (state is SellerOnboardError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is SellerOnboardSuccess) {
            // Navigate to Seller Login Page
            Navigator.of(context).pushReplacementNamed('/sellerlogin');
          }
        },
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ), // Max width for desktop/tablet
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 55,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(flex: 3),
                              // Store Icon or Image
                              Flexible(
                                flex: 6,
                                child: _buildStoreIcon(context),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                'Seller App',
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Subtitle
                              Text(
                                'Manage your restaurant\nbusiness with ease',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                              const Spacer(flex: 3),

                              // Get Started Button
                              _buildGetStartedButton(context, state),
                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Pizza Image
                      Expanded(
                        flex: 45,
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/seller onboard page_2.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.error)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreIcon(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Dynamic width/height using MediaQuery
    final double iconSize = (size.width * 0.35).clamp(100.0, 160.0);

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Image.asset(
        'assets/images/seller onboard page.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.storefront_rounded,
            size: iconSize * 0.6,
            color: Colors.orange.shade400,
          );
        },
      ),
    );
  }

  Widget _buildGetStartedButton(
    BuildContext context,
    SellerOnboardPageState state,
  ) {
    return PrimaryButton(
      text: 'Get Started',
      isLoading: state is SellerOnboardLoading,
      onPressed: () {
        context.read<SellerOnboardPageBloc>().add(
          SellerOnboardGetStartedPressed(),
        );
      },
    );
  }
}
