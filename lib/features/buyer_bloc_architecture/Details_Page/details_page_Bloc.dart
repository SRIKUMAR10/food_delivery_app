import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'details_page_Event.dart';
import 'details_page_State.dart';
import 'details_repository.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final DetailsRepository _repository;

  DetailsBloc({DetailsRepository? repository})
      : _repository = repository ?? DetailsRepository(),
        super(const DetailsState()) {
    on<DetailsQuantityIncreased>(_onQuantityIncreased);
    on<DetailsQuantityDecreased>(_onQuantityDecreased);
    on<SubmitRating>(_onSubmitRating);
    on<LoadDetailsRating>(_onLoadDetailsRating);
  }

  Future<void> _onLoadDetailsRating(
    LoadDetailsRating event,
    Emitter<DetailsState> emit,
  ) async {
    final avgStream = _repository.getAverageProductRatingStream(event.foodId);
    final userId = _repository.currentUserId;

    if (userId == null) {
      await emit.forEach<double>(
        avgStream,
        onData: (avg) => state.copyWith(averageRating: avg),
        onError: (_, __) => state,
      );
      return;
    }

    final userStream = _repository.getUserRatingStream(userId, event.foodId);

    await emit.forEach<List<double>>(
      Rx.combineLatest2(userStream, avgStream, (u, a) => [u, a]),
      onData: (data) {
        return state.copyWith(currentRating: data[0], averageRating: data[1]);
      },
      onError: (_, __) => state,
    );
  }

  void _onQuantityIncreased(
    DetailsQuantityIncreased event,
    Emitter<DetailsState> emit,
  ) {
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void _onQuantityDecreased(
    DetailsQuantityDecreased event,
    Emitter<DetailsState> emit,
  ) {
    if (state.quantity > 1) {
      emit(state.copyWith(quantity: state.quantity - 1));
    }
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<DetailsState> emit,
  ) async {
    emit(state.copyWith(ratingStatus: RatingStatus.submitting));

    try {
      final userId = _repository.currentUserId;
      if (userId == null) {
        emit(
          state.copyWith(
            ratingStatus: RatingStatus.failure,
            ratingMessage: 'User not signed in.',
          ),
        );
        return;
      }

      await _repository.submitRating(userId, event.foodId, event.rating);

      emit(state.copyWith(
        ratingStatus: RatingStatus.success,
        currentRating: event.rating, // Sync UI state with Firestore
        ratingMessage: 'Rating submitted successfully!',
      ));
    } catch (e) {
      emit(
        state.copyWith(
          ratingStatus: RatingStatus.failure,
          ratingMessage: 'Failed to submit rating: $e',
        ),
      );
    }
  }
}
