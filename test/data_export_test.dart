import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maison/data/models.dart';
import 'package:maison/features/exports/data_export.dart';

void main() {
  test('backup zip carries JSON, CSV and photos with cross-references', () {
    final records = [
      HomeRecord(
        kind: RecordKind.appliance,
        title: 'Furnace — Lennox ML296V',
        subtitle: 'Gas furnace',
        room: 'Basement',
        modelSerial: 'S/N 123',
        warrantyUntil: DateTime(2029, 9, 2),
        photoPath: 'uid/123.jpg',
      ),
      HomeRecord(
        kind: RecordKind.receipt,
        title: 'Running shoes, "on sale"',
        subtitle: 'Sports Experts',
        room: 'Home',
        cost: 129.99,
        returnBy: DateTime(2026, 10, 2),
      ),
    ];
    final reminders = [
      Reminder(
          title: 'Return window closes',
          detail: 'Running shoes',
          due: DateTime(2026, 9, 29)),
      Reminder(
          title: 'Filter change',
          detail: 'Furnace',
          due: DateTime(2026, 6, 1),
          doneAt: DateTime(2026, 6, 2)),
    ];
    final photoBytes = Uint8List.fromList(List.filled(64, 7));

    final zip = buildBackupZip(
      address: '214 Rue Clark, Montréal',
      profile: HomeProfile(
          type: 'Duplex', bedrooms: 3, bathrooms: 1.5, garage: true, basement: true),
      records: records,
      reminders: reminders,
      photos: {'uid/123.jpg': photoBytes},
      now: DateTime(2026, 9, 2),
    );

    final files = {for (final f in ZipDecoder().decodeBytes(zip)) f.name: f};
    expect(files.keys, contains('records.json'));
    expect(files.keys, contains('records.csv'));
    expect(files.keys.where((n) => n.startsWith('photos/')), hasLength(1));

    final manifest =
        jsonDecode(utf8.decode(files['records.json']!.content as List<int>)) as Map;
    expect(manifest['address'], '214 Rue Clark, Montréal');
    expect(manifest['home_profile']['bathrooms'], 1.5);
    expect(manifest['records'], hasLength(2));
    expect(manifest['reminders'], hasLength(2));
    expect(manifest['reminders'][1]['done_at'], '2026-06-02');

    // The JSON's photo reference points at a real entry in the zip.
    final photoRef = manifest['records'][0]['photo'] as String;
    expect(files.keys, contains(photoRef));
    expect(files[photoRef]!.content, photoBytes);
    expect(manifest['records'][1]['photo'], isNull);

    // CSV: header + 2 rows; commas and quotes in titles stay intact.
    final csv = utf8.decode(files['records.csv']!.content as List<int>);
    final lines = csv.trim().split('\n');
    expect(lines, hasLength(3));
    expect(lines[2], contains('"Running shoes, ""on sale"""'));
  });
}
