import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';

const _ink = PdfColor.fromInt(0xFF1B2432);
const _inkSoft = PdfColor.fromInt(0xFF4A5568);
const _accent = PdfColor.fromInt(0xFFD97742);
const _line = PdfColor.fromInt(0xFFE4DDD2);
const _paper = PdfColor.fromInt(0xFFFAF7F2);

String _fmtDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

pw.Widget _header(AppLocalizations l10n, String title, String address) {
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text('MAISON',
        style: pw.TextStyle(
            fontSize: 11, color: _accent, fontWeight: pw.FontWeight.bold, letterSpacing: 3)),
    pw.SizedBox(height: 4),
    pw.Text(title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _ink)),
    pw.SizedBox(height: 2),
    pw.Text(address, style: const pw.TextStyle(fontSize: 11, color: _inkSoft)),
    pw.SizedBox(height: 2),
    pw.Text(l10n.pdfGeneratedBy(_fmtDate(DateTime.now())),
        style: const pw.TextStyle(fontSize: 9, color: _inkSoft)),
    pw.Divider(color: _line, thickness: 1),
    pw.SizedBox(height: 8),
  ]);
}

pw.Widget _row(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.SizedBox(
          width: 110,
          child: pw.Text(label,
              style: pw.TextStyle(fontSize: 10, color: _inkSoft, fontWeight: pw.FontWeight.bold))),
      pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 11, color: _ink))),
    ]),
  );
}

/// Warranty claim pack: everything a manufacturer asks for, one page.
Future<Uint8List> buildClaimPack({
  required AppLocalizations l10n,
  required String address,
  required HomeRecord record,
  Uint8List? photo,
}) async {
  final doc = pw.Document();
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.letter,
    build: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _header(l10n, l10n.claimPackTitle, address),
      pw.Text(record.title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _ink)),
      pw.SizedBox(height: 8),
      _row(l10n.labelWhat, record.subtitle),
      _row(l10n.labelRoom, record.room),
      if (record.cost != null) _row(l10n.labelCost, '\$${record.cost!.toStringAsFixed(2)}'),
      if (record.vendor != null) _row(l10n.labelVendor, record.vendor!),
      if (record.modelSerial != null) _row(l10n.labelSerial, record.modelSerial!),
      _row(l10n.pdfAddedOn, _fmtDate(record.addedOn)),
      if (record.warrantyUntil != null)
        _row(l10n.labelWarranty, l10n.warrantyUntil(_fmtDate(record.warrantyUntil!))),
      if (record.returnBy != null) _row(l10n.labelReturnBy, _fmtDate(record.returnBy!)),
      if (record.rawInput != null) _row('Source', record.rawInput!.replaceAll('📸', '').trim()),
      if (photo != null) ...[
        pw.SizedBox(height: 14),
        pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _line), borderRadius: pw.BorderRadius.circular(6)),
          child: pw.ClipRRect(
            horizontalRadius: 6,
            verticalRadius: 6,
            child: pw.Image(pw.MemoryImage(photo), height: 300, fit: pw.BoxFit.contain),
          ),
        ),
      ],
    ]),
  ));
  return doc.save();
}

/// Insurance inventory: every record, values, photos, total.
Future<Uint8List> buildInventory({
  required AppLocalizations l10n,
  required String address,
  required List<HomeRecord> records,
  required Map<HomeRecord, Uint8List> photos,
}) async {
  final total = records.fold<double>(0, (sum, r) => sum + (r.cost ?? 0));
  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.letter,
    build: (context) => [
      _header(l10n, l10n.inventoryTitle, address),
      pw.TableHelper.fromTextArray(
        headers: [l10n.labelName, l10n.labelRoom, l10n.labelCost, l10n.labelWarranty],
        headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _paper),
        headerDecoration: const pw.BoxDecoration(color: _ink),
        cellStyle: const pw.TextStyle(fontSize: 10, color: _ink),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        border: pw.TableBorder.all(color: _line, width: 0.5),
        data: [
          for (final r in records)
            [
              r.title,
              r.room,
              r.cost != null ? '\$${r.cost!.toStringAsFixed(2)}' : '-',
              r.warrantyUntil != null ? _fmtDate(r.warrantyUntil!) : '-',
            ],
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('${l10n.pdfTotalValue}: \$${total.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _ink)),
      ),
      if (photos.isNotEmpty) ...[
        pw.SizedBox(height: 16),
        pw.Wrap(spacing: 10, runSpacing: 10, children: [
          for (final entry in photos.entries)
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.ClipRRect(
                horizontalRadius: 6,
                verticalRadius: 6,
                child: pw.Image(pw.MemoryImage(entry.value),
                    width: 160, height: 120, fit: pw.BoxFit.cover),
              ),
              pw.SizedBox(height: 3),
              pw.SizedBox(
                  width: 160,
                  child: pw.Text(entry.key.title,
                      style: const pw.TextStyle(fontSize: 8, color: _inkSoft), maxLines: 1)),
            ]),
        ]),
      ],
    ],
  ));
  return doc.save();
}

/// House history: the chronological story of the home.
Future<Uint8List> buildHouseHistory({
  required AppLocalizations l10n,
  required String address,
  required List<HomeRecord> records,
}) async {
  final sorted = [...records]..sort((a, b) => b.addedOn.compareTo(a.addedOn));
  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.letter,
    build: (context) => [
      _header(l10n, l10n.historyTitle, address),
      for (final r in sorted)
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
              color: _paper,
              border: pw.Border.all(color: _line, width: 0.5),
              borderRadius: pw.BorderRadius.circular(6)),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Expanded(
                  child: pw.Text(r.title,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold, color: _ink))),
              pw.Text(_fmtDate(r.addedOn), style: const pw.TextStyle(fontSize: 9, color: _inkSoft)),
            ]),
            pw.SizedBox(height: 2),
            pw.Text(
              [
                r.room,
                if (r.cost != null) '\$${r.cost!.toStringAsFixed(2)}',
                if (r.vendor != null) r.vendor!,
                if (r.warrantyUntil != null)
                  '${l10n.labelWarranty}: ${_fmtDate(r.warrantyUntil!)}',
              ].join('  ·  '),
              style: const pw.TextStyle(fontSize: 9.5, color: _inkSoft),
            ),
          ]),
        ),
    ],
  ));
  return doc.save();
}
