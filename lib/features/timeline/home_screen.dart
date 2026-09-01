import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../../data/models.dart';
import '../add_entry/add_entry_screens.dart';
import '../exports/exports_screen.dart';
import '../session/language_sheet.dart';
import '../session/session_cubit.dart';
import 'record_detail_screen.dart';
import 'timeline_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final address = session is SessionReady ? session.address : '';
    final profile = session is SessionReady ? session.profile : null;
    final homeId = session is SessionReady ? session.homeId : null;
    return BlocBuilder<TimelineCubit, TimelineState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MAISON',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                        color: context.mc.accentDeep)),
                Text(address, style: const TextStyle(fontSize: 17)),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.language, color: context.mc.navy),
                tooltip: context.l10n.languageTitle,
                onPressed: () => showLanguageSheet(context),
              ),
              IconButton(
                icon: Icon(Icons.ios_share, color: context.mc.navy),
                tooltip: context.l10n.exportsTooltip,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ExportsScreen())),
              ),
              const SizedBox(width: 4),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddSheet(context),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(context.l10n.addButton, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          body: RefreshIndicator(
            color: context.mc.accent,
            onRefresh: () async {
              if (homeId == null) return;
              await context.read<TimelineCubit>().load(homeId);
            },
            child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _HealthCard(state: state),
              if (profile != null) ...[
                const SizedBox(height: 24),
                _SectionTitle(context.l10n.sectionYourPlace),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...localizedChips(context.l10n, profile).map((c) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: context.mc.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: context.mc.line),
                          ),
                          child: Text(c,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        )),
                  ],
                ),
              ],
              if (state.pending.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionTitle(context.l10n.sectionUpNext),
                const SizedBox(height: 10),
                SizedBox(
                  height: 118,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.pending.length,
                    clipBehavior: Clip.none,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _ReminderCard(
                        reminder: state.pending[i],
                        onTap: () =>
                            _showReminderActions(context, state.pending[i], homeId)),
                  ),
                ),
              ],
              if (state.completed.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionTitle(context.l10n.sectionCompleted),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in state.completed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: context.mc.greenWash,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.check, size: 14, color: context.mc.green),
                          const SizedBox(width: 5),
                          Text(r.title,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: context.mc.green)),
                        ]),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              _SectionTitle(context.l10n.sectionTimeline),
              const SizedBox(height: 6),
              if (state.records.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.mc.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.mc.line),
                  ),
                  child: Column(
                    children: [
                      Text('📸', style: TextStyle(fontSize: 34)),
                      SizedBox(height: 10),
                      Text(context.l10n.emptyTitle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text(
                        context.l10n.emptyBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: context.mc.inkSoft, height: 1.45),
                      ),
                    ],
                  ),
                )
              else
                ...state.records.map((r) => _RecordTile(record: r)),
            ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            color: context.mc.accentDeep));
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.state});
  final TimelineState state;

  Widget _stat(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final next = state.pending.isEmpty ? null : state.pending.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [MaisonColors.ink, MaisonColors.navy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(context.l10n.homeHealth, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            const Spacer(),
            Tag(context.l10n.onTrack, color: context.mc.greenWash, textColor: context.mc.green),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _stat(context, '${state.records.length}', context.l10n.itemsOnRecord),
            _stat(context, '${state.activeWarranties}', context.l10n.activeWarranties),
            _stat(
              context,
              next == null
                  ? '—'
                  : switch (next.daysLeft) {
                      <= 0 => context.l10n.statToday,
                      1 => context.l10n.statTomorrow,
                      final d => context.l10n.statDays(d),
                    },
              next != null && next.daysLeft < 0
                  ? context.l10n.taskOverdue
                  : context.l10n.untilNextTask,
            ),
          ]),
        ],
      ),
    );
  }
}

void _showReminderActions(BuildContext context, Reminder reminder, String? homeId) {
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

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onTap});
  final Reminder reminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final urgent = reminder.daysLeft <= 14;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.mc.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.mc.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Tag(
              switch (reminder.daysLeft) {
                < -1 => context.l10n.overdueDays(-reminder.daysLeft),
                -1 => context.l10n.dueYesterday,
                0 => context.l10n.dueToday,
                1 => context.l10n.dueTomorrow,
                final d => context.l10n.inDays(d),
              },
              color: urgent ? context.mc.accentWash : context.mc.navyWash,
              textColor: urgent ? context.mc.accentDeep : context.mc.navy,
            ),
            if (reminder.seasonal) ...[
              const Spacer(),
              const Text('❄️', style: TextStyle(fontSize: 14)),
            ],
          ]),
          const Spacer(),
          Text(reminder.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(reminder.detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: context.mc.inkSoft, height: 1.35)),
        ],
      ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});
  final HomeRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: context.mc.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.mc.line),
      ),
      child: ListTile(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: record.photoPath != null
            ? FutureBuilder<String?>(
                future: Backend.instance.photoUrl(record.photoPath!),
                builder: (context, snapshot) {
                  final url = snapshot.data;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 46,
                      height: 46,
                      child: url == null
                          ? Container(color: context.mc.paper)
                          : Image.network(url, fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(color: context.mc.paper)),
                    ),
                  );
                },
              )
            : Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.mc.paper,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(record.emoji, style: const TextStyle(fontSize: 22)),
              ),
        title: Text(record.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Tag(record.room),
              if (record.cost != null)
                Tag('\$${record.cost!.toStringAsFixed(record.cost! % 1 == 0 ? 0 : 2)}',
                    color: context.mc.greenWash, textColor: context.mc.green),
              if (record.warrantyUntil != null)
                Tag('Warranty → ${record.warrantyUntil!.year}',
                    color: context.mc.accentWash, textColor: context.mc.accentDeep),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: context.mc.inkSoft),
      ),
    );
  }
}
