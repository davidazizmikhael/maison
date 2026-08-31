import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

/// Compile-time backend config. Run with:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ...
/// With no defines the app stays in demo mode (in-memory mock, no network).
class BackendConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get enabled => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

/// Initialize Supabase once at startup (no-op in demo mode).
Future<void> initBackend() async {
  if (!BackendConfig.enabled) return;
  await Supabase.initialize(
    url: BackendConfig.supabaseUrl,
    publishableKey: BackendConfig.supabaseAnonKey,
  );
}

/// What the app talks to. `MockBackend` mirrors the demo behavior;
/// `SupabaseBackend` is the real thing.
abstract class Backend {
  Future<void> signInAnonymously();

  /// The user's home from a previous session, or null if they never onboarded.
  Future<({String id, String address, HomeProfile? profile})?> existingHome();

  Future<String> upsertHome({required String address, HomeProfile? profile});
  Future<ParseResult> parseEntry(CaptureMode mode,
      {String? noteText, Uint8List? imageBytes, String mediaType});
  /// Persists and returns the record as stored (including its photo path).
  Future<HomeRecord> saveRecord(String homeId, ParseResult result, {Uint8List? photoBytes});

  /// Short-lived signed URL for a photo in the private bucket (null in demo mode).
  Future<String?> photoUrl(String path);

  /// Deletes the record row (reminders cascade) and its stored photo.
  Future<void> deleteRecord(HomeRecord record);

  /// Raw photo bytes for embedding into PDFs (null in demo mode).
  Future<Uint8List?> photoBytes(String path);

  Future<void> completeReminder(String reminderId);
  Future<void> snoozeReminder(String reminderId, DateTime newDue);
  Future<(List<HomeRecord>, List<Reminder>)> fetchAll(String homeId);

  static Backend get instance =>
      BackendConfig.enabled ? SupabaseBackend() : MockBackend();
}

/// Demo-mode backend: same canned AI as before, everything in memory.
class MockBackend implements Backend {
  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<({String id, String address, HomeProfile? profile})?> existingHome() async => null;

  @override
  Future<String> upsertHome({required String address, HomeProfile? profile}) async => 'demo-home';

  @override
  Future<ParseResult> parseEntry(CaptureMode mode,
      {String? noteText, Uint8List? imageBytes, String mediaType = 'image/jpeg'}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return MockAi.parse(mode, noteText: noteText);
  }

  @override
  Future<HomeRecord> saveRecord(String homeId, ParseResult result, {Uint8List? photoBytes}) async {
    // Demo mode keeps no store of its own — the TimelineCubit owns the state.
    return result.record;
  }

  @override
  Future<String?> photoUrl(String path) async => null;

  @override
  Future<void> deleteRecord(HomeRecord record) async {
    // Demo mode: the TimelineCubit owns the state.
  }

  @override
  Future<Uint8List?> photoBytes(String path) async => null;

  @override
  Future<void> completeReminder(String reminderId) async {}

  @override
  Future<void> snoozeReminder(String reminderId, DateTime newDue) async {}

  @override
  Future<(List<HomeRecord>, List<Reminder>)> fetchAll(String homeId) async =>
      (const <HomeRecord>[], const <Reminder>[]);
}

/// Real backend: Supabase auth + Postgres + storage + the parse-entry edge function.
class SupabaseBackend implements Backend {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<void> signInAnonymously() async {
    if (_db.auth.currentSession == null) {
      await _db.auth.signInAnonymously();
    }
  }

