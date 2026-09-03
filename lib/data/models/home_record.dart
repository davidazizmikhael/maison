enum RecordKind { appliance, receipt, service }


class HomeRecord {
  HomeRecord({
    this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.room,
    this.cost,
    this.vendor,
    this.vendorDomain,
    this.vendorPhone,
    this.vendorEmail,
    this.modelSerial,
    this.warrantyUntil,
    this.returnBy,
    this.manualFound = false,
    this.rawInput,
    this.photoPath,
    DateTime? addedOn,
  }) : addedOn = addedOn ?? DateTime.now();

  /// Database row id (null in demo mode and before first save).
  final String? id;

  final RecordKind kind;
  final String title;
  final String subtitle;
  final String room;
  final double? cost;
  final String? vendor;

  /// The vendor's primary web domain (e.g. "sportsexperts.ca") — used to
  /// render the store icon via a favicon service, no API key needed.
  final String? vendorDomain;
  final String? vendorPhone;
  final String? vendorEmail;
  final String? modelSerial;
  final DateTime? warrantyUntil;
  final DateTime? returnBy;
  final bool manualFound;
  final String? rawInput; // what the user snapped/typed, shown for AI transparency

  /// Storage path of the original photo in the private 'captures' bucket.
  final String? photoPath;
  final DateTime addedOn;

  HomeRecord copyWith({String? id, String? photoPath}) => HomeRecord(
        id: id ?? this.id,
        kind: kind,
        title: title,
        subtitle: subtitle,
        room: room,
        cost: cost,
        vendor: vendor,
        vendorDomain: vendorDomain,
        vendorPhone: vendorPhone,
        vendorEmail: vendorEmail,
        modelSerial: modelSerial,
        warrantyUntil: warrantyUntil,
        returnBy: returnBy,
        manualFound: manualFound,
        rawInput: rawInput,
        photoPath: photoPath ?? this.photoPath,
        addedOn: addedOn,
      );

  String get emoji => switch (kind) {
        RecordKind.appliance => '🔧',
        RecordKind.receipt => '🧾',
        RecordKind.service => '🛠️',
      };
}
