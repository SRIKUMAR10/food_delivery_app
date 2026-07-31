import 'dart:ui';
import 'package:flutter/material.dart';

class DeliveryIncomingOrderPageUi extends StatefulWidget {
  const DeliveryIncomingOrderPageUi({super.key});

  @override
  State<DeliveryIncomingOrderPageUi> createState() => _DeliveryIncomingOrderPageUiState();
}

class _DeliveryIncomingOrderPageUiState extends State<DeliveryIncomingOrderPageUi>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    // 15 seconds countdown timer
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..reverse(from: 1.0).then((_) {
        // Automatically decline on timeout
        if (mounted) Navigator.of(context).pop();
      });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            child: _buildMapPane(),
                          ),
                          Expanded(
                            flex: 4,
                            child: _buildDetailsPane(),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(child: _buildMapPane()),
                          _buildDetailsPane(),
                        ],
                      ),
              ),
              _buildBottomActionBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapPane() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C121E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, color: Color(0xFF00E676), size: 64),
            SizedBox(height: 16),
            Text(
              'Interactive Route Preview Map',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPane() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1424).withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DELIVERY PATHWAYS',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRouteNode(
                  icon: Icons.store,
                  color: Colors.cyanAccent,
                  title: 'Pickup Store',
                  address: 'Green Mart, 24, Anna Salai, Chennai',
                ),
                const SizedBox(height: 16),
                _buildRouteNode(
                  icon: Icons.location_on,
                  color: Colors.redAccent,
                  title: 'Drop Address',
                  address: 'Mike Residence, 12, Beach Road, Chennai',
                ),
                const Spacer(),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                _buildStatRow(Icons.route, 'Distance', '2.4 km'),
                _buildStatRow(Icons.timer, 'Estimated Time', '12 min'),
                _buildStatRow(Icons.payment, 'COD Status', 'COD Available', isGreen: true),
                _buildStatRow(Icons.currency_rupee, 'Order Value', '₹620.00'),
              ],
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
          backgroundColor: color.withOpacity(0.12),
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
              color: isGreen ? const Color(0xFF00E676) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: const Color(0xFF0C121E),
      child: Row(
        children: [
          // Timer Widget
          AnimatedBuilder(
            animation: _timerController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _timerController.value,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF00E676)),
                    backgroundColor: Colors.white10,
                  ),
                  Text(
                    '${(_timerController.value * 15).ceil()}s',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
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
                    onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Open Details directly to simulate acceptance flow
                      Navigator.of(context).pushNamed('/deliveryOrderDetails');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
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
