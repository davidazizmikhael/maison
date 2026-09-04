import 'package:flutter_test/flutter_test.dart';
import 'package:maison/data/backend.dart';
import 'package:maison/data/models.dart';
import 'package:maison/features/timeline/timeline_cubit.dart';

void main() {
  test('photo mode files the canned nameplate in demo', () async {
    final cubit = TimelineCubit(MockBackend());
    await cubit.captureAndFile(CaptureMode.photo, returnReminderTitle: 'Return window closes');
    expect(cubit.state.parsing, isEmpty, reason: cubit.state.parsing.map((t) => t.error).toString());
    expect(cubit.state.records.single.title, 'Furnace — Lennox ML296V');
    await cubit.close();
  });
}
