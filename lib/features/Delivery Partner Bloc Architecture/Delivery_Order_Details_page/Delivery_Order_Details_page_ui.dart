import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Order_Details_page_bloc.dart';
import 'Delivery_Order_Details_page_event.dart';
import 'Delivery_Order_Details_page_state.dart';
import '../auto_hide_app_bar_wrapper.dart';


class DeliveryOrderDetailsPageUi extends StatelessWidget {
  final String orderId;

  const DeliveryOrderDetailsPageUi({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    final appBar = AppBar(
      backgroundColor: const Color(0xFF0C121E),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'LOGISTICS ORDER PANEL',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
    );

    final Widget bodyContent = BlocBuilder<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      builder: (context, state) {
        if (state.status == OrderDetailsStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
            ),
          );
        } else if (state.status == OrderDetailsStatus.error) {
          return Center(
            child: Text(
              state.errorMessage ?? 'An error occurred',
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          );
        } else if (state.status == OrderDetailsStatus.success && state.order != null) {
          final order = state.order!;
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1024;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 1200 : 600,
                    ),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _buildDetailsColumn(context, order),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 7,
                                child: _buildLiveMapPane(),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildDetailsColumn(context, order),
                              const SizedBox(height: 16),
                              _buildLiveMapPane(),
                            ],
                          ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );

    return BlocProvider(
      create: (context) => DeliveryOrderDetailsPageBloc()..add(FetchOrderDetailsEvent(orderId)),
      child: Scaffold(
        backgroundColor: const Color(0xFF070B11),
        appBar: isMobile ? null : appBar,
        body: isMobile
            ? AutoHideAppBarWrapper(
                appBar: appBar,
                body: bodyContent,
                appBarHeight: kToolbarHeight,
                isMobile: true,
              )
            : bodyContent,
      ),
    );
  }


  Widget _buildDetailsColumn(BuildContext context, OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Glassmorphic Customer & Status Card
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1B2533),
                    child: Icon(Icons.person, color: Colors.white70, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Details',
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Mike Residence Client',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.customerPhone,
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E676).withOpacity(0.35)),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Pickup & Drop Details Card
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationRow(
                icon: Icons.store,
                iconColor: Colors.cyanAccent,
                title: 'Pickup Details (Merchant)',
                address: order.pickupAddress,
                phone: order.merchantPhone,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Colors.white10, height: 1),
              ),
              _buildLocationRow(
                icon: Icons.location_on,
                iconColor: Colors.redAccent,
                title: 'Drop Details (Customer)',
                address: order.dropoffAddress,
                phone: order.customerPhone,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Order Items & Financial Summary Card
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ORDERED ITEMS',
                style: TextStyle(
                  color: Color(0xFF00E676),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              _buildItemRow('Fresh Veggies Bundle', 'x3', '₹300.00'),
              _buildItemRow('Premium Fruits Assortment', 'x2', '₹320.00'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Colors.white10, height: 1),
              ),
              _buildSummaryRow('Distance', '${order.distance} km'),
              _buildSummaryRow('Order Value', '₹${order.orderValue.toStringAsFixed(2)}'),
              _buildSummaryRow('Your Earnings', '₹${order.earnings.toStringAsFixed(2)}', isHighlight: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Navigation & Action Buttons Row
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('NAVIGATE', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00E676),
                    side: const BorderSide(color: Color(0xFF00E676)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    // Navigate trigger
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    final nextStatus = _getNextStatus(order.status);
                    if (nextStatus != null) {
                      BlocProvider.of<DeliveryOrderDetailsPageBloc>(context)
                          .add(UpdateOrderStatusEvent(order.id, nextStatus));
                    }
                  },
                  child: Text(
                    _getButtonText(order.status).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1424).withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
    required String phone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: iconColor.withOpacity(0.12),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                'Contact: $phone',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(String name, String quantity, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(width: 8),
          Text(quantity, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Text(price, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? const Color(0xFF00E676) : Colors.white,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMapPane() {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        color: const Color(0xFF0C121E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.near_me, color: Color(0xFF00E676), size: 56),
            SizedBox(height: 16),
            Text(
              'LIVE ROUTE MAP PANEL',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tracking current delivery status in real-time',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String? _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Pending':
        return 'Reached Pickup';
      case 'Reached Pickup':
        return 'Started Delivery';
      case 'Started Delivery':
        return 'Completed';
      default:
        return null;
    }
  }

  String _getButtonText(String currentStatus) {
    switch (currentStatus) {
      case 'Pending':
        return 'Reached Pickup';
      case 'Reached Pickup':
        return 'Start Delivery';
      case 'Started Delivery':
        return 'Complete Order';
      default:
        return 'Order Completed';
    }
  }
}
