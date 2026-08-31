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
