import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_store_details_page__bloc.dart';
import 'seller_store_details_page__event.dart';
import 'seller_store_details_page__state.dart';

class SellerStoreDetailsPage extends StatelessWidget {
  const SellerStoreDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerStoreDetailsBloc()..add(LoadStoreDetailsEvent()),
      child: const _SellerStoreDetailsView(),
    );
  }
}

class _SellerStoreDetailsView extends StatelessWidget {
  const _SellerStoreDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Store Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<SellerStoreDetailsBloc, SellerStoreDetailsPageState>(
        builder: (context, state) {
          if (state is SellerStoreDetailsLoading || state is SellerStoreDetailsInitial) {
            return const _StoreDetailsSkeleton();
          } else if (state is SellerStoreDetailsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is SellerStoreDetailsLoaded) {
            return _StoreDetailsContent(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Trigger edit event or navigation
              context.read<SellerStoreDetailsBloc>().add(const EditStoreDetailsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Edit Store Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreDetailsContent extends StatelessWidget {
  final SellerStoreDetailsLoaded state;

  const _StoreDetailsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                icon: Icons.storefront,
                title: state.restaurantName,
                subtitle: '${state.address}\n${state.phone}',
              ),
              const Divider(height: 32),
              _buildInfoRow(
                icon: Icons.access_time,
                title: 'Opening Hours',
                subtitle: state.openingHours,
              ),
              const Divider(height: 32),
              _buildInfoRow(
                icon: Icons.timer_outlined,
                title: 'Delivery Time',
                subtitle: state.deliveryTime,
              ),
              const Divider(height: 32),
              _buildInfoRow(
                icon: Icons.delivery_dining,
                title: 'Delivery Area',
                subtitle: state.deliveryArea,
              ),
              if (state.gstNumber != null) ...[
                const Divider(height: 32),
                _buildInfoRow(
                  icon: Icons.account_balance_outlined,
                  title: 'GST Number',
                  subtitle: state.gstNumber!,
                ),
              ],
              if (state.fssaiNumber != null) ...[
                const Divider(height: 32),
                _buildInfoRow(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'FSSAI License Number',
                  subtitle: state.fssaiNumber!,
                ),
              ],
              if (state.panNumber != null) ...[
                const Divider(height: 32),
                _buildInfoRow(
                  icon: Icons.credit_card_outlined,
                  title: 'PAN Number',
                  subtitle: state.panNumber!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoreDetailsSkeleton extends StatelessWidget {
  const _StoreDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: List.generate(4, (index) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 16,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 200,
                              height: 14,
                              color: Colors.grey.shade300,
                            ),
                            if (index == 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 120,
                                height: 14,
                                color: Colors.grey.shade300,
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (index < 3) const Divider(height: 32),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
