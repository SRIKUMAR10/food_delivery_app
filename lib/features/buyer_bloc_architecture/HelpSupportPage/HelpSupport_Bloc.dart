import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'HelpSupport_Event.dart';
import 'HelpSupport_State.dart';
import 'HelpSupport_Repository.dart';

class HelpSupportBloc extends Bloc<HelpSupportEvent, HelpSupportState> {
  final HelpSupportRepository _repository;

  HelpSupportBloc({required HelpSupportRepository repository})
    : _repository = repository,
      super(const HelpSupportState()) {
    on<LoadHelpContent>(_onLoadHelpContent);
    on<SubmitSupportTicket>(_onSubmitSupportTicket);
    on<SubmitFeedback>(_onSubmitFeedback);
  }

  Future<void> _onLoadHelpContent(
    LoadHelpContent event,
    Emitter<HelpSupportState> emit,
  ) async {
    emit(state.copyWith(status: HelpSupportStatus.loading));

    final faqItems = const [
      FaqItem(
        question: 'How do I place an order?',
        answer: 'Browse restaurants, add items to your cart, and proceed to checkout. Select your payment method and confirm the order.',
      ),
      FaqItem(
        question: 'How can I track my order?',
        answer: 'Go to "My Orders" from your profile, select the order you want to track, and you will see the live status and delivery partner location.',
      ),
      FaqItem(
        question: 'What payment methods are accepted?',
        answer: 'We accept credit/debit cards, UPI, and wallet balance. You can manage your payment methods from the Profile section.',
      ),
      FaqItem(
        question: 'Can I cancel my order?',
        answer: 'Orders can be cancelled before the restaurant starts preparing. Go to "My Orders" and select Cancel if the option is available.',
      ),
      FaqItem(
        question: 'How do I get a refund?',
        answer: 'If your order is cancelled or there is an issue, the refund will be credited to your FoodGo wallet or original payment method within 5-7 business days.',
      ),
      FaqItem(
        question: 'How do I contact support?',
        answer: 'You can reach us via the Contact Us option, submit a ticket through Order/Payment/Delivery Issues, or email us at support@foodgo.app.',
      ),
    ];

    emit(state.copyWith(
      status: HelpSupportStatus.loaded,
      faqItems: faqItems,
    ));
  }

  Future<void> _onSubmitSupportTicket(
    SubmitSupportTicket event,
    Emitter<HelpSupportState> emit,
  ) async {
    emit(state.copyWith(status: HelpSupportStatus.submitting));

    try {
      await _repository.submitSupportTicket(
        type: event.type,
        subject: event.subject,
        message: event.message,
        orderId: event.orderId,
      );
      emit(state.copyWith(
        status: HelpSupportStatus.success,
        successMessage: 'Your ticket has been submitted. We will get back to you shortly.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedback event,
    Emitter<HelpSupportState> emit,
  ) async {
    emit(state.copyWith(status: HelpSupportStatus.submitting));

    try {
      await _repository.submitFeedback(
        rating: event.rating,
        comments: event.comments,
      );
      emit(state.copyWith(
        status: HelpSupportStatus.success,
        successMessage: 'Thank you for your feedback!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }
}
