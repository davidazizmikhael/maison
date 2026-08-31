class Reminder {
  Reminder({this.id, required this.title, required this.detail, required this.due, this.seasonal = false});

  /// Database row id (null in demo mode).
  final String? id;
  final String title;
  final String detail;
  final DateTime due;
  final bool seasonal;

  /// Whole calendar days until due (0 = today, negative = overdue),
  /// computed date-to-date so time of day never skews it.
  int get daysLeft {
    final now = DateTime.now();
    return DateTime(due.year, due.month, due.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  Reminder copyWith({DateTime? due}) =>
      Reminder(id: id, title: title, detail: detail, due: due ?? this.due, seasonal: seasonal);

  String get dueLabel => switch (daysLeft) {
        < -1 => 'OVERDUE ${-daysLeft} DAYS',
        -1 => 'DUE YESTERDAY',
        0 => 'DUE TODAY',
        1 => 'DUE TOMORROW',
        final d => 'IN $d DAYS',
      };
}
