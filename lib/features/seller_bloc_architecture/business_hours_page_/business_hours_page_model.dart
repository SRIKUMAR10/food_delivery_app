class BusinessDayModel {
  final String dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isOpen;

  const BusinessDayModel({
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

  Map<String, dynamic> toMap() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
    };
  }

  factory BusinessDayModel.fromMap(Map<String, dynamic> map) {
    return BusinessDayModel(
      dayOfWeek: map['dayOfWeek'] as String? ?? '',
      openTime: map['openTime'] as String? ?? '09:00 AM',
      closeTime: map['closeTime'] as String? ?? '10:00 PM',
      isOpen: map['isOpen'] as bool? ?? true,
    );
  }

  static List<BusinessDayModel> defaultWeeklySchedule() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days
        .map((day) => BusinessDayModel(
              dayOfWeek: day,
              openTime: '09:00 AM',
              closeTime: '10:00 PM',
              isOpen: true,
            ))
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessDayModel &&
          runtimeType == other.runtimeType &&
          dayOfWeek == other.dayOfWeek &&
          openTime == other.openTime &&
          closeTime == other.closeTime &&
          isOpen == other.isOpen;

  @override
  int get hashCode =>
      dayOfWeek.hashCode ^
      openTime.hashCode ^
      closeTime.hashCode ^
      isOpen.hashCode;

  @override
  String toString() {
    return 'BusinessDayModel(dayOfWeek: $dayOfWeek, openTime: $openTime, closeTime: $closeTime, isOpen: $isOpen)';
  }
}

