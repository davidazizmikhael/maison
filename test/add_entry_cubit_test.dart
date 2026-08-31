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
}
