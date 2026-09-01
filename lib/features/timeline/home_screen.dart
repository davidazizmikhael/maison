import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../../data/models.dart';
import '../add_entry/add_entry_screens.dart';
import '../exports/exports_screen.dart';
import '../session/account_sheet.dart';
import '../session/language_sheet.dart';
import '../session/session_cubit.dart';
import 'record_detail_screen.dart';
import 'timeline_cubit.dart';

/// The house journal: a Notes-style document — header, checklist, dated
/// entries, and a compose bar. No cards, hairlines only.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _profileSummary(BuildContext context, HomeProfile p) {
    // The chips carry emoji for chip UI; the document header wants plain text.
    return localizedChips(context.l10n, p)
        .map((c) => c.replaceFirst(RegExp(r'^\S+\s'), ''))
        .join(' · ');
  }

  String _dueShort(BuildContext context, Reminder r) {
    final d = r.daysLeft;
    if (d <= 0) return context.l10n.statToday;
    if (d == 1) return context.l10n.statTomorrow;
    return context.l10n.statDays(d);
  }

  String _dateHeader(BuildContext context, DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return context.l10n.todayHeader;
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}${d.year == now.year ? '' : ', ${d.year}'}';
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final address = session is SessionReady ? session.address : '';
    final profile = session is SessionReady ? session.profile : null;
    final homeId = session is SessionReady ? session.homeId : null;
    return BlocBuilder<TimelineCubit, TimelineState>(
      builder: (context, state) {
        // Group records by calendar day, newest first (list is already sorted).
        final groups = <String, List<HomeRecord>>{};
        for (final r in state.records) {
          groups.putIfAbsent(_dateHeader(context, r.addedOn), () => []).add(r);
        }
        final completedPreview = state.completed.take(3).toList();
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 44,
            actions: [
              if (BackendConfig.enabled)
                IconButton(
                  icon: Icon(Icons.person_outline, size: 22, color: context.mc.inkSoft),
                  tooltip: context.l10n.accountTitle,
                  onPressed: () => showAccountSheet(context),
                ),
              IconButton(
                icon: Icon(Icons.language, size: 22, color: context.mc.inkSoft),
                tooltip: context.l10n.languageTitle,
                onPressed: () => showLanguageSheet(context),
              ),
              IconButton(
                icon: Icon(Icons.ios_share, size: 22, color: context.mc.inkSoft),
                tooltip: context.l10n.exportsTooltip,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ExportsScreen())),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: context.mc.accent,
                  onRefresh: () async {
                    if (homeId == null) return;
                    await context.read<TimelineCubit>().load(homeId);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    children: [
                      Text('MAISON',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: context.mc.accentDeep)),
                      const SizedBox(height: 4),
                      Text(address,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                      if (profile != null) ...[
                        const SizedBox(height: 4),
                        Text(_profileSummary(context, profile),
                            style: TextStyle(fontSize: 13, color: context.mc.inkSoft)),
                      ],
                      if (state.pending.isNotEmpty || completedPreview.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _SectionLabel(context.l10n.sectionUpNext),
                        const SizedBox(height: 2),
                        for (final r in state.pending)
                          _ReminderRow(
                            reminder: r,
                            due: _dueShort(context, r),
                            urgent: r.daysLeft <= 14,
                            onTap: () => showReminderActions(context, r, homeId),
                          ),
                        for (final r in completedPreview) _DoneRow(reminder: r),
                      ],
                      const SizedBox(height: 18),
                      Container(height: 1, color: context.mc.line),
                      const SizedBox(height: 6),
                      if (state.records.isEmpty) ...[
                        const SizedBox(height: 18),
                        Text(context.l10n.emptyTitle,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(context.l10n.emptyBody,
                            style: TextStyle(
                                fontSize: 13, color: context.mc.inkSoft, height: 1.45)),
                      ] else
                        for (final entry in groups.entries) ...[
                          const SizedBox(height: 16),
                          _SectionLabel(entry.key),
                          const SizedBox(height: 4),
                          for (final r in entry.value) _RecordRow(record: r),
                        ],
                    ],
                  ),
                ),
              ),
              _ComposeBar(),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.mc.inkSoft));
  }
}

