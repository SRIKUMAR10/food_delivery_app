import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockSellerReviewService extends Mock implements SellerReviewService {}

void main() {
  late MockSellerReviewService mockService;
  late OverallRatingBloc bloc;

  setUp(() {
    mockService = MockSellerReviewService();
    bloc = OverallRatingBloc(service: mockService);
  });

  tearDown(() {
    bloc.close();
  });

  Widget buildApp() {
    return MaterialApp(
      home: BlocProvider.value(
        value: bloc,
        child: const OverallRatingPage(),
      ),
    );
  }

  testWidgets('Full flow integration: Loading to Success to Refresh',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var rating = 4.5;
    var total = 100;
    when(() => mockService.watchRatingsAndReviews()).thenAnswer((_) {
      return Stream.value({
        'overallRating': rating,
        'totalReviews': total,
        'reviews': <Map<String, dynamic>>[],
      });
    });

    await tester.pumpWidget(buildApp());
    expect(find.byType(ListView), findsOneWidget); // Loading skeleton

    await tester.pumpAndSettle();
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('(100 reviews)'), findsOneWidget);

    rating = 4.9;
    total = 105;

    await tester.fling(find.byType(ListView), const Offset(0.0, 300.0), 1000.0);
    await tester.pumpAndSettle();

    expect(find.text('4.9'), findsOneWidget);
    expect(find.text('(105 reviews)'), findsOneWidget);
  });
}
