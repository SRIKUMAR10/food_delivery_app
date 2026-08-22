import 'package:food_delivery_app/core/widgets/shimmer_loader.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(width: 46, height: 46, borderRadius: 14),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14, borderRadius: 6),
                SizedBox(height: 10),
                SkeletonBox(width: 220, height: 12, borderRadius: 6),
                SizedBox(height: 8),
                SkeletonBox(width: 160, height: 12, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
