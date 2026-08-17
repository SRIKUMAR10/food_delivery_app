import 'package:flutter/material.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/repositories/i_rating_repository.dart';
import '../../../repositories/firebase_rating_repository.dart';

class DeliveryRatingsStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'Rating & Reviews',
      'avgRating': 'Average Rating',
      'totalDeliveries': 'Total Deliveries',
      'totalReviews': 'Total Reviews',
      'ratingHistory': 'Rating History',
      'recentReviews': 'Recent Reviews',
      'all': 'All',
      'stars': 'Stars',
      'star': 'Star',
      'noReviews': 'No customer reviews yet',
      'noReviewsSub': 'Deliveries with great service will earn 5-star ratings here!',
      'order': 'Order',
    },
    'ta': {
      'title': 'மதிப்பீடு & விமர்சனங்கள்',
      'avgRating': 'சராசரி மதிப்பீடு',
      'totalDeliveries': 'மொத்த டெலிவரிகள்',
      'totalReviews': 'மொத்த விமர்சனங்கள்',
      'ratingHistory': 'மதிப்பீட்டு வரலாறு',
      'recentReviews': 'சமீபத்திய விமர்சனங்கள்',
      'all': 'அனைத்தும்',
      'stars': 'நட்சத்திரங்கள்',
      'star': 'நட்சத்திரம்',
      'noReviews': 'இன்னும் வாடிக்கையாளர் விமர்சனங்கள் இல்லை',
      'noReviewsSub': 'சிறந்த சேவை 5-நட்சத்திர மதிப்பீடுகளைப் பெற்றுத்தரும்!',
      'order': 'ஆர்டர்',
    },
  };

  static String of(String key, String lang) {
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }
}

class DeliveryRatingsReviewsSheet extends StatefulWidget {
  final String partnerId;
  final double initialAverageRating;
  final int initialTotalDeliveries;
  final IRatingRepository? ratingRepository;

  const DeliveryRatingsReviewsSheet({
    super.key,
    required this.partnerId,
    this.initialAverageRating = 4.8,
    this.initialTotalDeliveries = 1250,
    this.ratingRepository,
  });

  static Future<void> show(
    BuildContext context, {
    required String partnerId,
    double initialAverageRating = 4.8,
    int initialTotalDeliveries = 1250,
    IRatingRepository? ratingRepository,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryRatingsReviewsSheet(
        partnerId: partnerId,
        initialAverageRating: initialAverageRating,
        initialTotalDeliveries: initialTotalDeliveries,
        ratingRepository: ratingRepository,
      ),
    );
  }

  @override
  State<DeliveryRatingsReviewsSheet> createState() =>
      _DeliveryRatingsReviewsSheetState();
}

