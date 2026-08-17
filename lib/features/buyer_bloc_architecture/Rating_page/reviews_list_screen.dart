import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/repositories/firebase_rating_repository.dart';
import 'package:food_delivery_app/core/utils/app_localizations.dart';
import '../home_Page/home_page_models.dart';
import 'Rating_page_ui.dart';

const _red = Color(0xFFEF2A39);
const _star = Color(0xFFFFB800);

class ReviewsListScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final FoodItem? foodItem;
  final IRatingRepository? ratingRepository;
  final IAuthService? authService;

  const ReviewsListScreen({
    Key? key,
    required this.productId,
    required this.productName,
    this.foodItem,
    this.ratingRepository,
    this.authService,
  }) : super(key: key);

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  int? _selectedStar;

  IRatingRepository _resolveRatingRepository(BuildContext context) {
    if (widget.ratingRepository != null) return widget.ratingRepository!;
    try {
      return context.read<IRatingRepository>();
    } catch (_) {
      return FirebaseRatingRepository();
    }
  }

  String _resolveReporterId(BuildContext context) {
    if (widget.authService != null) {
      return widget.authService!.currentUserId ?? '';
    }
    try {
      return context.read<IAuthService>().currentUserId ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = _resolveRatingRepository(context);
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
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
                              foodId: widget.productId,
                              foodName: widget.productName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.rate_review,
                        size: 16,
                        color: _red,
                      ),
                      label: const Text(
                        'Write',
                        style: TextStyle(color: _red),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              _RatingBreakdownHeader(
                summaryStream: repository.watchProductRatingSummary(widget.productId),
                selectedStar: _selectedStar,
                onStarTap: (star) => setState(
                  () => _selectedStar = (_selectedStar == star) ? null : star,
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: repository.watchProductReviews(widget.productId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _red),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading reviews.'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No reviews yet. Be the first!'),
                      );
                    }

                    var reviews = snapshot.data!;
                    if (_selectedStar != null) {
                      reviews = reviews
                          .where((r) => ((r['rating'] as num?)?.toDouble() ?? 0)
                                  .round()
                                  .clamp(1, 5) ==
                              _selectedStar)
                          .toList();
                    }

                    if (reviews.isEmpty) {
                      return const Center(
                        child: Text('No reviews match your filter.'),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey.shade300, height: 24),
                      itemBuilder: (context, index) {
                        final data = reviews[index];
                        return _ReviewTile(
                          data: data,
                          reporterId: _resolveReporterId(context),
                          onReport: () => _showReportDialog(context, data),
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

  void _showReportDialog(BuildContext context, Map<String, dynamic> data) {
    final reasons = <String>[
      'Spam',
      AppLocalizations.reportAbusive(context),
      'Fake',
      AppLocalizations.reportIrrelevant(context),
      AppLocalizations.other(context),
    ];
    final reviewId = data['reviewerId'] as String? ?? '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(AppLocalizations.reportReview(dialogContext)),
          children: [
            for (final reason in reasons)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _resolveRatingRepository(context).reportReview(
                    productId: widget.productId,
                    reviewId: reviewId,
                    reason: reason,
                    reporterId: _resolveReporterId(context),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.reviewReportedSuccess(context)),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(reason),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RatingBreakdownHeader extends StatelessWidget {
  final Stream<Map<String, dynamic>> summaryStream;
  final int? selectedStar;
  final ValueChanged<int> onStarTap;

  const _RatingBreakdownHeader({
    Key? key,
    required this.summaryStream,
    required this.selectedStar,
    required this.onStarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: summaryStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox(height: 8);

        final overall = (data['overallRating'] as num?)?.toDouble() ?? 0.0;
        final total = (data['totalReviews'] as num?)?.toInt() ?? 0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    overall.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C)),
                  ),
                  const Icon(Icons.star_rounded, color: _star, size: 18),
                  Text(
                    '$total reviews',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (var star = 5; star >= 1; star--)
                      _MiniBreakdownRow(
                        star: star,
                        count: (data['${_starKey(star)}'] as num?)?.toInt() ?? 0,
                        total: total,
                        selected: selectedStar == star,
                        onTap: () => onStarTap(star),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _starKey(int star) {
    switch (star) {
      case 5:
        return 'fiveStar';
      case 4:
        return 'fourStar';
      case 3:
        return 'threeStar';
      case 2:
        return 'twoStar';
      default:
        return 'oneStar';
    }
  }
}

class _MiniBreakdownRow extends StatelessWidget {
  final int star;
  final int count;
  final int total;
  final bool selected;
  final VoidCallback onTap;

  const _MiniBreakdownRow({
    Key? key,
    required this.star,
    required this.count,
    required this.total,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : (count / total);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '$star',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.star_rounded, color: _star, size: 12),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      selected ? _red : _star),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              child: Text(
                '$count',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String reporterId;
  final VoidCallback onReport;

  const _ReviewTile({
    Key? key,
    required this.data,
    required this.reporterId,
    required this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayName = data['reviewerName'] ?? 'Anonymous';
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final text = data['reviewText'] ?? '';
    final sellerReply = data['sellerReply'] as String?;
    final sellerReplyAuthor = data['sellerReplyAuthor'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1C1C1C)),
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _star.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: _star, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: AppLocalizations.reportReview(context),
                  visualDensity: VisualDensity.compact,
                  onPressed: onReport,
                  icon: Icon(
                    (data['isReported'] as bool? ?? false)
                        ? Icons.flag
                        : Icons.flag_outlined,
                    size: 18,
                    color: (data['isReported'] as bool? ?? false)
                        ? Colors.orange
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 13),
          ),
        ],
        if (sellerReply != null && sellerReply.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _red.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront, size: 14, color: _red),
                    const SizedBox(width: 6),
                    Text(
                      sellerReplyAuthor ?? AppLocalizations.storeResponse(context),
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold, color: _red),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sellerReply,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1C1C1C), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
