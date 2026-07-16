import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_repository.dart';

class MockChatSupportRepository extends Mock implements ChatSupportRepository {}

void main() {
  group('ChatSupportBloc', () {
    late ChatSupportBloc bloc;
    late MockChatSupportRepository mockRepository;

    setUp(() {
      mockRepository = MockChatSupportRepository();
      bloc = ChatSupportBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ChatSupportInitial', () {
      expect(bloc.state, isA<ChatSupportInitial>());
    });

    blocTest<ChatSupportBloc, ChatSupportState>(
      'emits [Loading, Loaded] when LoadChatSessionsEvent is added',
      build: () {
        when(() => mockRepository.getActiveSessions(any())).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadChatSessionsEvent('seller1')),
      expect: () => [
        isA<ChatSupportLoading>(),
        isA<ChatSupportLoaded>(),
      ],
    );
  });
}
