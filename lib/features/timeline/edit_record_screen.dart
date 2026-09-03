import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../session/session_cubit.dart';
import 'timeline_cubit.dart';

/// Post-save editing: the same fields as the confirm screen's "fix" mode,
/// wired to the update path. Saving returns to the timeline.
class EditRecordScreen extends StatefulWidget {
  const EditRecordScreen({super.key, required this.record});
  final HomeRecord record;

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  late final TextEditingController _title = TextEditingController(text: widget.record.title);
  late final TextEditingController _room = TextEditingController(text: widget.record.room);
  late final TextEditingController _cost =
      TextEditingController(text: widget.record.cost?.toStringAsFixed(2) ?? '');
  late final TextEditingController _vendor =
      TextEditingController(text: widget.record.vendor ?? '');
  late DateTime? _warrantyUntil = widget.record.warrantyUntil;
  late DateTime? _returnBy = widget.record.returnBy;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _room.dispose();
    _cost.dispose();
    _vendor.dispose();
    super.dispose();
  }

  HomeRecord _updated() {
    final o = widget.record;
    return HomeRecord(
      id: o.id,
      kind: o.kind,
      title: _title.text.trim().isEmpty ? o.title : _title.text.trim(),
      subtitle: o.subtitle,
      room: _room.text.trim().isEmpty ? o.room : _room.text.trim(),
      cost: double.tryParse(_cost.text.replaceAll(',', '').replaceAll('\$', '')) ?? o.cost,
      vendor: _vendor.text.trim().isEmpty ? o.vendor : _vendor.text.trim(),
      vendorDomain: o.vendorDomain,
      vendorPhone: o.vendorPhone,
      vendorEmail: o.vendorEmail,
      modelSerial: o.modelSerial,
      warrantyUntil: _warrantyUntil,
      returnBy: _returnBy,
      manualFound: o.manualFound,
      rawInput: o.rawInput,
      photoPath: o.photoPath,
      addedOn: o.addedOn,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final session = context.read<SessionCubit>().state;
    final homeId = session is SessionReady ? session.homeId : null;
    await context
        .read<TimelineCubit>()
        .updateRecord(widget.record, _updated(), homeId: homeId);
    if (!mounted) return;
    final snack = context.l10n.savedCorrectionsSnack;
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(snack), duration: const Duration(seconds: 2)));
  }

  Future<void> _pickWarrantyDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _warrantyUntil ?? now.add(const Duration(days: 365)),
      firstDate: DateTime(now.year - 15),
      lastDate: DateTime(now.year + 30),
      helpText: context.l10n.labelWarranty,
    );
    if (picked != null) setState(() => _warrantyUntil = picked);
  }

  Future<void> _pickReturnDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnBy ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 2),
      lastDate: now.add(const Duration(days: 365)),
      helpText: context.l10n.labelReturnBy,
    );
    if (picked != null) setState(() => _returnBy = picked);
  }

  Future<void> _pickRoom() async {
    final session = context.read<SessionCubit>().state;
    final profile = session is SessionReady ? session.profile : null;
    final rooms = <String>{
      if (_room.text.trim().isNotEmpty) _room.text.trim(),
      ...?profile?.rooms,
      'Kitchen', 'Living room', 'Bathroom', 'Bedroom', 'Basement', 'Garage', 'Home',
    }.toList();
    final chosen = await showModalBottomSheet<String>(
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(sheetContext.l10n.labelRoom,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final room in rooms)
                    ListTile(
                      dense: true,
                      title: Text(room,
                          style: TextStyle(
                              fontWeight:
                                  room == _room.text ? FontWeight.w800 : FontWeight.w500)),
                      trailing: room == _room.text
                          ? Icon(Icons.check, color: sheetContext.mc.accentDeep)
                          : null,
                      onTap: () => Navigator.of(sheetContext).pop(room),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _room.text = chosen);
  }

  Widget _editRow(String label, TextEditingController controller, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
            width: 105,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: context.mc.inkSoft))),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: context.mc.paper,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.mc.line)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.mc.line)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.mc.accent, width: 1.5)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _pickRow(String label, String value, {required VoidCallback onTap, Key? key}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
            width: 105,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: context.mc.inkSoft))),
        Expanded(
          child: GestureDetector(
            key: key,
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: context.mc.paper,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.mc.line),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(value,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
                Icon(Icons.expand_more, size: 18, color: context.mc.inkSoft),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editRecord)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                _editRow(context.l10n.labelName, _title),
                _pickRow(context.l10n.labelRoom, _room.text,
                    key: const Key('room-edit'), onTap: _pickRoom),
                _editRow(context.l10n.labelCost, _cost,
                    keyboard: const TextInputType.numberWithOptions(decimal: true)),
                _editRow(context.l10n.labelVendor, _vendor),
                _pickRow(
                    context.l10n.labelWarranty,
                    _warrantyUntil != null
                        ? _fmtDate(_warrantyUntil!)
                        : context.l10n.tapToSet,
                    key: const Key('warranty-edit'),
                    onTap: _pickWarrantyDate),
                _pickRow(
                    context.l10n.labelReturnBy,
                    _returnBy != null ? _fmtDate(_returnBy!) : context.l10n.tapToSet,
                    key: const Key('return-edit'),
                    onTap: _pickReturnDate),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Icon(Icons.check),
            label: Text(_saving ? context.l10n.savingLabel : context.l10n.saveCorrections),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
