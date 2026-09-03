import 'home_record.dart';
import 'reminder.dart';

/// How the user is capturing this entry.
enum CaptureMode { nameplate, receipt, note }

/// A structured result from the AI (or its demo stand-in).
class ParseResult {
  ParseResult(
      {required this.record, required this.reminders, required this.steps, this.confidence});
  final HomeRecord record;
  final List<Reminder> reminders;
  final List<String> steps;

  /// The AI's own certainty ("high" | "medium" | "low") — low means the input
  /// was blurry/ambiguous and the confirm screen shows a double-check hint.
  final String? confidence;
}

/// Safety net for return windows: when the record carries a return-by date
/// but the AI scheduled no reminder near it, add one so the user is notified
/// BEFORE the window closes — 3 days ahead, clamped to today for short
/// windows. Deterministic on purpose: the return-deadline promise must not
/// depend on the model remembering to emit a reminder.
ParseResult ensureReturnReminder(ParseResult result, String title, {DateTime? now}) {
  final extra = returnReminderFor(result.record, result.reminders, title, now: now);
  if (extra == null) return result;
  return ParseResult(
    record: result.record,
    reminders: [...result.reminders, extra],
    steps: result.steps,
    confidence: result.confidence,
  );
}

/// The reminder a record's return-by date deserves, or null when the window
/// is absent/closed or an existing reminder already lands near the deadline.
/// Shared by the parse-time safety net and by post-save return-date edits.
Reminder? returnReminderFor(HomeRecord record, List<Reminder> existing, String title,
    {DateTime? now}) {
  final returnBy = record.returnBy;
  if (returnBy == null) return null;
  final today = now ?? DateTime.now();
  if (!returnBy.isAfter(today)) return null; // window already closed
  final covered = existing.any((r) =>
      !r.due.isAfter(returnBy) && r.due.isAfter(returnBy.subtract(const Duration(days: 8))));
  if (covered) return null;
  var due = returnBy.subtract(const Duration(days: 3));
  if (due.isBefore(today)) due = today;
  return Reminder(title: title, detail: record.title, due: due);
}
