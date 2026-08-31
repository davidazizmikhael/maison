import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({super.key, required this.record});
  final HomeRecord record;

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
      appBar: AppBar(title: Text(record.room)),
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
          if (warrantyDaysLeft != null) ...[
            const SizedBox(height: 16),
            Container(
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
                    const Text('🛡️ Warranty', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Tag('$warrantyDaysLeft DAYS LEFT',
                        color: MaisonColors.greenWash, textColor: MaisonColors.green),
                  ]),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: warrantyFraction,
                      minHeight: 9,
                      backgroundColor: MaisonColors.paper,
                      color: MaisonColors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Covered until ${w!.year}. If it breaks, Maison assembles the claim pack — receipt, serial, and terms — in one tap.',
                    style: const TextStyle(fontSize: 13, color: MaisonColors.inkSoft, height: 1.45),
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
                color: MaisonColors.accentWash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ORIGINAL INPUT',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: MaisonColors.accentDeep)),
                  const SizedBox(height: 6),
                  Text(record.rawInput!,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          color: MaisonColors.accentDeep,
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
                  color: MaisonColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: MaisonColors.line),
                ),
                child: ListTile(
                  leading: Text(item.$1, style: const TextStyle(fontSize: 22)),
                  title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  subtitle: Text(item.$3, style: const TextStyle(fontSize: 12.5, color: MaisonColors.inkSoft)),
                  trailing: const Icon(Icons.chevron_right, color: MaisonColors.inkSoft),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.$2} — wired to the backend in the real app'))),
                ),
              )),
        ],
      ),
    );
  }
}
