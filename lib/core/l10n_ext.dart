import 'package:flutter/widgets.dart';

import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Locale-aware version of [HomeProfile.chips].
List<String> localizedChips(AppLocalizations l10n, HomeProfile p) => [
      '🏠 ${p.type}',
      l10n.chipBedrooms(p.bedrooms),
      l10n.chipBathrooms(p.bathroomsLabel),
      if (p.garage) l10n.chipGarage,
      if (p.basement) l10n.chipBasement,
    ];
