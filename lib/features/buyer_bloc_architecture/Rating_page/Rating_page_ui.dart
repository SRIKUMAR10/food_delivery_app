import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Rating_page_bloc.dart';
import 'Rating_page_event.dart';
import 'Rating_page_state.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/repositories/i_rating_repository.dart';

class RatingPageUI extends StatelessWidget {
  final String foodId;
  final String foodName;

  const RatingPageUI({super.key, required this.foodId, required this.foodName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RatingPageBloc(
        ratingRepository: context.read<IRatingRepository>(),
        authService: context.read<IAuthService>(),
      )..add(LoadRating(foodId: foodId)),
      child: RatingPageView(foodId: foodId, foodName: foodName),
    );
  }
}

class RatingPageView extends StatefulWidget {
  final String foodId;
  final String foodName;

  const RatingPageView({
    super.key,
    required this.foodId,
    required this.foodName,
  });

  @override
  State<RatingPageView> createState() => _RatingPageViewState();
}

class _RatingPageViewState extends State<RatingPageView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _reviewController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
        rating: rating,
        reviewText: _reviewController.text.trim(),
      ),
    );
  }

  Widget _buildFractionalStar(double rating, int index) {
    double starValue = index + 1.0;
    if (rating >= starValue) {
      return const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 48);
    } else if (rating >= starValue - 0.5) {
      return const Icon(
        Icons.star_half_rounded,
        color: Color(0xFFFFB800),
        size: 48,
      );
    } else {
      return const Icon(
        Icons.star_border_rounded,
        color: Color(0xFFFFB800),
        size: 48,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive constraints
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
            _reviewController.clear(); // Reset to default state
            final emoji = _getRatingEmoji(state.rating);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Thank you! Your rating ${state.rating.toStringAsFixed(1)} has been submitted. $emoji',
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
              padding: const EdgeInsets.all(32),
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
            height: 600,
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
                  flex: 5,
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
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFB800,
                            ).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 100,
                            color: Color(0xFFFFB800),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Your Feedback\nMeans A Lot!',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C1C1C),
                                height: 1.2,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            'Help us improve by rating your experience with .',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
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
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: SingleChildScrollView(
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              size: 64,
              color: Color(0xFFFFB800),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'How was your food?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C1C1C),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Please rate ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
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
                child: _buildFractionalStar(state.rating, index),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // Slider for fractional rating
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFFFB800),
            inactiveTrackColor: const Color(0xFFFFB800).withValues(alpha: 0.2),
            thumbColor: const Color(0xFFFFB800),
            overlayColor: const Color(0xFFFFB800).withValues(alpha: 0.1),
            trackHeight: 6.0,
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
          ' / 5.0',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 32),
        // Review Input
        TextField(
          controller: _reviewController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Leave a comment (optional)...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF2A39),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state is RatingLoading
                ? null
                : () => _submitRating(context, state.rating),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF2A39),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: const Color(0xFFEF2A39).withValues(alpha: 0.4),
            ),
            child: state is RatingLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit Review',
                    style: TextStyle(
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
}
