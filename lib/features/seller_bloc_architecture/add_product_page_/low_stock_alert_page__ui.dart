import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'low_stock_alert_page__bloc.dart';
import 'low_stock_alert_page__event.dart';
import 'low_stock_alert_page__state.dart';

class LowStockAlertPage extends StatelessWidget {
  const LowStockAlertPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LowStockAlertBloc()..add(LoadLowStockData()),
      child: const LowStockAlertView(),
    );
  }
}

class LowStockAlertView extends StatefulWidget {
  const LowStockAlertView({Key? key}) : super(key: key);

  @override
  State<LowStockAlertView> createState() => _LowStockAlertViewState();
}

class _LowStockAlertViewState extends State<LowStockAlertView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handling responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB), // Very light grey bg
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
              child: BlocConsumer<LowStockAlertBloc, LowStockAlertState>(
                listener: (context, state) {
                  if (state is LowStockAlertLoaded) {
                    _animationController.forward();
                  } else if (state is LowStockAlertError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is LowStockAlertLoading || state is LowStockAlertInitial) {
                    return _buildSkeletonLoader();
                  } else if (state is LowStockAlertLoaded) {
                    return _buildContent(context, state);
                  } else if (state is LowStockAlertError) {
                    return _buildErrorState(context, state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          bottomNavigationBar: BlocBuilder<LowStockAlertBloc, LowStockAlertState>(
            builder: (context, state) {
              if (state is LowStockAlertLoaded) {
                return _buildBottomButton(isDesktop);
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, LowStockAlertLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LowStockAlertBloc>().add(RefreshLowStockData());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Warning Icon
            _buildWarningHeader(),
            const SizedBox(height: 24),

            // Titles
            const Text(
              'Low Stock Alert',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // Dark grey
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.totalLowStockCount} items are running low',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280), // Medium grey
              ),
            ),
            const SizedBox(height: 32),

            // List of items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                thickness: 1,
                height: 32,
              ),
              itemBuilder: (context, index) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (index / state.items.length) * 0.5,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _animationController,
                    child: _buildListItem(state.items[index]),
                  ),
                );
              },
            ),
            const SizedBox(height: 80), // Padding for bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildWarningHeader() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Very light orange background
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.warning_rounded,
            size: 64,
            color: Color(0xFFF59E0B), // Amber/Orange
          ),
          Positioned(
            right: 12,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444), // Red
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add, // Or appropriate small badge icon
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(LowStockItem item) {
    return Row(
      children: [
        // Circular Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(item.colorHex).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              _getIconForName(item.name),
              color: Color(item.colorHex),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Item Name
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),

        // Quantity & Unit
        Text(
          '${item.quantity} ${item.unit}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  IconData _getIconForName(String name) {
    // Simple mock icon mapping based on name
    switch (name.toLowerCase()) {
      case 'cheese':
        return Icons.circle; // Placeholder for cheese
      case 'chicken':
        return Icons.circle_outlined; // Placeholder for chicken
      case 'capsicum':
        return Icons.local_florist; // Placeholder for vegetable
      case 'olives':
        return Icons.lens; // Placeholder for olives
      default:
        return Icons.category;
    }
  }

  Widget _buildBottomButton(bool isDesktop) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? (MediaQuery.of(context).size.width - 600) / 2 + 24 : 24.0,
          vertical: 16.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to Inventory Action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), // Brand Red
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'View Inventory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 200,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade100,
                thickness: 1,
                height: 32,
              ),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<LowStockAlertBloc>().add(LoadLowStockData());
            },
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }
}
