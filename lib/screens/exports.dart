import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

class ExportsScreen extends StatelessWidget {
  const ExportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Exports')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'The documents that make the subscription worth it — generated from your timeline in one tap.',
            style: TextStyle(fontSize: 14.5, color: MaisonColors.inkSoft, height: 1.5),
          ),
          const SizedBox(height: 18),
          _ExportCard(
            emoji: '🛡️',
            title: 'Warranty claim pack',
            body:
                'Receipt, serial number, purchase date and warranty terms for any item — formatted the way the manufacturer asks for it.',
            cta: 'Generate for an item',
            onTap: () => _fakeGenerate(context, 'Warranty claim pack'),
          ),
          _ExportCard(
            emoji: '🏠',
            title: 'Insurance contents inventory',
            body:
                'Every item on record with photos, values and receipts — the document every fire or flood victim wishes they had.',
            cta: 'Generate inventory (${state.records.length} items)',
            onTap: () => _fakeGenerate(context, 'Insurance inventory'),
          ),
          _ExportCard(
            emoji: '🔑',
            title: 'House history report',
            body:
                'The full maintenance and upgrade story of your home — a trust-builder that adds real value when you sell.',
            cta: 'Generate house history',
            onTap: () => _fakeGenerate(context, 'House history report'),
          ),
        ],
      ),
    );
  }

  void _fakeGenerate(BuildContext context, String what) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: MaisonColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('📄  PDF ready', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(
          '$what generated from your timeline.\n\nIn the real app this opens the iOS share sheet — email it to your insurer, agent, or the manufacturer.',
          style: const TextStyle(fontSize: 14.5, height: 1.5, color: MaisonColors.inkSoft),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Nice'),
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
        color: MaisonColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MaisonColors.line),
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
          Text(body, style: const TextStyle(fontSize: 13.5, color: MaisonColors.inkSoft, height: 1.5)),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: MaisonColors.accentDeep,
              side: const BorderSide(color: MaisonColors.accent),
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
