import 'package:flutter/foundation.dart';

enum RecordKind { appliance, receipt, service }

enum CaptureMode { nameplate, receipt, note }

class HomeRecord {
  HomeRecord({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.room,
    this.cost,
    this.vendor,
    this.modelSerial,
    this.warrantyUntil,
    this.returnBy,
    this.manualFound = false,
    this.rawInput,
    DateTime? addedOn,
  }) : addedOn = addedOn ?? DateTime.now();

  final RecordKind kind;
  final String title;
  final String subtitle;
  final String room;
  final double? cost;
  final String? vendor;
  final String? modelSerial;
  final DateTime? warrantyUntil;
  final DateTime? returnBy;
  final bool manualFound;
  final String? rawInput; // what the user snapped/typed, shown for AI transparency
  final DateTime addedOn;

  String get emoji => switch (kind) {
        RecordKind.appliance => '🔧',
        RecordKind.receipt => '🧾',
        RecordKind.service => '🛠️',
      };
}

class Reminder {
  Reminder({required this.title, required this.detail, required this.due, this.seasonal = false});
  final String title;
  final String detail;
  final DateTime due;
  final bool seasonal;

  int get daysLeft => due.difference(DateTime.now()).inDays;
}

/// A canned "AI" parse result the demo pretends to extract.
class ParseResult {
  ParseResult({required this.record, required this.reminders, required this.steps});
  final HomeRecord record;
  final List<Reminder> reminders;
  final List<String> steps; // the fake progress steps shown while "parsing"
}

/// The home's shape, structured by "AI" from a free-text description.
class HomeProfile {
  HomeProfile({
    required this.type,
    required this.bedrooms,
    required this.bathrooms,
    required this.garage,
    required this.basement,
  });

  final String type;
  final int bedrooms;
  final double bathrooms;
  final bool garage;
  final bool basement;

  /// Demo stand-in for the AI: pulls the home's shape out of a sentence like
  /// "Duplex, 3 bedrooms, 2 bathrooms, garage, unfinished basement".
  static HomeProfile parse(String text) {
    final t = text.toLowerCase();
    int bedrooms = 3;
    double bathrooms = 1;
    final bedMatch = RegExp(r'(\d+)\s*(?:bed|br\b|chambre)').firstMatch(t);
    if (bedMatch != null) bedrooms = int.parse(bedMatch.group(1)!);
    final bathMatch = RegExp(r'(\d+(?:\.\d)?)\s*(?:bath|salle)').firstMatch(t);
    if (bathMatch != null) bathrooms = double.parse(bathMatch.group(1)!);
    final garage = t.contains('garage') && !t.contains('no garage');
    final basement = (t.contains('basement') || t.contains('sous-sol')) && !t.contains('no basement');
    String type = 'House';
    for (final kind in ['duplex', 'triplex', 'condo', 'apartment', 'townhouse', 'chalet', 'bungalow']) {
      if (t.contains(kind)) {
        type = kind[0].toUpperCase() + kind.substring(1);
        break;
      }
    }
    return HomeProfile(
        type: type, bedrooms: bedrooms, bathrooms: bathrooms, garage: garage, basement: basement);
  }

  String get bathroomsLabel =>
      bathrooms % 1 == 0 ? bathrooms.toInt().toString() : bathrooms.toString();

  List<String> get chips => [
        '🏠 $type',
        '🛏 $bedrooms bedrooms',
        '🚿 $bathroomsLabel bathroom${bathrooms > 1 ? 's' : ''}',
        if (garage) '🚗 Garage',
        if (basement) '🔦 Basement',
      ];

  /// Rooms Maison will file records under and build checklists for.
  List<String> get rooms => [
        'Kitchen',
        'Living room',
        for (var i = 1; i <= bedrooms; i++) 'Bedroom $i',
        for (var i = 1; i <= bathrooms.ceil(); i++) 'Bathroom $i',
        if (garage) 'Garage',
        if (basement) 'Basement',
      ];
}

/// App-wide state. Deliberately simple for a demo: one ChangeNotifier singleton.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  String address = '214 Rue Clark, Montréal';
  HomeProfile? profile;

  void setProfile(HomeProfile p) {
    profile = p;
    notifyListeners();
  }
  final List<HomeRecord> records = [];
  final List<Reminder> reminders = [];

  bool get hasData => records.isNotEmpty;

  int get activeWarranties =>
      records.where((r) => r.warrantyUntil != null && r.warrantyUntil!.isAfter(DateTime.now())).length;

  void seedDemoData() {
    if (records.isNotEmpty) return;
    final now = DateTime.now();
    records.addAll([
      HomeRecord(
        kind: RecordKind.service,
        title: 'Water heater replaced',
        subtitle: 'Rheem 50 gal · installed by Joe\'s Plumbing',
        room: 'Basement',
        cost: 1850,
        vendor: "Joe's Plumbing",
        warrantyUntil: DateTime(now.year + 6, now.month, now.day),
        rawInput: '"water heater replaced today, Rheem 50 gal, \$1,850, Joe\'s Plumbing"',
        addedOn: now.subtract(const Duration(days: 12)),
      ),
      HomeRecord(
        kind: RecordKind.appliance,
        title: 'Dishwasher — Bosch 300 Series',
        subtitle: 'SHEM63W55N · from Home Depot receipt',
        room: 'Kitchen',
        cost: 1249,
        vendor: 'Home Depot',
        modelSerial: 'S/N 9502 1104 552',
        warrantyUntil: now.add(const Duration(days: 353)),
        returnBy: now.add(const Duration(days: 28)),
        manualFound: true,
        rawInput: '📸 photo of Home Depot receipt',
        addedOn: now.subtract(const Duration(days: 2)),
      ),
    ]);
    reminders.addAll([
      Reminder(
        title: 'Furnace filter due',
        detail: 'Lennox ML296V · every 3 months',
        due: now.add(const Duration(days: 9)),
        seasonal: true,
      ),
      Reminder(
        title: 'Dishwasher return window',
        detail: 'Bosch 300 · Home Depot, keep the receipt',
        due: now.add(const Duration(days: 28)),
      ),
      Reminder(
        title: 'Clean gutters before freeze-up',
        detail: 'Seasonal · Montréal winter prep',
        due: now.add(const Duration(days: 41)),
        seasonal: true,
      ),
      if (profile?.garage ?? false)
        Reminder(
          title: 'Lubricate garage door springs',
          detail: 'Added because your place has a garage',
          due: now.add(const Duration(days: 21)),
          seasonal: true,
        ),
    ]);
    reminders.sort((a, b) => a.due.compareTo(b.due));
    notifyListeners();
  }

  void addParsed(ParseResult result) {
    records.insert(0, result.record);
    reminders.addAll(result.reminders);
    reminders.sort((a, b) => a.due.compareTo(b.due));
    notifyListeners();
  }
}

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
            modelSerial: 'S/N 5919C04532',
            manualFound: true,
            warrantyUntil: DateTime(now.year + 3, now.month, now.day),
            rawInput: '📸 photo of furnace nameplate',
          ),
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
            warrantyUntil: now.add(const Duration(days: 1095)),
            returnBy: now.add(const Duration(days: 90)),
            manualFound: true,
            rawInput: '📸 photo of Canadian Tire receipt',
          ),
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
        );
    }
  }
}
