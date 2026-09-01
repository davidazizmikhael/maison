import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/backend.dart';
import '../../data/models.dart';
import '../../data/notifications.dart';

class TimelineState {
  const TimelineState({this.records = const [], this.reminders = const [], this.refreshing = false});
  final List<HomeRecord> records;
  final List<Reminder> reminders;
  final bool refreshing;

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

  TimelineState copyWith({List<HomeRecord>? records, List<Reminder>? reminders, bool? refreshing}) =>
      TimelineState(
        records: records ?? this.records,
        reminders: reminders ?? this.reminders,
        refreshing: refreshing ?? this.refreshing,
      );
}

/// The house timeline: records + pending reminders, kept in sync with the
/// backend and mirrored into local notifications.
class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit(this._backend) : super(const TimelineState());

  final Backend _backend;

  void _emitSynced(List<HomeRecord> records, List<Reminder> reminders, {bool refreshing = false}) {
    final sorted = [...reminders]..sort((a, b) => a.due.compareTo(b.due));
    final next = TimelineState(records: records, reminders: sorted, refreshing: refreshing);
    emit(next);
    NotificationService.sync(next.pending);
  }

  Future<void> load(String homeId) async {
    emit(state.copyWith(refreshing: true));
    final (records, reminders) = await _backend.fetchAll(homeId);
    _emitSynced(records, reminders);
  }

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

  Future<void> updateRecord(HomeRecord original, HomeRecord updated, {String? homeId}) async {
    await _backend.updateRecord(updated);
    if (BackendConfig.enabled && homeId != null) {
      await load(homeId);
    } else {
      _emitSynced(
        [for (final r in state.records) identical(r, original) ? updated : r],
        state.reminders,
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
