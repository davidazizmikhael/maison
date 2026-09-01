import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/photo_viewer.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../../core/l10n_ext.dart';
import '../../data/models.dart';
import '../session/session_cubit.dart';
import 'edit_record_screen.dart';
import 'timeline_cubit.dart';

class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({super.key, required this.record});
  final HomeRecord record;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.mc.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(dialogContext.l10n.deleteConfirmTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(dialogContext.l10n.deleteConfirmBody,
            style: TextStyle(fontSize: 14.5, height: 1.5, color: dialogContext.mc.inkSoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.cancelButton,
                style: TextStyle(color: dialogContext.mc.inkSoft, fontWeight: FontWeight.w700)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: dialogContext.mc.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final session = context.read<SessionCubit>().state;
    final homeId = session is SessionReady ? session.homeId : null;
    await context.read<TimelineCubit>().delete(record, homeId: homeId);
    if (!context.mounted) return;
    final snack = context.l10n.deletedSnack;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(snack), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final w = record.warrantyUntil;
    final now = DateTime.now();
    double? warrantyFraction;
    int? warrantyDaysLeft;
    if (w != null && w.isAfter(now)) {
      warrantyDaysLeft = w.difference(now).inDays;
      // Assume a warranty horizon of up to 6 years for the progress bar.
      final total = w.difference(record.addedOn).inDays.clamp(1, 3650);
      warrantyFraction = 1 - (warrantyDaysLeft / total).clamp(0.0, 1.0);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(record.room),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: context.mc.navy),
            tooltip: context.l10n.editRecord,
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditRecordScreen(record: record))),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.mc.red),
            tooltip: context.l10n.deleteRecord,
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
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
                Text(record.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 10),
                Text(record.title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(record.subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14.5)),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  Tag(record.room, color: Colors.white24, textColor: Colors.white),
                  if (record.cost != null)
                    Tag('\$${record.cost!.toStringAsFixed(2)}', color: Colors.white24, textColor: Colors.white),
                  if (record.vendor != null)
                    Tag(record.vendor!, color: Colors.white24, textColor: Colors.white),
                ]),
              ],
            ),
          ),
          if (record.photoPath != null) ...[
            const SizedBox(height: 16),
            _RecordPhoto(photoPath: record.photoPath!),
          ],
          if (warrantyDaysLeft != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.mc.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.mc.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('🛡️ Warranty', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Tag('$warrantyDaysLeft DAYS LEFT',
                        color: context.mc.greenWash, textColor: context.mc.green),
                  ]),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: warrantyFraction,
                      minHeight: 9,
                      backgroundColor: context.mc.paper,
                      color: context.mc.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Covered until ${w!.year}. If it breaks, Maison assembles the claim pack — receipt, serial, and terms — in one tap.',
                    style: TextStyle(fontSize: 13, color: context.mc.inkSoft, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
          if (record.rawInput != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.mc.accentWash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ORIGINAL INPUT',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: context.mc.accentDeep)),
                  const SizedBox(height: 6),
                  Text(record.rawInput!,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          color: context.mc.accentDeep,
                          height: 1.4)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...[
            ('📖', 'View manual', record.manualFound ? 'PDF attached' : 'Not found yet'),
            ('🔔', 'Reminders', 'Manage the schedule for this item'),
            ('📄', 'Export claim pack', 'Receipt + serial + warranty terms as PDF'),
          ].map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: context.mc.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.mc.line),
                ),
                child: ListTile(
                  leading: Text(item.$1, style: const TextStyle(fontSize: 22)),
                  title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  subtitle: Text(item.$3, style: TextStyle(fontSize: 12.5, color: context.mc.inkSoft)),
                  trailing: Icon(Icons.chevron_right, color: context.mc.inkSoft),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.$2} — wired to the backend in the real app'))),
                ),
              )),
        ],
      ),
    );
  }
}


/// The captured photo, loaded via a short-lived signed URL from the private
/// bucket. Tapping opens the full-screen pinch-zoom viewer.
class _RecordPhoto extends StatefulWidget {
  const _RecordPhoto({required this.photoPath});
  final String photoPath;

  @override
  State<_RecordPhoto> createState() => _RecordPhotoState();
}

class _RecordPhotoState extends State<_RecordPhoto> {
  late final Future<String?> _url = Backend.instance.photoUrl(widget.photoPath);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _url,
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => openPhotoViewer(context, url: url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: context.mc.card,
              height: 190,
              width: double.infinity,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: context.mc.accent),
                        ),
                      ),
                errorBuilder: (context, error, stack) =>
                    Icon(Icons.broken_image_outlined, color: context.mc.inkSoft),
              ),
            ),
          ),
        );
      },
    );
  }
}
