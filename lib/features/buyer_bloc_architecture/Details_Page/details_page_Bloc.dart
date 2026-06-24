import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_page_Event.dart';
import 'details_page_State.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DetailsBloc() : super(const DetailsState()) {
    on<DetailsQuantityIncreased>(_onQuantityIncreased);
    on<DetailsQuantityDecreased>(_onQuantityDecreased);
    on<SubmitRating>(_onSubmitRating);
    on<LoadDetailsRating>(_onLoadDetailsRating);
  }

  Future<void> _onLoadDetailsRating(
    LoadDetailsRating event,
    Emitter<DetailsState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ratingStream = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ratings')
        .doc(event.foodId)
        .snapshots();

    await emit.forEach<DocumentSnapshot>(
      ratingStream,
      onData: (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final rating = (data['rating'] as num?)?.toDouble() ?? 4.5;
          return state.copyWith(currentRating: rating);
        }
        return state;
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
      final user = _auth.currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            ratingStatus: RatingStatus.failure,
            ratingMessage: 'User not signed in.',
          ),
        );
        return;
      }

      final uid = user.uid;
      // Define the target document path.
      final cartDocRef = _firestore
          .collection('orders')
          .doc(uid)
          .collection('transactions')
          .doc(event.foodId)
          .collection('cart')
          .doc(uid);

      // Save the rating first (at the top of the map object)
      await cartDocRef.set(
        {
          'rating': event.rating,
          'timestamp': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

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
