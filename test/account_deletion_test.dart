import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maison/data/backend.dart';
import 'package:maison/data/models.dart';
import 'package:maison/features/session/session_cubit.dart';
import 'package:maison/features/timeline/timeline_cubit.dart';

void main() {
  blocTest<SessionCubit, SessionState>(
    'deleteAccount wipes the backend and returns to loading',
    build: () => SessionCubit(MockBackend()),
    act: (cubit) => cubit.deleteAccount(),
    expect: () => [isA<SessionLoading>()],
  );

  test('TimelineCubit.reset drops all records and reminders', () async {
    final cubit = TimelineCubit(MockBackend());
    cubit.addParsed(MockAi.parse(CaptureMode.receipt));
    expect(cubit.state.records, isNotEmpty);
    expect(cubit.state.pending, isNotEmpty);

    cubit.reset();
    expect(cubit.state.records, isEmpty);
    expect(cubit.state.reminders, isEmpty);
    await cubit.close();
  });
}
