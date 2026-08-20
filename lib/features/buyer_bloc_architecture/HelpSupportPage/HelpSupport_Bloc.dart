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

    try {
      await emit.forEach<List<FaqItem>>(
        _repository.watchFaqs(),
        onData: (faqItems) => state.copyWith(
          status: HelpSupportStatus.loaded,
          faqItems: faqItems.isNotEmpty ? faqItems : HelpSupportRepository.defaultFaqs,
        ),
        onError: (e, _) => state.copyWith(
          status: HelpSupportStatus.loaded,
          faqItems: state.faqItems.isNotEmpty ? state.faqItems : HelpSupportRepository.defaultFaqs,
          errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportStatus.loaded,
        faqItems: state.faqItems.isNotEmpty ? state.faqItems : HelpSupportRepository.defaultFaqs,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
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
