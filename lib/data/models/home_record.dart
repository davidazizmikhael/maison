enum RecordKind { appliance, receipt, service }


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
