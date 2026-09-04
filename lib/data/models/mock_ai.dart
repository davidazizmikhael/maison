import 'home_record.dart';
import 'parse_result.dart';
import 'reminder.dart';

/// The demo's stand-in for the AI backend. Returns a canned structured record
/// for each capture mode after a fake "thinking" delay handled by the UI.
class MockAi {
  static ParseResult parse(CaptureMode mode, {String? noteText}) {
    final now = DateTime.now();
    switch (mode) {
      case CaptureMode.nameplate:
        return ParseResult(
          steps: ['Reading nameplate…', 'Identifying model…', 'Finding the manual…', 'Checking recalls…'],
          record: HomeRecord(
            kind: RecordKind.appliance,
            title: 'Furnace — Lennox ML296V',
            subtitle: 'High-efficiency gas furnace',
            room: 'Basement',
            vendorDomain: 'lennox.com',
            vendorPhone: '1-800-953-6669',
            modelSerial: 'S/N 5919C04532',
            manualFound: true,
            warrantyUntil: DateTime(now.year + 3, now.month, now.day),
            rawInput: '📸 photo of furnace nameplate',
          ),
          confidence: 'high',
          reminders: [
            Reminder(
              title: 'Replace furnace filter',
              detail: 'Lennox ML296V · every 3 months',
              due: now.add(const Duration(days: 90)),
              seasonal: true,
            ),
          ],
        );
      case CaptureMode.receipt:
        return ParseResult(
          steps: ['Scanning receipt…', 'Extracting items & prices…', 'Reading warranty terms…', 'Tracking return window…'],
          record: HomeRecord(
            kind: RecordKind.receipt,
            title: 'Snow blower — Toro Power Max 826',
            subtitle: 'From Canadian Tire receipt',
            room: 'Garage',
            cost: 1699.99,
            vendor: 'Canadian Tire',
            vendorDomain: 'canadiantire.ca',
            vendorPhone: '1-800-387-8803',
            warrantyUntil: now.add(const Duration(days: 1095)),
            returnBy: now.add(const Duration(days: 90)),
            manualFound: true,
            rawInput: '📸 photo of Canadian Tire receipt',
          ),
          confidence: 'high',
          reminders: [
            Reminder(
              title: 'Snow blower return window',
              detail: 'Toro Power Max · Canadian Tire',
              due: now.add(const Duration(days: 90)),
            ),
            Reminder(
              title: 'Snow blower oil change',
              detail: 'Before first snowfall',
              due: DateTime(now.year, 11, 15),
              seasonal: true,
            ),
          ],
        );
      case CaptureMode.note:
        final text = (noteText == null || noteText.trim().isEmpty)
            ? 'Fixed the leaky bathroom faucet, Moen cartridge, \$38 at Réno-Dépôt'
            : noteText.trim();
        final costMatch = RegExp(r'\$\s?([\d,]+(?:\.\d{1,2})?)').firstMatch(text);
        final cost = costMatch == null ? null : double.tryParse(costMatch.group(1)!.replaceAll(',', ''));
        return ParseResult(
          steps: ['Reading your note…', 'Extracting the details…', 'Filing under the right room…'],
          record: HomeRecord(
            kind: RecordKind.service,
            title: 'Bathroom faucet repair',
            subtitle: 'Moen 1225 cartridge replaced',
            room: 'Bathroom',
            cost: cost ?? 38,
            vendor: 'Réno-Dépôt',
            rawInput: '"$text"',
          ),
          reminders: [],
          confidence: 'high',
        );
    }
  }
}
