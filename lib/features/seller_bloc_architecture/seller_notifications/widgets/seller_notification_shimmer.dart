import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_loader.dart';

class SellerNotificationShimmer extends StatelessWidget {
  const SellerNotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 48, height: 48, borderRadius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(width: 130, height: 14, borderRadius: 4),
                        SkeletonBox(width: 45, height: 12, borderRadius: 4),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const SkeletonBox(
                      width: double.infinity,
                      height: 12,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 6),
                    const SkeletonBox(width: 180, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}