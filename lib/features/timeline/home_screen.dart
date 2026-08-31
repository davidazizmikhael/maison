import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
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
              if (state.reminders.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionTitle(context.l10n.sectionUpNext),
                const SizedBox(height: 10),
                SizedBox(
                  height: 118,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.reminders.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _ReminderCard(reminder: state.reminders[i]),
                  ),
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
    final next = state.reminders.isEmpty ? null : state.reminders.first;
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

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});
  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final urgent = reminder.daysLeft <= 14;
    return Container(
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
        leading: Container(
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
