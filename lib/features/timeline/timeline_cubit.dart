import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/backend.dart';
import '../../data/models.dart';
import '../../data/notifications.dart';

/// A capture that is being parsed (or failed) — shown in place on the home
/// screen as an animated card until it becomes a record.
class ParsingTask {
  const ParsingTask({
    required this.id,
    required this.mode,
    this.noteText,
    this.imageBytes,
    this.error,
  });
  final int id;
  final CaptureMode mode;
  final String? noteText;
  final Uint8List? imageBytes;
  final String? error; // null while parsing

  ParsingTask failed(String message) =>
      ParsingTask(id: id, mode: mode, noteText: noteText, imageBytes: imageBytes, error: message);
}

class TimelineState {
  const TimelineState({
    this.records = const [],
    this.reminders = const [],
    this.refreshing = false,
    this.parsing = const [],
    this.justFiled,
    this.justFiledConfidence,
    this.filedTick = 0,
  });
  final List<HomeRecord> records;
  final List<Reminder> reminders;
  final bool refreshing;

  /// Captures currently parsing in place (newest first).
  final List<ParsingTask> parsing;

  /// The most recently auto-filed record, for a one-shot "filed" toast;
  /// [filedTick] increments so listeners fire even for look-alike records.
  final HomeRecord? justFiled;
  final String? justFiledConfidence;
  final int filedTick;

  /// Reminders still waiting, soonest first.
  List<Reminder> get pending => [for (final r in reminders) if (!r.isDone) r];

  /// Completed reminders — the maintenance log, newest first.
  List<Reminder> get completed {
    final done = [for (final r in reminders) if (r.isDone) r];
    done.sort((a, b) => b.doneAt!.compareTo(a.doneAt!));
    return done;
  }

  int get activeWarranties => records
      .where((r) => r.warrantyUntil != null && r.warrantyUntil!.isAfter(DateTime.now()))
      .length;

  TimelineState copyWith({
    List<HomeRecord>? records,
    List<Reminder>? reminders,
    bool? refreshing,
    List<ParsingTask>? parsing,
    HomeRecord? justFiled,
    String? justFiledConfidence,
    int? filedTick,
  }) =>
      TimelineState(
        records: records ?? this.records,
        reminders: reminders ?? this.reminders,
        refreshing: refreshing ?? this.refreshing,
        parsing: parsing ?? this.parsing,
        justFiled: justFiled ?? this.justFiled,
        justFiledConfidence: justFiledConfidence ?? this.justFiledConfidence,
        filedTick: filedTick ?? this.filedTick,
      );
}

