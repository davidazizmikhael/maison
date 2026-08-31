import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

/// Entry point: the "+ Add" bottom sheet with the three capture modes.
void showAddSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: MaisonColors.paper,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add to your logbook',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('No forms. Point, shoot, or just say it.',
                style: TextStyle(fontSize: 14, color: MaisonColors.inkSoft)),
            const SizedBox(height: 18),
            _AddOption(
              emoji: '📸',
              title: 'Scan a nameplate',
              subtitle: 'Furnace, water heater, A/C — AI finds the model & manual',
              onTap: () => _startCapture(sheetContext, context, CaptureMode.nameplate),
            ),
            _AddOption(
              emoji: '🧾',
              title: 'Scan a receipt or invoice',
              subtitle: 'Warranty and return window extracted automatically',
              onTap: () => _startCapture(sheetContext, context, CaptureMode.receipt),
            ),
            _AddOption(
              emoji: '⌨️',
              title: 'Quick note',
              subtitle: 'Type it like a text message — AI structures it',
              onTap: () => _startCapture(sheetContext, context, CaptureMode.note),
            ),
          ],
        ),
      ),
    ),
  );
}

void _startCapture(BuildContext sheetContext, BuildContext parentContext, CaptureMode mode) {
  Navigator.of(sheetContext).pop();
  Navigator.of(parentContext).push(MaterialPageRoute(
    builder: (_) => mode == CaptureMode.note
        ? QuickNoteScreen()
        : FakeCameraScreen(mode: mode),
  ));
}

class _AddOption extends StatelessWidget {
  const _AddOption({required this.emoji, required this.title, required this.subtitle, required this.onTap});
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: MaisonColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaisonColors.line),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Text(emoji, style: const TextStyle(fontSize: 26)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12.5, color: MaisonColors.inkSoft)),
        trailing: const Icon(Icons.chevron_right, color: MaisonColors.inkSoft),
      ),
    );
  }
}

/// A simulated camera viewfinder — the demo has no camera permission needs.
class FakeCameraScreen extends StatelessWidget {
  const FakeCameraScreen({super.key, required this.mode});
  final CaptureMode mode;

