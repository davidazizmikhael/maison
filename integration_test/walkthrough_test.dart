import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maison/core/motion.dart';
import 'package:maison/data/notifications.dart';
import 'package:maison/features/add_entry/add_entry_screens.dart';
import 'package:maison/main.dart' as app;

/// Walks the full Maison user journey and captures a screenshot at each step.
/// Run with:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/walkthrough_test.dart -d [device]
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    await binding.takeScreenshot(name);
  }

  Future<void> waitFor(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 15)}) async {
    final end = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        await binding.takeScreenshot('zz-timeout'); // what the screen really showed
        throw TimeoutException('Timed out waiting for $finder');
      }
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 250)));
      await tester.pump();
    }
  }

  testWidgets('Full Maison walkthrough', (tester) async {
    MaisonMotion.ambient = false; // looping floats never settle under pumpAndSettle
    app.main();
    await tester.pumpAndSettle();
    // Android renders test screenshots from an offscreen image surface.
    if (defaultTargetPlatform == TargetPlatform.android) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    // 1 — Onboarding
    await shot(tester, '01-onboarding-welcome');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await shot(tester, '02-onboarding-address');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await shot(tester, '03-describe-your-place');
    await tester.tap(find.text('Structure it'));
    await waitFor(tester, find.text("HERE'S YOUR PLACE"));
    await shot(tester, '03b-structured-home-profile');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await shot(tester, '03c-onboarding-how-it-works');
    await tester.tap(find.text('Start my home profile'));
    await tester.pumpAndSettle();
    // Live mode creates the home over the network — wait for the journal.
    await waitFor(tester, find.byKey(const Key('compose-field')));

    // 2 — Home dashboard
    await shot(tester, '04-home-dashboard');

    // 3 — Camera button → capture sheet (nameplate/receipt toggle) → shutter.
    // The item then appears on the home screen and parses IN PLACE.
    await tester.tap(find.byKey(const Key('compose-camera')));
    await tester.pumpAndSettle();
    await waitFor(tester, find.byKey(const Key('capture')));
    // Regression: the sheet was once sized from its caller's tiny render box.
    expect(tester.getSize(find.byType(CaptureSheet)).height, greaterThan(400));
    await shot(tester, '05-capture-sheet');
    await tester.tap(find.byKey(const Key('capture')));
    // No pumpAndSettle here: the parsing card's spinner never settles.
    await tester.pump(const Duration(milliseconds: 500));
    await binding.takeScreenshot('06-parsing-in-place');
    // Filed, no screens in between. The rail may sit below the fold (lazy
    // list), so anchor on the toast, then scroll the rail into the tree.
    await waitFor(tester, find.text('Filed ✓'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView).first, const Offset(0, -700), 2000);
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('Furnace — Lennox ML296V'));
    await shot(tester, '07-home-after-file');

    // 4 — Corrections happen on the record itself: detail → Edit.
    // Let the "Filed" snackbar expire first; the rail may sit below the fold.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Furnace — Lennox ML296V'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Furnace — Lennox ML296V'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('View manual'));
    // Vendor contact extracted from the nameplate (tap-to-call row)
    expect(find.text('1-800-953-6669'), findsOneWidget);
    await shot(tester, '08-record-detail');

    // 4a — Export the claim pack straight from the record
    await tester.tap(find.text('Warranty claim pack'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('📄  PDF ready'));
    await tester.tap(find.text('Nice'));
    await tester.pumpAndSettle();

    // 4b — Edit: room, warranty date, and a hand-set return date (which must
    // spawn its reminder on save)
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await shot(tester, '09-edit-record');
    await tester.tap(find.byKey(const Key('room-edit')));
    await tester.pumpAndSettle();
    await shot(tester, '09b-room-picker');
    await tester.tap(find.text('Kitchen').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('warranty-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('return-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('return-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save my corrections'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.byKey(const Key('compose-field'))); // back on the journal
    // The list kept its scroll offset — bring Up next back into the tree.
    await tester.fling(find.byType(ListView).first, const Offset(0, 800), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Return window closes'), findsOneWidget);

    // 5 — Keyboard button → inline compose field (same screen) → send →
    // the note parses in place on home
    await tester.pump(const Duration(seconds: 4)); // corrections snackbar
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('compose-field')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('compose-input')),
        'Fixed the leaky bathroom faucet, Moen cartridge, \$38 at Réno-Dépôt');
    await tester.pumpAndSettle();
    await shot(tester, '10-inline-compose');
    await tester.tap(find.byKey(const Key('compose-send')));
    await tester.pump(const Duration(milliseconds: 300));
    await waitFor(tester, find.text('Filed ✓'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView).first, const Offset(0, -700), 2000);
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('Bathroom faucet repair'));
    await shot(tester, '11-home-after-note');

    // 6b — Delete the note record from its detail screen (snackbar again)
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Bathroom faucet repair'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bathroom faucet repair'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('View manual'));
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await shot(tester, '12b-delete-confirm');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.byKey(const Key('compose-field')));
    expect(find.text('Bathroom faucet repair'), findsNothing);

    // 6c — Complete a reminder from the Up next checklist
    await tester.ensureVisible(find.text('Furnace filter due'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Furnace filter due'));
    await tester.pumpAndSettle();
    await shot(tester, '12c-reminder-actions');
    await tester.tap(find.text('Mark as done'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('done')); // struck-through row keeps it visible
    expect(find.text('Furnace filter due'), findsOneWidget);

    // 7 — Exports
    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pumpAndSettle();
    await shot(tester, '13-exports');
    await tester.tap(find.textContaining('Generate inventory'));
    await tester.pumpAndSettle();
    await shot(tester, '14-export-generated');
    expect(find.text('📄  PDF ready'), findsOneWidget);
    await tester.tap(find.text('Nice'));
    await tester.pumpAndSettle();

    // 7b — Full backup ZIP (the "everything out, always" promise)
    await tester.ensureVisible(find.text('Export everything'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export everything'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('📦  Backup ready'));
    await shot(tester, '14b-backup-ready');
    await tester.tap(find.text('Nice'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 8 — Local notifications mirror the reminder list
    final pending = await tester.runAsync(() => NotificationService.pending());
    expect(pending, isNotNull);
    expect(pending!, isNotEmpty, reason: 'reminders should schedule local notifications');
    expect(pending.map((p) => p.title), contains('Replace furnace filter'));

    // 9 — Language: switch to French, verify, switch back to English.
    // Scroll home back to top first — the section labels build lazily.
    await tester.fling(find.byType(ListView).first, const Offset(0, 800), 2000);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await shot(tester, '15-language-sheet');
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('À VENIR'));
    expect(find.text('Bonjour'), findsOneWidget); // greeting is always above the fold
    await shot(tester, '16-home-french');
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('UP NEXT'));

    // 10 — Theme: simulate the device flipping to dark, verify the palette follows
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    final darkCtx = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(darkCtx).brightness, Brightness.dark,
        reason: 'themeMode.system should follow the device into dark');
    await shot(tester, '17-home-dark');
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
    await tester.pumpAndSettle();
    final lightCtx = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(lightCtx).brightness, Brightness.light);

    // 11 — Account deletion: wipes the data, cancels notifications, and
    // returns the app to onboarding (App Review guideline 5.1.1(v)).
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await shot(tester, '18-account-sheet');
    await tester.tap(find.text('Delete account & data'));
    await tester.pumpAndSettle();
    await shot(tester, '18b-delete-account-confirm');
    await tester.tap(find.text('Delete everything'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.textContaining('Snap it.')); // onboarding again
    final afterDelete = await tester.runAsync(() => NotificationService.pending());
    expect(afterDelete!, isEmpty, reason: 'deletion must cancel scheduled notifications');
    await shot(tester, '19-onboarding-after-delete');
  });
}
