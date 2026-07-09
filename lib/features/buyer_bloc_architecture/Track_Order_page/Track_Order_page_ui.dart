import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'Track_Order_page_bloc.dart';
import 'Track_Order_page_event.dart';
import 'Track_Order_page_state.dart';
import 'Track_Order_page_repository.dart';
import 'Track_Order_page_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Order Page/order_models.dart';
import '../user_profile_image/user_profile_image_Bloc.dart';

class TrackOrderPageUI extends StatelessWidget {
  final String orderId;
  final OrderModel? order;
  final bool
  isEmbedded; // If true, hide Scaffold app bar and use simple background

  const TrackOrderPageUI({
    super.key,
    required this.orderId,
    this.order,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TrackOrderBloc(
                repository: TrackOrderRepositoryImpl(
                  service: TrackOrderService(httpClient: http.Client()),
                ),
              )..add(
                LoadTrackOrderDetails(
                  orderId: orderId,
                  orderDate: order?.date ?? DateTime.now(),
                ),
              ),
        ),
        BlocProvider(
          create: (context) =>
              UserProfileBloc()..add(const LoadProfileStarted()),
        ),
      ],
      child: _TrackOrderView(order: order, isEmbedded: isEmbedded),
    );
  }
}

class _TrackOrderView extends StatelessWidget {
  final OrderModel? order;
  final bool isEmbedded;

  const _TrackOrderView({this.order, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // If the app is pushed as a mobile view but the window is resized to desktop,
          // pop this route so it doesn't duplicate the master-detail desktop layout.
          if (!isEmbedded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE52121)),
            );
          }
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );

    if (isEmbedded) {
      return Container(color: Colors.white, child: content);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: MediaQuery.of(context).size.width < 800
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Track Order'),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return BlocBuilder<TrackOrderBloc, TrackOrderState>(
      builder: (context, state) {
        if (state is TrackOrderLoading || state is TrackOrderInitial) {
          return _buildSkeletonLoader();
        } else if (state is TrackOrderError) {
          return _buildErrorState(context, state.message);
        } else if (state is TrackOrderLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(state),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                const SizedBox(height: 24),
                _buildTimeline(state.trackingSteps),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                const SizedBox(height: 24),
                _buildUserInfo(),
                if (order != null) ...[
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 24),
                  _buildOrderSummaryMobile(),
                ],
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return BlocBuilder<TrackOrderBloc, TrackOrderState>(
      builder: (context, state) {
        if (state is TrackOrderLoading || state is TrackOrderInitial) {
          return _buildSkeletonLoader();
        } else if (state is TrackOrderError) {
          return _buildErrorState(context, state.message);
        } else if (state is TrackOrderLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: Order Details & Payment Summary
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildHeaderInfo(state),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                        const SizedBox(height: 24),
                        if (order != null) _buildOrderItemsList(),
                        if (order != null) ...[
                          const SizedBox(height: 24),
                          const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                          const SizedBox(height: 16),
                          _buildPaymentSummary(),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Right column: Tracking Timeline & Partner
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tracking Status',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTimeline(state.trackingSteps),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                        const SizedBox(height: 24),
                        _buildUserInfo(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeaderInfo(TrackOrderLoaded state) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final formattedDate = order != null ? dateFormat.format(order!.date) : null;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Order ID',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              '#${state.orderId.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        if (formattedDate != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date & Time',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estimated Delivery',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              state.estimatedDelivery,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(List<TrackingStep> steps) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        int idx = entry.key;
        var step = entry.value;
        bool isLast = idx == steps.length - 1;
        return _buildTimelineNode(step, isLast);
      }).toList(),
    );
  }

  Widget _buildTimelineNode(TrackingStep step, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildStatusIcon(step.status),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color:
                        step.status == TrackingStatus.completed ||
                            step.status == TrackingStatus.current
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: step.status == TrackingStatus.future
                          ? Colors.black54
                          : Colors.black87,
                    ),
                  ),
                  if (step.time != null)
                    Text(
                      step.time!,
                      style: TextStyle(
                        fontSize: 12,
                        color: step.status == TrackingStatus.future
                            ? Colors.black38
                            : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(TrackingStatus status) {
    if (status == TrackingStatus.completed ||
        status == TrackingStatus.current) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 14),
      );
    } else if (status == TrackingStatus.upcoming) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black54, width: 1.5),
        ),
        child: const Icon(Icons.check, color: Colors.black54, size: 12),
      );
    } else {
      // Future
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black38, width: 1.5),
        ),
        child: Center(
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildUserInfo() {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileLoading || profileState is ProfileInitial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Color(0xFFE52121)),
            ),
          );
        } else if (profileState is ProfileError) {
          return const Text(
            'Failed to load user details',
            style: TextStyle(color: Colors.red),
          );
        } else if (profileState is ProfileLoaded) {
          final profile = profileState.profile;
          return Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    profile.imageUrl != null && profile.imageUrl!.isNotEmpty
                    ? NetworkImage(profile.imageUrl!)
                    : null,
                child: profile.imageUrl == null || profile.imageUrl!.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey, size: 24)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isNotEmpty ? profile.name : 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.address.isNotEmpty
                          ? profile.address
                          : 'No Address Provided',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionIcon(
                Icons.call,
                const Color(0xFF4CAF50),
                onTap: () => _handlePhoneCall(context, profile.phone),
              ),
              const SizedBox(width: 12),
              _buildActionIcon(Icons.message, const Color(0xFF4CAF50)),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _handlePhoneCall(BuildContext context, String phone) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No phone number provided')));
      return;
    }

    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Phone: $phone',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Copy to clipboard',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: phone));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      final Uri url = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone dialer')),
          );
        }
      }
    }
  }

  Widget _buildActionIcon(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildOrderSummaryMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 16),
        _buildOrderItemsList(),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFF0F0F0), thickness: 1),
        const SizedBox(height: 16),
        _buildPaymentSummary(),
      ],
    );
  }

  Widget _buildOrderItemsList() {
    if (order == null) return const SizedBox.shrink();
    return Column(
      children: order!.items.map((item) {
        final heroTag = 'track_order_${order!.id}_item_${item.id}';
        final imageUrl =
            item.image ??
            'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => _showImagePreview(context, imageUrl, heroTag),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showImagePreview(
    BuildContext context,
    String imageUrl,
    String heroTag,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 25,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentSummary() {
    if (order == null) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          '₹${order!.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE52121),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TrackOrderBloc>().add(
                RefreshTrackOrder(
                  orderId: order?.id ?? 'FG125678',
                  orderDate: order?.date ?? DateTime.now(),
                ),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 32),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
