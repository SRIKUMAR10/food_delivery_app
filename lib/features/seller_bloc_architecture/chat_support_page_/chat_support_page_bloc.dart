import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_support_page_event.dart';
import 'chat_support_page_state.dart';
import 'chat_support_page_repository.dart';

class ChatSupportBloc extends Bloc<ChatSupportEvent, ChatSupportState> {
  final ChatSupportRepository repository;
  String? _sellerId;

  ChatSupportBloc({required this.repository}) : super(ChatSupportInitial()) {
    on<LoadChatSessionsEvent>(_onLoadChatSessions);
    on<SelectChatSessionEvent>(_onSelectChatSession);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onLoadChatSessions(LoadChatSessionsEvent event, Emitter<ChatSupportState> emit) async {
    _sellerId = event.sellerId;
    emit(ChatSupportLoading());
    try {
      final sessions = await repository.getActiveSessions(event.sellerId);
      emit(ChatSupportLoaded(activeSessions: sessions));
    } catch (e) {
      emit(ChatSupportError('Failed to load chat sessions: $e'));
    }
  }

  void _onSelectChatSession(SelectChatSessionEvent event, Emitter<ChatSupportState> emit) {
    final currentState = state;
    if (currentState is! ChatSupportLoaded) return;

    // Mark session as read locally
    final updatedSessions = currentState.activeSessions.map((session) {
      if (session.sessionId == event.sessionId) {
        return session.copyWith(unreadCount: 0);
      }
      return session;
    }).toList();

    emit(currentState.copyWith(
      activeSessions: updatedSessions,
      selectedSessionId: event.sessionId,
      clearError: true,
    ));
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatSupportState> emit) async {
    final currentState = state;
    if (currentState is! ChatSupportLoaded) return;
    if (event.text.trim().isEmpty) return;

    emit(currentState.copyWith(isSendingMessage: true, clearError: true));

    try {
      if (_sellerId == null) throw Exception('Seller ID not initialized.');
      final newMessage = await repository.sendMessage(_sellerId!, event.sessionId, event.text);
      
      final updatedSessions = currentState.activeSessions.map((session) {
        if (session.sessionId == event.sessionId) {
          return session.copyWith(
            messages: List.from(session.messages)..add(newMessage),
          );
        }
        return session;
      }).toList();

      emit(currentState.copyWith(
        activeSessions: updatedSessions,
        isSendingMessage: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSendingMessage: false,
        errorMessage: 'Failed to send message. Please try again.',
      ));
    }
  }
}
