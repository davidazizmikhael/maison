import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../../data/models.dart';
import '../session/session_cubit.dart';
import '../timeline/timeline_cubit.dart';
import 'export_actions.dart';
import 'pdf_builder.dart';

class ExportsScreen extends StatefulWidget {
  const ExportsScreen({super.key});

  @override
  State<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends State<ExportsScreen> {
  String? _busy; // which card is generating

  String get _address {
    final session = context.read<SessionCubit>().state;
    return session is SessionReady ? session.address : '';
  }

  List<HomeRecord> get _records => context.read<TimelineCubit>().state.records;

  bool _guardEmpty() {
    if (_records.isNotEmpty) return false;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.noItemsSnack)));
    return true;
  }

  Future<void> _generate(String key, Future<Uint8List> Function() build,
      {required String what, required String filename}) async {
    setState(() => _busy = key);
    try {
      final bytes = await build();
      if (!mounted) return;
      await showPdfReadyDialog(context, what: what, bytes: bytes, filename: filename);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.saveError('$e'))));
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _claimPack() async {
    if (_guardEmpty()) return;
    final record = await showModalBottomSheet<HomeRecord>(
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
              child: Text(sheetContext.l10n.pickItemTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final r in _records)
                    ListTile(
                      leading: Text(r.emoji, style: const TextStyle(fontSize: 22)),
                      title: Text(r.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      subtitle: r.warrantyUntil != null
                          ? Text(
                              sheetContext.l10n
                                  .warrantyUntil('${r.warrantyUntil!.year}'),
                              style: TextStyle(
                                  fontSize: 12, color: sheetContext.mc.inkSoft))
                          : null,
                      onTap: () => Navigator.of(sheetContext).pop(r),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (record == null || !mounted) return;
    final l10n = context.l10n;
    final address = _address;
    await _generate('claim', () async {
      Uint8List? photo;
      if (record.photoPath != null) {
        photo = await Backend.instance.photoBytes(record.photoPath!);
      }
      return buildClaimPack(l10n: l10n, address: address, record: record, photo: photo);
    }, what: l10n.claimPackTitle, filename: 'maison-warranty-claim.pdf');
  }

  Future<void> _inventory() async {
    if (_guardEmpty()) return;
    final l10n = context.l10n;
    final address = _address;
    final records = _records;
    await _generate('inventory', () async {
      final photos = <HomeRecord, Uint8List>{};
      for (final r in records) {
        if (r.photoPath == null) continue;
        final bytes = await Backend.instance.photoBytes(r.photoPath!);
        if (bytes != null) photos[r] = bytes;
      }
      return buildInventory(l10n: l10n, address: address, records: records, photos: photos);
    }, what: l10n.inventoryTitle, filename: 'maison-insurance-inventory.pdf');
  }

  Future<void> _history() async {
    if (_guardEmpty()) return;
    final l10n = context.l10n;
    final address = _address;
    final records = _records;
    final completed = context.read<TimelineCubit>().state.completed;
    await _generate('history', () async {
      return buildHouseHistory(
          l10n: l10n, address: address, records: records, completed: completed);
    }, what: l10n.historyTitle, filename: 'maison-house-history.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimelineCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.exportsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.exportsIntro,
            style: TextStyle(fontSize: 14.5, color: context.mc.inkSoft, height: 1.5),
          ),
          const SizedBox(height: 18),
          _ExportCard(
            emoji: '🛡️',
            title: context.l10n.claimPackTitle,
            body: context.l10n.claimPackBody,
            cta: _busy == 'claim' ? context.l10n.generatingLabel : context.l10n.claimPackCta,
            onTap: _busy == null ? _claimPack : null,
          ),
          _ExportCard(
            emoji: '🏠',
            title: context.l10n.inventoryTitle,
            body: context.l10n.inventoryBody,
            cta: _busy == 'inventory'
                ? context.l10n.generatingLabel
                : context.l10n.inventoryCta(state.records.length),
            onTap: _busy == null ? _inventory : null,
          ),
          _ExportCard(
            emoji: '🔑',
            title: context.l10n.historyTitle,
            body: context.l10n.historyBody,
            cta: _busy == 'history' ? context.l10n.generatingLabel : context.l10n.historyCta,
            onTap: _busy == null ? _history : null,
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard(
      {required this.emoji,
      required this.title,
      required this.body,
      required this.cta,
      required this.onTap});
  final String emoji;
  final String title;
  final String body;
  final String cta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(fontSize: 13.5, color: context.mc.inkSoft, height: 1.5)),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.mc.accentDeep,
              side: BorderSide(color: context.mc.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onTap,
            child: Text(cta, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
