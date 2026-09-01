import 'package:flutter_test/flutter_test.dart';
import 'package:maison/data/models.dart';
import 'package:maison/features/timeline/record_detail_screen.dart';

void main() {
  test('warranty progress reflects the updated end date and stays in the 0..1 range', () {
    final now = DateTime(2026, 8, 31, 12, 0);
    final record = HomeRecord(
      kind: RecordKind.appliance,
      title: 'Dishwasher',
      subtitle: 'Test',
      room: 'Kitchen',
      warrantyUntil: now.add(const Duration(days: 180)),
      addedOn: now.subtract(const Duration(days: 365)),
    );

    final progress = calculateWarrantyProgress(record, now: now);

    expect(progress, isNotNull);
    expect(progress!.daysLeft, 180);
    expect(progress.totalDays, 545);
    expect(progress.progress, closeTo(0.330, 0.01));
    expect(progress.progress, inInclusiveRange(0.0, 1.0));
  });

  test('progress changes when the warranty end date is extended', () {
    final fixedNow = DateTime(2026, 8, 31, 12, 0);
    final baseRecord = HomeRecord(
      kind: RecordKind.appliance,
      title: 'Dishwasher',
      subtitle: 'Test',
      room: 'Kitchen',
      warrantyUntil: fixedNow.add(const Duration(days: 180)),
      addedOn: fixedNow.subtract(const Duration(days: 365)),
    );

    final updatedRecord = HomeRecord(
      kind: baseRecord.kind,
      title: baseRecord.title,
      subtitle: baseRecord.subtitle,
      room: baseRecord.room,
      warrantyUntil: fixedNow.add(const Duration(days: 400)),
      addedOn: baseRecord.addedOn,
    );

    final oldProgress = calculateWarrantyProgress(baseRecord, now: fixedNow)!;
    final newProgress = calculateWarrantyProgress(updatedRecord, now: fixedNow)!;

    expect(oldProgress.progress, isNot(equals(newProgress.progress)));
    expect(newProgress.progress, greaterThan(oldProgress.progress));
  });
}
