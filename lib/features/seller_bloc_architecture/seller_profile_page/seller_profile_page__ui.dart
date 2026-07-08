import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Assume this is in pubspec
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

class SellerProfilePageUI extends StatelessWidget {
  const SellerProfilePageUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerProfilePageBloc()..add(LoadProfile()),
      child: const Scaffold(
        backgroundColor: Colors.white,
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
          // Desktop Layout
          return const Center(
            child: SizedBox(
              width: 800,
              child: ProfileContent(),
            ),
          );
        } else if (constraints.maxWidth > 600) {
          // Tablet Layout
          return const Center(
            child: SizedBox(
              width: 600,
              child: ProfileContent(),
            ),
          );
        }
        // Mobile Layout
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade100,
                          image: const DecorationImage(
                            // In real app use CachedNetworkImageProvider
                            image: NetworkImage('https://via.placeholder.com/150'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.storeName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.phone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerWalletPage()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'Business Details',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerStoreDetailsPage()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.account_balance_outlined,
                    title: 'Bank Details',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerPaymentPage()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerForgotPasswordPageUI()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification Settings',
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
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      context.read<SellerProfilePageBloc>().add(LogoutRequested());
                    },
                  ),
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
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4B5563), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF3F4F6),
    );
  }
}

class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 100, height: 30, color: Colors.grey.shade200),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 20, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Container(width: 200, height: 16, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 16, color: Colors.grey.shade200),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          for (int i = 0; i < 5; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Container(width: 24, height: 24, color: Colors.grey.shade200),
                  const SizedBox(width: 16),
                  Container(width: 150, height: 20, color: Colors.grey.shade200),
                  const Spacer(),
                  Container(width: 24, height: 24, color: Colors.grey.shade200),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.transparent),
          ],
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3, // 'More' tab is selected in the image
      selectedItemColor: Colors.red,
      unselectedItemColor: const Color(0xFF6B7280),
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'More',
        ),
      ],
    );
  }
}
