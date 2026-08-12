import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Order_Details_page_bloc.dart';
import 'Delivery_Order_Details_page_event.dart';
import 'Delivery_Order_Details_page_state.dart';
import '../auto_hide_app_bar_wrapper.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_typography.dart';
import '../../../core/theme/delivery_app_spacing.dart';
import '../../../core/widgets/delivery_button.dart';
import '../../../core/widgets/delivery_card.dart';
import '../../../core/widgets/delivery_chip.dart';


class DeliveryOrderDetailsPageUi extends StatelessWidget {
  final String orderId;
  final DeliveryOrderDetailsPageBloc? bloc;

  const DeliveryOrderDetailsPageUi({super.key, required this.orderId, this.bloc});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    final appBar = AppBar(
      backgroundColor: DeliveryAppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: DeliveryAppColors.textPrimary),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
      ),
      title: Text(
        'LOGISTICS ORDER PANEL',
        style: DeliveryAppTypography.titleMedium.copyWith(
          color: DeliveryAppColors.textPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
    );

    Widget buildBody(BuildContext context, DeliveryOrderDetailsPageBloc bloc) {
      return BlocBuilder<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
        bloc: bloc,
        builder: (context, state) {
          if (state.status == OrderDetailsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(DeliveryAppColors.primary),
              ),
            );
          } else if (state.status == OrderDetailsStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? 'An error occurred',
                style: DeliveryAppTypography.bodyLarge.copyWith(
                  color: DeliveryAppColors.error,
                ),
              ),
            );
          } else if (state.status == OrderDetailsStatus.success && state.order != null) {
            final order = state.order!;
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1024;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(DeliveryAppSpacing.md),
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
    }

    if (bloc != null) {
      return BlocProvider<DeliveryOrderDetailsPageBloc>.value(
        value: bloc!,
        child: Scaffold(
          backgroundColor: DeliveryAppColors.background,
          appBar: isMobile ? null : appBar,
          body: isMobile
              ? AutoHideAppBarWrapper(
                  appBar: appBar,
                  body: Builder(
                    builder: (context) => buildBody(context, bloc!),
                  ),
                  appBarHeight: kToolbarHeight,
                  isMobile: true,
                )
              : buildBody(context, bloc!),
        ),
      );
    }

    return BlocProvider<DeliveryOrderDetailsPageBloc>(
      create: (context) => DeliveryOrderDetailsPageBloc()..add(FetchOrderDetailsEvent(orderId)),
      child: Scaffold(
        backgroundColor: DeliveryAppColors.background,
        appBar: isMobile ? null : appBar,
        body: isMobile
            ? AutoHideAppBarWrapper(
                appBar: appBar,
                body: Builder(
                  builder: (context) => buildBody(context, context.read<DeliveryOrderDetailsPageBloc>()),
                ),
                appBarHeight: kToolbarHeight,
                isMobile: true,
              )
            : Builder(
                builder: (context) => buildBody(context, context.read<DeliveryOrderDetailsPageBloc>()),
              ),
      ),
    );
  }


  Widget _buildDetailsColumn(BuildContext context, OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer & Status Card
        DeliveryCard(
          padding: EdgeInsets.all(DeliveryAppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: DeliveryAppColors.surfaceLight,
                    child: const Icon(Icons.person, color: DeliveryAppColors.textSecondary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Details',
                          style: DeliveryAppTypography.caption.copyWith(
                            color: DeliveryAppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName.isEmpty
                              ? 'Customer Details'
                              : order.customerName,
                          style: DeliveryAppTypography.titleMedium.copyWith(
                            color: DeliveryAppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.customerPhone,
                          style: DeliveryAppTypography.bodySmall.copyWith(
                            color: DeliveryAppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DeliveryChip(
                    variant: DeliveryChipVariant.success,
                    label: order.status.toUpperCase(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Pickup & Drop Details Card
        DeliveryCard(
          padding: EdgeInsets.all(DeliveryAppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationRow(
                icon: Icons.store,
                iconColor: DeliveryAppColors.info,
                title: 'Pickup Details (Merchant)',
                name: order.restaurantName,
                address: order.pickupAddress,
                phone: order.merchantPhone,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: DeliveryAppColors.border, height: 1),
              ),
              _buildLocationRow(
                icon: Icons.location_on,
                iconColor: DeliveryAppColors.error,
                title: 'Drop Details (Customer)',
                name: order.customerName,
                address: order.dropoffAddress,
                phone: order.customerPhone,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Order Items & Financial Summary Card
        DeliveryCard(
          padding: EdgeInsets.all(DeliveryAppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDERED ITEMS',
                style: DeliveryAppTypography.caption.copyWith(
                  color: DeliveryAppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              if (order.items.isEmpty)
                _buildItemRow('No items available', '-', '-')
              else
                for (final item in order.items)
                  _buildItemRow(
                    item.name,
                    'x${item.quantity}',
                    '₹${item.price.toStringAsFixed(2)}',
                  ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: DeliveryAppColors.border, height: 1),
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
              child: DeliveryButton(
                label: 'NAVIGATE',
                onPressed: () {
                  // Navigate trigger
                },
                variant: DeliveryButtonVariant.outline,
                icon: Icons.navigation,
                height: DeliveryAppSpacing.minTouchTargetSize,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DeliveryButton(
                label: _getButtonText(order.status).toUpperCase(),
                onPressed: () {
                  final nextStatus = _getNextStatus(order.status);
                  if (nextStatus != null) {
                    BlocProvider.of<DeliveryOrderDetailsPageBloc>(context)
                        .add(UpdateOrderStatusEvent(order.id, nextStatus));
                  }
                },
                variant: DeliveryButtonVariant.primary,
                height: DeliveryAppSpacing.minTouchTargetSize,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
    required String phone,
    String name = '',
  }) {
    final cleanName = name.trim();
    final cleanAddress = address.trim();
    final cleanPhone = phone.trim();

    final nameIsEmpty = cleanName.isEmpty;
    final isDefaultAddress = cleanAddress.isEmpty || cleanAddress == 'Primary Address';

    final displayName = nameIsEmpty
        ? (title.contains('Drop') ? 'Customer' : 'Partner Store')
        : cleanName;

    final displayAddress = isDefaultAddress
        ? (title.contains('Drop') ? 'Delivery Address' : 'Store Address')
        : cleanAddress;

    final showAddress = displayAddress.isNotEmpty &&
        displayAddress.toLowerCase() != cleanName.toLowerCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DeliveryAppTypography.caption.copyWith(
                  color: DeliveryAppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: DeliveryAppTypography.bodyMedium.copyWith(
                  color: DeliveryAppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showAddress) ...[
                const SizedBox(height: 2),
                Text(
                  displayAddress,
                  style: DeliveryAppTypography.bodyMedium.copyWith(
                    color: isDefaultAddress
                        ? DeliveryAppColors.textMuted
                        : DeliveryAppColors.textPrimary,
                    fontWeight: nameIsEmpty && isDefaultAddress
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
              if (cleanPhone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Contact: $cleanPhone',
                  style: DeliveryAppTypography.caption.copyWith(
                    color: DeliveryAppColors.textMuted,
                  ),
                ),
              ],
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
          Expanded(
            child: Text(
              name,
              style: DeliveryAppTypography.bodyMedium.copyWith(color: DeliveryAppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(quantity, style: DeliveryAppTypography.bodySmall.copyWith(color: DeliveryAppColors.textMuted)),
          const SizedBox(width: 8),
          Text(price, style: DeliveryAppTypography.bodyMedium.copyWith(color: DeliveryAppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: DeliveryAppTypography.bodyMedium.copyWith(color: DeliveryAppColors.textMuted)),
          const Spacer(),
          Text(
            value,
            style: DeliveryAppTypography.bodyMedium.copyWith(
              color: isHighlight ? DeliveryAppColors.primary : DeliveryAppColors.textPrimary,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMapPane() {
    return DeliveryCard(
      padding: EdgeInsets.all(DeliveryAppSpacing.lg),
      child: SizedBox(
        height: 450,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.near_me, color: DeliveryAppColors.primary, size: 56),
              SizedBox(height: 16),
              Text(
                'LIVE ROUTE MAP PANEL',
                style: TextStyle(
                  color: DeliveryAppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tracking current delivery status in real-time',
                style: TextStyle(color: DeliveryAppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
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