  @override
  Future<({String id, String address, HomeProfile? profile})?> existingHome() async {
    final rows = await _db.from('homes').select().order('created_at').limit(1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final p = row['profile'] as Map<String, dynamic>?;
    return (
      id: row['id'] as String,
      address: row['address'] as String,
      profile: p == null
          ? null
          : HomeProfile(
              type: (p['type'] as String?) ?? 'House',
              bedrooms: (p['bedrooms'] as num?)?.toInt() ?? 3,
              bathrooms: (p['bathrooms'] as num?)?.toDouble() ?? 1,
              garage: (p['garage'] as bool?) ?? false,
              basement: (p['basement'] as bool?) ?? false,
            ),
    );
  }

  @override
  Future<String> upsertHome({required String address, HomeProfile? profile}) async {
    final row = await _db
        .from('homes')
        .insert({
          'owner_id': _db.auth.currentUser!.id,
          'address': address,
          if (profile case final profile?)
            'profile': {
              'type': profile.type,
              'bedrooms': profile.bedrooms,
              'bathrooms': profile.bathrooms,
              'garage': profile.garage,
              'basement': profile.basement,
            },
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  @override
  Future<ParseResult> parseEntry(CaptureMode mode,
      {String? noteText, Uint8List? imageBytes, String mediaType = 'image/jpeg'}) async {
    final res = await _db.functions.invoke('parse-entry', body: {
      'mode': switch (mode) {
        CaptureMode.nameplate => 'nameplate',
        CaptureMode.receipt => 'receipt',
        CaptureMode.note => 'note',
      },
      'text': ?noteText,
      if (imageBytes != null) 'image_base64': base64Encode(imageBytes),
      if (imageBytes != null) 'media_type': mediaType,
    });
    final data = res.data as Map<String, dynamic>;
    final rec = data['record'] as Map<String, dynamic>;
    final record = HomeRecord(
      kind: RecordKind.values.byName(rec['kind'] as String),
      title: rec['title'] as String,
      subtitle: (rec['subtitle'] as String?) ?? '',
      room: (rec['room'] as String?) ?? 'Home',
      cost: (rec['cost'] as num?)?.toDouble(),
      vendor: rec['vendor'] as String?,
      modelSerial: rec['model_serial'] as String?,
      warrantyUntil: _date(rec['warranty_until']),
      returnBy: _date(rec['return_by']),
      rawInput: noteText != null ? '"$noteText"' : '📸 photo',
    );
    final reminders = [
      for (final r in (data['reminders'] as List? ?? []))
        Reminder(
          title: r['title'] as String,
          detail: (r['detail'] as String?) ?? '',
          due: _date(r['due_on']) ?? DateTime.now().add(const Duration(days: 90)),
          seasonal: (r['seasonal'] as bool?) ?? false,
        ),
    ];
    return ParseResult(record: record, reminders: reminders, steps: const []);
  }

  @override
  Future<HomeRecord> saveRecord(String homeId, ParseResult result, {Uint8List? photoBytes}) async {
    final uid = _db.auth.currentUser!.id;
    String? photoPath;
    if (photoBytes != null) {
      photoPath = '$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _db.storage.from('captures').uploadBinary(photoPath, photoBytes);
    }
    final r = result.record;
    final row = await _db
        .from('records')
        .insert({
          'home_id': homeId,
          'owner_id': uid,
          'kind': r.kind.name,
          'title': r.title,
          'subtitle': r.subtitle,
          'room': r.room,
          'cost': r.cost,
          'vendor': r.vendor,
          'model_serial': r.modelSerial,
          'warranty_until': r.warrantyUntil?.toIso8601String().substring(0, 10),
          'return_by': r.returnBy?.toIso8601String().substring(0, 10),
          'raw_input': r.rawInput,
          'photo_path': photoPath,
        })
        .select('id')
        .single();
    for (final rem in result.reminders) {
      await _db.from('reminders').insert({
        'home_id': homeId,
        'owner_id': uid,
        'record_id': row['id'],
        'title': rem.title,
        'detail': rem.detail,
        'due_on': rem.due.toIso8601String().substring(0, 10),
        'seasonal': rem.seasonal,
      });
    }
    return r.copyWith(id: row['id'] as String, photoPath: photoPath);
  }

  @override
  Future<void> deleteRecord(HomeRecord record) async {
    final id = record.id;
    if (id == null) return;
    await _db.from('records').delete().eq('id', id);
    final photo = record.photoPath;
    if (photo != null) {
      try {
        await _db.storage.from('captures').remove([photo]);
      } catch (_) {
        // The row is gone; a stray file is harmless and cleanable later.
      }
    }
  }

  static final _urlCache = <String, (String, DateTime)>{};

  @override
  Future<String?> photoUrl(String path) async {
    final cached = _urlCache[path];
    if (cached != null && cached.$2.isAfter(DateTime.now())) return cached.$1;
    final url = await _db.storage.from('captures').createSignedUrl(path, 3600);
    _urlCache[path] = (url, DateTime.now().add(const Duration(minutes: 50)));
    return url;
  }

  @override
  Future<Uint8List?> photoBytes(String path) async {
    try {
      return await _db.storage.from('captures').download(path);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> completeReminder(String reminderId) async {
    await _db
        .from('reminders')
        .update({'done_at': DateTime.now().toUtc().toIso8601String()}).eq('id', reminderId);
  }

  @override
  Future<void> snoozeReminder(String reminderId, DateTime newDue) async {
    await _db
        .from('reminders')
        .update({'due_on': newDue.toIso8601String().substring(0, 10)}).eq('id', reminderId);
  }

  @override
  Future<(List<HomeRecord>, List<Reminder>)> fetchAll(String homeId) async {
    final recordRows = await _db
        .from('records')
        .select()
        .eq('home_id', homeId)
        .order('created_at', ascending: false);
    final reminderRows = await _db
        .from('reminders')
        .select()
        .eq('home_id', homeId)
        .isFilter('done_at', null)
        .order('due_on');
    final records = [
      for (final r in recordRows)
        HomeRecord(
          id: r['id'] as String,
          kind: RecordKind.values.byName(r['kind'] as String),
          title: r['title'] as String,
          subtitle: (r['subtitle'] as String?) ?? '',
          room: (r['room'] as String?) ?? 'Home',
          cost: (r['cost'] as num?)?.toDouble(),
          vendor: r['vendor'] as String?,
          modelSerial: r['model_serial'] as String?,
          warrantyUntil: _date(r['warranty_until']),
          returnBy: _date(r['return_by']),
          manualFound: (r['manual_found'] as bool?) ?? false,
          rawInput: r['raw_input'] as String?,
          photoPath: r['photo_path'] as String?,
          addedOn: DateTime.parse(r['created_at'] as String),
        ),
    ];
    final reminders = [
      for (final r in reminderRows)
        Reminder(
          id: r['id'] as String,
          title: r['title'] as String,
          detail: (r['detail'] as String?) ?? '',
          due: _date(r['due_on'])!,
          seasonal: (r['seasonal'] as bool?) ?? false,
        ),
    ];
    return (records, reminders);
  }

  DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v as String);
}
