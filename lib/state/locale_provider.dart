import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'app_locale_code';

final appLocaleProvider =
    AsyncNotifierProvider<AppLocaleNotifier, Locale?>(AppLocaleNotifier.new);

class AppLocaleNotifier extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(_prefsKey));
  }

  Locale? _decode(String? code) {
    switch (code) {
      case 'en':
        return const Locale('en');
      case 'zh':
        return const Locale('zh');
      default:
        return null;
    }
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
    state = AsyncData(locale);
  }
}
