import 'package:flutter/material.dart';

class DeviceFrame extends StatelessWidget {
  final Widget child;
  final bool isDesktop;

  const DeviceFrame({
    super.key,
    required this.child,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return isDesktop ? _buildDesktopFrame() : _buildMobileFrame(context);
  }

  Widget _buildMobileFrame(BuildContext context) {
    return Container(
      width: 375, // Standard mobile width
      height: 812, // Standard mobile height
      padding: const EdgeInsets.all(14), // Frame thickness
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Dark iPhone frame color
        borderRadius: BorderRadius.circular(55),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: const Color(0xFF38383A), width: 2), // Subtle bezel
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: const EdgeInsets.only(top: 44, bottom: 34),
                ),
                child: child,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '9:41',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black),
                          SizedBox(width: 6),
                          Icon(Icons.wifi, size: 16, color: Colors.black),
                          SizedBox(width: 6),
                          Icon(Icons.battery_full, size: 16, color: Colors.black),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Dynamic Island
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFrame() {
    return Container(
      width: 1100, // Standard desktop width
      height: 750, // Standard desktop height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Column(
        children: [
          // Title bar (Windows style)
          Container(
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildWindowsButton(Icons.remove),
                    _buildWindowsButton(Icons.crop_square),
                    _buildWindowsButton(Icons.close),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey.shade300),
          // Content
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindowsButton(IconData icon) {
    return SizedBox(
      width: 46,
      height: 32,
      child: Icon(icon, size: 16, color: Colors.grey.shade700),
    );
  }
}
