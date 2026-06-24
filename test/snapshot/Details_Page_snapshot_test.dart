import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPage Snapshot Tests', () {
    testWidgets('DetailsPage matches snapshot tree', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const DetailsPage(itemId: '1'),
          ),
        ),
      );

      // We can use expectations on the widget tree to act like a snapshot
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BlocBuilder<DetailsPageBloc, DetailsPageState>), findsOneWidget);
    });
  });
}
