import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/backend.dart';
import '../../data/models.dart';

/// The add-flow as an explicit state machine:
/// parsing → parsed → saving → saved, with error able to occur in either leg.
sealed class AddEntryState {
  const AddEntryState();
}

class AddEntryParsing extends AddEntryState {
  const AddEntryParsing();
}

class AddEntryParsed extends AddEntryState {
  const AddEntryParsed(this.result);
  final ParseResult result;
}

class AddEntrySaving extends AddEntryState {
  const AddEntrySaving(this.result);
  final ParseResult result;
}

class AddEntrySaved extends AddEntryState {
  const AddEntrySaved(this.saved, {required this.edited});
  final ParseResult saved;
  final bool edited;
}

class AddEntryError extends AddEntryState {
  const AddEntryError(this.message, {this.result});
  final String message;

  /// Present when parsing succeeded but saving failed — the confirm screen
  /// stays usable so the user can retry.
  final ParseResult? result;
}

class AddEntryCubit extends Cubit<AddEntryState> {
  AddEntryCubit(this._backend) : super(const AddEntryParsing());

  final Backend _backend;

  Future<void> parse(CaptureMode mode, {String? noteText, Uint8List? imageBytes}) async {
    emit(const AddEntryParsing());
    try {
      final result = await _backend.parseEntry(mode, noteText: noteText, imageBytes: imageBytes);
      emit(AddEntryParsed(result));
    } catch (e) {
      emit(AddEntryError('$e'));
    }
  }

  Future<void> save(String homeId, ParseResult finalResult,
      {required bool edited, Uint8List? photoBytes}) async {
    emit(AddEntrySaving(finalResult));
    try {
      await _backend.saveRecord(homeId, finalResult, photoBytes: photoBytes);
      emit(AddEntrySaved(finalResult, edited: edited));
    } catch (e) {
      emit(AddEntryError('$e', result: finalResult));
    }
  }
}
