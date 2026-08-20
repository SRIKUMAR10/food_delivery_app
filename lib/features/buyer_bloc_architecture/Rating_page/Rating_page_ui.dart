import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Rating_page_bloc.dart';
import 'Rating_page_event.dart';
import 'Rating_page_state.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/repositories/i_rating_repository.dart';
import '../../../repositories/firebase_rating_repository.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

class RatingPageUI extends StatelessWidget {
  final String foodId;
  final String foodName;
  final String? partnerId;
  final String? partnerName;
  final String? partnerAvatarUrl;
  final String? orderId;
  final IRatingRepository? ratingRepository;
  final IAuthService? authService;
  final RatingPageBloc? bloc;

  const RatingPageUI({
    super.key,
    required this.foodId,
    required this.foodName,
    this.partnerId,
    this.partnerName,
    this.partnerAvatarUrl,
    this.orderId,
    this.ratingRepository,
    this.authService,
    this.bloc,
  });

  RatingPageBloc? _tryGetBloc(BuildContext context) {
    try {
      return BlocProvider.of<RatingPageBloc>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<RatingPageBloc>.value(
        value: bloc!,
        child: RatingPageView(
          foodId: foodId,
          foodName: foodName,
          partnerId: partnerId,
          partnerName: partnerName,
          partnerAvatarUrl: partnerAvatarUrl,
          orderId: orderId,
        ),
      );
    }

    final existingBloc = _tryGetBloc(context);
    if (existingBloc != null) {
      return RatingPageView(
        foodId: foodId,
        foodName: foodName,
        partnerId: partnerId,
        partnerName: partnerName,
        partnerAvatarUrl: partnerAvatarUrl,
        orderId: orderId,
      );
    }

    IRatingRepository ratingRepo;
    if (ratingRepository != null) {
      ratingRepo = ratingRepository!;
    } else {
      try {
        ratingRepo = context.read<IRatingRepository>();
      } catch (_) {
        ratingRepo = FirebaseRatingRepository();
      }
    }

    IAuthService auth;
    if (authService != null) {
      auth = authService!;
    } else {
      try {
        auth = context.read<IAuthService>();
      } catch (_) {
        auth = FirebaseAuthService();
      }
    }

    return BlocProvider(
      create: (context) => RatingPageBloc(
        ratingRepository: ratingRepo,
        authService: auth,
      )..add(LoadRating(foodId: foodId)),
      child: RatingPageView(
        foodId: foodId,
        foodName: foodName,
        partnerId: partnerId,
        partnerName: partnerName,
        partnerAvatarUrl: partnerAvatarUrl,
        orderId: orderId,
      ),
    );
  }
}

class RatingPageView extends StatefulWidget {
  final String foodId;
  final String foodName;
  final String? partnerId;
  final String? partnerName;
  final String? partnerAvatarUrl;
  final String? orderId;

  const RatingPageView({
    super.key,
    required this.foodId,
    required this.foodName,
    this.partnerId,
    this.partnerName,
    this.partnerAvatarUrl,
    this.orderId,
  });

  @override
  State<RatingPageView> createState() => _RatingPageViewState();
}

