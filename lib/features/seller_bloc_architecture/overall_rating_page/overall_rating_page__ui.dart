import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'overall_rating_page__bloc.dart';
import 'overall_rating_page__event.dart';
import 'overall_rating_page__state.dart';

class OverallRatingPage extends StatelessWidget {
  final SellerReviewService? service;
  const OverallRatingPage({Key? key, this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OverallRatingBloc(
        service: service ?? SellerReviewService(),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Premium light background
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.95),
          elevation: 0,
          scrolledUnderElevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          centerTitle: false,
          leading: BlocBuilder<OverallRatingBloc, OverallRatingState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rating & Reviews',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                'Customer Feedback',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<OverallRatingBloc, OverallRatingState>(
          builder: (context, state) {
            if (state is OverallRatingInitial) {
              context.read<OverallRatingBloc>().add(LoadOverallRatingEvent());
              return const _LoadingSkeleton();
            } else if (state is OverallRatingLoading) {
              return const _LoadingSkeleton();
            } else if (state is OverallRatingLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<OverallRatingBloc>().add(RefreshOverallRatingEvent());
                },
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + kToolbarHeight + 24.0,
                        left: 16.0,
                        right: 16.0,
                        bottom: 32.0,
                      ),
                      children: [
                        _OverallRatingCard(
                          overallRating: state.overallRating,
                          totalReviews: state.totalReviews,
                        ),
                        const SizedBox(height: 16),
                        ...state.reviews.map((review) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _ReviewCard(review: review),
                            )),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View All Reviews',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is OverallRatingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<OverallRatingBloc>().add(LoadOverallRatingEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _OverallRatingCard extends StatelessWidget {
  final double overallRating;
  final int totalReviews;

  const _OverallRatingCard({
    Key? key,
    required this.overallRating,
    required this.totalReviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Overall Rating',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3142)),
          ),
          const SizedBox(height: 8),
          Text(
            overallRating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
          ),
          const SizedBox(height: 8),
          _StarRating(rating: overallRating, size: 24),
          const SizedBox(height: 8),
          Text(
            '($totalReviews reviews)',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: CachedNetworkImageProvider(review.authorAvatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  review.authorName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                ),
              ),
              _StarRating(rating: review.rating, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.content,
            style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(
            DateFormat('dd MMM, yyyy').format(review.date),
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRating({Key? key, required this.rating, this.size = 18}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: const Color(0xFFFFB800), size: size);
        } else if (index == rating.floor() && rating % 1 != 0) {
          return Icon(Icons.star_half, color: const Color(0xFFFFB800), size: size);
        } else {
          return Icon(Icons.star_border, color: const Color(0xFFD1D5DB), size: size);
        }
      }),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 24.0,
            left: 16.0,
            right: 16.0,
            bottom: 32.0,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: index == 0 ? 180 : 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        ),
      ),
    );
  }
}
