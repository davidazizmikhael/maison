import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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
        throw TimeoutException('Timed out waiting for $finder');
      }
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 250)));
      await tester.pump();
    }
  }

  testWidgets('Full Maison walkthrough', (tester) async {
    app.main();
    await tester.pumpAndSettle();

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
    // Live mode creates the home over the network — wait for the dashboard.
    await waitFor(tester, find.text('Add'));

    // 2 — Home dashboard
    await shot(tester, '04-home-dashboard');

    // 3 — Add: scan a nameplate
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await shot(tester, '05-add-sheet');
    await tester.tap(find.text('Scan a nameplate'));
    await tester.pumpAndSettle();
    await shot(tester, '06-camera-nameplate');
    await tester.tap(find.byKey(const Key('capture')));
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot('07-ai-parsing');

    // 4 — AI result confirmation, including the "fix something" edit mode
    await waitFor(tester, find.text("Here's what I got"));
    await shot(tester, '08-confirm-parsed-record');
    await tester.tap(find.text('Fix something first'));
    await tester.pumpAndSettle();
    await shot(tester, '08b-fix-details-editing');
    await tester.tap(find.text('Save my corrections'));
    await tester.pumpAndSettle();
    // Saving hits the database in live mode — wait for the timeline to return.
    await waitFor(tester, find.textContaining('Lennox ML296V'));
    await shot(tester, '09-home-after-save');

    // 5 — Record detail
    await tester.tap(find.textContaining('Lennox ML296V').first);
    await tester.pumpAndSettle();
    await shot(tester, '10-record-detail');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 6 — Quick note flow
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quick note'));
    await tester.pumpAndSettle();
    await shot(tester, '11-quick-note');
    await tester.tap(find.text('Let Maison file it'));
    await waitFor(tester, find.text("Here's what I got"));
    await shot(tester, '12-confirm-note-record');
    await tester.tap(find.text('Looks right — save it'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('Add'));

    // 7 — Exports
    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pumpAndSettle();
    await shot(tester, '13-exports');
    await tester.tap(find.textContaining('Generate inventory'));
    await tester.pumpAndSettle();
    await shot(tester, '14-export-generated');

    expect(find.text('📄  PDF ready'), findsOneWidget);
  });
}
