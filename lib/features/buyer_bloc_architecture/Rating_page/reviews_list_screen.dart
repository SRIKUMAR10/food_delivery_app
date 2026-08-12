import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import '../home_Page/home_page_models.dart';
import 'Rating_page_ui.dart';

class ReviewsListScreen extends StatelessWidget {
  final String productId;
  final String productName;
  final FoodItem? foodItem;

  const ReviewsListScreen({
    Key? key,
    required this.productId,
    required this.productName,
    this.foodItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RatingPageUI(
                              foodId: productId,
                              foodName: productName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.rate_review,
                        size: 16,
                        color: Color(0xFFEF2A39),
                      ),
                      label: const Text(
                        'Write',
                        style: TextStyle(color: Color(0xFFEF2A39)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Reviews List Stream
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: context.read<IRatingRepository>().watchProductReviews(productId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEF2A39),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading reviews.'),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No reviews yet. Be the first!'),
                      );
                    }

                    final reviews = snapshot.data!;

                    return ListView.separated(
                      controller:
                          scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey.shade300, height: 24),
                      itemBuilder: (context, index) {
                        final data = reviews[index];
                        final String displayName =
                            data['reviewerName'] ?? 'Anonymous';
                        final double rating =
                            (data['rating'] as num?)?.toDouble() ?? 0.0;
                        final String text = data['reviewText'] ?? '';

                        return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1C1C1C),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFFB800,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Color(0xFFFFB800),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (text.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    text,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
