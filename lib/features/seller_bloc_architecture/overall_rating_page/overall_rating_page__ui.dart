import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/core/utils/app_localizations.dart';
import 'overall_rating_page__bloc.dart';
import 'overall_rating_page__event.dart';
import 'overall_rating_page__state.dart';

const _bg = Color(0xFFF8FAFC);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _primary = Color(0xFFEF2A39);
const _star = Color(0xFFFFB800);

class OverallRatingPage extends StatelessWidget {
  final SellerReviewService? service;
  final OverallRatingBloc? bloc;

  const OverallRatingPage({Key? key, this.service, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<OverallRatingBloc>.value(
        value: bloc!,
        child: const _OverallRatingContentView(),
      );
    }
    return BlocProvider(
      create: (context) => OverallRatingBloc(
        service: service ?? SellerReviewService(),
      ),
      child: const _OverallRatingContentView(),
    );
  }
}

class _OverallRatingContentView extends StatelessWidget {
  const _OverallRatingContentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _bg.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _ink, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.ratingsAndReviews(context),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: _ink),
            ),
            Text(
              AppLocalizations.customerFeedback(context),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _muted),
            ),
          ],
        ),
        actions: const [
          _LiveSyncBadge(),
          SizedBox(width: 16),
        ],
      ),
      body: BlocListener<OverallRatingBloc, OverallRatingState>(
        listener: (context, state) {
          if (state is OverallRatingLoaded && state.actionMessage != null) {
            final message = _actionMessageText(context, state.actionMessage!);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(message),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: state.actionMessage!.contains('Failed') ||
                          state.actionMessage!.contains('Error')
                      ? Colors.redAccent
                      : Colors.green.shade600,
                ),
              );
            context.read<OverallRatingBloc>().add(ClearActionMessageEvent());
          }
        },
        child: BlocBuilder<OverallRatingBloc, OverallRatingState>(
          builder: (context, state) {
            if (state is OverallRatingInitial) {
              context.read<OverallRatingBloc>().add(LoadOverallRatingEvent());
              return const _LoadingSkeleton();
            } else if (state is OverallRatingLoading) {
              return const _LoadingSkeleton();
            } else if (state is OverallRatingLoaded) {
              return _buildLoaded(context, state);
            } else if (state is OverallRatingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<OverallRatingBloc>()
                          .add(LoadOverallRatingEvent()),
                      child: Text(AppLocalizations.retry(context)),
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

  Widget _buildLoaded(BuildContext context, OverallRatingLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OverallRatingBloc>().add(RefreshOverallRatingEvent());
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final topPad = MediaQuery.of(context).padding.top +
                  kToolbarHeight +
                  24.0;

              return ListView(
                padding: EdgeInsets.only(
                  top: topPad,
                  left: 16,
                  right: 16,
                  bottom: 32,
                ),
                children: [
                  _buildSummary(context, state, wide),
                  const SizedBox(height: 16),
                  _FilterTabs(state: state),
                  const SizedBox(height: 16),
                  _buildReviewsHeader(context, state),
                  const SizedBox(height: 12),
                  if (state.filteredReviews.isEmpty)
                    _EmptyReviews(message: AppLocalizations.noFilteredReviews(context))
                  else
                    ...state.filteredReviews.map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ReviewCard(review: review),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(
      BuildContext context, OverallRatingLoaded state, bool wide) {
    final ratingCard = _OverallRatingCard(
      overallRating: state.overallRating,
      totalReviews: state.totalReviews,
    );
    final breakdown = _RatingBreakdownCard(
      breakdown: state.breakdown,
      selectedStar: state.selectedStarFilter,
      onStarTap: (star) {
        final current = context.read<OverallRatingBloc>().state;
        final already = current is OverallRatingLoaded &&
            current.selectedStarFilter == star;
        context.read<OverallRatingBloc>().add(
            FilterReviewsByStarEvent(already ? null : star));
      },
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ratingCard),
          const SizedBox(width: 16),
          Expanded(child: breakdown),
        ],
      );
    }
    return Column(
      children: [
        ratingCard,
        const SizedBox(height: 16),
        breakdown,
      ],
    );
  }

  Widget _buildReviewsHeader(BuildContext context, OverallRatingLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.customerReviews(context),
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: _ink),
        ),
        Text(
          '${state.filteredReviews.length} / ${state.allReviews.length}',
          style: const TextStyle(fontSize: 14, color: _muted),
        ),
      ],
    );
  }
}