void showReminderActions(BuildContext context, Reminder reminder, String? homeId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.mc.paper,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(reminder.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          ListTile(
            leading: Icon(Icons.check_circle_outline, color: sheetContext.mc.green),
            title: Text(sheetContext.l10n.markDone,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await context.read<TimelineCubit>().completeReminder(reminder, homeId: homeId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.l10n.reminderDoneSnack),
                    duration: const Duration(seconds: 2)));
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.snooze_outlined, color: sheetContext.mc.navy),
            title: Text(sheetContext.l10n.snoozeWeek,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final newDue = reminder.due.add(const Duration(days: 7));
              await context.read<TimelineCubit>().snoozeReminder(reminder, homeId: homeId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.l10n.reminderSnoozedSnack(
                        '${newDue.year}-${newDue.month.toString().padLeft(2, '0')}-${newDue.day.toString().padLeft(2, '0')}')),
                    duration: const Duration(seconds: 2)));
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow(
      {required this.reminder, required this.due, required this.urgent, required this.onTap});
  final Reminder reminder;
  final String due;
  final bool urgent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Row(children: [
          Icon(Icons.circle_outlined,
              size: 17, color: urgent ? context.mc.accent : context.mc.line),
          const SizedBox(width: 10),
          Expanded(
            child: Text(reminder.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15)),
          ),
          Text(due,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: urgent ? FontWeight.w600 : FontWeight.w400,
                  color: urgent ? context.mc.accentDeep : context.mc.inkSoft)),
        ]),
      ),
    );
  }
}

class _DoneRow extends StatelessWidget {
  const _DoneRow({required this.reminder});
  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(children: [
        Icon(Icons.check, size: 17, color: context.mc.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(reminder.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  color: context.mc.inkSoft,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: context.mc.inkSoft)),
        ),
        Text(context.l10n.doneShort,
            style: TextStyle(fontSize: 13, color: context.mc.inkSoft)),
      ]),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});
  final HomeRecord record;

  String _meta(BuildContext context) {
    return [
      record.room,
      if (record.cost != null)
        '\$${record.cost!.toStringAsFixed(record.cost! % 1 == 0 ? 0 : 2)}',
      if (record.vendor != null) record.vendor!,
      if (record.warrantyUntil != null)
        '${context.l10n.labelWarranty.toLowerCase()} ${record.warrantyUntil!.year}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(record.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(_meta(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: context.mc.inkSoft)),
            ]),
          ),
          if (record.photoPath != null) ...[
            const SizedBox(width: 12),
            FutureBuilder<String?>(
              future: Backend.instance.photoUrl(record.photoPath!),
              builder: (context, snapshot) {
                final url = snapshot.data;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: url == null
                        ? Container(color: context.mc.line)
                        : Image.network(url, fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                Container(color: context.mc.line)),
                  ),
                );
              },
            ),
          ],
        ]),
      ),
    );
  }
}

/// Notes-style compose bar: tap anywhere to write; the camera goes straight
/// to scanning.
class _ComposeBar extends StatelessWidget {
  void _openEntry(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuickNoteScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.mc.paper,
        border: Border(top: BorderSide(color: context.mc.line)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
      child: SafeArea(
        top: false,
        child: Row(children: [
          GestureDetector(
            key: const Key('compose-camera'),
            onTap: () => showCaptureSheet(context, CaptureMode.nameplate),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child:
                  Icon(Icons.photo_camera_outlined, size: 24, color: context.mc.accentDeep),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              key: const Key('compose-field'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _openEntry(context),
              child: SizedBox(
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(context.l10n.composeHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, color: context.mc.inkSoft)),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _openEntry(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: context.mc.accent),
              child: const Icon(Icons.add, size: 22, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}
