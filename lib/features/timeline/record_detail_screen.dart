import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/photo_viewer.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../../core/l10n_ext.dart';
import '../../data/models.dart';
import '../session/session_cubit.dart';
import '../exports/export_actions.dart';
import 'edit_record_screen.dart';
import 'timeline_cubit.dart';

/// The warranty bar's model: time remaining measured against a fixed
/// three-year horizon, so different amounts of runway LOOK different —
/// 3+ years reads full, weeks read as a sliver. Null when expired or absent.
/// (The true purchase date is unknowable until the AI reads receipts, so a
/// span-based fraction would always be 100% on the day a record is created.)
class WarrantyProgress {
  const WarrantyProgress(
      {required this.daysLeft, required this.totalDays, required this.progress});

  /// Fixed reference horizon: the ceiling of typical consumer warranties.
  static const horizonDays = 1095; // 3 years

  final int daysLeft;
  final int totalDays;

  /// daysLeft / 3 years, clamped so even a nearly-expired warranty stays
  /// visible as a sliver.
  final double progress;
}

WarrantyProgress? calculateWarrantyProgress(HomeRecord record, {DateTime? now}) {
  final w = record.warrantyUntil;
  final n = now ?? DateTime.now();
  if (w == null || !w.isAfter(n)) return null;
  final daysLeft = w.difference(n).inDays;
  const totalDays = WarrantyProgress.horizonDays;
  final progress = (daysLeft / totalDays).clamp(0.02, 1.0).toDouble();
  return WarrantyProgress(daysLeft: daysLeft, totalDays: totalDays, progress: progress);
}

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

  Widget _contactRow(BuildContext context, IconData icon, String label, String value,
      {required Uri uri}) {
    return InkWell(
      onTap: () => launchUrl(uri),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(
              width: 82,
              child: Text(label, style: TextStyle(fontSize: 13, color: context.mc.inkSoft))),
          Icon(icon, size: 15, color: context.mc.accentDeep),
          const SizedBox(width: 7),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 15,
                    color: context.mc.accentDeep,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 82,
            child: Text(label, style: TextStyle(fontSize: 13, color: context.mc.inkSoft))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
      ]),
    );
  }

  Widget _actionRow(BuildContext context, String title,
      {String? trailingText, Color? color, VoidCallback? onTap, bool chevron = false}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Row(children: [
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: onTap != null ? FontWeight.w600 : FontWeight.w400,
                    color: color ?? context.mc.ink)),
          ),
          if (trailingText != null)
            Text(trailingText, style: TextStyle(fontSize: 12, color: context.mc.inkSoft)),
          if (chevron) Icon(Icons.chevron_right, size: 18, color: context.mc.accentDeep),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = record.warrantyUntil;
    final warranty = calculateWarrantyProgress(record);
    final warrantyFraction = warranty?.progress;
    final warrantyDaysLeft = warranty?.daysLeft;

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
          Text(record.title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.2)),
          const SizedBox(height: 4),
          Text(record.subtitle, style: TextStyle(fontSize: 13, color: context.mc.inkSoft)),
          _kv(context, context.l10n.labelRoom, record.room),
          if (record.cost != null)
            _kv(context, context.l10n.labelCost, '\$${record.cost!.toStringAsFixed(2)}'),
          if (record.vendor != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: 82,
                    child: Text(context.l10n.labelVendor,
                        style: TextStyle(fontSize: 13, color: context.mc.inkSoft))),
                if (record.vendorDomain != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      // Free, key-less favicon service — the store's icon.
                      'https://www.google.com/s2/favicons?domain=${record.vendorDomain}&sz=64',
                      width: 18,
                      height: 18,
                      errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 7),
                ],
                Expanded(child: Text(record.vendor!, style: const TextStyle(fontSize: 15))),
              ]),
            ),
          if (record.vendorPhone != null)
            _contactRow(context, Icons.phone_outlined, context.l10n.labelPhone,
                record.vendorPhone!,
                uri: Uri(scheme: 'tel', path: record.vendorPhone!.replaceAll(RegExp(r'[^0-9+]'), ''))),
          if (record.vendorEmail != null)
            _contactRow(context, Icons.mail_outline, context.l10n.labelEmail,
                record.vendorEmail!, uri: Uri(scheme: 'mailto', path: record.vendorEmail!)),
          if (record.modelSerial != null)
            _kv(context, context.l10n.labelSerial, record.modelSerial!),
          if (record.photoPath != null) ...[
            const SizedBox(height: 16),
            _RecordPhoto(photoPath: record.photoPath!),
          ],
          if (warrantyDaysLeft != null) ...[
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: Text(
                    '${context.l10n.labelWarranty} — ${context.l10n.warrantyUntil('${w!.year}')}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              Text(context.l10n.statDays(warrantyDaysLeft),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: warrantyDaysLeft < 30 ? FontWeight.w600 : FontWeight.w400,
                      color: warrantyDaysLeft < 30
                          ? context.mc.accentDeep
                          : context.mc.inkSoft)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: warrantyFraction,
                minHeight: 3,
                backgroundColor: context.mc.line,
                color: warrantyDaysLeft < 30 ? context.mc.accent : context.mc.accentDeep,
              ),
            ),
          ],
          if (record.rawInput != null) ...[
            const SizedBox(height: 20),
            Text(context.l10n.youGaveMe(record.rawInput!),
                style: TextStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: context.mc.inkSoft,
                    height: 1.45)),
          ],
          const SizedBox(height: 20),
          Container(height: 1, color: context.mc.line),
          const SizedBox(height: 6),
          _actionRow(context, context.l10n.claimPackTitle,
              color: context.mc.accentDeep,
              chevron: true,
              onTap: () => shareClaimPack(context, record)),
          _actionRow(context, 'View manual',
              trailingText: record.manualFound ? 'PDF' : context.l10n.comingSoon,
              color: context.mc.inkSoft,
              onTap: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)))),
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