String _actionMessageText(BuildContext context, String key) {
  switch (key) {
    case 'replySubmittedSuccess':
      return AppLocalizations.replySubmittedSuccess(context);
    case 'reviewReportedSuccess':
      return AppLocalizations.reviewReportedSuccess(context);
    case 'replyFailed':
      return AppLocalizations.replyFailed(context);
    case 'reportFailed':
      return AppLocalizations.reportFailed(context);
    default:
      return key;
  }
}

class _LiveSyncBadge extends StatelessWidget {
  const _LiveSyncBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.08 + (0.06 * value)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.6 * value),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.live(context),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.overallRating(context),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: _ink),
          ),
          const SizedBox(height: 8),
          Text(
            overallRating.toStringAsFixed(1),
            style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold, color: _ink),
          ),
          const SizedBox(height: 8),
          _StarRating(rating: overallRating, size: 24),
          const SizedBox(height: 8),
          Text(
            '($totalReviews ${AppLocalizations.reviews(context)})',
            style: const TextStyle(fontSize: 14, color: _muted),
          ),
        ],
      ),
    );
  }
}

class _RatingBreakdownCard extends StatelessWidget {
  final RatingBreakdownModel breakdown;
  final int? selectedStar;
  final ValueChanged<int> onStarTap;

  const _RatingBreakdownCard({
    Key? key,
    required this.breakdown,
    required this.selectedStar,
    required this.onStarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.ratingBreakdown(context),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: _ink),
          ),
          const SizedBox(height: 16),
          for (var star = 5; star >= 1; star--)
            _BreakdownRow(
              star: star,
              count: breakdown.countForStar(star),
              percent: breakdown.percentForStar(star),
              selected: selectedStar == star,
              onTap: () => onStarTap(star),
            ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final int star;
  final int count;
  final double percent;
  final bool selected;
  final VoidCallback onTap;

  const _BreakdownRow({
    Key? key,
    required this.star,
    required this.count,
    required this.percent,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: Text(
                '$star ${AppLocalizations.starShort(context)}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent / 100),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          selected ? _primary : _star),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: Text(
                '$count (${percent.toStringAsFixed(0)}%)',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final OverallRatingLoaded state;

  const _FilterTabs({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = <(String, String)>[
      ('all', AppLocalizations.allReviews(context)),
      ('unreplied', AppLocalizations.needsReply(context)),
      ('replied', AppLocalizations.replied(context)),
      ('reported', AppLocalizations.flagged(context)),
    ];

    final starTabs = <int>[5, 4, 3, 2, 1];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final tab in tabs) ...[
            _chip(
              context,
              label: tab.$2,
              selected: state.activeTabFilter == tab.$1 &&
                  state.selectedStarFilter == null,
              onTap: () {
                context
                    .read<OverallRatingBloc>()
                    .add(FilterReviewsByTabEvent(tab.$1));
                context
                    .read<OverallRatingBloc>()
                    .add(const FilterReviewsByStarEvent(null));
              },
            ),
            const SizedBox(width: 8),
          ],
          for (final star in starTabs) ...[
            _chip(
              context,
              label: '$star★',
              selected: state.selectedStarFilter == star,
              onTap: () {
                context
                    .read<OverallRatingBloc>()
                    .add(FilterReviewsByStarEvent(star));
                context
                    .read<OverallRatingBloc>()
                    .add(const FilterReviewsByTabEvent('all'));
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context,
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : _muted,
      ),
      selectedColor: _primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? _primary : Colors.grey.shade300),
      ),
      showCheckmark: false,
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final ReviewModel review;

  const _ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: review.authorName, url: review.authorAvatarUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(review.date),
                      style:
                          const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
              _RatingChip(rating: review.rating),
            ],
          ),
          if (review.productName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _star.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review.productName,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB87A00)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ExpandableText(
            text: review.content,
            expanded: _expanded,
            onToggle: () => setState(() => _expanded = !_expanded),
          ),
          if (review.isReported) ...[
            const SizedBox(height: 12),
            _ReportedBadge(reason: review.reportReason),
          ],
          const SizedBox(height: 12),
          if (review.hasSellerReply) ...[
            _SellerReplyBox(review: review),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showReplySheet(context, review),
                  icon: Icon(
                    review.hasSellerReply ? Icons.edit_note : Icons.reply,
                    size: 18,
                  ),
                  label: Text(
                    review.hasSellerReply
                        ? AppLocalizations.editReply(context)
                        : AppLocalizations.replyToCustomer(context),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: AppLocalizations.reportReview(context),
                onPressed: () => _showReportDialog(context, review),
                icon: Icon(
                  review.isReported ? Icons.flag : Icons.flag_outlined,
                  color: review.isReported ? Colors.orange : _muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReplySheet(BuildContext context, ReviewModel review) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final controller = TextEditingController(text: review.sellerReply ?? '');
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.replyToCustomer(sheetContext),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: _ink),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.writeReply(sheetContext),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<OverallRatingBloc, OverallRatingState>(
                builder: (context, state) {
                  final submitting = state is OverallRatingLoaded &&
                      state.isSubmittingReply;
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: submitting
                          ? null
                          : () {
                              final text = controller.text.trim();
                              if (text.isEmpty) return;
                              context.read<OverallRatingBloc>().add(
                                    SubmitSellerReplyEvent(
                                      reviewId: review.id,
                                      replyText: text,
                                      customerId: review.customerId,
                                      productName: review.productName,
                                    ),
                                  );
                              Navigator.of(sheetContext).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppLocalizations.sendReply(sheetContext)),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, ReviewModel review) {
    final reasons = <String>[
      'Spam',
      AppLocalizations.reportAbusive(context),
      'Fake',
      AppLocalizations.reportIrrelevant(context),
      AppLocalizations.other(context),
    ];
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
                  context.read<OverallRatingBloc>().add(
                        ReportReviewEvent(
                          reviewId: review.id,
                          reason: reason,
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

class _Avatar extends StatelessWidget {
  final String name;
  final String url;

  const _Avatar({Key? key, required this.name, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: CachedNetworkImageProvider(url),
      );
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: _primary.withValues(alpha: 0.12),
      child: Text(
        initial,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: _primary),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;

  const _RatingChip({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _star.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: _star, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: _ink),
          ),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _ExpandableText({
    Key? key,
    required this.text,
    required this.expanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLong = text.length > 160;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: expanded ? null : 4,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.4),
        ),
        if (isLong)
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                expanded ? 'Show less' : 'Show more',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primary),
              ),
            ),
          ),
      ],
    );
  }
}

class _SellerReplyBox extends StatelessWidget {
  final ReviewModel review;

  const _SellerReplyBox({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, size: 16, color: _primary),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.storeResponse(context),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primary),
              ),
              const Spacer(),
              if (review.sellerRepliedAt != null)
                Text(
                  _timeAgo(review.sellerRepliedAt!),
                  style: const TextStyle(fontSize: 11, color: _muted),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.sellerReply ?? '',
            style: const TextStyle(fontSize: 14, color: _ink, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ReportedBadge extends StatelessWidget {
  final String? reason;

  const _ReportedBadge({Key? key, this.reason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.report_problem, size: 14, color: Colors.orange),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.reportedUnderReview(context),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange),
          ),
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  final String message;

  const _EmptyReviews({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.rate_review_outlined, size: 48, color: _muted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRating({Key? key, required this.rating, this.size = 18})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: _star, size: size);
        } else if (index == rating.floor() && rating % 1 != 0) {
          return Icon(Icons.star_half, color: _star, size: size);
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
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 24,
            left: 16,
            right: 16,
            bottom: 32,
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

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return DateFormat('dd MMM yyyy').format(date);
}
