class BusinessDayModel {
  final String dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isOpen;

  BusinessDayModel({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
  });

  BusinessDayModel copyWith({
    String? dayOfWeek,
    String? openTime,
    String? closeTime,
    bool? isOpen,
  }) {
    return BusinessDayModel(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
