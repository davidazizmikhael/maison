import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'locale_cubit.dart';

void showLanguageSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: context.mc.paper,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) {
      final cubit = context.read<LocaleCubit>();
      final current = cubit.state;
      Widget option(String label, Locale? value) {
        final selected = current?.languageCode == value?.languageCode;
        return ListTile(
          title: Text(label,
              style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
          trailing: selected ? Icon(Icons.check, color: sheetContext.mc.accentDeep) : null,
          onTap: () {
            cubit.set(value);
            Navigator.of(sheetContext).pop();
          },
        );
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('🌐 ${l10n.languageTitle}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            option(l10n.languageSystem, null),
            option('English', const Locale('en')),
            option('Français', const Locale('fr')),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
