import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Incoming_Order_page_bloc.dart';
import 'Delivery_Incoming_Order_page_event.dart';
import 'Delivery_Incoming_Order_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/widgets/app_google_map_view.dart';

class DeliveryIncomingOrderPageUi extends StatelessWidget {
  const DeliveryIncomingOrderPageUi({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryIncomingOrderBloc>(
      create: (_) => DeliveryIncomingOrderBloc()
        ..add(const DeliveryIncomingOrderLoadEvent()),
      child: const _IncomingOrderView(),
    );
  }
}

class _IncomingOrderView extends StatelessWidget {
  const _IncomingOrderView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryIncomingOrderBloc, DeliveryIncomingOrderState>(
      listener: (context, state) {
        if (state.status == IncomingOrderStatus.accepted) {
          Navigator.of(context).pushReplacementNamed(
            '/deliveryPickupConfirmation',
            arguments: {'orderId': state.orderId},
          );
        } else if (state.status == IncomingOrderStatus.declined ||
            state.status == IncomingOrderStatus.expired) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed('/deliveryNavigationBar');
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF070B11),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0C121E),
            title: const Text(
              'INCOMING ORDER REQUEST',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1024;
              return Column(
                children: [
                  Expanded(
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildMapPane(state),
                              ),
                              Expanded(
                                flex: 4,
                                child: _buildDetailsPane(state),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildMapPane(state),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildDetailsPane(state),
                              ),
                            ],
                          ),
                  ),
                  _buildBottomActionBar(context, state),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMapPane(DeliveryIncomingOrderState state) {
    final storeLoc = (state.storeLatitude != 0 && state.storeLongitude != 0)
        ? LatLng(state.storeLatitude, state.storeLongitude)
        : const LatLng(11.4299713, 77.6759418);
    final customerLoc = (state.customerLatitude != 0 && state.customerLongitude != 0)
        ? LatLng(state.customerLatitude, state.customerLongitude)
        : const LatLng(11.4555052, 77.6873137);
    final driverLoc = (state.driverLatitude != 0 && state.driverLongitude != 0)
        ? LatLng(state.driverLatitude, state.driverLongitude)
        : storeLoc;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C121E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: AppGoogleMapView(
                driverLocation: driverLoc,
                driverHeading: 0.0,
                vehicleType: 'two_wheeler',
                storeLocation: storeLoc,
                storeName: state.storeName.isNotEmpty ? state.storeName : 'Pickup Store',
                storeAddress: state.storeAddress,
                customerLocation: customerLoc,
                customerName: state.customerName.isNotEmpty ? state.customerName : 'Customer Address',
                customerAddress: state.customerAddress,
                isPickedUp: false,
                isDarkMode: true,
                showControls: true,
                showProgressCard: true,
                distanceKm: state.distanceKm > 0 ? state.distanceKm : null,
                etaText: state.etaMins > 0 ? '${state.etaMins} mins' : 'Calculating ETA...',
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route, color: DeliveryAppColors.primary, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'ROUTE PREVIEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPane(DeliveryIncomingOrderState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DeliveryAppColors.background.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DELIVERY PATHWAYS',
                    style: TextStyle(
                      color: DeliveryAppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(Icons.store, 'Pickup Store', state.storeName),
                  const SizedBox(height: 16),
                  _buildRouteNode(
                    icon: Icons.location_on,
                    color: Colors.redAccent,
                    title: 'Drop Address',
                    address: state.customerAddress,
                  ),
                  const SizedBox(height: 4),
                  _buildRouteNode(
                    icon: Icons.person,
                    color: Colors.amberAccent,
                    title: 'Customer',
                    address: state.customerName,
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    Icons.route,
                    'Distance',
                    state.distanceKm > 0
                        ? '${state.distanceKm.toStringAsFixed(1)} km'
                        : '-',
                  ),
                  _buildStatRow(
                    Icons.timer,
                    'Estimated Time',
                    state.etaMins > 0 ? '${state.etaMins} min' : '-',
                  ),
                  _buildStatRow(
                    Icons.payment,
                    'Payment',
                    state.paymentMethod.isEmpty ? '-' : state.paymentMethod,
                  ),
                  _buildStatRow(Icons.currency_rupee, 'Order Value', '₹${state.orderAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteNode({
    required IconData icon,
    required Color color,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isGreen ? DeliveryAppColors.primary : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, DeliveryIncomingOrderState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: const Color(0xFF0C121E),
      child: Row(
        children: [
          // Timer Widget
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: state.remainingSeconds / 15,
                  valueColor: const AlwaysStoppedAnimation(DeliveryAppColors.primary),
                  backgroundColor: Colors.white10,
                ),
              ),
              Text(
                '${state.remainingSeconds}s',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Action Buttons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 160,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => context
                        .read<DeliveryIncomingOrderBloc>()
                        .add(const DeliveryIncomingOrderDeclineEvent()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('DECLINE ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<DeliveryIncomingOrderBloc>()
                        .add(const DeliveryIncomingOrderAcceptEvent()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DeliveryAppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('ACCEPT ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
