import 'package:flutter/material.dart';

/// Skeleton shimmer list shown while notifications are loading.
class NotificationShimmer extends StatelessWidget {
  final int itemCount;

  const NotificationShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    final base = Colors.black.withValues(alpha: 0.06);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(base: base, width: 46, height: 46, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bar(base: base, width: double.infinity, height: 14, radius: 6),
                const SizedBox(height: 10),
                _Bar(base: base, width: 220, height: 12, radius: 6),
                const SizedBox(height: 8),
                _Bar(base: base, width: 160, height: 12, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final Color base;
  final double width;
  final double height;
  final double radius;

  const _Bar({
    required this.base,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
