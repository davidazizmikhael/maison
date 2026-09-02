import 'home_record.dart';
import 'reminder.dart';

/// How the user is capturing this entry.
enum CaptureMode { nameplate, receipt, note }

/// A structured result from the AI (or its demo stand-in).
class ParseResult {
  ParseResult({required this.record, required this.reminders, required this.steps});
  final HomeRecord record;
  final List<Reminder> reminders;
  final List<String> steps;
}

/// Safety net for return windows: when the record carries a return-by date
/// but the AI scheduled no reminder near it, add one so the user is notified
/// BEFORE the window closes — 3 days ahead, clamped to today for short
/// windows. Deterministic on purpose: the return-deadline promise must not
/// depend on the model remembering to emit a reminder.
ParseResult ensureReturnReminder(ParseResult result, String title, {DateTime? now}) {
  final returnBy = result.record.returnBy;
  if (returnBy == null) return result;
  final today = now ?? DateTime.now();
  if (!returnBy.isAfter(today)) return result; // window already closed
  final covered = result.reminders.any((r) =>
      !r.due.isAfter(returnBy) && r.due.isAfter(returnBy.subtract(const Duration(days: 8))));
  if (covered) return result;
  var due = returnBy.subtract(const Duration(days: 3));
  if (due.isBefore(today)) due = today;
  return ParseResult(
    record: result.record,
    reminders: [
      ...result.reminders,
      Reminder(title: title, detail: result.record.title, due: due),
    ],
    steps: result.steps,
  );
}
