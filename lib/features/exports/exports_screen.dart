import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../timeline/timeline_cubit.dart';

class ExportsScreen extends StatelessWidget {
  const ExportsScreen({super.key});

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
            cta: context.l10n.claimPackCta,
            onTap: () => _fakeGenerate(context, context.l10n.claimPackTitle),
          ),
          _ExportCard(
            emoji: '🏠',
            title: context.l10n.inventoryTitle,
            body: context.l10n.inventoryBody,
            cta: context.l10n.inventoryCta(state.records.length),
            onTap: () => _fakeGenerate(context, context.l10n.inventoryTitle),
          ),
          _ExportCard(
            emoji: '🔑',
            title: context.l10n.historyTitle,
            body: context.l10n.historyBody,
            cta: context.l10n.historyCta,
            onTap: () => _fakeGenerate(context, context.l10n.historyTitle),
          ),
        ],
      ),
    );
  }

  void _fakeGenerate(BuildContext context, String what) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.mc.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('📄  PDF ready', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(
          context.l10n.pdfBody(what),
          style: TextStyle(fontSize: 14.5, height: 1.5, color: context.mc.inkSoft),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.niceButton),
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({required this.emoji, required this.title, required this.body, required this.cta, required this.onTap});
  final String emoji;
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

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
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800))),
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
