import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n_ext.dart';
import '../../core/motion.dart';
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

/// The lively home: greeting, an animated house-health ring, floating
/// "up next" cards, a horizontal rail of recent records, and a centered
/// camera button. (The "Springy Cards" direction, remixed.)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _dueShort(BuildContext context, Reminder r) {
    final d = r.daysLeft;
    if (d <= 0) return context.l10n.statToday;
    if (d == 1) return context.l10n.statTomorrow;
    return context.l10n.statDays(d);
  }

  /// Honest-but-simple score: every pending reminder costs points, overdue
  /// ones cost the most. Floors at 35 so the ring never looks broken.
  int _healthScore(List<Reminder> pending) {
    var s = 100;
    for (final r in pending) {
      final d = r.daysLeft;
      s -= d <= 0 ? 18 : (d <= 14 ? 10 : 4);
    }
    return s.clamp(35, 100);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final address = session is SessionReady ? session.address : '';
    final homeId = session is SessionReady ? session.homeId : null;
    return BlocBuilder<TimelineCubit, TimelineState>(
      builder: (context, state) {
        final completedPreview = state.completed.take(3).toList();
        final score = _healthScore(state.pending);
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
          body: RefreshIndicator(
            color: context.mc.accent,
            onRefresh: () async {
              if (homeId == null) return;
              await context.read<TimelineCubit>().load(homeId);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(context.l10n.homeGreeting,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 13, color: context.mc.inkSoft)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _HealthHero(score: score, pendingCount: state.pending.length),
                if (state.pending.isNotEmpty || completedPreview.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _SectionLabel(context.l10n.sectionUpNext),
                  const SizedBox(height: 10),
                  for (var i = 0; i < state.pending.length; i++) ...[
                    FloatingCard(
                      duration: Duration(milliseconds: 3800 + i * 500),
                      phase: i * 0.3,
                      child: _ReminderCard(
                        reminder: state.pending[i],
                        due: _dueShort(context, state.pending[i]),
                        urgent: state.pending[i].daysLeft <= 14,
                        onTap: () => showReminderActions(context, state.pending[i], homeId),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  for (final r in completedPreview) _DoneRow(reminder: r),
                ],
                const SizedBox(height: 22),
                _SectionLabel(context.l10n.sectionRecent),
                const SizedBox(height: 12),
                if (state.records.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(context.l10n.emptyTitle,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(context.l10n.emptyBody,
                          style:
                              TextStyle(fontSize: 13, color: context.mc.inkSoft, height: 1.45)),
                    ]),
                  ),
                ] else
                  SizedBox(
                    height: 168,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: state.records.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => FloatingCard(
                        duration: Duration(milliseconds: 4200 + (i % 3) * 500),
                        phase: i * 0.35,
                        child: _RecordCard(record: state.records[i]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _CameraButton(
            key: const Key('compose-field'),
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuickNoteScreen())),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: context.mc.inkSoft)),
    );
  }
}

/// Dark hero card with a ring that draws itself to the health score.
/// Permanently-dark brand surface, same in both themes.
class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.score, required this.pendingCount});
  final int score;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = score >= 85
        ? l10n.healthGreat
        : score >= 60
            ? l10n.healthGood
            : l10n.healthAttention;
    final body = pendingCount == 0 ? l10n.healthClear : l10n.healthBody(pendingCount);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MaisonColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score / 100),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => CustomPaint(
            size: const Size(72, 72),
            painter: _RingPainter(fraction: value, accent: context.mc.accent),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Center(
                child: Text('${(value * 100).round()}',
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text(body,
                style: const TextStyle(fontSize: 13, color: Color(0xFFA8B0BD), height: 1.4)),
          ]),
        ),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.accent});
  final double fraction;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFF2E3644);
    canvas.drawCircle(center, radius, track);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = accent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2,
        2 * math.pi * fraction, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction || old.accent != accent;
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

class _ReminderCard extends StatelessWidget {
  const _ReminderCard(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: urgent ? context.mc.accentWash : context.mc.card,
          borderRadius: BorderRadius.circular(18),
          border: urgent ? null : Border.all(color: context.mc.line),
        ),
        child: Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: urgent ? context.mc.accent : context.mc.line, width: 2),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(reminder.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(due,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: urgent ? FontWeight.w600 : FontWeight.w400,
                      color: urgent ? context.mc.accentDeep : context.mc.inkSoft)),
            ]),
          ),
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
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          Icon(Icons.check, size: 17, color: context.mc.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(reminder.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14.5,
                    color: context.mc.inkSoft,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: context.mc.inkSoft)),
          ),
          Text(context.l10n.doneShort,
              style: TextStyle(fontSize: 13, color: context.mc.inkSoft)),
        ]),
      ),
    );
  }
}

/// One card in the "recently filed" rail: photo (or tinted placeholder) on
/// top, title and meta beneath.
class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});
  final HomeRecord record;

  String _meta(BuildContext context) {
    return [
      record.room,
      if (record.cost != null)
        '\$${record.cost!.toStringAsFixed(record.cost! % 1 == 0 ? 0 : 2)}',
      if (record.warrantyUntil != null)
        '${context.l10n.labelWarranty.toLowerCase()} ${record.warrantyUntil!.year}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record))),
      child: Container(
        width: 158,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.mc.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.mc.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 92,
            width: double.infinity,
            child: record.photoPath == null
                ? Container(
                    color: context.mc.navyWash,
                    child: Icon(Icons.inventory_2_outlined,
                        size: 30, color: context.mc.navy),
                  )
                : FutureBuilder<String?>(
                    future: Backend.instance.photoUrl(record.photoPath!),
                    builder: (context, snapshot) {
                      final url = snapshot.data;
                      return url == null
                          ? Container(color: context.mc.line)
                          : Image.network(url, fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(color: context.mc.line));
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(record.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(_meta(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: context.mc.inkSoft)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Centered camera button (the "Widget Board" placement): opens the New
/// entry screen — type a note or jump to a scan from there.
class _CameraButton extends StatelessWidget {
  const _CameraButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.mc.accent,
          boxShadow: [
            BoxShadow(
                color: context.mc.accent.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8)),
          ],
        ),
        child: const Icon(Icons.photo_camera_outlined, size: 26, color: MaisonColors.ink),
      ),
    );
  }
}