class _DeliveryRatingsReviewsSheetState
    extends State<DeliveryRatingsReviewsSheet> {
  int _selectedFilter = 0; // 0 = All, 5, 4, 3, 2, 1
  late final IRatingRepository _ratingRepo;

  @override
  void initState() {
    super.initState();
    _ratingRepo = widget.ratingRepository ?? FirebaseRatingRepository();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode == 'ta' ? 'ta' : 'en';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: DeliveryAppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Grab handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: DeliveryAppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DeliveryRatingsStrings.of('title', lang),
                  style: const TextStyle(
                    color: DeliveryAppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: DeliveryAppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: DeliveryAppColors.border),

          // Body
          Expanded(
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _ratingRepo.watchPartnerRatingSummary(widget.partnerId),
              builder: (context, summarySnap) {
                final summary = summarySnap.data ?? {
                  'overallRating': widget.initialAverageRating,
                  'totalReviews': 0,
                  'fiveStar': 0,
                  'fourStar': 0,
                  'threeStar': 0,
                  'twoStar': 0,
                  'oneStar': 0,
                };

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _ratingRepo.watchPartnerReviews(widget.partnerId),
                  builder: (context, reviewsSnap) {
                    final allReviews = reviewsSnap.data ?? [];
                    final filteredReviews = _selectedFilter == 0
                        ? allReviews
                        : allReviews.where((r) {
                            final rating = (r['rating'] as num?)?.toDouble() ?? 5.0;
                            return rating.round() == _selectedFilter;
                          }).toList();

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // 1. Dashboard summary card (⭐ 4.8 / Total Deliveries: 1,250)
                        _buildDashboardRatingCard(summary, lang),
                        const SizedBox(height: 16),

                        // 2. Star breakdown breakdown bar chart
                        _buildBreakdownCard(summary, lang),
                        const SizedBox(height: 20),

                        // 3. Filter chips
                        _buildFilterChips(summary, lang),
                        const SizedBox(height: 16),

                        // 4. Section Title
                        Text(
                          DeliveryRatingsStrings.of('recentReviews', lang),
                          style: const TextStyle(
                            color: DeliveryAppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 5. Reviews list or empty state
                        if (filteredReviews.isEmpty)
                          _buildEmptyReviews(lang)
                        else
                          ...filteredReviews.map((r) => _buildReviewCard(r, lang)),
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
  }

  Widget _buildDashboardRatingCard(Map<String, dynamic> summary, String lang) {
    final avgRating = (summary['overallRating'] as num?)?.toDouble() ?? widget.initialAverageRating;
    final totalDeliveries = widget.initialTotalDeliveries;
    final totalReviews = (summary['totalReviews'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Average Rating (⭐ 4.8)
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 32),
                  const SizedBox(width: 6),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DeliveryRatingsStrings.of('avgRating', lang),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(height: 50, width: 1, color: Colors.white24),
          // Total Deliveries (1,250)
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delivery_dining_rounded, color: DeliveryAppColors.primary, size: 28),
                  const SizedBox(width: 6),
                  Text(
                    _formatNumber(totalDeliveries),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DeliveryRatingsStrings.of('totalDeliveries', lang),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(height: 50, width: 1, color: Colors.white24),
          // Total Reviews
          Column(
            children: [
              Text(
                _formatNumber(totalReviews),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DeliveryRatingsStrings.of('totalReviews', lang),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(Map<String, dynamic> summary, String lang) {
    final total = (summary['totalReviews'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DeliveryAppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DeliveryRatingsStrings.of('ratingHistory', lang),
            style: const TextStyle(
              color: DeliveryAppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow(5, (summary['fiveStar'] as num?)?.toInt() ?? 0, total),
          const SizedBox(height: 6),
          _buildBreakdownRow(4, (summary['fourStar'] as num?)?.toInt() ?? 0, total),
          const SizedBox(height: 6),
          _buildBreakdownRow(3, (summary['threeStar'] as num?)?.toInt() ?? 0, total),
          const SizedBox(height: 6),
          _buildBreakdownRow(2, (summary['twoStar'] as num?)?.toInt() ?? 0, total),
          const SizedBox(height: 6),
          _buildBreakdownRow(1, (summary['oneStar'] as num?)?.toInt() ?? 0, total),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(int star, int count, int total) {
    final progress = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Row(
            children: [
              Text(
                '$star',
                style: const TextStyle(
                  color: DeliveryAppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: DeliveryAppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                star >= 4
                    ? const Color(0xFF10B981)
                    : (star == 3 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 36,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: DeliveryAppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(Map<String, dynamic> summary, String lang) {
    final filters = [0, 5, 4, 3, 2, 1];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          final label = filter == 0 ? DeliveryRatingsStrings.of('all', lang) : '$filter ★';

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            selectedColor: DeliveryAppColors.primary,
            backgroundColor: DeliveryAppColors.surface,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : DeliveryAppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? DeliveryAppColors.primary : DeliveryAppColors.border,
              ),
            ),
            onSelected: (val) {
              if (val) {
                setState(() => _selectedFilter = filter);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, String lang) {
    final customerName = (review['customerName'] as String?) ?? 'Customer';
    final rating = (review['rating'] as num?)?.toDouble() ?? 5.0;
    final reviewText = (review['reviewText'] as String?) ?? (review['content'] as String?) ?? '';
    final orderId = (review['orderId'] as String?) ?? '';
    final tags = (review['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final createdAt = review['createdAt'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DeliveryAppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: DeliveryAppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: DeliveryAppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        _formatDate(createdAt),
                        style: const TextStyle(
                          color: DeliveryAppColors.textDisabled,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reviewText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              reviewText,
              style: const TextStyle(
                color: DeliveryAppColors.textPrimary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '# $tag',
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
          if (orderId.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.tag_rounded, size: 14, color: DeliveryAppColors.textDisabled),
                Text(
                  '${DeliveryRatingsStrings.of('order', lang)}: ${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                  style: const TextStyle(
                    color: DeliveryAppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyReviews(String lang) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DeliveryAppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: DeliveryAppColors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            DeliveryRatingsStrings.of('noReviews', lang),
            style: const TextStyle(
              color: DeliveryAppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DeliveryRatingsStrings.of('noReviewsSub', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DeliveryAppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = (n % 1000).toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return '$n';
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
