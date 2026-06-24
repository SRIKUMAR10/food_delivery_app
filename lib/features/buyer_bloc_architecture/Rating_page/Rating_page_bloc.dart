import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Rating_page_event.dart';
import 'Rating_page_state.dart';

class RatingPageBloc extends Bloc<RatingPageEvent, RatingPageState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RatingPageBloc({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const RatingInitial()) {
    on<RatingChanged>(_onRatingChanged);
    on<SubmitRating>(_onSubmitRating);
    on<LoadRating>(_onLoadRating);
  }

  Future<void> _onLoadRating(LoadRating event, Emitter<RatingPageState> emit) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final ratingsStream = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ratings')
        .doc(event.foodId)
        .snapshots();
        
    await emit.forEach<DocumentSnapshot>(
      ratingsStream,
      onData: (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          return RatingLoaded(
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            reviewText: data['reviewText'] as String? ?? '',
          );
        }
        return const RatingInitial();
      },
      onError: (_, __) => state,
    );
  }

  void _onRatingChanged(RatingChanged event, Emitter<RatingPageState> emit) {
    emit(RatingUpdated(rating: event.rating));
  }

  Future<void> _onSubmitRating(SubmitRating event, Emitter<RatingPageState> emit) async {
    emit(RatingLoading(rating: state.rating));
    
    try {
      if (event.rating == 0) {
        throw Exception("Please provide a valid rating greater than 0.");
      }

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }

      final ratingsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratings')
          .doc(event.foodId);

      await ratingsRef.set({
        'rating': event.rating,
        'reviewText': event.reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final productReviewsRef = _firestore
          .collection('products')
          .doc(event.foodId)
          .collection('reviews')
          .doc(user.uid);

      await productReviewsRef.set({
        'reviewerName': user.displayName ?? 'Anonymous User',
        'rating': event.rating,
        'reviewText': event.reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      emit(RatingSuccess(rating: state.rating));
    } catch (e) {
      emit(RatingError(
        message: e.toString().replaceAll("Exception: ", ""), 
        rating: state.rating,
      ));
    }
  }
}
