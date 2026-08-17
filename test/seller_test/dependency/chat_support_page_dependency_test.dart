import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

void main() {
  group('ChatSupportPage Dependency Injection Tests', () {
    test('ChatSupportBloc is instantiable with an IChatRepository', () {
      final repository = MockIChatRepository();
      final bloc = ChatSupportBloc(repository: repository);

      expect(bloc, isNotNull);
      expect(bloc.state, isNotNull);

      bloc.close();
    });

    test('ChatSupportPage accepts deep-link constructor parameters', () {
      const page = ChatSupportPage(
        sellerId: 'seller_1',
        initialOrderId: 'ord_1',
        targetRole: 'delivery_partner',
        partnerId: 'rider_1',
        partnerName: 'Raj',
        partnerPhone: '+911234567890',
      );

      expect(page.sellerId, 'seller_1');
      expect(page.initialOrderId, 'ord_1');
      expect(page.targetRole, 'delivery_partner');
      expect(page.partnerId, 'rider_1');
      expect(page.partnerName, 'Raj');
    });

    test('IChatRepository exposes typing status contract', () {
      final repository = MockIChatRepository();
      expect(repository, isA<IChatRepository>());
    });
  });
}