class _RatingPageViewState extends State<RatingPageView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _partnerReviewController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  double _partnerRating = 5.0;
  final Set<String> _selectedPartnerTags = {};
  int _selectedTipAmount = 0;

  static const List<String> _availableTags = [
    '⚡ Super Fast',
    '🌟 Polite & Friendly',
    '📦 Hot & Fresh Packaging',
    '📍 Perfect Navigation',
  ];

  static const List<int> _tipOptions = [0, 20, 30, 50, 100];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _partnerReviewController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _getRatingEmoji(double rating) {
    if (rating <= 1.0) return '😞';
    if (rating <= 1.5) return '😕';
    if (rating <= 2.0) return '😐';
    if (rating <= 2.5) return '🙂';
    if (rating <= 3.0) return '😊';
    if (rating <= 3.5) return '😄';
    if (rating <= 4.0) return '😁';
    if (rating <= 4.5) return '😍';
    return '🤩';
  }

  void _submitRating(BuildContext context, double rating) {
    FocusScope.of(context).unfocus();
    context.read<RatingPageBloc>().add(
      SubmitRating(
        foodId: widget.foodId,
        foodName: widget.foodName,
        rating: rating,
        reviewText: _reviewController.text.trim(),
        partnerId: widget.partnerId,
        partnerName: widget.partnerName,
        orderId: widget.orderId,
        partnerRating: _partnerRating,
        partnerReviewText: _partnerReviewController.text.trim(),
        partnerTags: _selectedPartnerTags.toList(),
      ),
    );
  }

  Widget _buildFractionalStar(double rating, int index, {double size = 48}) {
    double starValue = index + 1.0;
    if (rating >= starValue) {
      return Icon(Icons.star_rounded, color: const Color(0xFFFFB800), size: size);
    } else if (rating >= starValue - 0.5) {
      return Icon(
        Icons.star_half_rounded,
        color: const Color(0xFFFFB800),
        size: size,
      );
    } else {
      return Icon(
        Icons.star_border_rounded,
        color: const Color(0xFFFFB800),
        size: size,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rating',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<RatingPageBloc, RatingPageState>(
        listener: (context, state) {
          if (state is RatingLoaded) {
            if (_reviewController.text.isEmpty && state.reviewText.isNotEmpty) {
              _reviewController.text = state.reviewText;
            }
          } else if (state is RatingSuccess) {
            _reviewController.clear();
            final emoji = _getRatingEmoji(state.rating);
            final tipMsg = _selectedTipAmount > 0 ? ' (₹$_selectedTipAmount Tip added!)' : '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Thank you! Your rating ${state.rating.toStringAsFixed(1)}$tipMsg has been submitted. $emoji',
                  style: const TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pop(context, true);
            });
          } else if (state is RatingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildDesktopLayout(context, state);
              }
              return _buildMobileLayout(context, state);
            },
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, RatingPageState state) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildRatingForm(context, state, isDesktop: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, RatingPageState state) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Container(
            width: 900,
            constraints: const BoxConstraints(maxHeight: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left Side: Illustration
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        bottomLeft: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 80,
                            color: Color(0xFFFFB800),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your Feedback\nMeans A Lot!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C1C1C),
                                height: 1.2,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Help us improve by rating your food and delivery experience.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right Side: Form
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildRatingForm(
                          context,
                          state,
                          isDesktop: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingForm(
    BuildContext context,
    RatingPageState state, {
    bool isDesktop = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDesktop) ...[
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              size: 48,
              color: Color(0xFFFFB800),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'How was your food?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C1C1C),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Please rate ${widget.foodName}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Star Rating Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<RatingPageBloc>().add(
                  RatingChanged((index + 1).toDouble()),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildFractionalStar(state.rating, index, size: 40),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        // Slider for fractional rating
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFFFB800),
            inactiveTrackColor: const Color(0xFFFFB800).withValues(alpha: 0.2),
            thumbColor: const Color(0xFFFFB800),
            overlayColor: const Color(0xFFFFB800).withValues(alpha: 0.1),
            trackHeight: 5.0,
          ),
          child: Slider(
            value: state.rating,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            label: state.rating.toStringAsFixed(1),
            onChanged: (value) {
              HapticFeedback.selectionClick();
              context.read<RatingPageBloc>().add(RatingChanged(value));
            },
          ),
        ),
        Text(
          '${state.rating.toStringAsFixed(1)} / 5.0',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 20),
        // Food Review Input
        TextField(
          controller: _reviewController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Leave a comment about the food (optional)...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: BuyerAppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Delivery Partner Section
        _buildDeliveryPartnerSection(),
        const SizedBox(height: 24),

        // Tip Partner Section
        _buildTippingSection(),
        const SizedBox(height: 28),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: state is RatingLoading
                ? null
                : () => _submitRating(context, state.rating),
            style: ElevatedButton.styleFrom(
              backgroundColor: BuyerAppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: BuyerAppColors.primary.withValues(alpha: 0.4),
            ),
            child: state is RatingLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _selectedTipAmount > 0
                        ? 'Submit Review & Tip ₹$_selectedTipAmount'
                        : 'Submit Review',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryPartnerSection() {
    final partnerName = widget.partnerName ?? 'Delivery Partner';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  color: Color(0xFF16A34A),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate Delivery: $partnerName',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'How was the delivery service?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Rider 5-star selector
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starVal = index + 1.0;
                final isFilled = _partnerRating >= starVal;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _partnerRating = starVal;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFF16A34A),
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Compliment Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedPartnerTags.contains(tag);
              return FilterChip(
                label: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF166534),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF16A34A),
                backgroundColor: Colors.white,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFBBF7D0),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (selected) {
                      _selectedPartnerTags.add(tag);
                    } else {
                      _selectedPartnerTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTippingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.volunteer_activism_rounded, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Text(
                'Tip your Delivery Partner',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '100% of the tip goes directly to your rider.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 12),
          // Tip Chips Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _tipOptions.map((amount) {
              final isSelected = _selectedTipAmount == amount;
              final label = amount == 0 ? 'No Tip' : '₹$amount';
              return ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF92400E),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFFD97706),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFD97706) : const Color(0xFFFDE68A),
                ),
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedTipAmount = selected ? amount : 0;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
