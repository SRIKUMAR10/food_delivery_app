// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Help_Support_page_event.dart';
import 'Delivery_Help_Support_page_repository.dart';
import 'Delivery_Help_Support_page_service.dart';
import 'Delivery_Help_Support_page_state.dart';

class DeliveryHelpSupportPageBloc
    extends Bloc<DeliveryHelpSupportPageEvent, DeliveryHelpSupportPageState> {
  final DeliveryHelpSupportPageRepositoryBase repository;
  final DeliveryHelpSupportPageServiceBase service;
  StreamSubscription<List<SupportTicket>>? _ticketSubscription;

  DeliveryHelpSupportPageBloc({
    DeliveryHelpSupportPageRepositoryBase? repository,
    DeliveryHelpSupportPageServiceBase? service,
  }) : repository = repository ?? DeliveryHelpSupportPageRepository(),
       service = service ?? DeliveryHelpSupportPageService(),
       super(const DeliveryHelpSupportPageState()) {
    on<DeliveryHelpSupportInitEvent>(_onInit);
    on<DeliveryHelpSupportSearchFAQEvent>(_onSearchFAQ);
    on<DeliveryHelpSupportSelectCategoryEvent>(_onSelectCategory);
    on<DeliveryHelpSupportSelectTicketFilterEvent>(_onSelectTicketFilter);
    on<DeliveryHelpSupportCreateTicketEvent>(_onCreateTicket);
    on<DeliveryHelpSupportSubmitFeedbackEvent>(_onSubmitFeedback);
    on<DeliveryHelpSupportTicketsUpdatedEvent>(_onTicketsUpdated);
  }

  Future<void> _onInit(
    DeliveryHelpSupportInitEvent event,
    Emitter<DeliveryHelpSupportPageState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DeliveryHelpSupportStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final faqs = await repository.getFAQs();
      await _ticketSubscription?.cancel();
      _ticketSubscription = repository.watchSupportTickets().listen(
        (tickets) {
          if (!isClosed) {
            add(DeliveryHelpSupportTicketsUpdatedEvent(tickets));
          }
        },
        onError: (_) {
          // Real-time streams retry internally; keep the UI alive.
        },
      );
      emit(
        state.copyWith(
          status: DeliveryHelpSupportStatus.loaded,
          faqs: faqs,
          filteredFaqs: _filterFAQs(
            faqs,
            state.searchQuery,
            state.selectedCategory,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryHelpSupportStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchFAQ(
    DeliveryHelpSupportSearchFAQEvent event,
    Emitter<DeliveryHelpSupportPageState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: event.query,
        filteredFaqs: _filterFAQs(
          state.faqs,
          event.query,
          state.selectedCategory,
        ),
      ),
    );
  }

  void _onSelectCategory(
    DeliveryHelpSupportSelectCategoryEvent event,
    Emitter<DeliveryHelpSupportPageState> emit,
  ) {
    final category = event.category == 'all' ? null : event.category;
    emit(
      state.copyWith(
        selectedCategory: category,
        clearCategory: event.category == 'all',
        filteredFaqs: _filterFAQs(state.faqs, state.searchQuery, category),
      ),
    );
  }

  void _onSelectTicketFilter(
    DeliveryHelpSupportSelectTicketFilterEvent event,
    Emitter<DeliveryHelpSupportPageState> emit,
  ) {
    emit(state.copyWith(ticketFilter: event.filter));
  }

  Future<void> _onCreateTicket(
    DeliveryHelpSupportCreateTicketEvent event,
    Emitter<DeliveryHelpSupportPageState> emit,
  ) async {
    final subject = event.subject.trim();
    final description = event.description.trim();

    if (subject.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Please enter a subject for your support ticket.',
        ),
      );
      return;
    }
    if (description.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Please describe the issue you are facing.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DeliveryHelpSupportStatus.submitting,
        isSubmitting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      await repository.createSupportTicket(
        subject: subject,
        category: event.category,
        priority: event.priority,
        description: description,
        orderId: event.orderId,
      );
      emit(
        state.copyWith(
          status: DeliveryHelpSupportStatus.loaded,
          isSubmitting: false,
          successMessage: 'Your support ticket has been submitted.',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryHelpSupportStatus.loaded,
          isSubmitting: false,
          errorMessage: 'Could not submit ticket. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSubmitFeedback(
    DeliveryHelpSupportSubmitFeedbackEvent event,
    Emitter<DeliveryHelpSupportPageState> emit,
  ) async {
    if (event.rating < 1 || event.rating > 5) {
      emit(
        state.copyWith(
          errorMessage: 'Please select a rating between 1 and 5 stars.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      await repository.submitFeedback(event.rating, event.comment);
      emit(
        state.copyWith(
          isSubmitting: false,
          feedbackSuccess: true,
          successMessage: 'Thank you for your feedback!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Could not submit feedback. Please try again.',
        ),
      );
    }
  }

  void _onTicketsUpdated(
    DeliveryHelpSupportTicketsUpdatedEvent event,
    Emitter<DeliveryHelpSupportPageState> emit,
  ) {
    emit(
      state.copyWith(
        status: state.status == DeliveryHelpSupportStatus.initial ||
                state.status == DeliveryHelpSupportStatus.error
            ? DeliveryHelpSupportStatus.loaded
            : state.status,
        tickets: event.tickets,
        clearError: true,
      ),
    );
  }

  List<FAQItem> _filterFAQs(
    List<FAQItem> faqs,
    String query,
    String? category,
  ) {
    final normalized = query.trim().toLowerCase();
    return faqs.where((item) {
      final matchesCategory =
          category == null || item.category == category;
      final matchesQuery =
          normalized.isEmpty ||
          item.question.toLowerCase().contains(normalized) ||
          item.answer.toLowerCase().contains(normalized);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Future<void> close() async {
    await _ticketSubscription?.cancel();
    return super.close();
  }
}
