import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:maison/data/backend.dart';
import 'package:maison/data/models.dart';
import 'package:maison/features/timeline/timeline_cubit.dart';

/// Fails the first parse (as a flaky network would), succeeds afterwards.
class _FlakyBackend extends MockBackend {
  bool _failedOnce = false;

  @override
  Future<ParseResult> parseEntry(CaptureMode mode,
      {String? noteText, Uint8List? imageBytes, String mediaType = 'image/jpeg'}) {
    if (!_failedOnce) {
      _failedOnce = true;
      throw Exception('network unreachable');
    }
    return super.parseEntry(mode, noteText: noteText, imageBytes: imageBytes);
  }
}

void main() {
  test('a capture parses in place and becomes a saved record with reminders', () async {
    final cubit = TimelineCubit(MockBackend());
    final filing = cubit.captureAndFile(CaptureMode.receipt, returnReminderTitle: 'Return window closes');
    expect(cubit.state.parsing, hasLength(1)); // card visible immediately
    await filing;
    expect(cubit.state.parsing, isEmpty);
    expect(cubit.state.records.single.title, contains('Snow blower'));
    expect(cubit.state.reminders, isNotEmpty);
    expect(cubit.state.justFiled, isNotNull);
    expect(cubit.state.filedTick, 1);
    await cubit.close();
  });

  test('a failed parse stays on the card and can be retried without losing the note', () async {
    final cubit = TimelineCubit(_FlakyBackend());
    await cubit.captureAndFile(CaptureMode.note,
        noteText: 'Fixed the faucet', returnReminderTitle: 'Return window closes');
    expect(cubit.state.parsing.single.error, contains('network unreachable'));
    expect(cubit.state.parsing.single.noteText, 'Fixed the faucet');
    expect(cubit.state.records, isEmpty);

    await cubit.retryParse(cubit.state.parsing.single, returnReminderTitle: 'Return window closes');
    expect(cubit.state.parsing, isEmpty);
    expect(cubit.state.records.single.title, 'Bathroom faucet repair');
    await cubit.close();
  });

  test('discarding a failed capture removes it', () async {
    final cubit = TimelineCubit(_FlakyBackend());
    await cubit.captureAndFile(CaptureMode.note, noteText: 'x', returnReminderTitle: 't');
    cubit.discardParse(cubit.state.parsing.single);
    expect(cubit.state.parsing, isEmpty);
    await cubit.close();
  });
}