  @override
  Widget build(BuildContext context) {
    final isNameplate = mode == CaptureMode.nameplate;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(isNameplate ? 'Scan nameplate' : 'Scan receipt',
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  border: Border.all(color: MaisonColors.accent, width: 2.5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isNameplate ? '🏷️' : '🧾', style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          isNameplate
                              ? 'Frame the metal label on the appliance.\nDemo mode: a furnace nameplate is pre-loaded.'
                              : 'Flatten the receipt in the frame.\nDemo mode: a Canadian Tire receipt is pre-loaded.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 44, top: 8),
            child: GestureDetector(
              key: const Key('capture'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ParsingScreen(mode: mode)),
                );
              },
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                padding: const EdgeInsets.all(5),
                child: const DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: MaisonColors.accent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick-note input, pre-filled with a realistic example.
class QuickNoteScreen extends StatefulWidget {
  const QuickNoteScreen({super.key});
  @override
  State<QuickNoteScreen> createState() => _QuickNoteScreenState();
}

class _QuickNoteScreenState extends State<QuickNoteScreen> {
  final _controller = TextEditingController(
      text: 'Fixed the leaky bathroom faucet, Moen cartridge, \$38 at Réno-Dépôt');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick note')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Write it like you\'d text a friend.',
                style: TextStyle(fontSize: 15, color: MaisonColors.inkSoft)),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(fontSize: 17, height: 1.45),
              decoration: InputDecoration(
                filled: true,
                fillColor: MaisonColors.card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: MaisonColors.line)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Let Maison file it'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => ParsingScreen(mode: CaptureMode.note, noteText: _controller.text)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The fake "AI is working" screen: animated step-by-step progress,
/// then pushes the confirmation screen with the parsed record.
class ParsingScreen extends StatefulWidget {
  const ParsingScreen({super.key, required this.mode, this.noteText});
  final CaptureMode mode;
  final String? noteText;

  @override
  State<ParsingScreen> createState() => _ParsingScreenState();
}

class _ParsingScreenState extends State<ParsingScreen> {
  late final ParseResult _result;
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _result = MockAi.parse(widget.mode, noteText: widget.noteText);
    _timer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (_step < _result.steps.length - 1) {
        setState(() => _step++);
      } else {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => ConfirmScreen(result: _result)));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(color: MaisonColors.accent, strokeWidth: 5),
                ),
              ),
              const SizedBox(height: 36),
              ...List.generate(_result.steps.length, (i) {
                final done = i < _step;
                final active = i == _step;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: i <= _step ? 1 : 0.25,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Icon(
                          done ? Icons.check_circle : (active ? Icons.autorenew : Icons.circle_outlined),
                          size: 22,
                          color: done ? MaisonColors.green : MaisonColors.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_result.steps[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// AI transparency: show what was extracted, let the user fix anything, then save.
class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key, required this.result});
  final ParseResult result;

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  ParseResult get result => widget.result;

  bool _editing = false;
  late final TextEditingController _title =
      TextEditingController(text: result.record.title);
  late final TextEditingController _room =
      TextEditingController(text: result.record.room);
  late final TextEditingController _cost = TextEditingController(
      text: result.record.cost?.toStringAsFixed(2) ?? '');
  late final TextEditingController _vendor =
      TextEditingController(text: result.record.vendor ?? '');

  @override
  void dispose() {
    _title.dispose();
    _room.dispose();
    _cost.dispose();
    _vendor.dispose();
    super.dispose();
  }

  /// The record with any user corrections applied on top of the AI parse.
  HomeRecord _correctedRecord() {
    final r = result.record;
    return HomeRecord(
      kind: r.kind,
      title: _title.text.trim().isEmpty ? r.title : _title.text.trim(),
      subtitle: r.subtitle,
      room: _room.text.trim().isEmpty ? r.room : _room.text.trim(),
      cost: double.tryParse(_cost.text.replaceAll(',', '').replaceAll('\$', '')) ?? r.cost,
      vendor: _vendor.text.trim().isEmpty ? r.vendor : _vendor.text.trim(),
      modelSerial: r.modelSerial,
      warrantyUntil: r.warrantyUntil,
      returnBy: r.returnBy,
      manualFound: r.manualFound,
      rawInput: r.rawInput,
      addedOn: r.addedOn,
    );
  }

  void _save() {
    AppState.instance.addParsed(ParseResult(
      record: _correctedRecord(),
      reminders: result.reminders,
      steps: result.steps,
    ));
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_editing
            ? 'Saved with your corrections ✓'
            : 'Saved to your house timeline ✓'),
        duration: const Duration(seconds: 2)));
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 105,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: MaisonColors.inkSoft))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _editRow(String label, TextEditingController controller, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 105,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: MaisonColors.inkSoft))),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: MaisonColors.paper,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: MaisonColors.line)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: MaisonColors.line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: MaisonColors.accent, width: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = result.record;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Fix the details' : 'Here\'s what I got')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (r.rawInput != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: MaisonColors.accentWash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('You gave me: ${r.rawInput!}',
                  style: const TextStyle(
                      fontSize: 13, fontStyle: FontStyle.italic, color: MaisonColors.accentDeep, height: 1.4)),
            ),
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
                  Text(r.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(r.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                ]),
                const Divider(height: 26, color: MaisonColors.line),
                if (_editing) ...[
                  _editRow('Name', _title),
                  _editRow('Room', _room),
                  _editRow('Cost', _cost, keyboard: const TextInputType.numberWithOptions(decimal: true)),
                  _editRow('Vendor', _vendor),
                ] else ...[
                  _row('What', r.subtitle),
                  _row('Room', r.room),
                  if (r.cost != null) _row('Cost', '\$${r.cost!.toStringAsFixed(2)}'),
                  if (r.vendor != null) _row('Vendor', r.vendor!),
                ],
                if (r.modelSerial != null) _row('Serial', r.modelSerial!),
                if (r.warrantyUntil != null)
                  _row('Warranty', 'Until ${_fmtDate(r.warrantyUntil!)}'),
                if (r.returnBy != null) _row('Return by', _fmtDate(r.returnBy!)),
                if (r.manualFound) _row('Manual', 'Found ✓ (attached as PDF)'),
              ],
            ),
          ),
          if (result.reminders.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MaisonColors.navyWash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔔 Reminders I\'ll set for you',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: MaisonColors.navy)),
                  const SizedBox(height: 6),
                  ...result.reminders.map((rem) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('•  ${rem.title} — ${_fmtDate(rem.due)}',
                            style: const TextStyle(fontSize: 13.5, color: MaisonColors.navy, height: 1.4)),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: Text(_editing ? 'Save my corrections' : 'Looks right — save it'),
            onPressed: _save,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _editing ? MaisonColors.inkSoft : MaisonColors.accentDeep,
              side: BorderSide(color: _editing ? MaisonColors.line : MaisonColors.accent),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(_editing ? Icons.undo : Icons.edit_outlined, size: 19),
            label: Text(_editing ? 'Never mind — keep the AI version' : 'Fix something first'),
            onPressed: () => setState(() {
              if (_editing) {
                // Revert any edits back to what the AI extracted.
                _title.text = result.record.title;
                _room.text = result.record.room;
                _cost.text = result.record.cost?.toStringAsFixed(2) ?? '';
                _vendor.text = result.record.vendor ?? '';
              }
              _editing = !_editing;
            }),
          ),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}
