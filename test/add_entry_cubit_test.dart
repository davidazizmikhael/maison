import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maison/data/backend.dart';
import 'package:maison/data/models.dart';
import 'package:maison/features/add_entry/add_entry_cubit.dart';

void main() {
  blocTest<AddEntryCubit, AddEntryState>(
    'parsing a note emits parsing → parsed',
    build: () => AddEntryCubit(MockBackend()),
    act: (cubit) => cubit.parse(CaptureMode.note, noteText: 'Fixed the faucet, \$38'),
    wait: const Duration(seconds: 2),
    expect: () => [isA<AddEntryParsing>(), isA<AddEntryParsed>()],
  );

  blocTest<AddEntryCubit, AddEntryState>(
    'saving emits saving → saved with the final result',
    build: () => AddEntryCubit(MockBackend()),
    act: (cubit) => cubit.save(
      'demo-home',
      MockAi.parse(CaptureMode.note, noteText: 'test'),
      edited: false,
    ),
    expect: () => [isA<AddEntrySaving>(), isA<AddEntrySaved>()],
  );

  blocTest<AddEntryCubit, AddEntryState>(
    'a failed parse can be retried with the same capture and succeed',
    build: () => AddEntryCubit(_FlakyBackend()),
    act: (cubit) async {
      await cubit.parse(CaptureMode.note, noteText: 'Fixed the faucet');
      await cubit.parse(CaptureMode.note, noteText: 'Fixed the faucet'); // retry
    },
    wait: const Duration(seconds: 2),
    expect: () => [
      isA<AddEntryParsing>(),
      isA<AddEntryError>(),
      isA<AddEntryParsing>(),
      isA<AddEntryParsed>(),
    ],
  );
}

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
