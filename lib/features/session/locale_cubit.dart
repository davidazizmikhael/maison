import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The chosen app language. `null` means "follow the device" (the default).
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit() : super(null);

  static const _key = 'app_locale';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) emit(Locale(code));
  }

  Future<void> set(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
    emit(locale);
  }
}
