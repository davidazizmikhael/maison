import 'package:flutter_test/flutter_test.dart';
import 'package:maison/data/models.dart';

ParseResult _result({DateTime? returnBy, List<Reminder> reminders = const []}) {
  return ParseResult(
    record: HomeRecord(
      kind: RecordKind.receipt,
      title: 'Running shoes — Nike Pegasus',
      subtitle: 'From Sports Experts receipt',
      room: 'Home',
      returnBy: returnBy,
    ),
    reminders: reminders,
    steps: const [],
  );
}

void main() {
  final today = DateTime(2026, 9, 2);

  group('ensureReturnReminder', () {
    test('no return-by date: unchanged', () {
      final r = ensureReturnReminder(_result(), 'Return window closes', now: today);
      expect(r.reminders, isEmpty);
    });

    test('window already closed: no reminder for the past', () {
      final r = ensureReturnReminder(
          _result(returnBy: DateTime(2026, 8, 20)), 'Return window closes',
          now: today);
      expect(r.reminders, isEmpty);
    });

    test('uncovered window: adds a reminder 3 days before it closes', () {
      final r = ensureReturnReminder(
          _result(returnBy: DateTime(2026, 10, 2)), 'Return window closes',
          now: today);
      expect(r.reminders, hasLength(1));
      expect(r.reminders.single.title, 'Return window closes');
      expect(r.reminders.single.detail, 'Running shoes — Nike Pegasus');
      expect(r.reminders.single.due, DateTime(2026, 9, 29));
    });

    test('short window: due date clamps to today, never the past', () {
      final r = ensureReturnReminder(
          _result(returnBy: DateTime(2026, 9, 3)), 'Return window closes',
          now: today);
      expect(r.reminders.single.due, today);
    });

    test('AI already scheduled one near the deadline: no duplicate', () {
      final r = ensureReturnReminder(
          _result(
            returnBy: DateTime(2026, 10, 2),
            reminders: [Reminder(title: 'Return the shoes', detail: 'Sports Experts', due: DateTime(2026, 9, 30))],
          ),
          'Return window closes',
          now: today);
      expect(r.reminders, hasLength(1));
      expect(r.reminders.single.title, 'Return the shoes');
    });

    test('an unrelated far-off reminder does not count as coverage', () {
      final r = ensureReturnReminder(
          _result(
            returnBy: DateTime(2026, 10, 2),
            reminders: [Reminder(title: 'Re-waterproof them', detail: 'Seasonal care', due: DateTime(2027, 3, 1))],
          ),
          'Return window closes',
          now: today);
      expect(r.reminders, hasLength(2));
    });
  });
}
