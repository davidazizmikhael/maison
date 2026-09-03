import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../data/models.dart';

/// Builds the full-backup ZIP: everything the user ever put in, in open
/// formats — records.json (complete), records.csv (spreadsheet-friendly),
/// and the original photos. The post-shutdown lesson from this category
/// (Centriq, Encircle) is that data must never be hostage; this is the
/// "everything out, always" promise made concrete.
Uint8List buildBackupZip({
  required String address,
  HomeProfile? profile,
  required List<HomeRecord> records,
  required List<Reminder> reminders,
  required Map<String, Uint8List> photos, // keyed by record.photoPath
  DateTime? now,
}) {
  final exportedAt = (now ?? DateTime.now()).toIso8601String();
  String? photoFile(HomeRecord r) {
    if (r.photoPath == null || !photos.containsKey(r.photoPath)) return null;
    final slug = r.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'photos/$slug-${r.photoPath.hashCode.toRadixString(16)}.jpg';
  }

  String iso(DateTime? d) => d == null ? '' : d.toIso8601String().substring(0, 10);

  final manifest = {
    'app': 'Maison',
    'export_version': 1,
    'exported_at': exportedAt,
    'address': address,
    if (profile != null)
      'home_profile': {
        'type': profile.type,
        'bedrooms': profile.bedrooms,
        'bathrooms': profile.bathrooms,
        'garage': profile.garage,
        'basement': profile.basement,
      },
    'records': [
      for (final r in records)
        {
          'title': r.title,
          'subtitle': r.subtitle,
          'kind': r.kind.name,
          'room': r.room,
          'cost': r.cost,
          'vendor': r.vendor,
          'vendor_domain': r.vendorDomain,
          'vendor_phone': r.vendorPhone,
          'vendor_email': r.vendorEmail,
          'model_serial': r.modelSerial,
          'warranty_until': r.warrantyUntil == null ? null : iso(r.warrantyUntil),
          'return_by': r.returnBy == null ? null : iso(r.returnBy),
          'added_on': iso(r.addedOn),
          'raw_input': r.rawInput,
          'photo': photoFile(r),
        }
    ],
    'reminders': [
      for (final r in reminders)
        {
          'title': r.title,
          'detail': r.detail,
          'due': iso(r.due),
          'seasonal': r.seasonal,
          'done_at': r.doneAt == null ? null : iso(r.doneAt),
        }
    ],
  };

  String csvCell(Object? v) {
    final s = v?.toString() ?? '';
    return s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  final csv = StringBuffer(
      'title,kind,room,cost,vendor,vendor_phone,vendor_email,model_serial,warranty_until,return_by,added_on,photo\n');
  for (final r in records) {
    csv.writeln([
      r.title,
      r.kind.name,
      r.room,
      r.cost,
      r.vendor,
      r.vendorPhone,
      r.vendorEmail,
      r.modelSerial,
      iso(r.warrantyUntil),
      iso(r.returnBy),
      iso(r.addedOn),
      photoFile(r),
    ].map(csvCell).join(','));
  }

  final archive = Archive();
  void addText(String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  addText('records.json', const JsonEncoder.withIndent('  ').convert(manifest));
  addText('records.csv', csv.toString());
  for (final r in records) {
    final name = photoFile(r);
    if (name == null) continue;
    final bytes = photos[r.photoPath]!;
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
