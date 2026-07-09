import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Cubit for Carousel State Management
class CarouselCubit extends Cubit<int> {
  CarouselCubit() : super(0);

  void onPageChanged(int index) => emit(index);
}

// Carousel Widget
class ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImageCarousel({super.key, required this.imageUrls});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late final PageController _pageController;
  final ScrollController _thumbnailScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  void _scrollToThumbnail(int index) {
    if (_thumbnailScrollController.hasClients) {
      final double position = index * 80.0; // Approximate item width + padding
      _thumbnailScrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      DialogRoute(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE50914),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: 350,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 64),
        ),
      );
    }

    return BlocProvider(
      create: (_) => CarouselCubit(),
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              // Main Image Slider with Zoom Support
              SizedBox(
                height: 320,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageUrls.length,
                        onPageChanged: (index) {
                          context.read<CarouselCubit>().onPageChanged(index);
                          _scrollToThumbnail(index);
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullScreenImage(context, index),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE50914),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade100,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Fullscreen button (UI Only for now)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              final currentIndex = context
                                  .read<CarouselCubit>()
                                  .state;
                              _showFullScreenImage(context, currentIndex);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Navigation Controls & Thumbnails
              BlocBuilder<CarouselCubit, int>(
                builder: (context, currentIndex) {
                  return Column(
                    children: [
                      // Thumbnail Gallery
                      if (widget.imageUrls.length > 1)
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            controller: _thumbnailScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.imageUrls.length,
                            itemBuilder: (context, index) {
                              final isSelected = currentIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE50914)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFE50914,
                                              ).withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrls[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade200,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey.shade200,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16),
                      // Text Navigation (Image 1 / 3 and Prev/Next)
                      if (widget.imageUrls.isNotEmpty)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: currentIndex > 0
                                    ? () {
                                        _pageController.previousPage(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 14,
                                ),
                                label: const Text('Previous'),
                                style: TextButton.styleFrom(
                                  foregroundColor: currentIndex > 0
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Image ${currentIndex + 1} / ${widget.imageUrls.length}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    currentIndex < widget.imageUrls.length - 1
                                    ? () {
                                        _pageController.nextPage(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      currentIndex < widget.imageUrls.length - 1
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Next'),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_ios, size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
