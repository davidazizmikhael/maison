import 'package:flutter/material.dart';
import '../models.dart';
import '../services/backend.dart';
import '../theme.dart';
import 'add_entry.dart';
import 'exports.dart';
import 'record_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MAISON',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                        color: MaisonColors.accentDeep)),
                Text(state.address, style: const TextStyle(fontSize: 17)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share, color: MaisonColors.navy),
                tooltip: 'Exports',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ExportsScreen())),
              ),
              const SizedBox(width: 4),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddSheet(context),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          body: RefreshIndicator(
            color: MaisonColors.accent,
            onRefresh: () async {
              final homeId = state.homeId;
              if (!BackendConfig.enabled || homeId == null) return;
              final (records, reminders) = await Backend.instance.fetchAll(homeId);
              state.hydrate(newRecords: records, newReminders: reminders);
            },
            child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _HealthCard(state: state),
              if (state.profile != null) ...[
                const SizedBox(height: 24),
                const _SectionTitle('YOUR PLACE'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...state.profile!.chips.map((c) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: MaisonColors.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: MaisonColors.line),
                          ),
                          child: Text(c,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        )),
                  ],
                ),
              ],
              if (state.reminders.isNotEmpty) ...[
                const SizedBox(height: 24),
                const _SectionTitle('UP NEXT'),
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
              const _SectionTitle('HOUSE TIMELINE'),
              const SizedBox(height: 6),
              if (state.records.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MaisonColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: MaisonColors.line),
                  ),
                  child: const Column(
                    children: [
                      Text('📸', style: TextStyle(fontSize: 34)),
                      SizedBox(height: 10),
                      Text('Your logbook is empty',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text(
                        'Walk the house and snap your first nameplate — the furnace is a great start.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: MaisonColors.inkSoft, height: 1.45),
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
        style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            color: MaisonColors.accentDeep));
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.state});
  final AppState state;

  Widget _stat(String value, String label) {
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
            const Text('Home health', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            const Spacer(),
            Tag('ON TRACK', color: MaisonColors.greenWash, textColor: MaisonColors.green),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _stat('${state.records.length}', 'items on record'),
            _stat('${state.activeWarranties}', 'active warranties'),
            _stat(
              next == null
                  ? '—'
                  : switch (next.daysLeft) {
                      <= 0 => 'today',
                      1 => 'tmrw',
                      final d => '${d}d',
                    },
              next != null && next.daysLeft < 0 ? 'task overdue' : 'until next task',
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
        color: MaisonColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaisonColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Tag(
              reminder.dueLabel,
              color: urgent ? MaisonColors.accentWash : MaisonColors.navyWash,
              textColor: urgent ? MaisonColors.accentDeep : MaisonColors.navy,
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
              style: const TextStyle(fontSize: 12, color: MaisonColors.inkSoft, height: 1.35)),
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
        color: MaisonColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaisonColors.line),
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
            color: MaisonColors.paper,
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
                    color: MaisonColors.greenWash, textColor: MaisonColors.green),
              if (record.warrantyUntil != null)
                Tag('Warranty → ${record.warrantyUntil!.year}',
                    color: MaisonColors.accentWash, textColor: MaisonColors.accentDeep),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: MaisonColors.inkSoft),
      ),
    );
  }
}
