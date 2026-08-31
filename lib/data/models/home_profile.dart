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