/// The house timeline: records + pending reminders, kept in sync with the
/// backend and mirrored into local notifications.
class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit(this._backend) : super(const TimelineState());

  final Backend _backend;

  int _taskSeq = 0;

  void _emitSynced(List<HomeRecord> records, List<Reminder> reminders,
      {bool refreshing = false,
      List<ParsingTask>? parsing,
      HomeRecord? justFiled,
      String? justFiledConfidence}) {
    final sorted = [...reminders]..sort((a, b) => a.due.compareTo(b.due));
    final next = TimelineState(
      records: records,
      reminders: sorted,
      refreshing: refreshing,
      parsing: parsing ?? state.parsing,
      justFiled: justFiled ?? state.justFiled,
      justFiledConfidence: justFiled != null ? justFiledConfidence : state.justFiledConfidence,
      filedTick: justFiled != null ? state.filedTick + 1 : state.filedTick,
    );
    emit(next);
    NotificationService.sync(next.pending);
  }

  /// The whole add-flow, in place: a card appears on the home screen at once,
  /// parses, then becomes the saved record (reminders + notifications follow).
  /// Failures stay on the card with retry/discard — the capture is never lost.
  Future<void> captureAndFile(CaptureMode mode,
      {String? noteText,
      Uint8List? imageBytes,
      String? homeId,
      required String returnReminderTitle}) async {
    final task = ParsingTask(id: _taskSeq++, mode: mode, noteText: noteText, imageBytes: imageBytes);
    emit(state.copyWith(parsing: [task, ...state.parsing]));
    try {
      var result = await _backend.parseEntry(mode, noteText: noteText, imageBytes: imageBytes);
      result = ensureReturnReminder(result, returnReminderTitle);
      final saved = await _backend.saveRecord(homeId ?? 'demo-home', result, photoBytes: imageBytes);
      final remaining = state.parsing.where((t) => t.id != task.id).toList();
      if (BackendConfig.enabled && homeId != null) {
        final (records, reminders) = await _backend.fetchAll(homeId); // rows with ids
        _emitSynced(records, reminders,
            parsing: remaining, justFiled: saved, justFiledConfidence: result.confidence);
      } else {
        _emitSynced([saved, ...state.records], [...state.reminders, ...result.reminders],
            parsing: remaining, justFiled: saved, justFiledConfidence: result.confidence);
      }
    } catch (e) {
      emit(state.copyWith(parsing: [
        for (final t in state.parsing) t.id == task.id ? t.failed('$e') : t,
      ]));
    }
  }

  /// Re-run a failed capture with the same photo/note.
  Future<void> retryParse(ParsingTask task,
      {String? homeId, required String returnReminderTitle}) {
    emit(state.copyWith(parsing: state.parsing.where((t) => t.id != task.id).toList()));
    return captureAndFile(task.mode,
        noteText: task.noteText,
        imageBytes: task.imageBytes,
        homeId: homeId,
        returnReminderTitle: returnReminderTitle);
  }

  void discardParse(ParsingTask task) {
    emit(state.copyWith(parsing: state.parsing.where((t) => t.id != task.id).toList()));
  }

  Future<void> load(String homeId) async {
    emit(state.copyWith(refreshing: true));
    final (records, reminders) = await _backend.fetchAll(homeId);
    _emitSynced(records, reminders);
  }

  /// Account deletion: drop everything and cancel scheduled notifications.
  void reset() => _emitSynced(const [], const [], parsing: const []);

  /// Optimistic insert after a successful save.
  void addParsed(ParseResult result) {
    _emitSynced([result.record, ...state.records], [...state.reminders, ...result.reminders]);
  }

  /// Deletes on the backend, then resyncs (live) or drops locally (demo).
  Future<void> delete(HomeRecord record, {String? homeId}) async {
    await _backend.deleteRecord(record);
    if (BackendConfig.enabled && homeId != null) {
      await load(homeId); // reminders cascade server-side; resync everything
    } else {
      _emitSynced(
        state.records.where((r) => !identical(r, record)).toList(),
        state.reminders,
      );
    }
  }

  Future<void> updateRecord(HomeRecord original, HomeRecord updated,
      {String? homeId, String? returnReminderTitle}) async {
    await _backend.updateRecord(updated);
    // A return date set after save still earns its reminder (same coverage
    // rules as the parse-time safety net).
    Reminder? extra;
    if (returnReminderTitle != null) {
      // Only THIS record's reminders count as coverage — another item's
      // return window landing on a nearby date must not suppress ours.
      final own = [
        for (final r in state.reminders)
          if ((updated.id != null && r.recordId == updated.id) ||
              (r.title == returnReminderTitle && r.detail == updated.title))
            r,
      ];
      extra = returnReminderFor(updated, own, returnReminderTitle);
    }
    if (BackendConfig.enabled && homeId != null) {
      if (extra != null) {
        await _backend.addReminder(homeId, extra, recordId: updated.id);
      }
      await load(homeId); // picks up the new reminder and reschedules
    } else {
      _emitSynced(
        [for (final r in state.records) identical(r, original) ? updated : r],
        [...state.reminders, ?extra],
      );
    }
  }

  Future<void> completeReminder(Reminder reminder, {String? homeId}) async {
    if (BackendConfig.enabled && reminder.id != null) {
      await _backend.completeReminder(reminder.id!);
      if (homeId != null) await load(homeId);
    } else {
      _emitSynced(state.records, [
        for (final r in state.reminders)
          identical(r, reminder) ? reminder.copyWith(doneAt: DateTime.now()) : r,
      ]);
    }
  }

  Future<void> snoozeReminder(Reminder reminder, {String? homeId}) async {
    final newDue = reminder.due.add(const Duration(days: 7));
    if (BackendConfig.enabled && reminder.id != null) {
      await _backend.snoozeReminder(reminder.id!, newDue);
      if (homeId != null) await load(homeId);
    } else {
      _emitSynced(state.records, [
        for (final r in state.reminders)
          identical(r, reminder) ? reminder.copyWith(due: newDue) : r,
      ]);
    }
  }

  /// Demo-mode canned data, shaped by the onboarding profile.
  void seedDemo(HomeProfile? profile) {
    if (state.records.isNotEmpty) return;
    final now = DateTime.now();
    final records = [
      HomeRecord(
        kind: RecordKind.service,
        title: 'Water heater replaced',
        subtitle: 'Rheem 50 gal · installed by Joe\'s Plumbing',
        room: 'Basement',
        cost: 1850,
        vendor: "Joe's Plumbing",
        warrantyUntil: DateTime(now.year + 6, now.month, now.day),
        rawInput: '"water heater replaced today, Rheem 50 gal, \$1,850, Joe\'s Plumbing"',
        addedOn: now.subtract(const Duration(days: 12)),
      ),
      HomeRecord(
        kind: RecordKind.appliance,
        title: 'Dishwasher — Bosch 300 Series',
        subtitle: 'SHEM63W55N · from Home Depot receipt',
        room: 'Kitchen',
        cost: 1249,
        vendor: 'Home Depot',
        modelSerial: 'S/N 9502 1104 552',
        warrantyUntil: now.add(const Duration(days: 353)),
        returnBy: now.add(const Duration(days: 28)),
        manualFound: true,
        rawInput: '📸 photo of Home Depot receipt',
        addedOn: now.subtract(const Duration(days: 2)),
      ),
    ];
    final reminders = [
      Reminder(
        title: 'Furnace filter due',
        detail: 'Lennox ML296V · every 3 months',
        due: now.add(const Duration(days: 9)),
        seasonal: true,
      ),
      Reminder(
        title: 'Dishwasher return window',
        detail: 'Bosch 300 · Home Depot, keep the receipt',
        due: now.add(const Duration(days: 28)),
      ),
      Reminder(
        title: 'Clean gutters before freeze-up',
        detail: 'Seasonal · Montréal winter prep',
        due: now.add(const Duration(days: 41)),
        seasonal: true,
      ),
      if (profile?.garage ?? false)
        Reminder(
          title: 'Lubricate garage door springs',
          detail: 'Added because your place has a garage',
          due: now.add(const Duration(days: 21)),
          seasonal: true,
        ),
    ];
    _emitSynced(records, reminders);
  }
}
