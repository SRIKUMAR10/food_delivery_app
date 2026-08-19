import 'package:equatable/equatable.dart';

enum HelpSupportStatus { initial, loading, loaded, submitting, success, failure }

class FaqItem extends Equatable {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});

  factory FaqItem.fromFirestore(Map<String, dynamic> data) {
    return FaqItem(
      question: data['question'] as String? ?? '',
      answer: data['answer'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [question, answer];
}

class HelpSupportState extends Equatable {
  final HelpSupportStatus status;
  final List<FaqItem> faqItems;
  final String? successMessage;
  final String? errorMessage;

  const HelpSupportState({
    this.status = HelpSupportStatus.initial,
    this.faqItems = const [],
    this.successMessage,
    this.errorMessage,
  });

  HelpSupportState copyWith({
    HelpSupportStatus? status,
    List<FaqItem>? faqItems,
    String? successMessage,
    String? errorMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return HelpSupportState(
      status: status ?? this.status,
      faqItems: faqItems ?? this.faqItems,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, faqItems, successMessage, errorMessage];
}
