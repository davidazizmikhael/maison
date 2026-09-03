import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maison/data/backend.dart';
import 'package:maison/data/models.dart';
import 'package:maison/features/add_entry/add_entry_cubit.dart';
import 'package:maison/features/add_entry/add_entry_screens.dart';
import 'package:maison/features/session/session_cubit.dart';
import 'package:maison/core/theme.dart';
import 'package:maison/features/timeline/timeline_cubit.dart';
import 'package:maison/l10n/gen/app_localizations.dart';

Widget _confirm(ParseResult result) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => SessionCubit(MockBackend())),
      BlocProvider(create: (_) => TimelineCubit(MockBackend())),
      BlocProvider(create: (_) => AddEntryCubit(MockBackend())),
    ],
    child: MaterialApp(
      theme: maisonTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ConfirmScreen(result: result),
    ),
  );
}

ParseResult _result({String? confidence}) => ParseResult(
      record: HomeRecord(
        kind: RecordKind.receipt,
        title: 'Mystery store purchase',
        subtitle: 'Faded thermal receipt',
        room: 'Home',
      ),
      reminders: const [],
      steps: const [],
      confidence: confidence,
    );

void main() {
  testWidgets('low confidence shows the double-check banner', (tester) async {
    await tester.pumpWidget(_confirm(_result(confidence: 'low')));
    await tester.pumpAndSettle();
    expect(find.textContaining("couldn't read everything"), findsOneWidget);
  });

  testWidgets('high confidence shows no banner', (tester) async {
    await tester.pumpWidget(_confirm(_result(confidence: 'high')));
    await tester.pumpAndSettle();
    expect(find.textContaining("couldn't read everything"), findsNothing);
  });
}
